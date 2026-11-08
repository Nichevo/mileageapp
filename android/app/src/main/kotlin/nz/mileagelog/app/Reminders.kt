package nz.mileagelog.app

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONArray

/**
 * Phone notifications for things coming due (service, WOF, rego, insurance,
 * tyre check, fuel running low). The app works out *when* each reminder
 * should fire and hands the list over; this side sets an alarm for each and
 * posts the notification. Keys of reminders already shown are remembered so
 * nothing is shown twice, and the list is re-armed after a reboot or update.
 */
object Reminders {
    const val CHANNEL_ID = "reminders"
    private const val PREFS_LIST = "reminders"
    private const val PREFS_FIRED = "remindersFired"
    private const val PREFS_ARMED = "remindersArmed"

    fun ensureChannel(ctx: Context) {
        val nm = ctx.getSystemService(NotificationManager::class.java)
        if (nm.getNotificationChannel(CHANNEL_ID) == null) {
            nm.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "Reminders", NotificationManager.IMPORTANCE_DEFAULT).apply {
                    description = "Service, WOF, registration, insurance, tyres and fuel"
                }
            )
        }
    }

    /** Replaces the scheduled reminders with [json] (a list from the app). */
    fun schedule(ctx: Context, json: String) {
        val prefs = TripRecorderService.prefs(ctx)
        val list = JSONArray(json)
        val keys = (0 until list.length()).map { list.getJSONObject(it).getString("key") }.toSet()
        // Forget fired keys that are no longer planned, so the set stays small.
        val fired = (prefs.getStringSet(PREFS_FIRED, emptySet()) ?: emptySet()).filter { it in keys }.toSet()
        prefs.edit().putString(PREFS_LIST, json).putStringSet(PREFS_FIRED, fired).apply()
        arm(ctx)
    }

    /** (Re-)sets an alarm for every planned reminder that hasn't fired. */
    fun arm(ctx: Context) {
        val prefs = TripRecorderService.prefs(ctx)
        val am = ctx.getSystemService(AlarmManager::class.java)
        // Cancel what was armed before.
        for (code in prefs.getStringSet(PREFS_ARMED, emptySet()) ?: emptySet()) {
            am.cancel(pending(ctx, code.toInt(), null, null, null))
        }
        val list = JSONArray(prefs.getString(PREFS_LIST, "[]"))
        val fired = prefs.getStringSet(PREFS_FIRED, emptySet()) ?: emptySet()
        val armed = mutableSetOf<String>()
        val now = System.currentTimeMillis()
        for (i in 0 until list.length()) {
            val r = list.getJSONObject(i)
            val key = r.getString("key")
            if (key in fired) continue
            val at = r.getLong("at").coerceAtLeast(now + 5_000)
            val code = key.hashCode()
            // Inexact is fine for reminders and needs no special permission.
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pending(ctx, code, key, r.getString("title"), r.getString("body")))
            armed.add(code.toString())
        }
        prefs.edit().putStringSet(PREFS_ARMED, armed).apply()
    }

    private fun pending(ctx: Context, code: Int, key: String?, title: String?, body: String?): PendingIntent {
        val i = Intent(ctx, ReminderReceiver::class.java).setAction("nz.mileagelog.app.REMINDER")
        if (key != null) i.putExtra("key", key).putExtra("title", title).putExtra("body", body)
        return PendingIntent.getBroadcast(ctx, code, i, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    fun show(ctx: Context, key: String, title: String, body: String) {
        val prefs = TripRecorderService.prefs(ctx)
        val fired = (prefs.getStringSet(PREFS_FIRED, emptySet()) ?: emptySet()).toMutableSet()
        if (key in fired) return
        fired.add(key)
        prefs.edit().putStringSet(PREFS_FIRED, fired).apply()
        ensureChannel(ctx)
        val open = PendingIntent.getActivity(
            ctx, key.hashCode(),
            Intent(ctx, MainActivity::class.java).putExtra("open", if (key.startsWith("fuel")) "fillup" else "care")
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val n = Notification.Builder(ctx, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_trip)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setAutoCancel(true)
            .setContentIntent(open)
            .build()
        try {
            ctx.getSystemService(NotificationManager::class.java).notify(key.hashCode(), n)
        } catch (_: SecurityException) {
            // Notifications not allowed; nothing to do.
        }
    }
}

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val key = intent.getStringExtra("key") ?: return
        Reminders.show(ctx, key, intent.getStringExtra("title") ?: "MileageLog", intent.getStringExtra("body") ?: "")
    }
}

/** Alarms are cleared by a reboot or an app update; set them again. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Reminders.arm(ctx)
                HomeWidgets.updateAll(ctx)
            }
        }
    }
}
