import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/energy.dart';
import '../domain/stats.dart';
import 'format.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});
  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int _rangeMonths = 12; // 0 = all
  Period _period = Period.month;
  bool _full = false; // show unusually big periods at full height
  String? _energyKind; // plug-in hybrids can switch between fuel and charging

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: StreamBuilder<List<Vehicle>>(
        stream: scope.repo.watchVehicles(),
        builder: (context, vs) {
          final kind = vs.data?.where((v) => v.id == vid).firstOrNull?.kind ?? 'petrol';
          final energy = _energyKind == 'charge'
              ? Energy.charge
              : _energyKind == 'fuel'
              ? Energy.fuel
              : Energy.primaryFor(kind);
          final both = usesFuel(kind) && usesCharging(kind);
          return StreamBuilder<List<EnergyEvent>>(
            stream: scope.repo.watchEvents(vid, kind: null),
            builder: (context, snap) {
              final all = (snap.data ?? const <EnergyEvent>[]).where((e) => e.kind == energy.eventKind).toList();
              final now = DateTime.now();
              final cutoff = _rangeMonths == 0 ? null : DateTime(now.year, now.month - _rangeMonths + 1, 1);
              final allRows = Repository.toFuelRows(all, kind: energy.eventKind);
              final rows = cutoff == null ? allRows : allRows.where((r) => !r.at.isBefore(cutoff)).toList();
              final stats = tankStats(rows);
              final cs = Theme.of(context).colorScheme;
              if (all.length < 2) {
                return Column(
                  children: [
                    if (both) _energySwitch(energy),
                    Expanded(child: Center(child: Text('Charts appear after a couple of ${energy.nounPlural}'))),
                  ],
                );
              }
              // Spreading uses every fill, so the first period in range is complete.
              final periods = periodTotals(allRows, _period, from: cutoff);
              final totalKm = periods.fold<double>(0, (a, t) => a + t.km);
              final totalCost = periods.fold<double>(0, (a, t) => a + t.cost);
              final byMonth = _kmPerDayByMonth(rows);
              final byDow = _fillsByWeekday(rows);
              final unit = switch (_period) {
                Period.week => 'week',
                Period.month => 'month',
                Period.year => 'year',
              };
              List<_Bar> series(double? Function(PeriodTotals) f) => [
                for (var i = 0; i < periods.length; i++) _Bar(_axisLabel(periods, i), _fullLabel(periods[i].start), f(periods[i]) ?? 0),
              ];
              final busiest = periods.isEmpty ? null : periods.reduce((a, b) => a.km >= b.km ? a : b);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  if (both) _energySwitch(energy),
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 6, label: Text('6 mo')),
                      ButtonSegment(value: 12, label: Text('1 yr')),
                      ButtonSegment(value: 36, label: Text('3 yr')),
                      ButtonSegment(value: 0, label: Text('All')),
                    ],
                    selected: {_rangeMonths},
                    onSelectionChanged: (s) => setState(() {
                      _rangeMonths = s.first;
                      // Keep a sensible number of bars for the range.
                      if (_rangeMonths == 0 && _period == Period.week) _period = Period.month;
                      if (_rangeMonths == 6 && _period == Period.year) _period = Period.month;
                    }),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<Period>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: Period.week, label: Text('Weekly')),
                      ButtonSegment(value: Period.month, label: Text('Monthly')),
                      ButtonSegment(value: Period.year, label: Text('Yearly')),
                    ],
                    selected: {_period},
                    onSelectionChanged: (s) => setState(() => _period = s.first),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilterChip(
                      label: const Text('Show long trips in full'),
                      selected: _full,
                      onSelected: (v) => setState(() => _full = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChartCard(
                    title: 'Distance per $unit · km',
                    caption:
                        '${fmtKm(totalKm)} km in this range'
                        '${busiest == null || busiest.km == 0 ? '' : ', most in ${_fullLabel(busiest.start)} (${fmtKm(busiest.km)} km)'}. '
                        'Distance between two ${energy.nounPlural} is spread evenly over the days between them.'
                        '${_full ? '' : ' Bars with a break at the top are off the scale; tap one for its value.'}',
                    child: _bars(series((t) => t.km), cs.primary, fit: !_full),
                  ),
                  _ChartCard(
                    title: '${energy.isCharge ? 'Charging' : 'Fuel'} spend per $unit · \$',
                    caption: '${fmtMoney0(totalCost)} in this range',
                    child: _bars(series((t) => t.cost), cs.tertiary, fit: !_full),
                  ),
                  _ChartCard(
                    title: 'Cost per 100 km · \$ per $unit',
                    caption: totalKm > 0 ? 'Average \$${(totalCost / totalKm * 100).toStringAsFixed(2)} per 100 km over the range' : '',
                    child: _bars(series((t) => t.costPer100), cs.tertiary, fit: !_full),
                  ),
                  _ChartCard(
                    title: 'Price per ${energy.isCharge ? 'kWh' : 'litre'} · \$ per $unit',
                    caption: 'Average of the ${energy.nounPlural} made in each $unit. Empty bars had no ${energy.noun}.',
                    child: _bars(series((t) => t.pricePerUnit), cs.tertiary, decimals: 2, fit: !_full),
                  ),
                  _ChartCard(
                    title: '${energy.isCharge ? 'Energy use' : 'Fuel economy'} · ${energy.per100}, rolling 5 ${energy.nounPlural}',
                    caption: 'Dashed line is the rolling average; dots are single ${energy.isCharge ? 'charges' : 'tanks'}',
                    child: _economy(stats, cs.primary),
                  ),
                  _ChartCard(
                    title: 'Driving by month of year · average km per day',
                    caption: _busiestMonths(byMonth),
                    child: _bars([
                      for (var m = 1; m <= 12; m++)
                        _Bar('JFMAMJJASOND'[m - 1], DateFormat('MMMM').format(DateTime(2000, m)), byMonth[m] ?? 0),
                    ], cs.primary),
                  ),
                  _ChartCard(
                    title: '${energy.nounPluralCap} by weekday',
                    caption:
                        '${byDow.sublist(0, 5).fold(0, (a, b) => a + b)} weekday · ${byDow[5] + byDow[6]} weekend. Weekday vs weekend driving comes from recorded trips.',
                    child: _bars(
                      [
                        for (var d = 0; d < 7; d++)
                          _Bar('MTWTFSS'[d], DateFormat('EEEE').format(DateTime(2024, 1, d + 1)), byDow[d].toDouble()),
                      ],
                      cs.primary,
                      decimals: 0,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _energySwitch(Energy energy) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SegmentedButton<String>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: 'fuel', label: Text('Fuel'), icon: Icon(Icons.local_gas_station)),
        ButtonSegment(value: 'charge', label: Text('Charging'), icon: Icon(Icons.ev_station)),
      ],
      selected: {energy.eventKind},
      onSelectionChanged: (s) => setState(() => _energyKind = s.first),
    ),
  );

  /// Label under every bar: 3-Nov, Nov-26, 2026.
  String _axisLabel(List<PeriodTotals> ps, int i) {
    final d = ps[i].start;
    return switch (_period) {
      Period.week => DateFormat('d-MMM').format(d),
      Period.month => DateFormat('MMM-yy').format(d),
      Period.year => '${d.year}',
    };
  }

  String _fullLabel(DateTime d) => switch (_period) {
    Period.week => 'week of ${DateFormat('d MMM yyyy').format(d)}',
    Period.month => DateFormat('MMM yyyy').format(d),
    Period.year => '${d.year}',
  };

  /// Bar chart with a fixed value scale on the left and every bar labelled.
  /// When the bars don't fit, the chart scrolls sideways (newest showing).
  /// With [fit], the scale is set by typical periods: a bar far above them
  /// (a long road trip) is cut off at the top with a break mark, and its
  /// real value shows when tapped.
  Widget _bars(List<_Bar> data, Color color, {int? decimals, bool fit = false}) {
    if (data.isEmpty) return const SizedBox();
    final values = [for (final d in data) d.value];
    final cap = fit ? ChartScale.typicalCap(values) : null;
    final double maxV = cap ?? values.fold<double>(0, math.max);
    final scale = ChartScale.of(maxV);
    final surface = Theme.of(context).colorScheme.surfaceContainerLow;
    final rotate = data.any((d) => d.label.length > 3);
    final bottomH = rotate ? 46.0 : 20.0;
    const axisW = 44.0;
    const labelStyle = TextStyle(fontSize: 10);
    return LayoutBuilder(
      builder: (context, box) {
        final plotH = box.maxHeight - bottomH;
        // The same scale on both sides, so long or scrolled charts are easy to read.
        Widget axis({required bool left}) => SizedBox(
          width: axisW,
          height: box.maxHeight,
          child: Stack(
            children: [
              for (final (v, pos) in scale.ticks)
                Positioned(
                  left: left ? 0 : 6,
                  right: left ? 6 : 0,
                  top: (plotH * (1 - pos / scale.top) - 7).clamp(0.0, plotH),
                  child: Text(scale.label(v), style: labelStyle, textAlign: left ? TextAlign.right : TextAlign.left),
                ),
            ],
          ),
        );
        final minSlot = rotate ? 20.0 : 14.0;
        final room = box.maxWidth - axisW * 2;
        final width = math.max(room, data.length * minSlot);
        final barW = (width / data.length * 0.6).clamp(2.0, 16.0);
        final chart = BarChart(
          BarChartData(
            minY: 0,
            maxY: scale.top,
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              checkToShowHorizontalLine: (y) => scale.ticks.any((t) => (t.$2 - y).abs() < 1e-6),
              horizontalInterval: scale.top / 200,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: bottomH,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= data.length || data[i].label.isEmpty) return const SizedBox();
                    final text = Text(data[i].label, style: labelStyle, maxLines: 1, softWrap: false);
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: rotate ? RotatedBox(quarterTurns: 3, child: text) : text,
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                  '${data[g.x].tooltip}\n${_fmt(data[g.x].value, decimals)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < data.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    if (data[i].value > scale.top)
                      // Off the scale: full height with a break near the top.
                      BarChartRodData(
                        toY: scale.top,
                        color: color,
                        width: barW,
                        borderRadius: BorderRadius.circular(barW > 6 ? 3 : 1),
                        rodStackItems: [
                          BarChartRodStackItem(0, scale.top * 0.86, color),
                          BarChartRodStackItem(scale.top * 0.86, scale.top * 0.9, surface),
                          BarChartRodStackItem(scale.top * 0.9, scale.top, color),
                        ],
                      )
                    else
                      BarChartRodData(
                        toY: scale.pos(data[i].value),
                        color: color,
                        width: barW,
                        borderRadius: BorderRadius.circular(barW > 6 ? 3 : 1),
                      ),
                  ],
                ),
            ],
          ),
        );
        return Row(
          children: [
            axis(left: true),
            Expanded(
              child: width <= room
                  ? chart
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: SizedBox(width: width, height: box.maxHeight, child: chart),
                    ),
            ),
            axis(left: false),
          ],
        );
      },
    );
  }

  String _fmt(double v, [int? decimals]) =>
      decimals != null ? v.toStringAsFixed(decimals) : (v >= 100 ? fmtKm(v) : v.toStringAsFixed(v >= 10 ? 1 : 2));

  Widget _economy(List<TankStat> stats, Color color) {
    final dots = <FlSpot>[];
    final roll = rollingPer100(stats);
    final line = <FlSpot>[];
    for (var i = 0; i < stats.length; i++) {
      final v = stats[i].litresPer100;
      if (v != null) dots.add(FlSpot(i.toDouble(), v));
      if (roll[i] != null) line.add(FlSpot(i.toDouble(), roll[i]!));
    }
    if (dots.length < 2) return const Center(child: Text('Need two full fills'));
    final ys = dots.map((d) => d.y);
    final lo = ys.reduce(math.min), hi = ys.reduce(math.max);
    final step = ChartScale.niceStep(math.max(hi - lo, 1) / 4);
    final minY = (lo / step).floor() * step, maxY = (hi / step).ceil() * step;
    const style = TextStyle(fontSize: 10);
    final sideY = SideTitles(
      showTitles: true,
      reservedSize: 34,
      interval: step,
      getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(step < 1 ? 1 : 0), style: style),
    );
    // Dates under about five evenly spaced tanks.
    final every = math.max(1, (stats.length / 5).ceil());
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY == minY ? minY + step : maxY,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: step),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          leftTitles: AxisTitles(sideTitles: sideY),
          rightTitles: AxisTitles(sideTitles: sideY),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.round();
                if (i != v || i < 0 || i >= stats.length || i % every != 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(DateFormat('MMM-yy').format(stats[i].fill.at), style: style),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(spots: dots, color: color.withValues(alpha: 0.35), barWidth: 0, dotData: const FlDotData(show: true)),
          LineChartBarData(spots: line, color: color, barWidth: 2.5, dashArray: [6, 4], dotData: const FlDotData(show: false)),
        ],
      ),
    );
  }

  Map<int, double> _kmPerDayByMonth(List<FuelRow> rows) {
    final sorted = [...rows]..sort((a, b) => a.odometerKm.compareTo(b.odometerKm));
    final sums = <int, List<double>>{};
    for (var i = 1; i < sorted.length; i++) {
      final days = sorted[i].at.difference(sorted[i - 1].at).inDays;
      if (days <= 0) continue;
      final km = sorted[i].odometerKm - sorted[i - 1].odometerKm;
      sums.putIfAbsent(sorted[i].at.month, () => []).add(km / days);
    }
    return {for (final e in sums.entries) e.key: e.value.reduce((a, b) => a + b) / e.value.length};
  }

  List<int> _fillsByWeekday(List<FuelRow> rows) {
    final out = List.filled(7, 0);
    for (final r in rows) {
      out[r.at.weekday - 1]++;
    }
    return out;
  }

  String _busiestMonths(Map<int, double> byMonth) {
    if (byMonth.isEmpty) return '';
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final sorted = byMonth.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return 'Busiest ${names[sorted.first.key - 1]} (${sorted.first.value.toStringAsFixed(0)} km/day), quietest ${names[sorted.last.key - 1]} (${sorted.last.value.toStringAsFixed(0)} km/day)';
  }
}

