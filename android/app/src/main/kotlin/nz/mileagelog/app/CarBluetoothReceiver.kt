package nz.mileagelog.app

import android.Manifest
import android.annotation.SuppressLint
import android.app.Notification
import android.app.PendingIntent
import android.app.NotificationManager
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build

/**
 * Starts a trip when the phone connects to the car's Bluetooth and stops it
 * two minutes after it disconnects (so a quick stop at the shops with the
 * engine off does not split the trip if you're back within the grace period).
 *
 * ACL connect/disconnect broadcasts are exempt from Android's implicit
 * broadcast limits, so this receiver is declared in the manifest and works
 * with the app closed.
 */
class CarBluetoothReceiver : BroadcastReceiver() {
    @SuppressLint("MissingPermission") // checked just below
    override fun onReceive(ctx: Context, intent: Intent) {
        val prefs = TripRecorderService.prefs(ctx)
        if (!prefs.getBoolean("autoStart", false)) return
        val cars = TripRecorderService.carAddresses(ctx)
        if (cars.isEmpty()) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            ctx.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
        ) return
        @Suppress("DEPRECATION")
        val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
        val address = try { device?.address } catch (_: SecurityException) { null } ?: return
        if (!cars.contains(address.uppercase())) return
        // While one car's trip is recording, another car's Bluetooth (say,
        // the second car parked in the garage) doesn't touch it.
        val current = TripRecorderService.currentCar(ctx)
        val sameCar = current == null || current.equals(address, ignoreCase = true)

        when (intent.action) {
            BluetoothDevice.ACTION_ACL_CONNECTED -> {
                if (TripRecorderService.currentTripId(ctx) != null) {
                    if (sameCar) TripRecorderService.send(ctx, TripRecorderService.ACTION_CAR_CONNECTED)
                    return
                }
                try {
                    TripRecorderService.start(ctx, "bluetooth", carAddress = address)
                } catch (e: Exception) {
                    // Android can refuse to start location tracking from the
                    // background (battery optimisation on, or location not
                    // "Allow all the time"). Fall back to a one-tap prompt.
                    promptToStart(ctx)
                }
            }
            BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                if (TripRecorderService.currentTripId(ctx) != null && sameCar) {
                    try {
                        TripRecorderService.send(ctx, TripRecorderService.ACTION_CAR_DISCONNECTED)
                    } catch (_: Exception) {}
                }
            }
        }
    }

    private fun promptToStart(ctx: Context) {
        TripRecorderService.ensureChannel(ctx)
        val open = PendingIntent.getActivity(
            ctx, 2,
            Intent(ctx, MainActivity::class.java).putExtra("startTrip", true)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val n = Notification.Builder(ctx, TripRecorderService.CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_trip)
            .setContentTitle("Connected to your car")
            .setContentText("Tap to start recording this trip")
            .setAutoCancel(true)
            .setContentIntent(open)
            .build()
        ctx.getSystemService(NotificationManager::class.java).notify(42, n)
    }
}
