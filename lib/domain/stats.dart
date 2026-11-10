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

/// Chart granularity on the Insights page.
enum Period { week, month, year }

/// Distance, fuel and cost that fall in one week, month or year.
class PeriodTotals {
  final DateTime start;
  double km = 0, quantity = 0, cost = 0;
  // Price is taken from the fills made in the period, not spread.
  double filledQuantity = 0, filledCost = 0;
  PeriodTotals(this.start);
  double? get per100 => km > 0.5 ? quantity / km * 100 : null;
  double? get costPer100 => km > 0.5 ? cost / km * 100 : null;
  double? get pricePerUnit => filledQuantity > 0 ? filledCost / filledQuantity : null;
}

DateTime periodStart(DateTime d, Period p) => switch (p) {
      Period.week => DateTime(d.year, d.month, d.day - (d.weekday - 1)), // Monday
      Period.month => DateTime(d.year, d.month),
      Period.year => DateTime(d.year),
    };

DateTime nextPeriod(DateTime start, Period p) => switch (p) {
      Period.week => DateTime(start.year, start.month, start.day + 7),
      Period.month => DateTime(start.year, start.month + 1),
      Period.year => DateTime(start.year + 1),
    };

/// Totals per week, month or year. A tank's distance, fuel and cost are
/// spread evenly over the days between the two fills, so a month without a
/// fill-up still shows the driving done in it. Every period from the first
/// to the last fill is present, including empty ones. With [from], periods
/// before it are dropped (the spreading still uses the earlier fill).
List<PeriodTotals> periodTotals(List<FuelRow> rows, Period p, {DateTime? from}) {
  if (rows.length < 2) return const [];
  final sorted = [...rows]..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));
  final buckets = <DateTime, PeriodTotals>{};
  PeriodTotals bucket(DateTime day) {
    final s = periodStart(day, p);
    return buckets.putIfAbsent(s, () => PeriodTotals(s));
  }

  for (var i = 1; i < sorted.length; i++) {
    final a = sorted[i - 1], b = sorted[i];
    final km = b.odometerKm - a.odometerKm;
    if (km < 0) continue;
    final startDay = DateTime(a.at.year, a.at.month, a.at.day);
    final endDay = DateTime(b.at.year, b.at.month, b.at.day);
    final days = endDay.difference(startDay).inDays;
    if (days <= 0) {
      final t = bucket(endDay);
      t.km += km;
      t.quantity += b.quantity;
      t.cost += b.cost;
    } else {
      for (var d = 0; d < days; d++) {
        final t = bucket(DateTime(startDay.year, startDay.month, startDay.day + d));
        t.km += km / days;
        t.quantity += b.quantity / days;
        t.cost += b.cost / days;
      }
    }
    final f = bucket(b.at);
    f.filledQuantity += b.quantity;
    f.filledCost += b.cost;
  }

  // Fill in empty periods so gaps show as gaps.
  var cur = periodStart(sorted.first.at, p);
  final last = periodStart(sorted.last.at, p);
  final out = <PeriodTotals>[];
  while (!cur.isAfter(last)) {
    out.add(buckets[cur] ?? PeriodTotals(cur));
    cur = nextPeriod(cur, p);
  }
  if (from == null) return out;
  final cut = periodStart(from, p);
  return out.where((t) => !t.start.isBefore(cut)).toList();
}

/// Several vehicles' period totals added together, every period from the
/// earliest to the latest present (empty ones included).
List<PeriodTotals> mergePeriodTotals(List<List<PeriodTotals>> lists, Period p) {
  final all = [for (final l in lists) ...l];
  if (all.isEmpty) return const [];
  final byStart = <DateTime, PeriodTotals>{};
  for (final t in all) {
    final m = byStart.putIfAbsent(t.start, () => PeriodTotals(t.start));
    m
      ..km += t.km
      ..quantity += t.quantity
      ..cost += t.cost
      ..filledQuantity += t.filledQuantity
      ..filledCost += t.filledCost;
  }
  final starts = byStart.keys.toList()..sort();
  final out = <PeriodTotals>[];
  for (var cur = starts.first; !cur.isAfter(starts.last); cur = nextPeriod(cur, p)) {
    out.add(byStart[cur] ?? PeriodTotals(cur));
  }
  return out;
}