class _Bar {
  final String label, tooltip;
  final double value;
  const _Bar(this.label, this.tooltip, this.value);
}

class _ChartCard extends StatelessWidget {
  final String title, caption;
  final Widget child;
  const _ChartCard({required this.title, required this.caption, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: t.labelSmall),
            const SizedBox(height: 8),
            SizedBox(height: 190, child: child),
            if (caption.isNotEmpty) ...[const SizedBox(height: 6), Text(caption, style: t.bodySmall)],
          ],
        ),
      ),
    );
  }
}

/// Value axis for the bar charts: round-number ticks, linear or log.
class ChartScale {
  final bool log;
  final double top; // in plotted units
  final double step; // linear tick step (1 decade for log)
  final List<(double value, double pos)> ticks;
  const ChartScale._(this.log, this.top, this.step, this.ticks);

  String label(double v) {
    if (log) return v >= 1000 ? '${(v / 1000).round()}k' : v.toStringAsFixed(0);
    if (step < 1) return v.toStringAsFixed((step * 10).roundToDouble() == step * 10 ? 1 : 2);
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    return NumberFormat.decimalPattern('en_NZ').format(v.round());
  }

  double pos(double v) => log ? math.log(math.max(v, 0) + 1) / math.ln10 : v;

  static double niceStep(double rough) {
    if (rough <= 0) return 1;
    final mag = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final f = rough / mag;
    final nice = f <= 1
        ? 1
        : f <= 2
        ? 2
        : f <= 2.5
        ? 2.5
        : f <= 5
        ? 5
        : 10;
    return nice * mag;
  }

  /// A scale top that fits typical values: 2.5 times the median of the
  /// non-zero values. Null when nothing stands out (or too few values).
  static double? typicalCap(List<double> values) {
    final v = values.where((x) => x > 0).toList()..sort();
    if (v.length < 4) return null;
    final mid = v.length ~/ 2;
    final median = v.length.isOdd ? v[mid] : (v[mid - 1] + v[mid]) / 2;
    final cap = median * 2.5;
    return v.last > cap * 1.15 ? cap : null;
  }

  factory ChartScale.of(double maxV, {bool log = false}) {
    if (log) {
      final decades = math.max(1, (math.log(math.max(maxV, 0) + 1) / math.ln10).ceil());
      return ChartScale._(true, decades.toDouble(), 1, [
        (0, 0),
        for (var k = 1; k <= decades; k++) (math.pow(10, k).toDouble(), math.log(math.pow(10, k) + 1) / math.ln10),
      ]);
    }
    final step = niceStep(maxV / 4);
    var top = (maxV / step).ceil() * step;
    if (top <= 0) top = step;
    return ChartScale._(false, top.toDouble(), step, [for (var v = 0.0; v <= top + step / 1000; v += step) (v, v)]);
  }
}
