package nz.mileagelog.app

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock
import org.json.JSONObject
import java.io.File
import java.io.FileWriter
import java.util.UUID

/**
 * Records a trip in a foreground service so it keeps going with the screen
 * off or the app closed. Each GPS fix is appended to files/trips/<id>.csv;
 * the Flutter side reads that file for the live view and imports it into the
 * database when the trip ends. Nothing here touches the database directly.
 *
 * Battery: GPS updates are adaptive. Every 2 s below ~20 km/h (to catch short
 * stops such as traffic lights), every 5 s or 25 m when moving faster, and
 * every 15 s after 3 minutes parked.
 */
class TripRecorderService : Service(), LocationListener {

    companion object {
        const val ACTION_START = "nz.mileagelog.app.START_TRIP"
        const val ACTION_STOP = "nz.mileagelog.app.STOP_TRIP"
        const val ACTION_CAR_DISCONNECTED = "nz.mileagelog.app.CAR_DISCONNECTED"
        const val ACTION_CAR_CONNECTED = "nz.mileagelog.app.CAR_CONNECTED"
        /** From the home screen widget: start a trip, or stop the one running. */
        const val ACTION_TOGGLE = "nz.mileagelog.app.TOGGLE_TRIP"
        /** From [TripStopReceiver]: see whether the trip should end now. */
        const val ACTION_CHECK_STOP = "nz.mileagelog.app.CHECK_STOP"
        const val EXTRA_TRIP_ID = "tripId"
        const val EXTRA_STARTED_BY = "startedBy"
        /** Bluetooth address of the car that started the trip, if any. */
        const val EXTRA_CAR = "carAddress"
        const val CHANNEL_ID = "trip_recording"
        const val NOTIFICATION_ID = 41
        /** The running service, so the stop alarm knows whether it's alive. */
        @Volatile var instance: TripRecorderService? = null

        fun tripsDir(ctx: Context): File = File(ctx.filesDir, "trips").apply { mkdirs() }
        fun prefs(ctx: Context) = ctx.getSharedPreferences("mileagelog_native", Context.MODE_PRIVATE)
        fun currentTripId(ctx: Context): String? = prefs(ctx).getString("currentTripId", null)

        fun start(ctx: Context, startedBy: String, tripId: String? = null, carAddress: String? = null) {
            val i = Intent(ctx, TripRecorderService::class.java)
                .setAction(ACTION_START)
                .putExtra(EXTRA_TRIP_ID, tripId ?: UUID.randomUUID().toString())
                .putExtra(EXTRA_STARTED_BY, startedBy)
            if (carAddress != null) i.putExtra(EXTRA_CAR, carAddress)
            ctx.startForegroundService(i)
        }

        /** Every car's Bluetooth address that may start a trip. */
        fun carAddresses(ctx: Context): Set<String> {
            val p = prefs(ctx)
            val out = mutableSetOf<String>()
            p.getString("carAddress", null)?.let { out.add(it.uppercase()) }
            try {
                val arr = org.json.JSONArray(p.getString("carAddresses", "[]"))
                for (i in 0 until arr.length()) out.add(arr.getString(i).uppercase())
            } catch (_: Exception) {}
            return out
        }

        /**
         * The vehicle a new trip belongs to: the one whose Bluetooth started
         * it, else the one selected in the app when it started.
         */
        fun vehicleFor(ctx: Context, carAddress: String?): String? {
            val p = prefs(ctx)
            if (carAddress != null) {
                try {
                    val owners = JSONObject(p.getString("carVehicles", "{}") ?: "{}")
                    val v = owners.optString(carAddress.uppercase(), "")
                    if (v.isNotEmpty()) return v
                } catch (_: Exception) {}
            }
            return p.getString("activeVehicleId", null)
        }

        /** Car that started the trip in progress, or null for a manual trip. */
        fun currentCar(ctx: Context): String? = prefs(ctx).getString("currentCarAddress", null)

        fun send(ctx: Context, action: String) {
            ctx.startService(Intent(ctx, TripRecorderService::class.java).setAction(action))
        }

        fun ensureChannel(ctx: Context) {
            val nm = ctx.getSystemService(NotificationManager::class.java)
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                nm.createNotificationChannel(
                    NotificationChannel(CHANNEL_ID, "Trip recording", NotificationManager.IMPORTANCE_LOW).apply {
                        description = "Shown while a trip is being recorded"
                        setShowBadge(false)
                    }
                )
            }
        }
    }

    private enum class Mode(val intervalMs: Long, val minDistanceM: Float) {
        SLOW(2_000, 0f), FAST(5_000, 25f), PARKED(15_000, 0f)
    }

    private lateinit var lm: LocationManager
    private val handler = Handler(Looper.getMainLooper())
    private var tripId: String? = null
    private var writer: FileWriter? = null
    private var mode: Mode? = null
    private var last: Location? = null
    private var distanceM = 0.0
    private var stillSinceElapsed = 0L
    private var startedAtMs = 0L
    private var lastNotifyElapsed = 0L
    private var anchor: Location? = null // where the car last came to rest
    val isRecording: Boolean get() = tripId != null
    private val checkStop = Runnable { checkAutoStop() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        lm = getSystemService(LocationManager::class.java)
        ensureChannel(this)
        instance = this
    }

    /** Ends the trip if Bluetooth or parking says so; else waits for the next check. */
    private fun checkAutoStop() {
        if (tripId == null) return
        val due = TripAutoStop.dueEnd(this)
        if (due != null) {
            stopTrip(endAt = due.first, reason = due.second)
            return
        }
        TripAutoStop.schedule(this)
        handler.removeCallbacks(checkStop)
        handler.postDelayed(checkStop, 60_000L)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val id = intent.getStringExtra(EXTRA_TRIP_ID) ?: UUID.randomUUID().toString()
                val by = intent.getStringExtra(EXTRA_STARTED_BY) ?: "manual"
                startTrip(id, by, intent.getStringExtra(EXTRA_CAR))
            }
            ACTION_STOP -> if (tripId != null) stopTrip() else {
                TripAutoStop.finishSaved(this, null, "manual")
                stopSelf()
            }
            // The receiver has already saved the disconnect and set the alarm.
            ACTION_CAR_DISCONNECTED -> if (tripId != null) {
                val mins = TripAutoStop.graceMs(this) / 60_000
                notifyNow("Car disconnected, stopping in $mins minute${if (mins == 1L) "" else "s"}")
                handler.removeCallbacks(checkStop)
                handler.postDelayed(checkStop, TripAutoStop.graceMs(this) + 1_000L)
            } else stopSelf()
            ACTION_CAR_CONNECTED -> if (tripId != null) notifyNow(null) else stopSelf()
            ACTION_CHECK_STOP -> if (tripId != null) checkAutoStop() else {
                TripAutoStop.dueEnd(this)?.let { TripAutoStop.finishSaved(this, it.first, it.second) }
                stopSelf()
            }
            ACTION_TOGGLE -> {
                if (tripId != null || currentTripId(this) != null) {
                    // Started with startForegroundService, so we must go
                    // foreground briefly even when stopping.
                    if (tripId == null && currentTripId(this) != null) {
                        // Service was restarted without the trip in memory:
                        // end the saved trip at its last GPS point.
                        TripAutoStop.finishSaved(this, null, "manual")
                    }
                    if (goForeground("Stopping…")) stopTrip() else stopSelf()
                } else {
                    startTrip(UUID.randomUUID().toString(), "widget")
                }
            }
            null -> {
                // Restarted by the system after being killed: resume the trip
                // that was in progress, if any.
                val id = currentTripId(this)
                val due = if (id != null) TripAutoStop.dueEnd(this) else null
                when {
                    id == null -> stopSelf()
                    // It should have ended while the app was stopped.
                    due != null -> {
                        TripAutoStop.finishSaved(this, due.first, due.second)
                        stopSelf()
                    }
                    else -> startTrip(id, prefs(this).getString("currentStartedBy", "manual")!!, currentCar(this))
                }
            }
        }
        return START_STICKY
    }

    @SuppressLint("MissingPermission")
    private fun startTrip(id: String, startedBy: String, car: String? = null) {
        if (tripId == id) return
        // Tapping "Connected to your car" starts a manual trip; it still
        // belongs to that car if the tap came within 15 minutes.
        var carAddress = car
        if (carAddress == null && startedBy == "manual") {
            val p = prefs(this)
            val at = p.getLong("promptAt", 0L)
            if (System.currentTimeMillis() - at < 15 * 60_000L) carAddress = p.getString("promptCar", null)
            p.edit().remove("promptCar").remove("promptAt").apply()
        }
        if (tripId != null) stopTrip(keepService = true)

        if (!goForeground("Starting…")) {
            // No location permission (or Android refused): explain instead of crashing.
            ensureChannel(this)
            val open = PendingIntent.getActivity(
                this, 3, Intent(this, MainActivity::class.java).putExtra("open", "trips").addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            getSystemService(NotificationManager::class.java).notify(
                43,
                Notification.Builder(this, CHANNEL_ID).setSmallIcon(R.drawable.ic_stat_trip)
                    .setContentTitle("Couldn't start the trip")
                    .setContentText("Open MileageLog and allow location to record trips")
                    .setAutoCancel(true).setContentIntent(open).build()
            )
            stopSelf()
            return
        }

        tripId = id
        // Mark the trip current before its files appear, so the app never
        // mistakes a just-started trip for an abandoned one.
        prefs(this).edit().putString("currentTripId", id).putString("currentStartedBy", startedBy).apply {
            if (carAddress != null) putString("currentCarAddress", carAddress) else remove("currentCarAddress")
        }.commit()
        val meta = File(tripsDir(this), "$id.meta.json")
        val csv = File(tripsDir(this), "$id.csv")
        val resuming = meta.exists()
        if (resuming) {
            // Resuming after a restart: carry on appending.
            val j = JSONObject(meta.readText())
            startedAtMs = j.optLong("startAt", System.currentTimeMillis())
        } else {
            TripAutoStop.clear(this)
            // A trip started by the car's Bluetooth means the car is connected.
            prefs(this).edit().putBoolean("carConnected", startedBy == "bluetooth").putLong("lastMoveAt", System.currentTimeMillis()).commit()
            startedAtMs = System.currentTimeMillis()
            val m = JSONObject().put("id", id).put("startAt", startedAtMs).put("startedBy", startedBy)
            if (carAddress != null) m.put("carAddress", carAddress)
            vehicleFor(this, carAddress)?.let { m.put("vehicleId", it) }
            batteryPct()?.let { m.put("batteryStart", it) }
            if (isCharging()) m.put("charging", true)
            meta.writeText(m.toString())
        }
        writer = FileWriter(csv, true)
        distanceM = 0.0
        last = null
        stillSinceElapsed = 0L
        anchor = null
        prefs(this).edit().putFloat("liveKm", 0f).putLong("liveStartMs", startedAtMs).commit()
        if (resuming && prefs(this).getLong("lastMoveAt", 0L) == 0L) prefs(this).edit().putLong("lastMoveAt", System.currentTimeMillis()).apply()
        TripAutoStop.schedule(this)
        handler.removeCallbacks(checkStop)
        handler.postDelayed(checkStop, 60_000L)
        setMode(Mode.SLOW)
        notifyNow(null)
        HomeWidgets.updateTrip(this)
    }

    /** Returns false when Android won't let the service go foreground. */
    private fun goForeground(text: String): Boolean = try {
        val notification = buildNotification(text)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        true
    } catch (e: Exception) {
        false
    }

    private fun stopTrip(keepService: Boolean = false, endAt: Long? = null, reason: String = "manual") {
        handler.removeCallbacks(checkStop)
        TripAutoStop.clear(this)
        try { lm.removeUpdates(this) } catch (_: Exception) {}
        mode = null
        try { writer?.close() } catch (_: Exception) {}
        writer = null
        tripId?.let { id ->
            val meta = File(tripsDir(this), "$id.meta.json")
            val j = if (meta.exists()) JSONObject(meta.readText()) else JSONObject().put("id", id)
            j.put("endAt", endAt ?: System.currentTimeMillis())
            j.put("endReason", reason)
            batteryPct()?.let { j.put("batteryEnd", it) }
            if (chargedDuringTrip || isCharging()) j.put("charging", true)
            meta.writeText(j.toString())
        }
        tripId = null
        chargedDuringTrip = false
        prefs(this).edit().remove("currentTripId").remove("currentStartedBy").remove("currentCarAddress").remove("liveKm").remove("liveStartMs").apply()
        HomeWidgets.updateTrip(this)
        if (!keepService) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
        }
    }

    @SuppressLint("MissingPermission")
    private fun setMode(m: Mode) {
        if (mode == m) return
        mode = m
        try {
            lm.removeUpdates(this)
            lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, m.intervalMs, m.minDistanceM, this, Looper.getMainLooper())
        } catch (e: SecurityException) {
            notifyNow("Location permission is off, trip paused")
        }
    }

    override fun onLocationChanged(loc: Location) {
        val w = writer ?: return
        val speed = if (loc.hasSpeed()) loc.speed.toString() else ""
        val acc = if (loc.hasAccuracy()) loc.accuracy.toString() else ""
        val alt = if (loc.hasAltitude()) loc.altitude.toString() else ""
        w.write("${loc.time},${loc.latitude},${loc.longitude},$speed,$acc,$alt\n")
        w.flush()

        val prev = last
        val kmh = if (loc.hasSpeed()) loc.speed * 3.6 else 0.0
        if (prev != null && loc.accuracy <= 50 && kmh >= 3) distanceM += prev.distanceTo(loc)
        last = loc

        // Movement for the parked check: 100 m from where the car came to
        // rest, or clearly driving. GPS wander while parked doesn't count.
        if (loc.accuracy <= 50) {
            val a = anchor
            if (a == null || loc.distanceTo(a) > 100f || kmh >= 15) {
                anchor = loc
                prefs(this).edit().putLong("lastMoveAt", loc.time).apply()
            }
        }

        val now = SystemClock.elapsedRealtime()
        if (kmh < 3) {
            if (stillSinceElapsed == 0L) stillSinceElapsed = now
            if (now - stillSinceElapsed > 180_000) setMode(Mode.PARKED)
        } else {
            stillSinceElapsed = 0L
            when {
                kmh >= 22 -> setMode(Mode.FAST)
                kmh <= 17 -> setMode(Mode.SLOW)
                mode == Mode.PARKED -> setMode(Mode.SLOW)
            }
        }
        if (now - lastNotifyElapsed > 30_000) notifyNow(null)
        if (TripAutoStop.dueEnd(this) != null) checkAutoStop()
    }

    @Deprecated("Deprecated in Java")
    override fun onStatusChanged(provider: String?, status: Int, extras: android.os.Bundle?) {}
    override fun onProviderEnabled(provider: String) {}
    override fun onProviderDisabled(provider: String) { notifyNow("GPS is turned off") }

    // Battery use per trip, so the cost of recording can be seen, not guessed.
    private var chargedDuringTrip = false

    private fun batteryPct(): Int? = try {
        getSystemService(BatteryManager::class.java).getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY).takeIf { it in 0..100 }
    } catch (e: Exception) {
        null
    }

    private fun isCharging(): Boolean = try {
        getSystemService(BatteryManager::class.java).isCharging
    } catch (e: Exception) {
        false
    }

    private fun notifyNow(text: String?) {
        lastNotifyElapsed = SystemClock.elapsedRealtime()
        if (tripId != null && isCharging()) chargedDuringTrip = true
        if (tripId != null) {
            prefs(this).edit().putFloat("liveKm", (distanceM / 1000).toFloat()).apply()
            HomeWidgets.updateTrip(this)
        }
        val mins = ((System.currentTimeMillis() - startedAtMs) / 60_000).coerceAtLeast(0)
        val body = text ?: String.format("%.1f km · %d min", distanceM / 1000, mins)
        getSystemService(NotificationManager::class.java).notify(NOTIFICATION_ID, buildNotification(body))
    }

    private fun buildNotification(text: String): Notification {
        val open = PendingIntent.getActivity(
            this, 0, Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val stop = PendingIntent.getService(
            this, 1, Intent(this, TripRecorderService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        return Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_trip)
            .setContentTitle("Recording trip")
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(open)
            .addAction(Notification.Action.Builder(null, "Stop", stop).build())
            .build()
    }

    override fun onDestroy() {
        if (instance === this) instance = null
        handler.removeCallbacks(checkStop)
        try { lm.removeUpdates(this) } catch (_: Exception) {}
        try { writer?.close() } catch (_: Exception) {}
        super.onDestroy()
    }
}
