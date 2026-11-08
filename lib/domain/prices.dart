/// Fuel price comparisons against MBIE's weekly national average pump
/// prices, plus which of your own stations tend to be cheaper. Pure
/// functions, tested directly; downloading lives in lib/prices/.
library;

import 'package:csv/csv.dart';

const mbieRegular = 'Regular Petrol';
const mbiePremium = 'Premium Petrol 95R';
const mbieDiesel = 'Diesel';

/// The MBIE series to compare a fill-up's fuel against.
String mbieFuelFor(String? fuelType) => switch (fuelType) {
      '95' || '98' => mbiePremium,
      'diesel' => mbieDiesel,
      _ => mbieRegular,
    };

String mbieFuelLabel(String fuel) => switch (fuel) {
      mbiePremium => 'Premium 95',
      mbieDiesel => 'Diesel',
      _ => '91',
    };

class WeekPrice {
  final DateTime week;
  final double centsPerL;
  const WeekPrice(this.week, this.centsPerL);
}

DateTime? _parseDate(String s) {
  s = s.trim();
  final iso = DateTime.tryParse(s);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);
  final m = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$').firstMatch(s);
  if (m == null) return null;
  var y = int.parse(m[3]!);
  if (y < 100) y += 2000;
  return DateTime(y, int.parse(m[2]!), int.parse(m[1]!));
}

/// MBIE weekly fuel price monitoring: national average board (pump) price
/// per fuel, by week.
class NationalPrices {
  final Map<String, List<WeekPrice>> byFuel;
  const NationalPrices(this.byFuel);

  /// Parses MBIE's weekly-table.csv (columns Week, Date, Variable, Fuel,
  /// Value, Unit, Status; prices in cents per litre). Only the "Board
  /// price" rows are kept. Columns are found by name so a reordering
  /// doesn't break it.
  static NationalPrices parseMbie(String csv) {
    final rows = const CsvToListConverter(shouldParseNumbers: false, eol: '\n').convert(csv.replaceAll('\r\n', '\n'));
    if (rows.isEmpty) return const NationalPrices({});
    final head = [for (final h in rows.first) h.toString().trim().toLowerCase()];
    final iDate = head.indexOf('date'), iVar = head.indexOf('variable'), iFuel = head.indexOf('fuel'), iVal = head.indexOf('value');
    if ([iDate, iVar, iFuel, iVal].any((i) => i < 0)) return const NationalPrices({});
    final out = <String, Map<DateTime, double>>{};
    for (final r in rows.skip(1)) {
      if (r.length <= [iDate, iVar, iFuel, iVal].reduce((a, b) => a > b ? a : b)) continue;
      if (r[iVar].toString().trim().toLowerCase() != 'board price') continue;
      final fuel = r[iFuel].toString().trim();
      final date = _parseDate(r[iDate].toString());
      var v = double.tryParse(r[iVal].toString().trim());
      if (fuel.isEmpty || date == null || v == null || v <= 0) continue;
      if (v < 20) v *= 100; // dollars, not cents
      (out[fuel] ??= {})[date] = v;
    }
    return NationalPrices({
      for (final e in out.entries) e.key: [for (final w in e.value.entries) WeekPrice(w.key, w.value)]..sort((a, b) => a.week.compareTo(b.week)),
    });
  }

  bool get isEmpty => byFuel.values.every((l) => l.isEmpty);

  /// The national average for the week containing [at], in cents per litre.
  /// Uses the nearest week within 10 days; null outside the data.
  double? centsAt(String fuel, DateTime at) {
    final list = byFuel[fuel];
    if (list == null || list.isEmpty) return null;
    WeekPrice? best;
    var bestD = 11;
    for (final w in list) {
      final d = w.week.difference(at).inDays.abs();
      if (d < bestD) {
        bestD = d;
        best = w;
      }
    }
    return best?.centsPerL;
  }

  WeekPrice? latest(String fuel) => byFuel[fuel]?.lastOrNull;

  /// Change from the week before the latest, in cents.
  double? latestChange(String fuel) {
    final l = byFuel[fuel];
    if (l == null || l.length < 2) return null;
    return l.last.centsPerL - l[l.length - 2].centsPerL;
  }
}

/// A fill-up's price set against the national average for that week.
class PricedFill {
  final DateTime at;
  final String? station;
  final double litres;
  final double paidCents; // per litre
  final double nationalCents;
  const PricedFill({required this.at, required this.station, required this.litres, required this.paidCents, required this.nationalCents});
  double get diffCents => paidCents - nationalCents;
  /// Dollars more (positive) or less than paying the national average.
  double get diffDollars => diffCents * litres / 100;
}

typedef FillInput = ({DateTime at, double litres, double cost, String? station, String? fuelType});

/// Fill-ups with a national price to compare against, oldest first. Fills
/// with no cost recorded or an implausible price are left out.
List<PricedFill> priceFills(List<FillInput> fills, NationalPrices national) {
  final out = <PricedFill>[];
  for (final f in fills) {
    if (f.litres <= 0 || f.cost <= 0) continue;
    final paid = f.cost / f.litres * 100;
    if (paid < 50 || paid > 1000) continue;
    final nat = national.centsAt(mbieFuelFor(f.fuelType), f.at);
    if (nat == null) continue;
    out.add(PricedFill(at: f.at, station: f.station, litres: f.litres, paidCents: paid, nationalCents: nat));
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out;
}

class StationPrice {
  final String name;
  final int fills;
  final double avgDiffCents;
  final DateTime lastAt;
  const StationPrice(this.name, this.fills, this.avgDiffCents, this.lastAt);
}

/// Your stations ranked by how far under the national average they were,
/// cheapest first. Comparing against the national figure for the same week
/// means fills from different years can be ranked fairly.
List<StationPrice> rankStations(List<PricedFill> fills, {int minFills = 2}) {
  final groups = <String, List<PricedFill>>{};
  for (final f in fills) {
    final name = f.station?.trim();
    if (name == null || name.isEmpty) continue;
    (groups[name.toLowerCase()] ??= []).add(f);
  }
  final out = [
    for (final g in groups.values)
      if (g.length >= minFills)
        StationPrice(g.last.station!.trim(), g.length, g.map((f) => f.diffCents).reduce((a, b) => a + b) / g.length,
            g.map((f) => f.at).reduce((a, b) => a.isAfter(b) ? a : b)),
  ]..sort((a, b) => a.avgDiffCents.compareTo(b.avgDiffCents));
  return out;
}

/// Dollars saved (positive) compared with paying the national average.
double savedDollars(Iterable<PricedFill> fills) => -fills.fold(0.0, (a, f) => a + f.diffDollars);

/// "6c under the national average" / "3c over" / "about average".
String diffText(double diffCents) {
  final c = diffCents.abs().round();
  if (c == 0) return 'about the national average';
  return '${c}c ${diffCents < 0 ? 'under' : 'over'} the national average';
}
