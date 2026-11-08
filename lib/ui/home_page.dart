import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/reminders.dart';
import '../domain/stats.dart';
import 'care_page.dart';
import 'fillup_form.dart';
import 'format.dart';
import 'insights_page.dart' show ChartScale;
import 'prices_page.dart' show FuelPriceCard;
import 'import_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vehicleId = scope.settings.activeVehicleId!;
    return StreamBuilder<List<Vehicle>>(
      stream: scope.repo.watchVehicles(),
      builder: (context, vs) {
        final vehicle = vs.data?.where((v) => v.id == vehicleId).firstOrNull ?? vs.data?.firstOrNull;
        return StreamBuilder<List<EnergyEvent>>(
          stream: scope.repo.watchEvents(vehicleId),
          builder: (context, snap) {
            final events = snap.data ?? const <EnergyEvent>[];
            return _Dashboard(vehicle: vehicle, events: events);
          },
        );
      },
    );
  }
}

class _Dashboard extends StatelessWidget {
  final Vehicle? vehicle;
  final List<EnergyEvent> events; // newest first
  const _Dashboard({required this.vehicle, required this.events});

  @override
  Widget build(BuildContext context) {
    final rows = Repository.toFuelRows(events);
    final stats = tankStats(rows); // ascending by odometer
    final lifetime = lifetimeTotals(rows);
    final latest = events.isNotEmpty ? events.first : null;
    final lastTank = stats.isNotEmpty ? stats.last : null;
    final rolling = rollingPer100(stats);
    final recent = rolling.isNotEmpty ? rolling.lastWhere((v) => v != null, orElse: () => null) : null;
    final year = DateTime.now().year;
    final thisYear = yearlyTotals(rows)[year];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle == null ? 'MileageLog' : '${vehicle!.name} · ${latest == null ? '' : '${fmtKm(latest.odometerKm)} km'}'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          FilledButton.icon(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FillUpForm())),
            icon: const Icon(Icons.local_gas_station),
            label: const Text('Log a fill-up', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 12),
          const ComingUpCard(),
          FuelPriceCard(events: events),
          if ((latestEconomyChange(stats) ?? 0) >= 0.15)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: cs.tertiaryContainer,
              child: ListTile(
                leading: Icon(Icons.trending_up, color: cs.onTertiaryContainer),
                title: Text(
                  'Last tank used ${(latestEconomyChange(stats)! * 100).round()}% more fuel than usual',
                  style: TextStyle(color: cs.onTertiaryContainer),
                ),
                subtitle: Text(
                  'Lots of short trips, a heavy load or a roof rack can do it. Low tyre pressure or a dragging brake can too, so a tyre check is worth a minute.',
                  style: TextStyle(color: cs.onTertiaryContainer),
                ),
              ),
            ),
          if (events.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No fill-ups yet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('Import your history from the Google Sheet or the old app\'s export, or log your first fill.'),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportPage())),
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Import history'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _Tile(label: 'Last tank', value: fmtPer100(lastTank?.litresPer100), unit: 'L/100 km'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Tile(label: 'Lifetime', value: fmtPer100(lifetime.per100), unit: 'L/100 km'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Tile(
                    label: 'Last price',
                    value: lastTank == null ? '—' : '\$${lastTank.pricePerUnit.toStringAsFixed(2)}',
                    unit: '/L',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Tile(
                    label: 'Cost / 100 km',
                    value: lastTank?.costPer100 == null ? '—' : '\$${lastTank!.costPer100!.toStringAsFixed(1)}',
                    unit: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _RangeTile(vehicle: vehicle, latest: latest, recentPer100: recent),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('L/100 KM · LAST 10 FILLS', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: _EconomyChart(stats: stats.length > 10 ? stats.sublist(stats.length - 10) : stats, color: cs.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Tile(
                    label: 'This year',
                    value: thisYear == null ? '0' : fmtKm(thisYear.km),
                    unit: 'km',
                    sub: thisYear == null
                        ? null
                        : '${fmtMoney0(thisYear.cost)} · ${fmtKm(thisYear.quantity)} L · ${fmtPer100(thisYear.per100)} L/100',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Tile(
                    label: 'Lifetime',
                    value: fmtKm(lifetime.km),
                    unit: 'km',
                    sub: '${lifetime.fills} fills · ${fmtMoney0(lifetime.cost)}',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label, value, unit;
  final String? sub;
  const _Tile({required this.label, required this.value, required this.unit, this.sub});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: t.labelSmall),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                style: t.headlineSmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                children: [
                  TextSpan(text: value),
                  if (unit.isNotEmpty) TextSpan(text: ' $unit', style: t.bodySmall),
                ],
              ),
            ),
            if (sub != null) Text(sub!, style: t.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _RangeTile extends StatelessWidget {
  final Vehicle? vehicle;
  final EnergyEvent? latest;
  final double? recentPer100;
  const _RangeTile({required this.vehicle, required this.latest, required this.recentPer100});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tank = vehicle?.tankSize;
    String text;
    if (latest == null) {
      text = 'Log a fill to see range';
    } else if (tank == null) {
      text = 'Set the tank size on the vehicle page to see range left';
    } else {
      final fullRange = recentPer100 == null ? null : tank / recentPer100! * 100;
      text = fullRange == null
          ? 'Need two full fills to estimate range'
          : 'About ${fmtKm(fullRange)} km on a full tank at ${fmtPer100(recentPer100)} L/100 km · last fill ${fmtDate(latest!.at)} at ${fmtKm(latest!.odometerKm)} km';
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.route_outlined),
        title: Text('Range', style: t.labelSmall),
        subtitle: Text(text),
      ),
    );
  }
}

class _EconomyChart extends StatelessWidget {
  final List<TankStat> stats;
  final Color color;
  const _EconomyChart({required this.stats, required this.color});

  @override
  Widget build(BuildContext context) {
    // Only tanks with a figure, evenly spaced, dated underneath.
    final points = [
      for (final s in stats)
        if (s.litresPer100 != null) s,
    ];
    if (points.length < 2) {
      return const Center(child: Text('Need two full fills for a trend'));
    }
    final spots = [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].litresPer100!)];
    final ys = spots.map((s) => s.y);
    final lo = ys.reduce(math.min), hi = ys.reduce(math.max);
    final step = ChartScale.niceStep(math.max(hi - lo, 1) / 3);
    var minY = (lo / step).floor() * step, maxY = (hi / step).ceil() * step;
    if (maxY - minY < step * 2) maxY = minY + step * 2;
    const style = TextStyle(fontSize: 10);
    final side = SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: step,
      getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(step < 1 ? 1 : 0), style: style),
    );
    final every = points.length <= 6 ? 1 : 2;
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: spots.length - 1.0,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: step),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          leftTitles: AxisTitles(sideTitles: side),
          rightTitles: AxisTitles(sideTitles: side),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.round();
                if ((v - i).abs() > 1e-6 || i < 0 || i >= points.length) return const SizedBox();
                // Always label the latest fill; thin the rest when crowded.
                if ((points.length - 1 - i) % every != 0) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(DateFormat('d-MMM').format(points[i].fill.at), style: style),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touched) => [
              for (final t in touched)
                LineTooltipItem(
                  '${DateFormat('d MMM yyyy').format(points[t.x.round()].fill.at)}\n${t.y.toStringAsFixed(1)} L/100 km',
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: color,
            barWidth: 2.5,
            isCurved: false,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }
}
