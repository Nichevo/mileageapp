/// What a vehicle runs on, and the words and units that go with it.
library;

/// Stored in Vehicles.kind.
const vehicleKinds = ['petrol', 'diesel', 'hybrid', 'phev', 'ev'];

String vehicleKindLabel(String kind) => switch (kind) {
      'diesel' => 'Diesel',
      'hybrid' => 'Hybrid',
      'phev' => 'Plug-in hybrid',
      'ev' => 'Electric',
      _ => 'Petrol',
    };

bool usesFuel(String kind) => kind != 'ev';
bool usesCharging(String kind) => kind == 'ev' || kind == 'phev';

/// Units and wording for one kind of energy event ('fuel' or 'charge').
class Energy {
  final String eventKind;
  final String unit; // L or kWh
  final String noun; // fill-up / charge
  final String nounPlural;
  final String fillWord; // tank / charge, as in "last tank"
  const Energy._(this.eventKind, this.unit, this.noun, this.nounPlural, this.fillWord);

  static const fuel = Energy._('fuel', 'L', 'fill-up', 'fill-ups', 'tank');
  static const charge = Energy._('charge', 'kWh', 'charge', 'charges', 'charge');

  /// The main energy for a vehicle kind: charging for an EV, fuel otherwise
  /// (a plug-in hybrid's economy figures stay in L/100 km).
  static Energy primaryFor(String? vehicleKind) => vehicleKind == 'ev' ? charge : fuel;

  bool get isCharge => eventKind == 'charge';
  String get per100 => '$unit/100 km';
  String get nounCap => noun[0].toUpperCase() + noun.substring(1);
  String get nounPluralCap => nounPlural[0].toUpperCase() + nounPlural.substring(1);

  String quantity(num v) => isCharge ? '${v.toStringAsFixed(1)} kWh' : '${v.toStringAsFixed(2)} L';
  String price(num? v) => v == null ? '—' : (isCharge ? '\$${v.toStringAsFixed(2)}/kWh' : '\$${v.toStringAsFixed(3)}/L');
}

/// Where a charge happened. Stored in EnergyEvents.chargerType.
const chargePlaces = ['home', 'ac', 'dc'];

String chargePlaceLabel(String? place) => switch (place) {
      'ac' => 'Public AC',
      'dc' => 'Fast DC',
      _ => 'Home',
    };

/// Energy that went into the car, worked out from the battery % before and
/// after when the battery size is known; otherwise the meter's kWh.
/// Charging losses mean the meter reads a little more than the battery got.
double chargeKwh({required double? meterKwh, double? pctStart, double? pctEnd, double? batteryKwh}) {
  if (meterKwh != null && meterKwh > 0) return meterKwh;
  if (pctStart != null && pctEnd != null && batteryKwh != null && pctEnd > pctStart) {
    return (pctEnd - pctStart) / 100 * batteryKwh;
  }
  return 0;
}
