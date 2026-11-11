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
  var _byHour = false;

  static String _clock(BuildContext context, int minute) => TimeOfDay(hour: minute ~/ 60 % 24, minute: minute % 60).format(context);

  /// Half-hour slots for weekdays and weekends, with the quickest weekday slot.
  List<Widget> _slotTable(BuildContext context, List<RunStats> runs) {
    final t = Theme.of(context).textTheme;
    final out = <Widget>[];
    for (final weekend in [false, true]) {
      final slots = timeSlots(runs, weekend: weekend);
      if (slots.isEmpty) continue;
      double usual(TimeSlot s) => median([for (final r in s.runs) _factor.value(r)!]);
      final multi = [for (final s in slots) if (s.runs.length >= 2) s];
      TimeSlot? best;
      if (multi.length >= 2) {
        best = multi.reduce((a, b) => (_factor.lowerIsBetter ? usual(a) <= usual(b) : usual(a) >= usual(b)) ? a : b);
      }
      out.add(Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4),
        child: Text(weekend ? 'Weekends, by time you reached it' : 'Weekdays, by time you reached it', style: t.titleSmall),
      ));
      if (best != null) {
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text('Best ${_factor.label.toLowerCase()}: ${_clock(context, best.minute)} to ${_clock(context, best.minute + 30)} (usually ${_factor.format(usual(best))})',
              style: t.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ));
      }
      for (final sl in slots) {
        out.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Expanded(child: Text('${_clock(context, sl.minute)} to ${_clock(context, sl.minute + 30)}', style: t.bodyMedium)),
            Text('${sl.runs.length} run${sl.runs.length == 1 ? '' : 's'}   ', style: t.bodySmall),
            SizedBox(
              width: 96,
              child: Text(_factor.format(usual(sl)),
                  textAlign: TextAlign.end, style: t.bodyMedium?.copyWith(fontWeight: sl == best ? FontWeight.w700 : FontWeight.w500)),
            ),
          ]),
        ));
      }
    }
    if (out.isNotEmpty) {
      out.add(Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text('Half-hour slots. With one run in a slot it\'s just that run; with more it\'s the usual (middle) figure.', style: t.bodySmall),
      ));
    }
    return out;
  }

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
    double hourOf(RunStats r) {
      final l = r.at.toLocal();
      return l.hour + l.minute / 60;
    }

    double x(RunStats r) => _byHour ? hourOf(r) : r.at.difference(first).inHours / 24;
    final minX = !_byHour || runs.isEmpty ? 0.0 : (runs.map(hourOf).reduce((a, b) => a < b ? a : b) - 0.5).floorToDouble().clamp(0.0, 24.0);
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
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('By date'), icon: Icon(Icons.calendar_month_outlined)),
                ButtonSegment(value: true, label: Text('By time of day'), icon: Icon(Icons.schedule)),
              ],
              selected: {_byHour},
              onSelectionChanged: (v) => setState(() => _byHour = v.first),
            ),
            const SizedBox(height: 16),
            if (runs.length >= 2)
              SizedBox(
                height: 220,
                child: ScatterChart(ScatterChartData(
                  minX: minX,
                  maxX: _byHour ? (maxX + 0.5).ceilToDouble().clamp(minX + 1, 24.0) : (maxX <= 0 ? 1 : maxX * 1.05),
                  minY: 0,
                  maxY: maxY <= 0 ? 1 : maxY * 1.15,
                  scatterSpots: [
                    for (final r in runs)
                      ScatterSpot(
                        x(r),
                        _factor.value(r)!,
                        dotPainter: FlDotCirclePainter(
                          radius: r.tripId == widget.tripId ? 8 : 5,
                          color: r.tripId == widget.tripId
                              ? cs.primary
                              : (r.rainy ? Colors.blue.shade400 : (_byHour && r.at.toLocal().weekday >= DateTime.saturday ? Colors.orange.shade400 : cs.outline)),
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
                        interval: _byHour ? (maxX - minX > 8 ? 3 : (maxX - minX > 4 ? 2 : 1)) : (maxX <= 0 ? 1 : (maxX / 3).ceilToDouble().clamp(1, double.infinity)),
                        getTitlesWidget: (v, m) => v == m.max && !_byHour
                            ? const SizedBox.shrink()
                            : Text(_byHour ? _clock(context, (v * 60).round()) : fmtDateShort(first.add(Duration(hours: (v * 24).round()))), style: t.labelSmall),
                      ),
                    ),
                  ),
                  scatterTouchData: ScatterTouchData(
                    touchTooltipData: ScatterTouchTooltipData(
                      getTooltipColor: (_) => cs.inverseSurface,
                      getTooltipItems: (spot) {
                        final r = runs.firstWhere((r) => x(r) == spot.x && _factor.value(r) == spot.y, orElse: () => runs.first);
                        return ScatterTooltipItem('${_factor.format(spot.y)}\n${fmtDate(r.at)} ${TimeOfDay.fromDateTime(r.at.toLocal()).format(context)}',
                            textStyle: TextStyle(color: cs.onInverseSurface));
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
                if (_byHour) 'Orange: weekend.',
                'Usual: ${values.isEmpty ? '—' : _factor.format(median(values))}.',
              ].join(' '),
              style: t.bodySmall,
            ),
            if (_byHour) ..._slotTable(context, runs),
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
