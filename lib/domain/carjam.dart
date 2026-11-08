/// Vehicle details from CarJam's "Absolute Basic Car Details" API
/// (https://www.carjam.co.nz/dev/abcd/). Parsing only; the request lives
/// in lib/vehicle/carjam_client.dart.
library;

class CarDetails {
  final String? plate, make, model, submodel, fuelType, colour, bodyStyle;
  final int? year, ccRating;
  final DateTime? wofExpiry, licenceExpiry, firstRegisteredNz;
  final double? odometerKm;
  /// Rated fuel use from the government fuel economy label, L/100 km.
  final double? ratedPer100;

  const CarDetails({
    this.plate,
    this.make,
    this.model,
    this.submodel,
    this.fuelType,
    this.colour,
    this.bodyStyle,
    this.year,
    this.ccRating,
    this.wofExpiry,
    this.licenceExpiry,
    this.firstRegisteredNz,
    this.odometerKm,
    this.ratedPer100,
  });

  bool get isEmpty => make == null && model == null && year == null;

  /// Make and model in normal case for the form fields.
  String get summaryMake => _title(make) ?? '';
  String get summaryModel => [?_title(model), ?submodel].join(' ');

  /// "2015 Toyota Corolla GX, 1,798 cc petrol"
  String get summary {
    final name = [if (year != null) '$year', ?_title(make), ?_title(model), ?submodel].join(' ');
    final engine = [if (ccRating != null) '$ccRating cc', ?fuelType?.toLowerCase()].join(' ');
    return [if (name.isNotEmpty) name, if (engine.isNotEmpty) engine].join(', ');
  }

  static CarDetails fromJson(Map<String, Object?> j) {
    String? str(String k) {
      final v = j[k];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    int? integer(String k) => j[k] is num ? (j[k] as num).toInt() : int.tryParse(str(k)?.replaceAll(RegExp(r'[^0-9]'), '') ?? '');
    double? number(Object? v) => v is num ? v.toDouble() : double.tryParse(v?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '');
    final se = j['safety_economy'];
    final rated = se is Map ? number(se['fuel_consumption']) : null;
    return CarDetails(
      plate: str('plate'),
      make: str('make'),
      model: str('model'),
      submodel: str('submodel'),
      fuelType: str('fuel_type'),
      colour: str('main_colour'),
      bodyStyle: str('body_style'),
      year: integer('year_of_manufacture'),
      ccRating: integer('cc_rating'),
      wofExpiry: parseCarJamDate(j['expiry_date_of_last_successful_wof']),
      licenceExpiry: parseCarJamDate(j['licence_expiry_date']),
      firstRegisteredNz: parseCarJamDate(j['date_of_first_registration_in_nz']),
      odometerKm: number(j['latest_odometer_reading']),
      ratedPer100: rated != null && rated > 1 && rated < 40 ? rated : null,
    );
  }
}

String? _title(String? s) {
  if (s == null) return null;
  // CarJam often returns upper case: TOYOTA COROLLA -> Toyota Corolla.
  if (s != s.toUpperCase() || s.length <= 3) return s;
  return s.split(' ').map((w) => w.isEmpty ? w : w[0] + w.substring(1).toLowerCase()).join(' ');
}

/// CarJam dates come as Unix timestamps (seconds) or date strings.
DateTime? parseCarJamDate(Object? v) {
  if (v == null) return null;
  if (v is num || (v is String && RegExp(r'^\d{9,13}$').hasMatch(v.trim()))) {
    final n = v is num ? v.toInt() : int.parse((v as String).trim());
    if (n <= 0) return null;
    final d = DateTime.fromMillisecondsSinceEpoch(n > 100000000000 ? n : n * 1000);
    return DateTime(d.year, d.month, d.day);
  }
  final s = v.toString().trim();
  final iso = DateTime.tryParse(s);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);
  final m = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})').firstMatch(s);
  if (m != null) return DateTime(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
  return null;
}

/// The "last done" date that makes something with an [intervalMonths]
/// interval fall due on [due] (day clamped to the shorter month).
DateTime lastDoneForDue(DateTime due, int intervalMonths) {
  final total = due.year * 12 + (due.month - 1) - intervalMonths;
  final y = total ~/ 12, m = total % 12 + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, due.day > lastDay ? lastDay : due.day);
}

/// Plates are stored and sent upper case without spaces.
String normalisePlate(String s) => s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
