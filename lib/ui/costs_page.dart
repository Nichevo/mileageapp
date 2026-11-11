/// Cost of owning: every dollar spent on a vehicle over time, by category,
/// with depreciation, cost per km and whether it's going up.
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart' show newId;
import '../domain/ownership_cost.dart';
import '../domain/stats.dart';
import 'charts.dart';
import 'format.dart';
import 'vehicle_page.dart' show VehicleChip;

const costColors = {
  CostCategory.fuel: Color(0xff1e88e5),
  CostCategory.charging: Color(0xff00acc1),
  CostCategory.servicing: Color(0xff43a047),
  CostCategory.rego: Color(0xff8e24aa),
  CostCategory.insurance: Color(0xfffb8c00),
  CostCategory.tyres: Color(0xff6d4c41),
  CostCategory.tollsParking: Color(0xfffdd835),
  CostCategory.other: Color(0xff90a4ae),
  CostCategory.depreciation: Color(0xffe53935),
};

String perKmLabel(double? v) => v == null ? '—' : '${(v * 100).toStringAsFixed(1)} c/km';

/// Everything needed to cost one vehicle.
class VehicleCosts {
  final Vehicle vehicle;
  final List<CostItem> items;
  final ValueCurve curve;
  final List<FuelRow> odometer; // readings only, for km per period
  final bool hasInsured;
  VehicleCosts(this.vehicle, this.items, this.curve, this.odometer, this.hasInsured);

  bool get hasData => items.isNotEmpty || !curve.isEmpty;

  factory VehicleCosts.of(Vehicle v, List<EnergyEvent> events, List<Expense> expenses, List<VehicleValue> values, List<InsurancePolicy> policies) {
    final ev = events.where((e) => e.vehicleId == v.id).toList();
    final ex = expenses.where((e) => e.vehicleId == v.id).toList();
    final insured = [
      for (final p in policies)
        if (p.vehicleId == v.id && p.insuredValue != null && p.insuredValue! > 0) ValuePoint(p.startAt, p.insuredValue!, 'insured'),
    ];
    return VehicleCosts(
      v,
      [
        for (final e in ev) CostItem(e.at, e.kind == 'charge' ? CostCategory.charging : CostCategory.fuel, e.cost),
        for (final e in ex) CostItem(e.at, categoryForExpense(e.kind), e.cost),
      ],
      ValueCurve([
        for (final x in values)
          if (x.vehicleId == v.id) ValuePoint(x.at, x.value, x.source),
        ...insured,
      ]),
      [
        for (final e in ev) FuelRow(at: e.at, odometerKm: e.odometerKm, quantity: 0, cost: 0),
        for (final e in ex)
          if (e.odometerKm != null) FuelRow(at: e.at, odometerKm: e.odometerKm!, quantity: 0, cost: 0),
      ],
      insured.isNotEmpty,
    );
  }

  List<CostPeriod> periods(Period p, {required DateTime now, DateTime? from}) =>
      costPeriods(items, curve, periodTotals(odometer, p), p, now: now, from: from);
}

class CostsPage extends StatefulWidget {
  const CostsPage({super.key});
  @override
  State<CostsPage> createState() => _CostsPageState();
}

