/// EV running costs: where charging happens, road user charges, and what
/// your driving would cost in an EV compared with fuel.
library;

import 'stats.dart';

/// Light EV road user charges in NZ, dollars per 1,000 km (from April 2024).
/// Plug-in hybrids pay a lower rate. Editable in the app since rates change.
const rucEvPer1000 = 76.0;
const rucPhevPer1000 = 38.0;

/// Does this vehicle kind pay road user charges (rather than fuel excise)?
bool paysRuc(String kind) => kind == 'ev' || kind == 'phev' || kind == 'diesel';

class ChargePlaceTotal {
  final String place; // home, ac, dc
  final double kwh, cost;
  final int count;
  const ChargePlaceTotal(this.place, this.kwh, this.cost, this.count);
  double? get pricePerKwh => kwh > 0 ? cost / kwh : null;
}

/// kWh, cost and count of charges by where they happened.
List<ChargePlaceTotal> chargeSplit(Iterable<({String? place, double kwh, double cost})> charges) {
  final kwh = <String, double>{}, cost = <String, double>{}, n = <String, int>{};
  for (final c in charges) {
    final p = c.place ?? 'home';
    kwh[p] = (kwh[p] ?? 0) + c.kwh;
    cost[p] = (cost[p] ?? 0) + c.cost;
    n[p] = (n[p] ?? 0) + 1;
  }
  return [for (final p in const ['home', 'ac', 'dc']) if (n.containsKey(p)) ChargePlaceTotal(p, kwh[p]!, cost[p]!, n[p]!)];
}

/// Distance and fuel spend over the [days] before [now], from fill-ups.
/// Distance runs from the last reading before the window (or the first in
/// it) to the latest; spend is the fills inside the window.
({double km, double cost, int days})? recentDriving(List<FuelRow> rows, {required DateTime now, int days = 365}) {
  if (rows.length < 2) return null;
  final sorted = [...rows]..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));
  final from = now.subtract(Duration(days: days));
  final inside = sorted.where((r) => r.at.isAfter(from)).toList();
  if (inside.isEmpty) return null;
  final before = sorted.where((r) => !r.at.isAfter(from)).lastOrNull;
  final start = before ?? inside.first;
  final km = inside.last.odometerKm - start.odometerKm;
  // Without a reading before the window, the first fill's fuel was used
  // before it, so it isn't part of the distance.
  final spent = (before == null ? inside.skip(1) : inside).fold(0.0, (a, r) => a + r.cost);
  final span = before == null ? inside.last.at.difference(inside.first.at).inDays : days;
  if (km <= 0 || span <= 0) return null;
  return (km: km, cost: spent, days: span);
}

class EvEstimate {
  final double km;
  final double energyCost, ruc;
  const EvEstimate(this.km, this.energyCost, this.ruc);
  double get total => energyCost + ruc;
}

/// What [km] would cost in an EV using [kwhPer100], charged [homeShare] of
/// the time at home at [homePerKwh] and the rest at [publicPerKwh].
EvEstimate evEstimate({
  required double km,
  required double kwhPer100,
  required double homeShare,
  required double homePerKwh,
  required double publicPerKwh,
  double rucPer1000 = rucEvPer1000,
}) {
  final kwh = km * kwhPer100 / 100;
  final energy = kwh * (homeShare * homePerKwh + (1 - homeShare) * publicPerKwh);
  return EvEstimate(km, energy, km / 1000 * rucPer1000);
}

/// When the road user charges licence runs out, from typical driving.
DateTime? rucDueOn({required double rucUntilKm, required double? currentKm, required double? kmPerDay, required DateTime now}) {
  if (currentKm == null || kmPerDay == null || kmPerDay <= 0) return null;
  final left = rucUntilKm - currentKm;
  return now.add(Duration(hours: (left / kmPerDay * 24).round()));
}
