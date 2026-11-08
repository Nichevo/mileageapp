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
        const val EXTRA_TRIP_ID = "tripId"
        const val EXTRA_STARTED_BY = "startedBy"
        const val CHANNEL_ID = "trip_recording"
        const val NOTIFICATION_ID = 41
        private const val DISCONNECT_GRACE_MS = 120_000L

        fun tripsDir(ctx: Context): File = File(ctx.filesDir, "trips").apply { mkdirs() }
        fun prefs(ctx: Context) = ctx.getSharedPreferences("mileagelog_native", Context.MODE_PRIVATE)
        fun currentTripId(ctx: Context): String? = prefs(ctx).getString("currentTripId", null)

        fun start(ctx: Context, startedBy: String, tripId: String? = null) {
            val i = Intent(ctx, TripRecorderService::class.java)
                .setAction(ACTION_START)
                .putExtra(EXTRA_TRIP_ID, tripId ?: UUID.randomUUID().toString())
                .putExtra(EXTRA_STARTED_BY, startedBy)
            ctx.startForegroundService(i)
        }

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
    private val stopAfterDisconnect = Runnable { stopTrip() }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        lm = getSystemService(LocationManager::class.java)
        ensureChannel(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val id = intent.getStringExtra(EXTRA_TRIP_ID) ?: UUID.randomUUID().toString()
                val by = intent.getStringExtra(EXTRA_STARTED_BY) ?: "manual"
                startTrip(id, by)
            }
            ACTION_STOP -> stopTrip()
            ACTION_CAR_DISCONNECTED -> if (tripId != null) {
                handler.removeCallbacks(stopAfterDisconnect)
                handler.postDelayed(stopAfterDisconnect, DISCONNECT_GRACE_MS)
                notifyNow("Car disconnected, stopping in 2 minutes")
            } else stopSelf()
            ACTION_CAR_CONNECTED -> handler.removeCallbacks(stopAfterDisconnect)
            ACTION_TOGGLE -> {
                if (tripId != null || currentTripId(this) != null) {
                    // Started with startForegroundService, so we must go
                    // foreground briefly even when stopping.
                    if (goForeground("Stopping…")) stopTrip() else stopSelf()
                    if (tripId == null && currentTripId(this) != null) {
                        // Service was restarted without the trip in memory.
                        prefs(this).edit().remove("currentTripId").remove("currentStartedBy").apply()
                        HomeWidgets.updateTrip(this)
                    }
                } else {
                    startTrip(UUID.randomUUID().toString(), "widget")
                }
            }
            null -> {
                // Restarted by the system after being killed: resume the trip
                // that was in progress, if any.
                val id = currentTripId(this)
                if (id != null) startTrip(id, prefs(this).getString("currentStartedBy", "manual")!!) else stopSelf()
            }
        }
        return START_STICKY
    }

    @SuppressLint("MissingPermission")
    private fun startTrip(id: String, startedBy: String) {
        if (tripId == id) return
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
        prefs(this).edit().putString("currentTripId", id).putString("currentStartedBy", startedBy).commit()
        val meta = File(tripsDir(this), "$id.meta.json")
        val csv = File(tripsDir(this), "$id.csv")
        if (meta.exists()) {
            // Resuming after a restart: carry on appending.
            val j = JSONObject(meta.readText())
            startedAtMs = j.optLong("startAt", System.currentTimeMillis())
        } else {
            startedAtMs = System.currentTimeMillis()
            val m = JSONObject().put("id", id).put("startAt", startedAtMs).put("startedBy", startedBy)
            batteryPct()?.let { m.put("batteryStart", it) }
            if (isCharging()) m.put("charging", true)
            meta.writeText(m.toString())
        }
        writer = FileWriter(csv, true)
        distanceM = 0.0
        last = null
        stillSinceElapsed = 0L
        prefs(this).edit().putFloat("liveKm", 0f).putLong("liveStartMs", startedAtMs).apply()
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

    private fun stopTrip(keepService: Boolean = false) {
        handler.removeCallbacks(stopAfterDisconnect)
        try { lm.removeUpdates(this) } catch (_: Exception) {}
        mode = null
        try { writer?.close() } catch (_: Exception) {}
        writer = null
        tripId?.let { id ->
            val meta = File(tripsDir(this), "$id.meta.json")
            val j = if (meta.exists()) JSONObject(meta.readText()) else JSONObject().put("id", id)
            j.put("endAt", System.currentTimeMillis())
            batteryPct()?.let { j.put("batteryEnd", it) }
            if (chargedDuringTrip || isCharging()) j.put("charging", true)
            meta.writeText(j.toString())
        }
        tripId = null
        chargedDuringTrip = false
        prefs(this).edit().remove("currentTripId").remove("currentStartedBy").remove("liveKm").remove("liveStartMs").apply()
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
        try { lm.removeUpdates(this) } catch (_: Exception) {}
        try { writer?.close() } catch (_: Exception) {}
        super.onDestroy()
    }
}
