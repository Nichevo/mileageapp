/// What a vehicle costs to own over time: running costs by category,
/// depreciation from what it was worth, cost per km, and whether costs are
/// rising. Pure Dart so it can be tested and reused by the web view.
library;

import 'dart:math' as math;

import 'stats.dart';

enum CostCategory { fuel, charging, servicing, rego, insurance, tyres, tollsParking, other, depreciation }

String costLabel(CostCategory c) => switch (c) {
      CostCategory.fuel => 'Fuel',
      CostCategory.charging => 'Charging',
      CostCategory.servicing => 'Servicing & WOF',
      CostCategory.rego => 'Registration & RUC',
      CostCategory.insurance => 'Insurance',
      CostCategory.tyres => 'Tyres',
      CostCategory.tollsParking => 'Tolls & parking',
      CostCategory.other => 'Other',
      CostCategory.depreciation => 'Depreciation',
    };

/// Expense kinds to cost categories.
CostCategory categoryForExpense(String kind) => switch (kind) {
      'service' || 'wof' => CostCategory.servicing,
      'rego' || 'ruc' => CostCategory.rego,
      'insurance' => CostCategory.insurance,
      'tyres' => CostCategory.tyres,
      'toll' || 'parking' => CostCategory.tollsParking,
      _ => CostCategory.other,
    };

class CostItem {
  final DateTime at;
  final CostCategory category;
  final double cost;
  const CostItem(this.at, this.category, this.cost);
}

/// A known value of the car: what you paid, an estimate, an insured value,
/// or what it sold for.
class ValuePoint {
  final DateTime at;
  final double value;
  final String source; // 'purchase', 'estimate', 'insured', 'sold'
  const ValuePoint(this.at, this.value, this.source);
}

const valueSources = {'purchase': 'Bought for', 'estimate': 'Estimated value', 'insured': 'Insured value', 'sold': 'Sold for'};

/// Typical yearly loss of value used after the last known value, until you
/// add a newer one. 15% a year (compounding) is a common rule of thumb for
/// a used car.
const defaultDepreciationRate = 0.15;

/// The car's value over time, from known values.
class ValueCurve {
  final List<ValuePoint> points; // by date
  final double rate; // yearly loss after the last point
  ValueCurve(List<ValuePoint> pts, {double? rate})
      : points = ([...pts]..sort((a, b) => a.at.compareTo(b.at))),
        rate = rate ?? _fittedRate(pts);

  bool get isEmpty => points.isEmpty;
  DateTime? get start => points.firstOrNull?.at;
  ValuePoint? get sold => points.where((p) => p.source == 'sold').firstOrNull;

  /// Yearly rate between the first and last known values, when they're far
  /// enough apart to tell; otherwise the rule of thumb.
  static double _fittedRate(List<ValuePoint> pts) {
    if (pts.length < 2) return defaultDepreciationRate;
    final s = [...pts]..sort((a, b) => a.at.compareTo(b.at));
    final years = s.last.at.difference(s.first.at).inDays / 365.25;
    if (years < 0.75 || s.first.value <= 0 || s.last.value <= 0) return defaultDepreciationRate;
    final r = 1 - math.pow(s.last.value / s.first.value, 1 / years).toDouble();
    return r.clamp(0.0, 0.5);
  }

  /// Value on [d]: straight line between known values; after the last one,
  /// [rate] a year (none after a sale). Null before the first known value.
  double? valueAt(DateTime d) {
    if (points.isEmpty || d.isBefore(points.first.at)) return null;
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1], b = points[i];
      if (!d.isAfter(b.at)) {
        final span = b.at.difference(a.at).inSeconds;
        if (span <= 0) return b.value;
        return a.value + (b.value - a.value) * d.difference(a.at).inSeconds / span;
      }
    }
    final last = points.last;
    if (last.source == 'sold') return last.value;
    final years = d.difference(last.at).inDays / 365.25;
    return last.value * math.pow(1 - rate, years);
  }

  /// Whether the value on [d] comes from the rule of thumb (past the last
  /// known value).
  bool estimatedAt(DateTime d) => points.isNotEmpty && sold == null && d.isAfter(points.last.at);

  /// Value lost between [a] and [b] (only while owned: from the first known
  /// value to a sale).
  double lostBetween(DateTime a, DateTime b) {
    if (points.isEmpty) return 0;
    final from = a.isBefore(points.first.at) ? points.first.at : a;
    final end = sold != null && b.isAfter(sold!.at) ? sold!.at : b;
    if (!end.isAfter(from)) return 0;
    return (valueAt(from) ?? 0) - (valueAt(end) ?? 0);
  }
}

