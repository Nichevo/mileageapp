/// Sorting, filtering and merge suggestions for the trips list.
library;

import 'trip_stats.dart' show haversineKm;

enum TripSort { newest, oldest, longest, longestTime, fastest }

String tripSortLabel(TripSort s) => switch (s) {
      TripSort.newest => 'Newest',
      TripSort.oldest => 'Oldest',
      TripSort.longest => 'Longest distance',
      TripSort.longestTime => 'Longest time',
      TripSort.fastest => 'Fastest average',
    };

enum TripPeriod { all, week, month, months3, year }

String tripPeriodLabel(TripPeriod p) => switch (p) {
      TripPeriod.all => 'Any time',
      TripPeriod.week => 'Last 7 days',
      TripPeriod.month => 'Last 30 days',
      TripPeriod.months3 => 'Last 3 months',
      TripPeriod.year => 'This year',
    };

enum TripSize { any, short, medium, long }

String tripSizeLabel(TripSize s) => switch (s) {
      TripSize.any => 'Any length',
      TripSize.short => 'Under 5 km',
      TripSize.medium => '5 to 50 km',
      TripSize.long => 'Over 50 km',
    };

/// What the list needs to know about a trip.
class TripRow {
  final String id;
  final DateTime start;
  final DateTime? end;
  final double? km;
  final Duration? duration;
  final double? avgKmh;
  final ({double lat, double lon})? from, to;
  const TripRow({required this.id, required this.start, this.end, this.km, this.duration, this.avgKmh, this.from, this.to});
}

bool _inPeriod(DateTime t, TripPeriod p, DateTime now) => switch (p) {
      TripPeriod.all => true,
      TripPeriod.week => t.isAfter(now.subtract(const Duration(days: 7))),
      TripPeriod.month => t.isAfter(now.subtract(const Duration(days: 30))),
      TripPeriod.months3 => t.isAfter(now.subtract(const Duration(days: 91))),
      TripPeriod.year => t.year == now.year,
    };

bool _inSize(double? km, TripSize s) => switch (s) {
      TripSize.any => true,
      TripSize.short => km != null && km < 5,
      TripSize.medium => km != null && km >= 5 && km <= 50,
      TripSize.long => km != null && km > 50,
    };

List<TripRow> filterTrips(List<TripRow> rows, {TripSort sort = TripSort.newest, TripPeriod period = TripPeriod.all, TripSize size = TripSize.any, required DateTime now}) {
  final out = rows.where((r) => _inPeriod(r.start, period, now) && _inSize(r.km, size)).toList();
  int byNum(double? a, double? b) => (b ?? -1).compareTo(a ?? -1); // biggest first, unknown last
  out.sort(switch (sort) {
    TripSort.newest => (a, b) => b.start.compareTo(a.start),
    TripSort.oldest => (a, b) => a.start.compareTo(b.start),
    TripSort.longest => (a, b) => byNum(a.km, b.km),
    TripSort.longestTime => (a, b) => byNum(a.duration?.inSeconds.toDouble(), b.duration?.inSeconds.toDouble()),
    TripSort.fastest => (a, b) => byNum(a.avgKmh, b.avgKmh),
  });
  return out;
}

/// Trips probably split from one journey: the next one starts within [gap]
/// of the previous ending, close to where it ended. Returns pairs of ids
/// (earlier, later).
List<(String, String)> mergeSuggestions(List<TripRow> rows, {Duration gap = const Duration(minutes: 30), double withinKm = 0.5}) {
  final sorted = rows.where((r) => r.end != null).toList()..sort((a, b) => a.start.compareTo(b.start));
  final out = <(String, String)>[];
  for (var i = 1; i < sorted.length; i++) {
    final a = sorted[i - 1], b = sorted[i];
    final wait = b.start.difference(a.end!);
    if (wait.isNegative || wait > gap) continue;
    if (a.to != null && b.from != null && haversineKm(a.to!.lat, a.to!.lon, b.from!.lat, b.from!.lon) > withinKm) continue;
    out.add((a.id, b.id));
  }
  return out;
}
