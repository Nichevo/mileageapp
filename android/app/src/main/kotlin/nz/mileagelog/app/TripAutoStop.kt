package nz.mileagelog.app

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONObject
import java.io.File

/**
 * When a trip should end by itself, worked out from saved state only, so it
 * still works after the phone has slept or Android has restarted the app:
 *
 *  - the car's Bluetooth disconnected and didn't come back within the grace
 *    time (default 2 minutes), or
 *  - the car hasn't moved 100 m for the parked time (default 10 minutes)
 *    while its Bluetooth isn't connected.
 *
 * The trip then ends when the car last moved, not when the check ran.
 * An alarm wakes the phone for the next check; GPS updates check too.
 */
object TripAutoStop {
    private const val REQUEST = 51

    fun graceMs(ctx: Context): Long = TripRecorderService.prefs(ctx).getInt("stopGraceMin", 2) * 60_000L
    fun parkedMs(ctx: Context): Long = TripRecorderService.prefs(ctx).getInt("parkedStopMin", 10) * 60_000L

    /** End time if the trip in progress should stop now, else null. */
    fun dueEnd(ctx: Context, now: Long = System.currentTimeMillis()): Pair<Long, String>? {
        val p = TripRecorderService.prefs(ctx)
        if (TripRecorderService.currentTripId(ctx) == null) return null
        val start = p.getLong("liveStartMs", now)
        val lastMove = p.getLong("lastMoveAt", 0L).takeIf { it > 0 } ?: start
        val disconnectAt = p.getLong("disconnectAt", 0L)
        if (disconnectAt > 0 && now >= disconnectAt + graceMs(ctx)) {
            // Engine off usually comes a moment after parking.
            return Pair(minOf(disconnectAt, lastMove + 30_000L).coerceAtLeast(start), "bluetooth")
        }
        val parked = parkedMs(ctx)
        if (parked > 0 && !p.getBoolean("carConnected", false) && now >= lastMove + parked) {
            return Pair((lastMove + 30_000L).coerceAtLeast(start).coerceAtMost(now), "parked")
        }
        return null
    }

    /** When the next check is due, or null when nothing can stop the trip. */
    private fun nextCheck(ctx: Context, now: Long): Long? {
        val p = TripRecorderService.prefs(ctx)
        if (TripRecorderService.currentTripId(ctx) == null) return null
        val times = mutableListOf<Long>()
        val disconnectAt = p.getLong("disconnectAt", 0L)
        if (disconnectAt > 0) times.add(disconnectAt + graceMs(ctx))
        val parked = parkedMs(ctx)
        if (parked > 0 && !p.getBoolean("carConnected", false)) {
            val lastMove = p.getLong("lastMoveAt", 0L).takeIf { it > 0 } ?: p.getLong("liveStartMs", now)
            times.add(lastMove + parked)
        }
        return times.minOrNull()?.coerceAtLeast(now + 15_000L)
    }

    private fun pending(ctx: Context) = PendingIntent.getBroadcast(
        ctx, REQUEST, Intent(ctx, TripStopReceiver::class.java),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )

    /** Sets (or clears) the wake-up for the next check. */
    fun schedule(ctx: Context, now: Long = System.currentTimeMillis()) {
        val am = ctx.getSystemService(AlarmManager::class.java) ?: return
        val at = nextCheck(ctx, now)
        try {
            if (at == null) am.cancel(pending(ctx))
            else am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pending(ctx))
        } catch (_: Exception) {}
    }

    fun carDisconnected(ctx: Context, now: Long = System.currentTimeMillis()) {
        TripRecorderService.prefs(ctx).edit().putLong("disconnectAt", now).putBoolean("carConnected", false).commit()
        schedule(ctx, now)
    }

    fun carConnected(ctx: Context) {
        TripRecorderService.prefs(ctx).edit().remove("disconnectAt").putBoolean("carConnected", true).commit()
        schedule(ctx)
    }

    /** Clears per-trip state once a trip is over. */
    fun clear(ctx: Context) {
        TripRecorderService.prefs(ctx).edit().remove("disconnectAt").remove("carConnected").remove("lastMoveAt").commit()
        try { ctx.getSystemService(AlarmManager::class.java)?.cancel(pending(ctx)) } catch (_: Exception) {}
    }

    /** Time of the last GPS point saved for a trip, if any. */
    fun lastPointAt(ctx: Context, id: String): Long? = try {
        val f = File(TripRecorderService.tripsDir(ctx), "$id.csv")
        if (!f.exists()) null else f.useLines { lines -> lines.lastOrNull { it.isNotBlank() } }?.substringBefore(',')?.toLongOrNull()
    } catch (_: Exception) {
        null
    }

    /**
     * Ends the saved trip without the recording service, for when Android has
     * stopped the service. The app picks the files up next time it opens.
     */
    fun finishSaved(ctx: Context, endAt: Long?, reason: String) {
        val p = TripRecorderService.prefs(ctx)
        val id = TripRecorderService.currentTripId(ctx) ?: return
        val meta = File(TripRecorderService.tripsDir(ctx), "$id.meta.json")
        try {
            val j = if (meta.exists()) JSONObject(meta.readText()) else JSONObject().put("id", id).put("startAt", p.getLong("liveStartMs", System.currentTimeMillis()))
            j.put("endAt", endAt ?: lastPointAt(ctx, id) ?: System.currentTimeMillis())
            j.put("endReason", reason)
            meta.writeText(j.toString())
        } catch (_: Exception) {}
        p.edit().remove("currentTripId").remove("currentStartedBy").remove("currentCarAddress").remove("liveKm").remove("liveStartMs").commit()
        clear(ctx)
        try { ctx.getSystemService(NotificationManager::class.java).cancel(TripRecorderService.NOTIFICATION_ID) } catch (_: Exception) {}
        HomeWidgets.updateTrip(ctx)
    }
}

/** Alarm for [TripAutoStop]: asks the running recorder to check, or ends the saved trip itself. */
class TripStopReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        if (TripRecorderService.currentTripId(ctx) == null) return
        if (TripRecorderService.instance?.isRecording == true) {
            try {
                TripRecorderService.send(ctx, TripRecorderService.ACTION_CHECK_STOP)
                return
            } catch (_: Exception) {}
        }
        val due = TripAutoStop.dueEnd(ctx)
        if (due != null) TripAutoStop.finishSaved(ctx, due.first, due.second)
        else TripAutoStop.schedule(ctx)
    }
}