/// One week, month or year of costs.
class CostPeriod {
  final DateTime start;
  final cost = <CostCategory, double>{};
  double km = 0;
  CostPeriod(this.start);
  double get total => cost.values.fold(0.0, (a, b) => a + b);
  double get running => total - (cost[CostCategory.depreciation] ?? 0);
  double? get perKm => km < 10 ? null : total / km;
  double? get runningPerKm => km < 10 ? null : running / km;
}

/// Costs per period from the first cost or value to [now], with
/// depreciation spread over each period and km from [km] (odometer spread
/// by [periodTotals]).
List<CostPeriod> costPeriods(List<CostItem> items, ValueCurve values, List<PeriodTotals> km, Period p, {required DateTime now, DateTime? from}) {
  final starts = [...items.map((i) => i.at), ?values.start, ...km.map((k) => k.start)];
  if (starts.isEmpty) return const [];
  final first = starts.reduce((a, b) => a.isBefore(b) ? a : b);
  final out = <DateTime, CostPeriod>{};
  final list = <CostPeriod>[];
  for (var cur = periodStart(first, p); !cur.isAfter(periodStart(now, p)); cur = nextPeriod(cur, p)) {
    list.add(out[cur] = CostPeriod(cur));
  }
  for (final i in items) {
    final b = out[periodStart(i.at, p)];
    if (b != null) b.cost[i.category] = (b.cost[i.category] ?? 0) + i.cost;
  }
  for (final k in km) {
    out[k.start]?.km += k.km;
  }
  for (final b in list) {
    final end = nextPeriod(b.start, p);
    final lost = values.lostBetween(b.start, end.isAfter(now) ? now : end);
    if (lost != 0) b.cost[CostCategory.depreciation] = lost;
  }
  if (from == null) return list;
  final cut = periodStart(from, p);
  return list.where((x) => !x.start.isBefore(cut)).toList();
}

/// Each vehicle's periods added together (same period starts).
List<CostPeriod> mergeCostPeriods(List<List<CostPeriod>> lists) {
  final m = <DateTime, CostPeriod>{};
  for (final l in lists) {
    for (final c in l) {
      final t = m.putIfAbsent(c.start, () => CostPeriod(c.start));
      t.km += c.km;
      c.cost.forEach((k, v) => t.cost[k] = (t.cost[k] ?? 0) + v);
    }
  }
  return m.values.toList()..sort((a, b) => a.start.compareTo(b.start));
}

/// Last 12 months against the 12 before, per category and in total.
class CostTrend {
  final Map<CostCategory, double> recent, before;
  final double recentKm, beforeKm;
  const CostTrend(this.recent, this.before, this.recentKm, this.beforeKm);
  double get recentTotal => recent.values.fold(0.0, (a, b) => a + b);
  double get beforeTotal => before.values.fold(0.0, (a, b) => a + b);
  double? get change => beforeTotal <= 0 ? null : recentTotal / beforeTotal - 1;
  double? get recentPerKm => recentKm < 100 ? null : recentTotal / recentKm;
  double? get beforePerKm => beforeKm < 100 ? null : beforeTotal / beforeKm;
}

/// Uses monthly periods so the two years line up with today.
CostTrend costTrend(List<CostPeriod> monthly, DateTime now) {
  final recentStart = DateTime(now.year - 1, now.month + 1);
  final beforeStart = DateTime(now.year - 2, now.month + 1);
  final recent = <CostCategory, double>{}, before = <CostCategory, double>{};
  var rk = 0.0, bk = 0.0;
  for (final p in monthly) {
    if (p.start.isBefore(beforeStart)) continue;
    final target = p.start.isBefore(recentStart) ? before : recent;
    p.cost.forEach((k, v) => target[k] = (target[k] ?? 0) + v);
    if (identical(target, recent)) {
      rk += p.km;
    } else {
      bk += p.km;
    }
  }
  return CostTrend(recent, before, rk, bk);
}

/// Least-squares slope of [ys] per step (e.g. dollars per year, year on
/// year). Null with fewer than three values.
double? slope(List<double> ys) {
  if (ys.length < 3) return null;
  final n = ys.length;
  final mx = (n - 1) / 2;
  final my = ys.reduce((a, b) => a + b) / n;
  var num = 0.0, den = 0.0;
  for (var i = 0; i < n; i++) {
    num += (i - mx) * (ys[i] - my);
    den += (i - mx) * (i - mx);
  }
  return num / den;
}
