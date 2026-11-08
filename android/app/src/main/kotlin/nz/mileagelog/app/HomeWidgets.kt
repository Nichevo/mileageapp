package nz.mileagelog.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONObject

/**
 * Home screen widgets. The app writes a small text snapshot (last fill,
 * this year, next due, last trip) whenever its data changes; the widgets
 * just show it. The trip widget also reads the recorder's live state.
 */
object HomeWidgets {
    private const val PREFS_SNAPSHOT = "widgetSnapshot"

    fun save(ctx: Context, json: String) {
        TripRecorderService.prefs(ctx).edit().putString(PREFS_SNAPSHOT, json).apply()
        updateAll(ctx)
    }

    fun snapshot(ctx: Context): JSONObject =
        try { JSONObject(TripRecorderService.prefs(ctx).getString(PREFS_SNAPSHOT, "{}") ?: "{}") } catch (_: Exception) { JSONObject() }

    fun updateAll(ctx: Context) {
        val mgr = AppWidgetManager.getInstance(ctx)
        for (cls in listOf(FillUpWidget::class.java, TripWidget::class.java, SummaryWidget::class.java)) {
            val ids = mgr.getAppWidgetIds(ComponentName(ctx, cls))
            if (ids.isEmpty()) continue
            for (id in ids) mgr.updateAppWidget(id, render(ctx, cls))
        }
    }

    fun updateTrip(ctx: Context) {
        val mgr = AppWidgetManager.getInstance(ctx)
        val ids = mgr.getAppWidgetIds(ComponentName(ctx, TripWidget::class.java))
        for (id in ids) mgr.updateAppWidget(id, render(ctx, TripWidget::class.java))
    }

    private fun openApp(ctx: Context, what: String, code: Int): PendingIntent =
        PendingIntent.getActivity(
            ctx, code,
            Intent(ctx, MainActivity::class.java).putExtra("open", what)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

    fun render(ctx: Context, cls: Class<*>): RemoteViews {
        val s = snapshot(ctx)
        return when (cls) {
            FillUpWidget::class.java -> RemoteViews(ctx.packageName, R.layout.widget_fillup).apply {
                setTextViewText(R.id.widget_title, "Log a fill-up")
                setTextViewText(R.id.widget_detail, s.optString("fill", "Tap to add your first fill-up"))
                setOnClickPendingIntent(R.id.widget_root, openApp(ctx, "fillup", 10))
            }
            TripWidget::class.java -> RemoteViews(ctx.packageName, R.layout.widget_trip).apply {
                val prefs = TripRecorderService.prefs(ctx)
                val recording = TripRecorderService.currentTripId(ctx) != null
                if (recording) {
                    val km = prefs.getFloat("liveKm", 0f)
                    val mins = ((System.currentTimeMillis() - prefs.getLong("liveStartMs", System.currentTimeMillis())) / 60_000).coerceAtLeast(0)
                    setTextViewText(R.id.widget_title, "Recording · tap to stop")
                    setTextViewText(R.id.widget_detail, String.format("%.1f km · %d min", km, mins))
                    setImageViewResource(R.id.widget_icon, R.drawable.ic_widget_stop)
                } else {
                    setTextViewText(R.id.widget_title, "Start a trip")
                    setTextViewText(R.id.widget_detail, s.optString("trip", "Tap to record"))
                    setImageViewResource(R.id.widget_icon, R.drawable.ic_widget_play)
                }
                val toggle = PendingIntent.getForegroundService(
                    ctx, 11,
                    Intent(ctx, TripRecorderService::class.java).setAction(TripRecorderService.ACTION_TOGGLE),
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                )
                setOnClickPendingIntent(R.id.widget_root, toggle)
            }
            else -> RemoteViews(ctx.packageName, R.layout.widget_summary).apply {
                setTextViewText(R.id.widget_title, s.optString("yearTitle", "This year"))
                setTextViewText(R.id.widget_detail, s.optString("year", "No fill-ups yet"))
                setTextViewText(R.id.widget_economy, s.optString("economy", ""))
                setTextViewText(R.id.widget_next, s.optString("next", "Nothing due soon"))
                setOnClickPendingIntent(R.id.widget_root, openApp(ctx, "home", 12))
            }
        }
    }
}

abstract class BaseWidget : AppWidgetProvider() {
    override fun onUpdate(ctx: Context, mgr: AppWidgetManager, ids: IntArray) {
        for (id in ids) mgr.updateAppWidget(id, HomeWidgets.render(ctx, this::class.java))
    }
}

class FillUpWidget : BaseWidget()
class TripWidget : BaseWidget()
class SummaryWidget : BaseWidget()
