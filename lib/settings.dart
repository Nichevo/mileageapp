import 'package:shared_preferences/shared_preferences.dart';

/// Small key/value settings. Stored in SharedPreferences, which Android backs
/// up with the app data and keeps across updates.
class Settings {
  final SharedPreferences _p;
  Settings._(this._p);

  static Future<Settings> load() async => Settings._(await SharedPreferences.getInstance());

  String? get activeVehicleId => _p.getString('activeVehicleId');
  Future<void> setActiveVehicleId(String id) => _p.setString('activeVehicleId', id);

  String? get spreadsheetId => _p.getString('spreadsheetId');
  Future<void> setSpreadsheetId(String? id) async =>
      id == null || id.isEmpty ? await _p.remove('spreadsheetId') : await _p.setString('spreadsheetId', id);

  bool get sheetsSyncEnabled => _p.getBool('sheetsSyncEnabled') ?? false;
  Future<void> setSheetsSyncEnabled(bool v) => _p.setBool('sheetsSyncEnabled', v);

  /// Tyre pressures are stored in kPa and shown in psi unless changed.
  bool get pressurePsi => _p.getBool('pressurePsi') ?? true;
  Future<void> setPressurePsi(bool v) => _p.setBool('pressurePsi', v);

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
