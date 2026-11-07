import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
  int _rangeYears = 0; // 0 = all

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: StreamBuilder<List<EnergyEvent>>(
        stream: scope.repo.watchEvents(vid),
        builder: (context, snap) {
          var events = snap.data ?? const <EnergyEvent>[];
          if (_rangeYears > 0) {
            final cutoff = DateTime.now().subtract(Duration(days: 365 * _rangeYears));
            events = events.where((e) => e.at.isAfter(cutoff)).toList();
          }
          final rows = Repository.toFuelRows(events);
          final stats = tankStats(rows);
          final yearly = yearlyTotals(rows);
          final years = yearly.keys.toList()..sort();
          final cs = Theme.of(context).colorScheme;
          if (events.length < 2) {
            return const Center(child: Text('Charts appear after a couple of fill-ups'));
          }
          final byMonth = _kmPerDayByMonth(rows);
          final byDow = _fillsByWeekday(rows);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1 yr')),
                  ButtonSegment(value: 3, label: Text('3 yr')),
                  ButtonSegment(value: 0, label: Text('All')),
                ],
                selected: {_rangeYears},
                onSelectionChanged: (s) => setState(() => _rangeYears = s.first),
              ),
              const SizedBox(height: 12),
              _ChartCard(
                title: 'Distance per year · km',
                caption: years.isEmpty ? '' : '${fmtKm(yearly[years.first]!.km)} km in ${years.first}, ${fmtKm(yearly[years.last]!.km)} km in ${years.last}${years.last == DateTime.now().year ? ' (year to date)' : ''}',
                child: _bars(years.map((y) => (label: '${y % 100}', value: yearly[y]!.km)).toList(), cs.primary),
              ),
              _ChartCard(
                title: 'Cost per 100 km · \$ per year',
                caption: years.isEmpty ? '' : '\$${yearly[years.first]!.costPer100?.toStringAsFixed(1)} in ${years.first}, \$${yearly[years.last]!.costPer100?.toStringAsFixed(1)} in ${years.last}',
                child: _bars(years.map((y) => (label: '${y % 100}', value: yearly[y]!.costPer100 ?? 0)).toList(), cs.tertiary),
              ),
              _ChartCard(
                title: 'Price per litre · \$ per year',
                caption: years.isEmpty ? '' : '\$${yearly[years.first]!.pricePerUnit?.toStringAsFixed(2)} in ${years.first}, \$${yearly[years.last]!.pricePerUnit?.toStringAsFixed(2)} in ${years.last}',
                child: _bars(years.map((y) => (label: '${y % 100}', value: yearly[y]!.pricePerUnit ?? 0)).toList(), cs.tertiary),
              ),
              _ChartCard(
                title: 'Fuel economy · L/100 km, rolling 5 fills',
                caption: 'Dashed line is the rolling average; dots are single tanks',
                child: _economy(stats, cs.primary),
              ),
              _ChartCard(
                title: 'Driving by month · average km per day',
                caption: _busiestMonths(byMonth),
                child: _bars([for (var m = 1; m <= 12; m++) (label: 'JFMAMJJASOND'[m - 1], value: byMonth[m] ?? 0)], cs.primary),
              ),
              _ChartCard(
                title: 'Fill-ups by weekday',
                caption: '${byDow.sublist(0, 5).fold(0, (a, b) => a + b)} weekday · ${byDow[5] + byDow[6]} weekend. Weekday vs weekend driving needs recorded trips.',
                child: _bars([for (var d = 0; d < 7; d++) (label: 'MTWTFSS'[d], value: byDow[d].toDouble())], cs.primary),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bars(List<({String label, double value})> data, Color color) {
    if (data.isEmpty) return const SizedBox();
    final maxV = data.map((d) => d.value).fold(0.0, (a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: maxV == 0 ? 1 : maxV * 1.15,
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
                if (i < 0 || i >= data.length) return const SizedBox();
                return Text(data[i].label, style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(_fmt(rod.toY), const TextStyle(color: Colors.white)),
          ),
        ),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(x: i, barRods: [BarChartRodData(toY: data[i].value, color: color, width: data.length > 12 ? 8 : 14, borderRadius: BorderRadius.circular(3))]),
        ],
      ),
    );
  }

  String _fmt(double v) => v >= 100 ? fmtKm(v) : v.toStringAsFixed(v >= 10 ? 1 : 2);

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