class _CostsPageState extends State<CostsPage> {
  int _years = 0; // 0 = all
  Period _period = Period.year;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final repo = scope.repo;
    return Scaffold(
      appBar: AppBar(title: const Text('Running costs'), actions: const [VehicleChip(allowAll: true)]),
      body: ValueListenableBuilder<bool>(
        valueListenable: scope.settings.viewAll,
        builder: (context, all, _) => ValueListenableBuilder<String?>(
          valueListenable: scope.settings.activeVehicle,
          builder: (context, vid, _) => StreamBuilder<List<Vehicle>>(
            stream: repo.watchVehicles(),
            builder: (context, vs) => StreamBuilder<List<EnergyEvent>>(
              stream: repo.watchEvents(null, kind: null),
              builder: (context, es) => StreamBuilder<List<Expense>>(
                stream: repo.watchExpenses(null),
                builder: (context, xs) => StreamBuilder<List<VehicleValue>>(
                  stream: repo.watchValues(null),
                  builder: (context, vals) => StreamBuilder<List<InsurancePolicy>>(
                    stream: repo.watchAllPolicies(),
                    builder: (context, ps) {
                      if (!vs.hasData || !es.hasData || !xs.hasData || !vals.hasData || !ps.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final costs = [
                        for (final v in vs.data!)
                          if (all || v.id == vid) VehicleCosts.of(v, es.data!, xs.data!, vals.data!, ps.data!),
                      ].where((c) => c.hasData || !all).toList();
                      return _body(context, costs, all, vid);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _label(DateTime d) => _period == Period.year ? '${d.year}' : DateFormat('MMM-yy').format(d);
  String _tip(DateTime d) => _period == Period.year ? '${d.year}' : DateFormat('MMM yyyy').format(d);

  Widget _body(BuildContext context, List<VehicleCosts> costs, bool all, String? vid) {
    final t = Theme.of(context).textTheme;
    final now = DateTime.now();
    final from = _years == 0 ? null : DateTime(now.year - _years, now.month + 1);
    final periods = mergeCostPeriods([for (final c in costs) c.periods(_period, now: now, from: from)]);
    final monthly = mergeCostPeriods([for (final c in costs) c.periods(Period.month, now: now)]);
    final controls = [
      SegmentedButton<int>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: 1, label: Text('1 yr')),
          ButtonSegment(value: 3, label: Text('3 yr')),
          ButtonSegment(value: 5, label: Text('5 yr')),
          ButtonSegment(value: 0, label: Text('All')),
        ],
        selected: {_years},
        onSelectionChanged: (s) => setState(() => _years = s.first),
      ),
      const SizedBox(height: 8),
      SegmentedButton<Period>(
        showSelectedIcon: false,
        segments: const [ButtonSegment(value: Period.month, label: Text('Monthly')), ButtonSegment(value: Period.year, label: Text('Yearly'))],
        selected: {_period},
        onSelectionChanged: (s) => setState(() => _period = s.first),
      ),
      const SizedBox(height: 12),
    ];
    if (periods.isEmpty || periods.every((p) => p.total == 0)) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        ...controls,
        const Text('No costs yet. Fill-ups, charges and expenses (History > Expenses) show here, along with depreciation once you add what you paid.'),
        if (!all && costs.isNotEmpty) ...[const SizedBox(height: 16), _valueCard(context, costs.single, now)],
      ]);
    }
    final byCat = <CostCategory, double>{};
    for (final p in periods) {
      p.cost.forEach((k, v) => byCat[k] = (byCat[k] ?? 0) + v);
    }
    final total = byCat.values.fold(0.0, (a, b) => a + b);
    final dep = byCat[CostCategory.depreciation] ?? 0;
    final km = periods.fold(0.0, (a, p) => a + p.km);
    final firstWithData = periods.firstWhere((p) => p.total != 0, orElse: () => periods.first).start;
    final years = (now.difference(firstWithData).inDays / 365.25).clamp(1 / 12, 1000.0);
    final unit = _period == Period.year ? 'year' : 'month';
    final labels = [for (final p in periods) _label(p.start)];
    final tips = [for (final p in periods) _tip(p.start)];
    final trend = costTrend(monthly, now);
    Widget tile(String label, String value) => Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: t.bodySmall), Text(value, style: t.titleMedium)]),
          ),
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        ...controls,
        Text('${fmtMoney0(total)} in ${_years == 0 ? 'all' : 'the last $_years year${_years == 1 ? '' : 's'}'}'
            '${dep > 0 ? ', ${fmtMoney0(dep)} of it depreciation' : ''}', style: t.titleMedium),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 560 ? 4 : 2;
          final w = (c.maxWidth - (cols - 1) * 8) / cols;
          return Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (l, v) in [
              ('Per year', fmtMoney0(total / years)),
              ('Per month', fmtMoney0(total / years / 12)),
              ('Per km, all in', perKmLabel(km < 10 ? null : total / km)),
              ('Per km, running only', perKmLabel(km < 10 ? null : (total - dep) / km)),
              ('Distance', '${fmtKm(km)} km'),
              ('Per day', fmtMoney(total / years / 365.25)),
            ])
              SizedBox(width: w, child: tile(l, v)),
          ]);
        }),
        const SizedBox(height: 12),
        _trendCard(context, trend, periods),
        _card(
          context,
          'Cost per $unit by type · \$',
          'Tap a bar for its breakdown. Rego and insurance land on the day you paid, so Yearly gives the fairest picture.',
          StackedBars(
            labels: labels,
            tips: tips,
            fmt: (v) => fmtMoney0(v),
            parts: [for (final c in CostCategory.values) StackPart(costLabel(c), costColors[c]!, [for (final p in periods) p.cost[c] ?? 0])],
          ),
        ),
        _card(
          context,
          'Cost per km · \$ per $unit',
          'Running costs plus depreciation, divided by the km driven that $unit (from odometer readings).',
          StackedBars(
            labels: labels,
            tips: tips,
            fmt: (v) => perKmLabel(v),
            parts: [
              StackPart('Running', costColors[CostCategory.fuel]!, [for (final p in periods) p.runningPerKm ?? 0]),
              StackPart('Depreciation', costColors[CostCategory.depreciation]!, [for (final p in periods) p.km < 10 ? 0 : (p.cost[CostCategory.depreciation] ?? 0) / p.km]),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('WHERE THE MONEY WENT', style: t.labelSmall),
              const SizedBox(height: 6),
              for (final c in CostCategory.values)
                if ((byCat[c] ?? 0) != 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Container(width: 10, height: 10, color: costColors[c]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(costLabel(c))),
                      SizedBox(width: 48, child: Text('${(byCat[c]! / total * 100).round()}%', textAlign: TextAlign.right, style: t.bodySmall)),
                      SizedBox(width: 84, child: Text('${fmtMoney0(byCat[c]! / years)}/yr', textAlign: TextAlign.right, style: t.bodySmall)),
                      SizedBox(width: 84, child: Text(fmtMoney0(byCat[c]!), textAlign: TextAlign.right)),
                    ]),
                  ),
            ]),
          ),
        ),
        if (all) _compareCard(context, costs, now, from) else if (costs.isNotEmpty) _valueCard(context, costs.single, now),
      ],
    );
  }

  Widget _card(BuildContext context, String title, String caption, Widget child) {
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: t.labelSmall),
          const SizedBox(height: 8),
          SizedBox(height: 220, child: child),
          if (caption.isNotEmpty) ...[const SizedBox(height: 6), Text(caption, style: t.bodySmall)],
        ]),
      ),
    );
  }

  Widget _arrow(double? change) {
    if (change == null) return const SizedBox(width: 60);
    final up = change > 0.02, down = change < -0.02;
    final color = up ? Colors.red.shade600 : (down ? Colors.green.shade700 : Colors.grey);
    return SizedBox(
      width: 60,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Icon(up ? Icons.arrow_upward : (down ? Icons.arrow_downward : Icons.remove), size: 14, color: color),
        Text('${(change.abs() * 100).round()}%', style: TextStyle(color: color, fontSize: 12)),
      ]),
    );
  }

  Widget _trendCard(BuildContext context, CostTrend tr, List<CostPeriod> periods) {
    final t = Theme.of(context).textTheme;
    final ch = tr.change;
    final perKmCh = tr.recentPerKm != null && tr.beforePerKm != null && tr.beforePerKm! > 0 ? tr.recentPerKm! / tr.beforePerKm! - 1 : null;
    // Year-on-year running cost per km over complete years.
    final now = DateTime.now();
    final yearly = mergeCostPeriods([periods]).where((p) => _period == Period.year && p.start.year < now.year && p.runningPerKm != null).toList();
    final s = slope([for (final p in yearly) p.runningPerKm!]);
    final headline = ch == null
        ? 'Not enough history to compare yet: this needs costs from more than a year ago.'
        : ch > 0.05
            ? 'Yes: the last 12 months cost ${fmtMoney0(tr.recentTotal)}, up ${(ch * 100).round()}% on the 12 before (${fmtMoney0(tr.beforeTotal)}).'
            : ch < -0.05
                ? 'No: the last 12 months cost ${fmtMoney0(tr.recentTotal)}, down ${(-ch * 100).round()}% on the 12 before (${fmtMoney0(tr.beforeTotal)}).'
                : 'About the same: ${fmtMoney0(tr.recentTotal)} in the last 12 months, ${fmtMoney0(tr.beforeTotal)} in the 12 before.';
    final cats = [
      for (final c in CostCategory.values)
        if ((tr.recent[c] ?? 0) != 0 || (tr.before[c] ?? 0) != 0) c,
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('IS IT GOING UP?', style: t.labelSmall),
          const SizedBox(height: 6),
          Text(headline, style: t.bodyMedium),
          if (perKmCh != null)
            Text('Per km: ${perKmLabel(tr.recentPerKm)} against ${perKmLabel(tr.beforePerKm)} '
                '(${perKmCh >= 0 ? 'up' : 'down'} ${(perKmCh.abs() * 100).round()}%), so it isn\'t just driving more or less.', style: t.bodySmall),
          if (s != null && yearly.length >= 3)
            Text('Year on year since ${yearly.first.start.year}, running costs per km have ${s >= 0 ? 'risen' : 'fallen'} about ${(s.abs() * 100).toStringAsFixed(1)} c/km a year.',
                style: t.bodySmall),
          if (ch != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Expanded(child: SizedBox()),
              SizedBox(width: 84, child: Text('12 before', textAlign: TextAlign.right, style: t.labelSmall)),
              SizedBox(width: 84, child: Text('Last 12', textAlign: TextAlign.right, style: t.labelSmall)),
              const SizedBox(width: 60),
            ]),
            for (final c in cats)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  Container(width: 10, height: 10, color: costColors[c]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(costLabel(c))),
                  SizedBox(width: 84, child: Text(fmtMoney0(tr.before[c] ?? 0), textAlign: TextAlign.right, style: t.bodySmall)),
                  SizedBox(width: 84, child: Text(fmtMoney0(tr.recent[c] ?? 0), textAlign: TextAlign.right)),
                  _arrow((tr.before[c] ?? 0) <= 0 ? null : (tr.recent[c] ?? 0) / tr.before[c]! - 1),
                ]),
              ),
          ],
        ]),
      ),
    );
  }

  /// Every vehicle side by side.
  Widget _compareCard(BuildContext context, List<VehicleCosts> costs, DateTime now, DateTime? from) {
    final t = Theme.of(context).textTheme;
    final rows = [
      for (final c in costs)
        () {
          final ps = c.periods(Period.month, now: now, from: from);
          final total = ps.fold(0.0, (a, p) => a + p.total);
          final dep = ps.fold(0.0, (a, p) => a + (p.cost[CostCategory.depreciation] ?? 0));
          final km = ps.fold(0.0, (a, p) => a + p.km);
          final first = ps.where((p) => p.total != 0).firstOrNull?.start;
          final end = c.curve.sold?.at ?? c.vehicle.archivedAt ?? now;
          final years = first == null ? 1.0 : (end.difference(first).inDays / 365.25).clamp(1 / 12, 1000.0);
          return (c: c, total: total, dep: dep, km: km, years: years);
        }(),
    ]..sort((a, b) => b.total.compareTo(a.total));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EACH VEHICLE', style: t.labelSmall),
          const SizedBox(height: 6),
          for (final r in rows)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(r.c.vehicle.name),
              subtitle: Text([
                '${fmtMoney0(r.total / r.years)}/yr',
                perKmLabel(r.km < 10 ? null : r.total / r.km),
                if (r.dep > 0) '${fmtMoney0(r.dep)} depreciation',
                if (r.c.curve.valueAt(now) != null && r.c.curve.sold == null) 'worth about ${fmtMoney0(r.c.curve.valueAt(now)!)}',
                if (r.c.vehicle.archivedAt != null) 'past vehicle',
              ].join(' · ')),
              trailing: Text(fmtMoney0(r.total), style: t.titleSmall),
            ),
          Text('Pick one vehicle from the top bar to see and add its values.', style: t.bodySmall),
        ]),
      ),
    );
  }

  Widget _valueCard(BuildContext context, VehicleCosts c, DateTime now) {
    final t = Theme.of(context).textTheme;
    final scope = AppScope.of(context);
    final curve = c.curve;
    final purchase = curve.points.where((p) => p.source == 'purchase').firstOrNull;
    return StreamBuilder<List<VehicleValue>>(
      stream: scope.repo.watchValues(c.vehicle.id),
      builder: (context, snap) {
        final rows = snap.data ?? const <VehicleValue>[];
        final worth = curve.valueAt(now);
        final first = curve.points.firstOrNull;
        final end = curve.sold?.at ?? now;
        final years = first == null ? 0.0 : end.difference(first.at).inDays / 365.25;
        final lost = first == null ? 0.0 : first.value - (curve.valueAt(end) ?? first.value);
        final kmOwned = c.odometer.isEmpty || first == null
            ? 0.0
            : () {
                final r = c.odometer.where((o) => !o.at.isBefore(first.at)).map((o) => o.odometerKm).toList()..sort();
                return r.length < 2 ? 0.0 : r.last - r.first;
              }();
        final est = <({DateTime at, double value})>[];
        if (curve.points.isNotEmpty && curve.estimatedAt(now)) {
          final last = curve.points.last.at;
          for (var d = DateTime(last.year, last.month + 3); d.isBefore(now); d = DateTime(d.year, d.month + 3)) {
            est.add((at: d, value: curve.valueAt(d)!));
          }
          est.add((at: now, value: worth!));
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('VALUE AND DEPRECIATION', style: t.labelSmall),
              const SizedBox(height: 6),
              if (curve.isEmpty)
                Text('Add what you paid for ${c.vehicle.name} to include depreciation. Insured values from Car care > Insurance are used too, '
                    'and you can add estimates (say from a dealer or Trade Me) over time.', style: t.bodyMedium)
              else ...[
                SizedBox(
                  height: 180,
                  child: ValueLine(
                    known: [for (final p in curve.points) (at: p.at, value: p.value)],
                    estimated: est,
                    fmt: (v) => fmtMoney0(v),
                  ),
                ),
                const SizedBox(height: 8),
                Text([
                  if (purchase != null) 'Bought for ${fmtMoney0(purchase.value)} in ${DateFormat('MMM yyyy').format(purchase.at)}.',
                  if (curve.sold != null)
                    'Sold for ${fmtMoney0(curve.sold!.value)}.'
                  else if (worth != null)
                    'Worth about ${fmtMoney0(worth)} now${curve.estimatedAt(now) ? ' (estimated at ${(curve.rate * 100).round()}% a year since the last value)' : ''}.',
                  if (lost > 0 && years > 0.1)
                    'Lost ${fmtMoney0(lost)} so far, ${fmtMoney0(lost / years)} a year${kmOwned > 100 ? ', ${perKmLabel(lost / kmOwned)}' : ''}.',
                ].join(' '), style: t.bodyMedium),
              ],
              const SizedBox(height: 8),
              for (final p in curve.points)
                () {
                  final row = rows.where((r) => r.at == p.at && r.value == p.value && r.source == p.source).firstOrNull;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(switch (p.source) {
                      'purchase' => Icons.shopping_cart_outlined,
                      'sold' => Icons.sell_outlined,
                      'insured' => Icons.shield_outlined,
                      _ => Icons.price_check,
                    }),
                    title: Text('${valueSources[p.source] ?? p.source} ${fmtMoney0(p.value)}'),
                    subtitle: Text([fmtDate(p.at), if (p.source == 'insured') 'from your insurance policy', ?row?.notes].join(' · ')),
                    trailing: row == null ? null : const Icon(Icons.edit_outlined, size: 18),
                    onTap: row == null ? null : () => editVehicleValue(context, c.vehicle, existing: row),
                  );
                }(),
              Wrap(spacing: 8, children: [
                if (purchase == null)
                  FilledButton.tonalIcon(
                    onPressed: () => editVehicleValue(context, c.vehicle, source: 'purchase'),
                    icon: const Icon(Icons.add),
                    label: const Text('What you paid'),
                  ),
                OutlinedButton.icon(
                  onPressed: () => editVehicleValue(context, c.vehicle, source: 'estimate'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add a value'),
                ),
                if (curve.sold == null && purchase != null)
                  TextButton(onPressed: () => editVehicleValue(context, c.vehicle, source: 'sold'), child: const Text('Sold it')),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

/// Add or change a known value: bought for, an estimate, or sold for.
Future<void> editVehicleValue(BuildContext context, Vehicle v, {VehicleValue? existing, String source = 'estimate'}) async {
  final repo = AppScope.of(context).repo;
  var src = existing?.source ?? source;
  var at = existing?.at ?? (src == 'purchase' ? v.purchaseDate ?? DateTime.now() : DateTime.now());
  final amount = TextEditingController(text: existing?.value.toStringAsFixed(0) ?? '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, set) => AlertDialog(
        title: Text(existing == null ? 'Add a value' : 'Change value'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'purchase', label: Text('Bought')),
                ButtonSegment(value: 'estimate', label: Text('Estimate')),
                ButtonSegment(value: 'sold', label: Text('Sold')),
              ],
              selected: {src},
              onSelectionChanged: (s) => set(() => src = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amount,
              autofocus: existing == null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Value \$', border: OutlineInputBorder()),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(fmtDate(at)),
              onTap: () async {
                final d = await showDatePicker(context: c, initialDate: at, firstDate: DateTime(1980), lastDate: DateTime.now());
                if (d != null) set(() => at = d);
              },
            ),
            TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes (optional), e.g. dealer quote', border: OutlineInputBorder())),
          ]),
        ),
        actions: [
          if (existing != null) TextButton(onPressed: () => Navigator.pop(c, 'delete'), child: const Text('Delete')),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, 'save'), child: const Text('Save')),
        ],
      ),
    ),
  );
  if (result == 'delete' && existing != null) {
    await repo.deleteValue(existing.id);
    return;
  }
  final value = double.tryParse(amount.text.replaceAll(r'$', '').replaceAll(',', ''));
  if (result != 'save' || value == null) return;
  await repo.upsertValue(VehicleValuesCompanion(
    id: Value(existing?.id ?? newId()),
    vehicleId: Value(v.id),
    at: Value(at),
    value: Value(value),
    source: Value(src),
    notes: Value(notes.text.trim().isEmpty ? null : notes.text.trim()),
  ));
}
