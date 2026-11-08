import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../data/database.dart';
import '../domain/prices.dart';
import '../prices/national_prices.dart';
import 'format.dart';

/// Opens Gaspy for live prices at nearby stations (or its Play Store page).
Future<void> openGaspy(BuildContext context) async {
  try {
    await const MethodChannel('mileagelog/trips').invokeMethod('openApp', {'package': 'nz.hwem.gaspy'});
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Couldn\'t open Gaspy')));
    }
  }
}

bool get gaspyAvailable => Platform.isAndroid;

List<FillInput> fillInputs(List<EnergyEvent> events) => [
      for (final e in events)
        if (e.kind == 'fuel') (at: e.at, litres: e.quantity, cost: e.cost, station: e.stationName, fuelType: e.fuelType),
    ];

/// The fuel you usually buy, from your recent fill-ups.
String usualFuel(List<EnergyEvent> events) {
  final recent = events.where((e) => e.kind == 'fuel' && e.fuelType != null).take(10).map((e) => mbieFuelFor(e.fuelType)).toList();
  if (recent.isEmpty) return mbieRegular;
  final counts = <String, int>{};
  for (final f in recent) {
    counts[f] = (counts[f] ?? 0) + 1;
  }
  return (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
}

class PricesPage extends StatefulWidget {
  const PricesPage({super.key});
  @override
  State<PricesPage> createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  NationalPrices? _national;
  List<EnergyEvent> _events = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool refresh = false}) async {
    final scope = AppScope.of(context);
    setState(() => _loading = true);
    final events = await scope.repo.events(scope.settings.activeVehicleId!);
    NationalPrices? national;
    try {
      national = await NationalPriceSource.load(refresh: refresh);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _events = events;
      _national = national;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final national = _national;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel prices'),
        actions: [IconButton(tooltip: 'Refresh', onPressed: _loading ? null : () => _load(refresh: true), icon: const Icon(Icons.refresh))],
      ),
      body: _loading && national == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (gaspyAvailable) ...[
                  FilledButton.tonalIcon(
                    onPressed: () => openGaspy(context),
                    icon: const Icon(Icons.local_gas_station_outlined),
                    label: const Text('Check prices nearby in Gaspy'),
                  ),
                  const SizedBox(height: 4),
                  Text('Gaspy has live prices at each station but doesn\'t share them with other apps, so this opens Gaspy itself.', style: t.bodySmall),
                  const SizedBox(height: 16),
                ],
                if (national == null || national.isEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.cloud_off_outlined),
                      title: const Text('National prices aren\'t available yet'),
                      subtitle: const Text('They download from MBIE once a week. Check the connection and tap refresh.'),
                    ),
                  )
                else
                  ..._withNational(context, national),
              ],
            ),
    );
  }

  List<Widget> _withNational(BuildContext context, NationalPrices national) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final usual = usualFuel(_events);
    final priced = priceFills(fillInputs(_events), national);
    final yearAgo = DateTime.now().subtract(const Duration(days: 365));
    final lastYear = priced.where((p) => p.at.isAfter(yearAgo)).toList();
    final stations = rankStations(priced);
    final latestWeek = national.latest(usual)?.week;

    return [
      Text('National average this week', style: t.titleSmall),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final fuel in [mbieRegular, mbiePremium, mbieDiesel])
          if (national.latest(fuel) != null)
            Card(
              margin: EdgeInsets.zero,
              color: fuel == usual ? cs.secondaryContainer : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mbieFuelLabel(fuel), style: t.bodySmall),
                  Text(fmtPrice(national.latest(fuel)!.centsPerL / 100), style: t.titleMedium),
                  if (national.latestChange(fuel) != null) Text(_change(national.latestChange(fuel)!), style: t.bodySmall),
                ]),
              ),
            ),
      ]),
      if (latestWeek != null) ...[
        const SizedBox(height: 6),
        Text('Average pump price for the week of ${fmtDate(latestWeek)}, from ${NationalPriceSource.sourceName}.', style: t.bodySmall),
      ],
      const SizedBox(height: 20),
      if (priced.isEmpty)
        Text('Your fill-ups will be compared with the national average once you have some with litres and cost.', style: t.bodyMedium)
      else ...[
        Text('How your prices compare', style: t.titleSmall),
        const SizedBox(height: 8),
        if (lastYear.isNotEmpty) _savingLine(context, 'Last 12 months', lastYear),
        _savingLine(context, 'All your history', priced),
        const SizedBox(height: 12),
        SizedBox(height: 180, child: _PriceChart(fills: priced.where((p) => p.at.isAfter(DateTime.now().subtract(const Duration(days: 730)))).toList(), national: national, fuel: usual)),
        const SizedBox(height: 4),
        Text('Line: national average for ${mbieFuelLabel(usual)}. Dots: what you paid at each fill-up (last two years).', style: t.bodySmall),
      ],
      if (stations.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text('Your stations, cheapest first', style: t.titleSmall),
        const SizedBox(height: 4),
        Text('Measured against the national average in the same week, so older fills count fairly. Stations with at least two fill-ups.', style: t.bodySmall),
        for (final s in stations.take(12))
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(s.avgDiffCents < 0 ? Icons.thumb_up_alt_outlined : Icons.thumb_down_alt_outlined,
                color: s.avgDiffCents < 0 ? Colors.green.shade700 : cs.error),
            title: Text(s.name),
            subtitle: Text('${s.fills} fill-ups · last ${fmtDate(s.lastAt)}'),
            trailing: Text(_cents(s.avgDiffCents), style: t.titleSmall),
          ),
      ],
    ];
  }

  Widget _savingLine(BuildContext context, String label, List<PricedFill> fills) {
    final t = Theme.of(context).textTheme;
    final saved = savedDollars(fills);
    final avgDiff = fills.map((f) => f.diffCents).reduce((a, b) => a + b) / fills.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(TextSpan(children: [
        TextSpan(text: '$label: ', style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        TextSpan(
          text: '${fills.length} fill-ups averaged ${diffText(avgDiff)}, '
              '${saved >= 0 ? 'saving' : 'costing'} about ${fmtMoney0(saved.abs())} ${saved >= 0 ? 'compared with' : 'more than'} paying the average.',
          style: t.bodyMedium,
        ),
      ])),
    );
  }

  static String _cents(double c) {
    final r = c.round();
    return r == 0 ? 'average' : '${r > 0 ? '+' : '−'}${r.abs()}c';
  }

  static String _change(double c) {
    final r = c.round();
    return r == 0 ? 'no change' : '${r > 0 ? 'up' : 'down'} ${r.abs()}c on last week';
  }
}

