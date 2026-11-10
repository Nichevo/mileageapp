part of 'insights_page.dart';

/// "Driving over time": recorded trips per week, month or year, below the
/// fuel charts.
extension _Driving on _InsightsPageState {
  List<TripFacts> _factsOf(List<Trip> trips) {
    if (!identical(trips, _factsSrc)) {
      _factsSrc = trips;
      _facts = [
        for (final t in trips)
          if (t.status == 'done') ?TripFacts.fromJson(t.startAt, t.statsJson),
      ];
    }
    return _facts;
  }

  /// [vid] null: every vehicle.
  Widget _drivingSection(String? vid, DateTime? cutoff, String unit) {
    final scope = AppScope.of(context);
    return StreamBuilder<List<Trip>>(
      key: ValueKey(vid),
      stream: scope.repo.watchTrips(vid),
      builder: (context, snap) {
        final facts = _factsOf(snap.data ?? const []);
        final inRange = cutoff == null ? facts : facts.where((f) => !f.start.isBefore(cutoff)).toList();
        final t = Theme.of(context).textTheme;
        final cs = Theme.of(context).colorScheme;
        final heading = Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text('Driving over time', style: t.titleMedium),
        );
        if (inRange.isEmpty) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            heading,
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: Text('Recorded trips in this range will show here: speeds, road types, traffic lights and more.', style: t.bodySmall),
            ),
          ]);
        }
        final ps = drivingPeriods(facts, _period, from: cutoff, now: DateTime.now());
        List<_Bar> s(double? Function(DrivingPeriod) f) => [
              for (var i = 0; i < ps.length; i++) _Bar(_labelAt(ps[i].start), _fullLabel(ps[i].start), f(ps[i]) ?? 0),
            ];
        final labels = [for (final p in ps) _labelAt(p.start)];
        final tips = [for (final p in ps) _fullLabel(p.start)];
        final trips = ps.fold(0, (a, p) => a + p.trips);
        final km = ps.fold(0.0, (a, p) => a + p.km);
        final total = ps.fold(Duration.zero, (a, p) => a + p.total);
        final moving = ps.fold(Duration.zero, (a, p) => a + p.moving);
        final lights = ps.fold(0, (a, p) => a + p.lights);
        final red = ps.fold(0, (a, p) => a + p.red);
        final cycleRed = ps.fold(0, (a, p) => a + (p.cycleLights > 0 ? p.red : 0));
        final phases = ps.fold(0, (a, p) => a + p.phases);
        final multi = ps.fold(0, (a, p) => a + p.multi);
        final wait = ps.fold(Duration.zero, (a, p) => a + p.lightWait);
        final shortStops = ps.fold(0, (a, p) => a + p.shortStops);
        final harsh = ps.fold(0, (a, p) => a + p.harsh);
        final climb = ps.fold(0.0, (a, p) => a + p.climbM);
        final weather = ps.fold(0, (a, p) => a + p.weatherTrips);
        final rain = ps.fold(0, (a, p) => a + p.rainTrips);
        final temp = ps.fold(0.0, (a, p) => a + p.tempSum);
        final roadKm = <RoadClass, double>{};
        final bandKm = <SpeedBand, double>{};
        for (final p in ps) {
          p.roadKm.forEach((k, v) => roadKm[k] = (roadKm[k] ?? 0) + v);
          p.bandKm.forEach((k, v) => bandKm[k] = (bandKm[k] ?? 0) + v);
        }
        final roadTotal = roadKm.values.fold(0.0, (a, b) => a + b);
        final byHour = tripsByHour(inRange);
        final byLength = tripsByLength(inRange);
        final peakHour = byHour.indexOf(byHour.reduce(math.max));
        String pct(num a, num b) => b == 0 ? '—' : '${(a / b * 100).round()}%';
        final roadColors = {
          RoadClass.motorway: cs.secondary,
          RoadClass.main: cs.primary,
          RoadClass.suburban: cs.tertiary,
          RoadClass.local: Colors.orange.shade400,
          RoadClass.other: Colors.grey,
        };
        final bandColors = {SpeedBand.urban: cs.tertiary, SpeedBand.openRoad: cs.primary, SpeedBand.motorway: cs.secondary};
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          heading,
          _ChartCard(
            title: 'Trips per $unit',
            caption: '$trips recorded trips, ${fmtKm(km)} km, ${fmtKm1(trips == 0 ? 0 : km / trips)} km per trip on average',
            child: _bars(s((p) => p.trips.toDouble()), cs.primary, decimals: 0),
          ),
          _ChartCard(
            title: 'Time driving per $unit · hours',
            caption: '${fmtDuration(total)} in all, ${pct(moving.inSeconds, total.inSeconds)} of it moving',
            child: _bars(s((p) => p.total.inMinutes / 60), cs.primary, decimals: 1, fit: !_full),
          ),
          _ChartCard(
            title: 'Average speed per $unit · km/h',
            caption: 'Overall ${fmtKmh(total.inSeconds < 60 ? null : km / (total.inSeconds / 3600))}, '
                'moving ${fmtKmh(moving.inSeconds < 60 ? null : km / (moving.inSeconds / 3600))}. '
                'Moving speed leaves out time stopped.',
            child: _lines(labels, tips, [
              ('Overall', cs.primary, [for (final p in ps) p.avgKmh]),
              ('Moving', cs.tertiary, [for (final p in ps) p.movingKmh]),
            ]),
          ),
          if (roadTotal > 0)
            _ChartCard(
              title: 'Road types per $unit · share of km',
              caption: [
                for (final c in RoadClass.values)
                  if ((roadKm[c] ?? 0) > 0) '${roadLabel(c)} ${pct(roadKm[c]!, roadTotal)}',
              ].join(' · '),
              child: _stacked(labels, tips, [
                for (final c in RoadClass.values)
                  (roadLabel(c), roadColors[c]!, [for (final p in ps) p.roadTotal == 0 ? 0.0 : (p.roadKm[c] ?? 0) / p.roadTotal]),
              ]),
            ),
          if (bandKm.isNotEmpty)
            _ChartCard(
              title: 'Speed bands per $unit · share of km',
              caption: 'By the speed you were doing: urban under 60, open road 60–89, motorway 90+ km/h.',
              child: _stacked(labels, tips, [
                for (final b in SpeedBand.values)
                  (
                    bandLabel(b),
                    bandColors[b]!,
                    [
                      for (final p in ps)
                        () {
                          final tot = p.bandKm.values.fold(0.0, (a, v) => a + v);
                          return tot == 0 ? 0.0 : (p.bandKm[b] ?? 0) / tot;
                        }(),
                    ],
                  ),
              ]),
            ),
          if (lights > 0) ...[
            _ChartCard(
              title: 'Traffic lights caught red per $unit · %',
              caption: 'Red at $red of $lights lights (${pct(red, lights)}). '
                  'Tap Your traffic lights below for the worst ones.',
              child: _bars(s((p) => p.redShare == null ? null : p.redShare! * 100), Colors.red.shade400, decimals: 0),
            ),
            _ChartCard(
              title: 'Waiting at lights per $unit · minutes',
              caption: '${fmtDuration(wait)} waiting at lights'
                  '${red == 0 ? '' : ', ${fmtMinSec(Duration(seconds: wait.inSeconds ~/ red))} per red on average'}',
              child: _bars(s((p) => p.lightWait.inSeconds / 60), Colors.red.shade400, decimals: 1, fit: !_full),
            ),
            if (cycleRed > 0)
              _ChartCard(
                title: 'Red phases per stop at a light · per $unit',
                caption: '${(phases / cycleRed).toStringAsFixed(2)} phases per red stop; '
                    'missed the next green too $multi time${multi == 1 ? '' : 's'}. Estimated from creeping in the queue.',
                child: _bars(s((p) => p.phasesPerRed), Colors.red.shade400, decimals: 2),
              ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.traffic_outlined),
              label: const Text('Your traffic lights'),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LightsPage(vehicleId: vid))),
            ),
          ),
          _ChartCard(
            title: 'Short stops per 10 km · per $unit',
            caption: '$shortStops short stops (5 s to 2 min) in all: queues, give-ways and lights.',
            child: _bars(s((p) => p.stopsPer10km), cs.tertiary, decimals: 1),
          ),
          if (harsh > 0)
            _ChartCard(
              title: 'Harsh braking and acceleration · per 100 km',
              caption: '$harsh in all, ${(km == 0 ? 0 : harsh / km * 100).toStringAsFixed(1)} per 100 km',
              child: _bars(s((p) => p.km < 1 ? null : p.harsh / p.km * 100), cs.tertiary, decimals: 1),
            ),
          if (climb > 0)
            _ChartCard(
              title: 'Climbing per $unit · metres',
              caption: '${fmtKm(climb)} m climbed, ${(km == 0 ? 0 : climb / km).toStringAsFixed(1)} m per km',
              child: _bars(s((p) => p.climbM), cs.primary, decimals: 0, fit: !_full),
            ),
          if (weather > 0)
            _ChartCard(
              title: 'Trips in the rain per $unit · %',
              caption: '$rain of $weather trips with weather were wet (${pct(rain, weather)}); average ${(temp / weather).toStringAsFixed(1)} °C on the road.',
              child: _bars(s((p) => p.rainShare == null ? null : p.rainShare! * 100), Colors.blue.shade400, decimals: 0),
            ),
          _ChartCard(
            title: 'When you set off · trips by hour',
            caption: 'Busiest hour ${_hourLabel(peakHour)}, ${byHour[peakHour]} trips. '
                '${byHour.sublist(7, 10).fold(0, (a, b) => a + b) + byHour.sublist(16, 19).fold(0, (a, b) => a + b)} trips in the 7–10 am and 4–7 pm peaks.',
            child: _bars([for (var h = 0; h < 24; h++) _Bar(h % 3 == 0 ? '$h' : '', _hourLabel(h), byHour[h].toDouble())], cs.primary, decimals: 0),
          ),
          _ChartCard(
            title: 'Trip length · number of trips by km',
            caption: '${pct(byLength[0] + byLength[1], inRange.length)} of trips are under 5 km.',
            child: _bars([
              for (var i = 0; i < byLength.length; i++) _Bar(tripLengthLabels[i], '${tripLengthLabels[i]} km', byLength[i].toDouble()),
            ], cs.primary, decimals: 0),
          ),
        ]);
      },
    );
  }

  String _hourLabel(int h) => h == 0
      ? 'midnight'
      : h == 12
          ? 'noon'
          : h < 12
              ? '$h am'
              : '${h - 12} pm';

  /// Line chart, one line per series; gaps where a value is null.
  Widget _lines(List<String> labels, List<String> tips, List<(String, Color, List<double?>)> series) {
    final vals = [for (final s in series) ...s.$3.whereType<double>()];
    if (vals.isEmpty) return const Center(child: Text('No data yet'));
    final scale = ChartScale.of(vals.reduce(math.max));
    const labelStyle = TextStyle(fontSize: 10);
    final rotate = labels.any((l) => l.length > 3);
    final every = math.max(1, (labels.length / 14).ceil());
    return Column(children: [
      Expanded(
        child: LineChart(LineChartData(
          minY: 0,
          maxY: scale.top,
          minX: 0,
          maxX: math.max(1, labels.length - 1).toDouble(),
          gridData: FlGridData(drawVerticalLine: false, horizontalInterval: scale.step),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: scale.step,
                getTitlesWidget: (v, m) => Text(scale.label(v), style: labelStyle),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: rotate ? 46 : 20,
                getTitlesWidget: (v, m) {
                  final i = v.round();
                  if (i < 0 || i >= labels.length || (labels.length - 1 - i) % every != 0) return const SizedBox();
                  final text = Text(labels[i], style: labelStyle, maxLines: 1, softWrap: false);
                  return Padding(padding: const EdgeInsets.only(top: 4), child: rotate ? RotatedBox(quarterTurns: 3, child: text) : text);
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) => [
                for (final (k, sp) in spots.indexed)
                  LineTooltipItem(
                    '${k == 0 ? '${tips[sp.x.round()]}\n' : ''}${series[sp.barIndex].$1} ${sp.y.toStringAsFixed(1)}',
                    TextStyle(color: series[sp.barIndex].$2, fontSize: 12),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            for (final s in series)
              LineChartBarData(
                spots: [for (var i = 0; i < s.$3.length; i++) s.$3[i] == null ? FlSpot.nullSpot : FlSpot(i.toDouble(), s.$3[i]!)],
                color: s.$2,
                barWidth: 2.5,
                isCurved: false,
                dotData: FlDotData(show: labels.length <= 24),
              ),
          ],
        )),
      ),
      const SizedBox(height: 4),
      _legend([for (final s in series) (s.$1, s.$2)]),
    ]);
  }

  /// 100% stacked bars: each bar is a period, split by share.
  Widget _stacked(List<String> labels, List<String> tips, List<(String, Color, List<double>)> parts) {
    final shown = parts.where((p) => p.$3.any((v) => v > 0)).toList();
    const labelStyle = TextStyle(fontSize: 10);
    final rotate = labels.any((l) => l.length > 3);
    return Column(children: [
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          final minSlot = rotate ? 20.0 : 14.0;
          final room = box.maxWidth - 36;
          final width = math.max(room, labels.length * minSlot);
          final barW = (width / math.max(1, labels.length) * 0.6).clamp(2.0, 16.0);
          final chart = BarChart(BarChartData(
            minY: 0,
            maxY: 1,
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(drawVerticalLine: false, horizontalInterval: 0.25),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: rotate ? 46 : 20,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox();
                    final text = Text(labels[i], style: labelStyle, maxLines: 1, softWrap: false);
                    return Padding(padding: const EdgeInsets.only(top: 4), child: rotate ? RotatedBox(quarterTurns: 3, child: text) : text);
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                  [
                    tips[g.x],
                    for (final p in shown)
                      if (p.$3[g.x] > 0) '${p.$1} ${(p.$3[g.x] * 100).round()}%',
                  ].join('\n'),
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < labels.length; i++)
                () {
                  var y = 0.0;
                  final items = <BarChartRodStackItem>[];
                  for (final p in shown) {
                    final v = p.$3[i];
                    if (v <= 0) continue;
                    items.add(BarChartRodStackItem(y, y + v, p.$2));
                    y += v;
                  }
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: y, width: barW, rodStackItems: items, color: Colors.transparent, borderRadius: BorderRadius.zero),
                  ]);
                }(),
            ],
          ));
          return Row(children: [
            SizedBox(
              width: 36,
              child: Stack(children: [
                for (final v in const [0.0, 0.5, 1.0])
                  Positioned(
                    left: 0,
                    right: 4,
                    top: ((box.maxHeight - (rotate ? 46 : 20)) * (1 - v) - 7).clamp(0.0, box.maxHeight),
                    child: Text('${(v * 100).round()}%', style: labelStyle, textAlign: TextAlign.right),
                  ),
              ]),
            ),
            Expanded(
              child: width <= room
                  ? chart
                  : SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: SizedBox(width: width, height: box.maxHeight, child: chart)),
            ),
          ]);
        }),
      ),
      const SizedBox(height: 4),
      _legend([for (final p in shown) (p.$1, p.$2)]),
    ]);
  }

  Widget _legend(List<(String, Color)> items) => Wrap(spacing: 12, runSpacing: 2, children: [
        for (final (name, c) in items)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Text(name, style: const TextStyle(fontSize: 11)),
          ]),
      ]);
}
