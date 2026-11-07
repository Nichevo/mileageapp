/// Pure fuel-economy maths. No Flutter or database imports so it can be unit
/// tested and reused by the web view.
library;

class FuelRow {
  final DateTime at;
  final double odometerKm;
  final double quantity; // litres or kWh
  final double cost;
  final bool isFull;
  final double? tripKm; // as recorded by the source, optional
  const FuelRow({
    required this.at,
    required this.odometerKm,
    required this.quantity,
    required this.cost,
    this.isFull = true,
    this.tripKm,
  });
}

/// Per-tank figures derived from consecutive fills.
class TankStat {
  final FuelRow fill;
  final double? distanceKm; // since the previous fill
  final double? litresPer100; // null when not computable (partial fills, first fill)
  final double? costPer100;
  final double pricePerUnit;
  const TankStat({
    required this.fill,
    this.distanceKm,
    this.litresPer100,
    this.costPer100,
    required this.pricePerUnit,
  });
}

/// Computes per-tank economy. Economy is only computed between two FULL
/// fills; quantity from partial fills in between is added to the next full
/// fill's tank.
List<TankStat> tankStats(List<FuelRow> rows) {
  final sorted = [...rows]..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));
  final out = <TankStat>[];
  FuelRow? lastFull;
  double pendingQty = 0;
  double pendingCost = 0;
  FuelRow? prev;
  for (final r in sorted) {
    final price = r.quantity > 0 ? r.cost / r.quantity : 0.0;
    double? dist;
    if (prev != null) {
      dist = r.odometerKm - prev.odometerKm;
      if (dist <= 0) dist = r.tripKm;
    } else {
      dist = r.tripKm;
    }
    double? l100;
    double? c100;
    if (r.isFull && lastFull != null) {
      final span = r.odometerKm - lastFull.odometerKm;
      if (span > 0) {
        final qty = pendingQty + r.quantity;
        final cost = pendingCost + r.cost;
        l100 = qty / span * 100;
        c100 = cost / span * 100;
      }
    }
    out.add(TankStat(
      fill: r,
      distanceKm: dist,
      litresPer100: l100,
      costPer100: c100,
      pricePerUnit: price,
    ));
    if (r.isFull) {
      lastFull = r;
      pendingQty = 0;
      pendingCost = 0;
    } else {
      pendingQty += r.quantity;
      pendingCost += r.cost;
    }
    prev = r;
  }
  return out;
}

class Totals {
  final double km;
  final double quantity;
  final double cost;
  final int fills;
  const Totals({required this.km, required this.quantity, required this.cost, required this.fills});
  double? get per100 => km > 0 ? quantity / km * 100 : null;
  double? get costPer100 => km > 0 ? cost / km * 100 : null;
  double? get pricePerUnit => quantity > 0 ? cost / quantity : null;
}

/// Lifetime totals: distance between first and last fill, all quantity and
/// cost except the first fill (which filled a tank used before tracking).
Totals lifetimeTotals(List<FuelRow> rows) {
  if (rows.isEmpty) return const Totals(km: 0, quantity: 0, cost: 0, fills: 0);
  final sorted = [...rows]..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));
  final km = sorted.last.odometerKm - sorted.first.odometerKm;
  double qty = 0, cost = 0;
  for (var i = 1; i < sorted.length; i++) {
    qty += sorted[i].quantity;
    cost += sorted[i].cost;
  }
  return Totals(km: km, quantity: qty, cost: cost, fills: sorted.length);
}

/// Totals per calendar year keyed by year. Distance is attributed to the
/// year of the fill that closes the tank.
Map<int, Totals> yearlyTotals(List<FuelRow> rows) {
  final sorted = [...rows]..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));
  final acc = <int, List<double>>{}; // km, qty, cost, fills
  for (var i = 1; i < sorted.length; i++) {
    final r = sorted[i];
    final km = r.odometerKm - sorted[i - 1].odometerKm;
    final a = acc.putIfAbsent(r.at.year, () => [0, 0, 0, 0]);
    a[0] += km;
    a[1] += r.quantity;
    a[2] += r.cost;
    a[3] += 1;
  }
  return {
    for (final e in acc.entries)
      e.key: Totals(km: e.value[0], quantity: e.value[1], cost: e.value[2], fills: e.value[3].toInt())
  };
}

/// Rolling average of litres/100 over the last [n] computable tanks ending at
/// each index. Entries without economy are skipped.
List<double?> rollingPer100(List<TankStat> stats, {int n = 5}) {
  final out = <double?>[];
  final window = <double>[];
  for (final s in stats) {
    if (s.litresPer100 != null) {
      window.add(s.litresPer100!);
      if (window.length > n) window.removeAt(0);
      out.add(window.reduce((a, b) => a + b) / window.length);
    } else {
      out.add(null);
    }
  }
  return out;
}

/// Estimated km left in the tank given tank size and recent economy.
double? rangeLeftKm({
  required double? tankSize,
  required double? recentPer100,
  required double kmSinceFill,
}) {
  if (tankSize == null || recentPer100 == null || recentPer100 <= 0) return null;
  final fullRange = tankSize / recentPer100 * 100;
  final left = fullRange - kmSinceFill;
  return left < 0 ? 0 : left;
}
