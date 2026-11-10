/// A loan car (courtesy car while yours is in the shop, a friend's car) or a
/// rental: when and how it was collected and handed back, and for rentals
/// the booking details. Stored as JSON on the vehicle.
library;

import 'dart:convert';

const fuelPolicies = {
  'full_to_full': 'Full to full',
  'same_level': 'Same level back',
  'prepaid': 'Prepaid fuel',
  'none': 'Not specified',
};

/// Fuel gauge in eighths: 0 = empty, 8 = full.
String fuelLabel(int? eighths) => switch (eighths) {
      null => '—',
      0 => 'Empty',
      8 => 'Full',
      4 => '1/2',
      2 => '1/4',
      6 => '3/4',
      final e => '$e/8',
    };

class LoanDetails {
  final String kind; // 'loan' or 'rental'
  final String? from, reason, plate, forVehicleId, notes;
  final DateTime collectedAt;
  final double? collectedKm;
  final int? collectedFuel;
  final DateTime? returnedAt;
  final double? returnedKm;
  final int? returnedFuel;
  // Rentals.
  final String? bookingRef, pickupPlace, returnPlace, fuelPolicy;
  final DateTime? dueBackAt;
  final double? totalCost, excess;
  final int? kmAllowance; // total km included; null = unlimited

  const LoanDetails({
    required this.kind,
    required this.collectedAt,
    this.from,
    this.reason,
    this.plate,
    this.forVehicleId,
    this.notes,
    this.collectedKm,
    this.collectedFuel,
    this.returnedAt,
    this.returnedKm,
    this.returnedFuel,
    this.bookingRef,
    this.pickupPlace,
    this.returnPlace,
    this.fuelPolicy,
    this.dueBackAt,
    this.totalCost,
    this.excess,
    this.kmAllowance,
  });

  bool get isRental => kind == 'rental';
  bool get returned => returnedAt != null;
  String get label => isRental ? 'Rental' : 'Loan car';

  /// Km on the odometer between collection and return.
  double? get odoKm => collectedKm != null && returnedKm != null && returnedKm! >= collectedKm! ? returnedKm! - collectedKm! : null;

  /// Fuel gauge difference in eighths (negative = brought back with less).
  int? get fuelDiff => collectedFuel != null && returnedFuel != null ? returnedFuel! - collectedFuel! : null;

  int? kmOver(double km) => kmAllowance == null || km <= kmAllowance! ? null : (km - kmAllowance!).round();

  LoanDetails handBack({required DateTime at, double? km, int? fuel, String? notes}) => LoanDetails(
        kind: kind,
        collectedAt: collectedAt,
        from: from,
        reason: reason,
        plate: plate,
        forVehicleId: forVehicleId,
        notes: notes ?? this.notes,
        collectedKm: collectedKm,
        collectedFuel: collectedFuel,
        returnedAt: at,
        returnedKm: km,
        returnedFuel: fuel,
        bookingRef: bookingRef,
        pickupPlace: pickupPlace,
        returnPlace: returnPlace,
        fuelPolicy: fuelPolicy,
        dueBackAt: dueBackAt,
        totalCost: totalCost,
        excess: excess,
        kmAllowance: kmAllowance,
      );

  Map<String, Object?> toJson() => {
        'kind': kind,
        'from': from,
        'reason': reason,
        'plate': plate,
        'forVehicleId': forVehicleId,
        'notes': notes,
        'collectedAt': collectedAt.toIso8601String(),
        'collectedKm': collectedKm,
        'collectedFuel': collectedFuel,
        'returnedAt': returnedAt?.toIso8601String(),
        'returnedKm': returnedKm,
        'returnedFuel': returnedFuel,
        'bookingRef': bookingRef,
        'pickupPlace': pickupPlace,
        'returnPlace': returnPlace,
        'fuelPolicy': fuelPolicy,
        'dueBackAt': dueBackAt?.toIso8601String(),
        'totalCost': totalCost,
        'excess': excess,
        'kmAllowance': kmAllowance,
      }..removeWhere((k, v) => v == null);

  String encode() => jsonEncode(toJson());

  static LoanDetails? decode(String? s) {
    if (s == null || s.isEmpty) return null;
    final j = jsonDecode(s) as Map<String, dynamic>;
    DateTime? d(String k) => j[k] == null ? null : DateTime.parse(j[k] as String);
    double? n(String k) => (j[k] as num?)?.toDouble();
    return LoanDetails(
      kind: j['kind'] as String? ?? 'loan',
      collectedAt: d('collectedAt') ?? DateTime(2000),
      from: j['from'] as String?,
      reason: j['reason'] as String?,
      plate: j['plate'] as String?,
      forVehicleId: j['forVehicleId'] as String?,
      notes: j['notes'] as String?,
      collectedKm: n('collectedKm'),
      collectedFuel: (j['collectedFuel'] as num?)?.toInt(),
      returnedAt: d('returnedAt'),
      returnedKm: n('returnedKm'),
      returnedFuel: (j['returnedFuel'] as num?)?.toInt(),
      bookingRef: j['bookingRef'] as String?,
      pickupPlace: j['pickupPlace'] as String?,
      returnPlace: j['returnPlace'] as String?,
      fuelPolicy: j['fuelPolicy'] as String?,
      dueBackAt: d('dueBackAt'),
      totalCost: n('totalCost'),
      excess: n('excess'),
      kmAllowance: (j['kmAllowance'] as num?)?.toInt(),
    );
  }
}

/// What happened while you had the car.
class LoanSummary {
  final int trips;
  final double tripKm;
  final double? odoKm;
  final double fuelLitres, fuelCost, otherCost;
  final int? fuelDiff, kmOver;
  const LoanSummary({
    required this.trips,
    required this.tripKm,
    required this.odoKm,
    required this.fuelLitres,
    required this.fuelCost,
    required this.otherCost,
    required this.fuelDiff,
    required this.kmOver,
  });

  /// Best distance figure: odometer when both readings exist, else trips.
  double get km => odoKm ?? tripKm;

  List<String> lines(LoanDetails l, String Function(num) money) => [
        '${km.round()} km${odoKm == null ? ' (from recorded trips)' : ''}, $trips trip${trips == 1 ? '' : 's'} recorded',
        if (fuelLitres > 0) '${fuelLitres.toStringAsFixed(1)} L of fuel bought, ${money(fuelCost)}',
        if (otherCost > 0) 'Tolls and parking ${money(otherCost)}',
        if (l.totalCost != null) 'Rental cost ${money(l.totalCost!)}',
        if (fuelDiff != null && fuelDiff! < 0) 'Returned with ${-fuelDiff!}/8 tank less than collected',
        if (fuelDiff != null && fuelDiff! > 0) 'Returned with ${fuelDiff!}/8 tank more than collected',
        if (fuelDiff == 0) 'Returned with the same fuel level',
        if (kmOver != null) '$kmOver km over the ${l.kmAllowance} km allowance',
      ];
}

LoanSummary summariseLoan(LoanDetails l, {required int trips, required double tripKm, required double fuelLitres, required double fuelCost, double otherCost = 0}) {
  final odo = l.odoKm;
  return LoanSummary(
    trips: trips,
    tripKm: tripKm,
    odoKm: odo,
    fuelLitres: fuelLitres,
    fuelCost: fuelCost,
    otherCost: otherCost,
    fuelDiff: l.fuelDiff,
    kmOver: l.kmOver(odo ?? tripKm),
  );
}
