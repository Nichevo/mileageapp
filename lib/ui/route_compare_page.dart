import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../domain/route_compare.dart';
import '../trips/route_compare_service.dart';
import 'format.dart';
import 'trip_detail_page.dart';
import 'trip_map.dart';

/// "12 min 30 s", or "1 h 05 min" for long ones.
String fmtMinSec(Duration d) {
  if (d.inHours > 0) return '${d.inHours} h ${(d.inMinutes % 60).toString().padLeft(2, '0')} min';
  final s = d.inSeconds % 60;
  return s == 0 ? '${d.inMinutes} min' : '${d.inMinutes} min $s s';
}

String ordinal(int n) {
  final s = (n % 100 >= 11 && n % 100 <= 13) ? 'th' : switch (n % 10) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' };
  return '$n$s';
}

enum CompareFactor { time, avgSpeed, movingSpeed, stops, redLights, maxSpeed }

extension on CompareFactor {
  String get label => switch (this) {
        CompareFactor.time => 'Time',
        CompareFactor.avgSpeed => 'Average speed',
        CompareFactor.movingSpeed => 'Moving average',
        CompareFactor.stops => 'Stops',
        CompareFactor.redLights => 'Red lights',
        CompareFactor.maxSpeed => 'Top speed',
      };
  bool get lowerIsBetter => this == CompareFactor.time || this == CompareFactor.stops || this == CompareFactor.redLights;
  double? value(RunStats r) => switch (this) {
        CompareFactor.time => r.time.inSeconds / 60,
        CompareFactor.avgSpeed => r.avgKmh,
        CompareFactor.movingSpeed => r.movingKmh,
        CompareFactor.stops => r.stops.toDouble(),
        CompareFactor.redLights => r.redLights?.toDouble(),
        CompareFactor.maxSpeed => r.maxKmh,
      };
  String format(double v) => switch (this) {
        CompareFactor.time => fmtMinSec(Duration(seconds: (v * 60).round())),
        CompareFactor.stops || CompareFactor.redLights => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1),
        _ => '${v.round()} km/h',
      };
}

/// One-line summary of how a trip did on a stretch, e.g. "This time 12 min,
/// 2nd quickest of 15 (usually 13 min 40 s)".
String stretchSummary(StretchResult s, String tripId) {
  final me = s.runOf(tripId);
  if (me == null) return '';
  final times = [for (final r in s.runs) r.time.inSeconds]..sort();
  final rank = times.indexOf(me.time.inSeconds) + 1;
  final usual = Duration(seconds: median(times));
  return 'This time ${fmtMinSec(me.time)}, ${ordinal(rank)} quickest of ${s.runs.length} (usually ${fmtMinSec(usual)})';
}

/// The same stretch of road driven on different days, compared.
class RouteComparePage extends StatefulWidget {
  final StretchResult stretch;
  final String? tripId; // the trip we came from, highlighted
  const RouteComparePage({super.key, required this.stretch, this.tripId});
  @override
  State<RouteComparePage> createState() => _RouteComparePageState();
}

class _RouteComparePageState extends State<RouteComparePage> {
  var _factor = CompareFactor.time;