class _PriceChart extends StatelessWidget {
  final List<PricedFill> fills;
  final NationalPrices national;
  final String fuel;
  const _PriceChart({required this.fills, required this.national, required this.fuel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (fills.isEmpty) return const Center(child: Text('No fill-ups in the last two years'));
    final from = fills.first.at.subtract(const Duration(days: 7));
    final to = DateTime.now();
    double x(DateTime d) => d.difference(from).inHours / 24;
    final line = [
      for (final w in national.byFuel[fuel] ?? const <WeekPrice>[])
        if (!w.week.isBefore(from) && !w.week.isAfter(to)) FlSpot(x(w.week), w.centsPerL / 100),
    ];
    final dots = [for (final f in fills) FlSpot(x(f.at), f.paidCents / 100)];
    final fmt = DateFormat('MMM yy');
    return LineChart(LineChartData(
      minX: 0,
      maxX: x(to),
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text('\$${v.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10))),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            interval: (x(to) / 4).clamp(30, 400).toDouble(),
            getTitlesWidget: (v, m) => Text(fmt.format(from.add(Duration(days: v.round()))), style: const TextStyle(fontSize: 10)),
          ),
        ),
      ),
      lineTouchData: const LineTouchData(enabled: false),
      lineBarsData: [
        if (line.length > 1) LineChartBarData(spots: line, color: cs.outline, barWidth: 2, dotData: const FlDotData(show: false)),
        LineChartBarData(
          spots: dots,
          color: Colors.transparent,
          barWidth: 0,
          dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 3.5, color: cs.primary, strokeWidth: 0)),
        ),
      ],
    ));
  }
}

/// One-line national price on Home, with how your last fill compared.
/// Hidden until the national figures have downloaded.
class FuelPriceCard extends StatefulWidget {
  final List<EnergyEvent> events; // newest first
  const FuelPriceCard({super.key, required this.events});
  @override
  State<FuelPriceCard> createState() => _FuelPriceCardState();
}

class _FuelPriceCardState extends State<FuelPriceCard> {
  NationalPrices? _national;

  @override
  void initState() {
    super.initState();
    NationalPriceSource.load().then((n) {
      if (mounted) setState(() => _national = n);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final n = _national;
    if (n == null || n.isEmpty || widget.events.isEmpty) return const SizedBox.shrink();
    final fuel = usualFuel(widget.events);
    final latest = n.latest(fuel);
    if (latest == null) return const SizedBox.shrink();
    final change = n.latestChange(fuel);
    final last = priceFills(fillInputs(widget.events.take(1).toList()), n).firstOrNull;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.price_check),
        title: Text('${mbieFuelLabel(fuel)} national average ${fmtPrice(latest.centsPerL / 100)}'
            '${change == null || change.round() == 0 ? '' : ', ${change > 0 ? 'up' : 'down'} ${change.abs().round()}c'}'),
        subtitle: last == null ? null : Text('Your last fill was ${diffText(last.diffCents)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PricesPage())),
      ),
    );
  }
}
