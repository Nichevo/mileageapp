import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small key/value settings. Stored in SharedPreferences, which Android backs
/// up with the app data and keeps across updates.
class Settings {
  final SharedPreferences _p;
  Settings._(this._p);

  static Future<Settings> load() async => Settings._(await SharedPreferences.getInstance());

  String? get activeVehicleId => _p.getString('activeVehicleId');
  Future<void> setActiveVehicleId(String id) async {
    await _p.setString('activeVehicleId', id);
    activeVehicle.value = id;
  }

  /// Changes when you switch vehicles, so the app can rebuild for it.
  late final ValueNotifier<String?> activeVehicle = ValueNotifier(activeVehicleId);

  String? get spreadsheetId => _p.getString('spreadsheetId');
  Future<void> setSpreadsheetId(String? id) async =>
      id == null || id.isEmpty ? await _p.remove('spreadsheetId') : await _p.setString('spreadsheetId', id);

  bool get sheetsSyncEnabled => _p.getBool('sheetsSyncEnabled') ?? false;
  Future<void> setSheetsSyncEnabled(bool v) => _p.setBool('sheetsSyncEnabled', v);

  /// Tyre pressures are stored in kPa and shown in psi unless changed.
  bool get pressurePsi => _p.getBool('pressurePsi') ?? true;
  Future<void> setPressurePsi(bool v) => _p.setBool('pressurePsi', v);

  bool get remindersEnabled => _p.getBool('remindersEnabled') ?? true;
  Future<void> setRemindersEnabled(bool v) => _p.setBool('remindersEnabled', v);

  /// Time of day reminders are shown.
  int get reminderHour => _p.getInt('reminderHour') ?? 9;
  int get reminderMinute => _p.getInt('reminderMinute') ?? 0;
  Future<void> setReminderTime(int hour, int minute) async {
    await _p.setInt('reminderHour', hour);
    await _p.setInt('reminderMinute', minute);
  }

  /// "Fuel probably getting low" reminders (needs the tank size).
  bool get fuelReminders => _p.getBool('fuelReminders') ?? true;
  Future<void> setFuelReminders(bool v) => _p.setBool('fuelReminders', v);

  /// Remind to pay after a trip on a toll road. Off when a toll account
  /// pays automatically.
  bool get tollReminders => _p.getBool('tollReminders') ?? true;
  Future<void> setTollReminders(bool v) => _p.setBool('tollReminders', v);

  /// Look up traffic lights and road types for finished trips on OpenStreetMap.
  bool get roadLookup => _p.getBool('roadLookup') ?? true;
  Future<void> setRoadLookup(bool v) => _p.setBool('roadLookup', v);

  /// The car's number plate, per vehicle. Kept on the phone only.
  String? plateFor(String vehicleId) => _p.getString('plate_$vehicleId');
  Future<void> setPlate(String vehicleId, String? plate) async =>
      plate == null || plate.isEmpty ? await _p.remove('plate_$vehicleId') : await _p.setString('plate_$vehicleId', plate);

  /// The user's own CarJam API key for plate lookups.
  String? get carjamKey => _p.getString('carjamKey');
  Future<void> setCarjamKey(String? k) async =>
      k == null || k.trim().isEmpty ? await _p.remove('carjamKey') : await _p.setString('carjamKey', k.trim());

  /// Home electricity rate for costing home EV charges, cents per kWh.
  double get homeRateCents => _p.getDouble('homeRateCents') ?? 30;
  Future<void> setHomeRateCents(double v) => _p.setDouble('homeRateCents', v);

  bool get useGps => _p.getBool('useGps') ?? true;
  Future<void> setUseGps(bool v) => _p.setBool('useGps', v);

  String? get lastStation => _p.getString('lastStation');
  Future<void> setLastStation(String? s) async =>
      s == null ? await _p.remove('lastStation') : await _p.setString('lastStation', s);

  String? get lastFuelType => _p.getString('lastFuelType');
  Future<void> setLastFuelType(String? s) async =>
      s == null ? await _p.remove('lastFuelType') : await _p.setString('lastFuelType', s);

  DateTime? get lastBackupAt {
    final s = _p.getString('lastBackupAt');
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> setLastBackupAt(DateTime d) => _p.setString('lastBackupAt', d.toIso8601String());

  /// Turns a pasted Google Sheets URL or bare ID into the ID.
  static String? spreadsheetIdFrom(String text) {
    final t = text.trim();
    final m = RegExp(r'/spreadsheets/d/([A-Za-z0-9_-]{20,})').firstMatch(t);
    if (m != null) return m[1];
    if (RegExp(r'^[A-Za-z0-9_-]{20,}$').hasMatch(t)) return t;
    return null;
  }
}
