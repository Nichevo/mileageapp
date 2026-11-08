import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
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

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: StreamBuilder<List<EnergyEvent>>(
        stream: scope.repo.watchEvents(vid),
        builder: (context, snap) {
          final all = snap.data ?? const <EnergyEvent>[];
          final now = DateTime.now();
          final cutoff = _rangeMonths == 0 ? null : DateTime(now.year, now.month - _rangeMonths + 1, 1);
          final allRows = Repository.toFuelRows(all);
          final rows = cutoff == null ? allRows : allRows.where((r) => !r.at.isBefore(cutoff)).toList();
          final stats = tankStats(rows);
          final cs = Theme.of(context).colorScheme;
          if (all.length < 2) {
            return const Center(child: Text('Charts appear after a couple of fill-ups'));
          }
          // Spreading uses every fill, so the first period in range is complete.
          final periods = periodTotals(allRows, _period, from: cutoff);
          final totalKm = periods.fold<double>(0, (a, t) => a + t.km);
          final totalCost = periods.fold<double>(0, (a, t) => a + t.cost);
          final byMonth = _kmPerDayByMonth(rows);
          final byDow = _fillsByWeekday(rows);
          final unit = switch (_period) { Period.week => 'week', Period.month => 'month', Period.year => 'year' };
          List<_Bar> series(double? Function(PeriodTotals) f) => [
                for (var i = 0; i < periods.length; i++)
                  _Bar(_axisLabel(periods, i), _fullLabel(periods[i].start), f(periods[i]) ?? 0),
              ];
          final busiest = periods.isEmpty ? null : periods.reduce((a, b) => a.km >= b.km ? a : b);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
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
              const SizedBox(height: 12),
              _ChartCard(
                title: 'Distance per $unit · km',
                caption: '${fmtKm(totalKm)} km in this range'
                    '${busiest == null || busiest.km == 0 ? '' : ', most in ${_fullLabel(busiest.start)} (${fmtKm(busiest.km)} km)'}. '
                    'Distance between two fill-ups is spread evenly over the days between them.',
                child: _bars(series((t) => t.km), cs.primary),
              ),
              _ChartCard(
                title: 'Fuel spend per $unit · \$',
                caption: '${fmtMoney0(totalCost)} in this range',
                child: _bars(series((t) => t.cost), cs.tertiary),
              ),
              _ChartCard(
                title: 'Cost per 100 km · \$ per $unit',
                caption: totalKm > 0 ? 'Average \$${(totalCost / totalKm * 100).toStringAsFixed(2)} per 100 km over the range' : '',
                child: _bars(series((t) => t.costPer100), cs.tertiary),
              ),
              _ChartCard(
                title: 'Price per litre · \$ per $unit',
                caption: 'Average of the fill-ups made in each $unit. Empty bars had no fill-up.',
                child: _bars(series((t) => t.pricePerUnit), cs.tertiary, decimals: 2),
              ),
              _ChartCard(
                title: 'Fuel economy · L/100 km, rolling 5 fills',
                caption: 'Dashed line is the rolling average; dots are single tanks',
                child: _economy(stats, cs.primary),
              ),
              _ChartCard(
                title: 'Driving by month of year · average km per day',
                caption: _busiestMonths(byMonth),
                child: _bars([for (var m = 1; m <= 12; m++) _Bar('JFMAMJJASOND'[m - 1], DateFormat('MMMM').format(DateTime(2000, m)), byMonth[m] ?? 0)], cs.primary),
              ),
              _ChartCard(
                title: 'Fill-ups by weekday',
                caption: '${byDow.sublist(0, 5).fold(0, (a, b) => a + b)} weekday · ${byDow[5] + byDow[6]} weekend. Weekday vs weekend driving comes from recorded trips.',
                child: _bars([for (var d = 0; d < 7; d++) _Bar('MTWTFSS'[d], DateFormat('EEEE').format(DateTime(2024, 1, d + 1)), byDow[d].toDouble())], cs.primary, decimals: 0),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Short label under a bar, thinned out so labels never overlap.
  String _axisLabel(List<PeriodTotals> ps, int i) {
    final n = ps.length;
    final step = (n / 7).ceil().clamp(1, 1000);
    if (i % step != 0) return '';
    final d = ps[i].start;
    return switch (_period) {
      Period.week => DateFormat('d MMM').format(d),
      Period.month => n <= 12 ? DateFormat('MMM').format(d) : DateFormat("MMM ''yy").format(d),
      Period.year => "'${d.year % 100}",
    };
  }

  String _fullLabel(DateTime d) => switch (_period) {
        Period.week => 'week of ${DateFormat('d MMM yyyy').format(d)}',
        Period.month => DateFormat('MMM yyyy').format(d),
        Period.year => '${d.year}',
      };

  Widget _bars(List<_Bar> data, Color color, {int? decimals}) {
    if (data.isEmpty) return const SizedBox();
    final maxV = data.map((d) => d.value).fold(0.0, (a, b) => a > b ? a : b);
    final width = data.length > 40 ? 3.0 : data.length > 20 ? 6.0 : data.length > 12 ? 9.0 : 14.0;
    return BarChart(
      BarChartData(
        maxY: maxV == 0 ? 1 : maxV * 1.15,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= data.length || data[i].label.isEmpty) return const SizedBox();
                return Text(data[i].label, style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.visible, softWrap: false);
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
              '${data[g.x].tooltip}\n${_fmt(rod.toY, decimals)}',
              const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: data[i].value, color: color, width: width, borderRadius: BorderRadius.circular(width > 6 ? 3 : 1))]),
        ],
      ),
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
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 1)),
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
            SizedBox(height: 150, child: child),
            if (caption.isNotEmpty) ...[const SizedBox(height: 6), Text(caption, style: t.bodySmall)],
          ],
        ),
      ),
    );
  }
}
