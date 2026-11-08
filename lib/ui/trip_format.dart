import '../domain/trip_stats.dart';

String fmtDuration(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60;
  if (h == 0) return '$m min';
  return '$h h ${m.toString().padLeft(2, '0')} min';
}

String fmtKmh(double? v) => v == null ? '—' : '${v.toStringAsFixed(0)} km/h';

/// Percentages of distance in each speed band, for the split bar.
Map<SpeedBand, double> bandShares(Map<SpeedBand, double> km) {
  final total = km.values.fold<double>(0, (a, b) => a + b);
  if (total <= 0) return const {};
  return {for (final b in SpeedBand.values) b: (km[b] ?? 0) / total};
}