  @override
  Widget build(BuildContext context) {
    final s = widget.stretch;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final hasLights = s.runs.any((r) => r.redLights != null);
    final hasWeather = s.runs.any((r) => r.weather != null);
    final runs = [for (final r in s.runs) if (_factor.value(r) != null) r];
    final values = [for (final r in runs) _factor.value(r)!];
    final groups = groupMedians(runs, (r) => _factor.value(r)!);
    final first = s.runs.first.at;
    double x(RunStats r) => r.at.difference(first).inHours / 24;
    final maxX = runs.isEmpty ? 1.0 : runs.map(x).reduce((a, b) => a > b ? a : b);
    final maxY = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    final ranked = [...runs]..sort((a, b) {
        final c = _factor.value(a)!.compareTo(_factor.value(b)!);
        return _factor.lowerIsBetter ? c : -c;
      });

    return Scaffold(
      appBar: AppBar(title: Text(s.name)),
      body: ListView(children: [
        SizedBox(height: 220, child: TripMap(route: [for (final p in s.path) LatLng(p.lat, p.lon)])),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Driven ${s.runs.length} times, ${fmtDate(first)} to ${fmtDate(s.runs.last.at)}', style: t.titleMedium),
            if (widget.tripId != null && s.runOf(widget.tripId!) != null) ...[
              const SizedBox(height: 4),
              Text(stretchSummary(s, widget.tripId!), style: t.bodyMedium),
            ],
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final f in CompareFactor.values)
                if (f != CompareFactor.redLights || hasLights)
                  ChoiceChip(label: Text(f.label), selected: _factor == f, onSelected: (_) => setState(() => _factor = f)),
            ]),
            const SizedBox(height: 16),
            if (runs.length >= 2)
              SizedBox(
                height: 220,
                child: ScatterChart(ScatterChartData(
                  minX: 0,
                  maxX: maxX <= 0 ? 1 : maxX * 1.05,
                  minY: 0,
                  maxY: maxY <= 0 ? 1 : maxY * 1.15,
                  scatterSpots: [
                    for (final r in runs)
                      ScatterSpot(
                        x(r),
                        _factor.value(r)!,
                        dotPainter: FlDotCirclePainter(
                          radius: r.tripId == widget.tripId ? 8 : 5,
                          color: r.tripId == widget.tripId ? cs.primary : (r.rainy ? Colors.blue.shade400 : cs.outline),
                        ),
                      ),
                  ],
                  gridData: const FlGridData(drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 56,
                        getTitlesWidget: (v, m) => v == m.max ? const SizedBox.shrink() : Text(_factor.format(v), style: t.labelSmall),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: maxX <= 0 ? 1 : (maxX / 3).ceilToDouble().clamp(1, double.infinity),
                        getTitlesWidget: (v, m) => v == m.max
                            ? const SizedBox.shrink()
                            : Text(fmtDateShort(first.add(Duration(hours: (v * 24).round()))), style: t.labelSmall),
                      ),
                    ),
                  ),
                  scatterTouchData: ScatterTouchData(
                    touchTooltipData: ScatterTouchTooltipData(
                      getTooltipColor: (_) => cs.inverseSurface,
                      getTooltipItems: (spot) {
                        final r = runs.firstWhere((r) => x(r) == spot.x && _factor.value(r) == spot.y, orElse: () => runs.first);
                        return ScatterTooltipItem('${_factor.format(spot.y)}\n${fmtDate(r.at)}', textStyle: TextStyle(color: cs.onInverseSurface));
                      },
                    ),
                  ),
                )),
              ),
            const SizedBox(height: 4),
            Text(
              [
                if (widget.tripId != null) 'Big dot: this trip.',
                if (hasWeather) 'Blue: rain.',
                'Usual: ${values.isEmpty ? '—' : _factor.format(median(values))}.',
              ].join(' '),
              style: t.bodySmall,
            ),
            if (groups.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('${_factor.label}, usually', style: t.titleSmall),
              const SizedBox(height: 4),
              for (final e in groups.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Expanded(child: Text(runGroupLabel(e.key), style: t.bodyMedium)),
                    Text(_factor.format(e.value), style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
            ],
            const SizedBox(height: 20),
            Text('Each time, best first', style: t.titleSmall),
          ]),
        ),
        for (final (i, r) in ranked.indexed)
          ListTile(
            selected: r.tripId == widget.tripId,
            leading: CircleAvatar(radius: 14, child: Text('${i + 1}', style: t.labelSmall)),
            title: Text('${fmtDate(r.at)}, ${TimeOfDay.fromDateTime(r.at).format(context)}${r.tripId == widget.tripId ? ' (this trip)' : ''}'),
            subtitle: Text([
              fmtMinSec(r.time),
              '${r.avgKmh.round()} km/h',
              '${r.stops} stop${r.stops == 1 ? '' : 's'}',
              if (r.redLights != null) '${r.redLights} red of ${r.lights}',
              if (r.weather != null) r.weather!.describe(),
            ].join(' · ')),
            trailing: Text(_factor.format(_factor.value(r)!), style: t.labelLarge),
            onTap: r.tripId == widget.tripId
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripDetailPage(tripId: r.tripId))),
          ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

/// Stretches you drive most, across all trips.
class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});
  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  Future<List<StretchResult>>? _future;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    _future ??= RouteCompare.common(scope.repo, scope.settings.activeVehicleId!, scope.settings.places);
    return Scaffold(
      appBar: AppBar(title: const Text('Routes you drive often')),
      body: FutureBuilder<List<StretchResult>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) return Padding(padding: const EdgeInsets.all(24), child: Text('Couldn\'t compare routes: ${snap.error}'));
          if (!snap.hasData) {
            return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Matching routes…')]));
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nothing yet. Once three or more trips share at least 2 km of the same road, driven the same way, it shows up here.'),
            );
          }
          return ListView(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('Stretches of road at least 2 km long that several trips share, even when the trips start or end elsewhere.', style: t.bodySmall),
            ),
            for (final s in list)
              ListTile(
                leading: const Icon(Icons.route_outlined),
                title: Text(s.name),
                subtitle: Text(() {
                  final times = [for (final r in s.runs) r.time.inSeconds]..sort();
                  return 'Driven ${s.runs.length} times · usually ${fmtMinSec(Duration(seconds: median(times)))} · best ${fmtMinSec(Duration(seconds: times.first))}';
                }()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RouteComparePage(stretch: s))),
              ),
          ]);
        },
      ),
    );
  }
}
