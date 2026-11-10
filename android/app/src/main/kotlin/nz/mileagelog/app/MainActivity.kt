package nz.mileagelog.app

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothManager
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Bridges the Flutter UI to the native trip recorder and Bluetooth set-up. */
class MainActivity : FlutterActivity() {
    private var pendingPermission: MethodChannel.Result? = null
    private var startTripRequested = false
    /** Screen to open, from a widget or notification: fillup, trips, care, home. */
    private var launchAction: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startTripRequested = intent?.getBooleanExtra("startTrip", false) == true
        launchAction = intent?.getStringExtra("open")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.getBooleanExtra("startTrip", false)) startTripRequested = true
        intent.getStringExtra("open")?.let { launchAction = it }
    }

    private fun permissionsFor(name: String): Array<String> = when (name) {
        "location" -> arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION)
        "backgroundLocation" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
            arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION) else arrayOf()
        "notifications" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            arrayOf(Manifest.permission.POST_NOTIFICATIONS) else arrayOf()
        "bluetooth" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S)
            arrayOf(Manifest.permission.BLUETOOTH_CONNECT) else arrayOf()
        else -> arrayOf()
    }

    private fun granted(name: String): Boolean =
        permissionsFor(name).all { checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED }

    @SuppressLint("MissingPermission")
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mileagelog/trips").setMethodCallHandler { call, result ->
            val prefs = TripRecorderService.prefs(this)
            when (call.method) {
                "tripsDir" -> result.success(TripRecorderService.tripsDir(this).absolutePath)
                "currentTrip" -> result.success(TripRecorderService.currentTripId(this))
                "startTrip" -> {
                    try {
                        TripRecorderService.start(this, "manual", call.argument<String>("tripId"))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("start_failed", e.message, null)
                    }
                }
                "stopTrip" -> {
                    TripRecorderService.send(this, TripRecorderService.ACTION_STOP)
                    result.success(true)
                }
                "consumeStartRequest" -> {
                    result.success(startTripRequested)
                    startTripRequested = false
                }
                "consumeLaunchAction" -> {
                    result.success(launchAction)
                    launchAction = null
                }
                "updateWidgets" -> {
                    HomeWidgets.save(this, call.argument<String>("json") ?: "{}")
                    result.success(true)
                }
                "scheduleReminders" -> {
                    Reminders.schedule(this, call.argument<String>("json") ?: "[]")
                    result.success(true)
                }
                "hasPermission" -> result.success(granted(call.argument<String>("name") ?: ""))
                "requestPermission" -> {
                    val name = call.argument<String>("name") ?: ""
                    val perms = permissionsFor(name)
                    if (perms.isEmpty() || granted(name)) {
                        result.success(true)
                    } else {
                        pendingPermission?.success(false)
                        pendingPermission = result
                        requestPermissions(perms, 7)
                    }
                }
                "batteryUnrestricted" -> {
                    val pm = getSystemService(PowerManager::class.java)
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "requestBatteryUnrestricted" -> {
                    try {
                        @SuppressLint("BatteryLife")
                        val i = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:$packageName"))
                        startActivity(i)
                    } catch (_: Exception) {
                        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                    }
                    result.success(true)
                }
                "openUrl" -> {
                    try {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(call.argument<String>("url"))))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("open_failed", e.message, null)
                    }
                }
                "openApp" -> {
                    // Opens another app, or its Play Store page when it isn't installed.
                    val pkg = call.argument<String>("package") ?: ""
                    val launch = packageManager.getLaunchIntentForPackage(pkg)
                    try {
                        if (launch != null) {
                            startActivity(launch)
                        } else {
                            try {
                                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$pkg")))
                            } catch (e: Exception) {
                                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$pkg")))
                            }
                        }
                        result.success(launch != null)
                    } catch (e: Exception) {
                        result.error("open_failed", e.message, null)
                    }
                }
                "openAppSettings" -> {
                    startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")))
                    result.success(true)
                }
                "bondedDevices" -> {
                    if (!granted("bluetooth")) {
                        result.error("no_permission", "Bluetooth permission not granted", null)
                    } else {
                        val adapter = getSystemService(BluetoothManager::class.java)?.adapter
                        val list = adapter?.bondedDevices?.map { mapOf("name" to (it.name ?: it.address), "address" to it.address) } ?: emptyList()
                        result.success(list)
                    }
                }
                "getCar" -> result.success(
                    mapOf(
                        "address" to prefs.getString("carAddress", null),
                        "name" to prefs.getString("carName", null),
                        "autoStart" to prefs.getBoolean("autoStart", false),
                    )
                )
                "setCar" -> {
                    val address = call.argument<String>("address")
                    prefs.edit().apply {
                        if (address == null) remove("carAddress").remove("carName")
                        else putString("carAddress", address).putString("carName", call.argument<String>("name"))
                    }.apply()
                    result.success(true)
                }
                "setCars" -> {
                    val list = call.argument<List<String>>("addresses") ?: emptyList()
                    prefs.edit().putString("carAddresses", org.json.JSONArray(list).toString()).apply()
                    result.success(true)
                }
                "setAutoStart" -> {
                    prefs.edit().putBoolean("autoStart", call.argument<Boolean>("enabled") == true).apply()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 7) {
            pendingPermission?.success(grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED })
            pendingPermission = null
        }
    }
}
