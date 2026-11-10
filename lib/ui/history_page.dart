import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/stats.dart';
import 'fillup_form.dart';
import '../domain/energy.dart';
import 'charge_form.dart';
import 'format.dart';
import 'toll_form.dart';
import 'expense_page.dart';
import 'service_page.dart' show expenseKinds;
import 'vehicle_page.dart' show VehicleChip;

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int? _year;
  int _tab = 0; // 0 fills, 1 expenses
  // Expense filters.
  String? _kind;
  int? _expYear;
  bool _withDocs = false;
  bool _searching = false;
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: scope.settings.viewAll,
      builder: (context, all, _) => ValueListenableBuilder<String?>(
        valueListenable: scope.settings.activeVehicle,
        builder: (context, vid, _) => StreamBuilder<List<Vehicle>>(
          stream: scope.repo.watchVehicles(),
          builder: (context, vs) {
            final names = {for (final v in vs.data ?? const <Vehicle>[]) v.id: v.name};
            final showVid = all ? null : vid!;
            return Scaffold(
              appBar: AppBar(title: const Text('History'), actions: const [VehicleChip(allowAll: true)]),
              floatingActionButton: _tab == 1
                  ? FloatingActionButton.extended(onPressed: () => addExpense(context), icon: const Icon(Icons.add), label: const Text('Add expense'))
                  : null,
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Fuel & charging')),
                        ButtonSegment(value: 1, label: Text('Expenses')),
                      ],
                      selected: {_tab},
                      onSelectionChanged: (s) => setState(() => _tab = s.first),
                    ),
                  ),
                  Expanded(child: _tab == 0 ? _fills(scope, showVid, all ? names : null) : _expenses(scope, showVid, all ? names : null)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// [names] is set when every vehicle is shown, to label each row.
  Widget _fills(AppScope scope, String? vid, Map<String, String>? names) {
    return StreamBuilder<List<EnergyEvent>>(
      stream: scope.repo.watchEvents(vid, kind: null),
      builder: (context, snap) {
        final events = snap.data ?? const <EnergyEvent>[];
        if (events.isEmpty) return const Center(child: Text('Nothing logged yet'));
        // Economy is worked out separately for each vehicle, and for fill-ups and charges.
        final byId = <(String, String, double), TankStat>{
          for (final v in events.map((e) => e.vehicleId).toSet())
            for (final kind in ['fuel', 'charge'])
              for (final s in tankStats(Repository.toFuelRows([for (final e in events) if (e.vehicleId == v) e], kind: kind))) (v, kind, s.fill.odometerKm): s,
        };
        final sorted = names == null ? events : ([...events]..sort((a, b) => b.at.compareTo(a.at)));
        final years = events.map((e) => e.at.year).toSet().toList()..sort((a, b) => b.compareTo(a));
        final shown = _year == null ? sorted : sorted.where((e) => e.at.year == _year).toList();
        return Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(label: const Text('All'), selected: _year == null, onSelected: (_) => setState(() => _year = null)),
                  ),
                  for (final y in years)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(label: Text('$y'), selected: _year == y, onSelected: (_) => setState(() => _year = y)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: shown.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = shown[i];
                  final s = byId[(e.vehicleId, e.kind, e.odometerKm)];
                  final energy = e.kind == 'charge' ? Energy.charge : Energy.fuel;
                  final tags = [
                    if (names != null) names[e.vehicleId] ?? '',
                    if (energy.isCharge) chargePlaceLabel(e.chargerType),
                    if (e.stationName != null) e.stationName!,
                    if (e.paymentNote != null) e.paymentNote!,
                    if (!e.isFull) 'partial',
                  ];
                  return ListTile(
                    leading: energy.isCharge ? const Icon(Icons.ev_station) : null,
                    title: Text('${fmtDate(e.at)}${tags.isEmpty ? '' : ' · ${tags.join(' · ')}'}'),
                    subtitle: Text(
                      '${fmtKm(e.odometerKm)} km${s?.distanceKm == null ? '' : ' · ${fmtKm(s!.distanceKm!)} km'} · ${energy.quantity(e.quantity)} · ${fmtMoney(e.cost)} · ${energy.price(s?.pricePerUnit)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(fmtPer100(s?.litresPer100), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        Text('${energy.unit}/100', style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => energy.isCharge ? ChargeForm(existing: e) : FillUpForm(existing: e))),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _expenses(AppScope scope, String? vid, Map<String, String>? names) {
    return StreamBuilder<List<Attachment>>(
      stream: vid == null ? scope.repo.watchAllAttachments() : scope.repo.watchVehicleAttachments(vid),
      builder: (context, docsSnap) {
        final docs = <String, int>{};
        for (final a in docsSnap.data ?? const <Attachment>[]) {
          if (a.ownerKind == 'expense') docs[a.ownerId] = (docs[a.ownerId] ?? 0) + 1;
        }
        return StreamBuilder<List<Expense>>(
          stream: scope.repo.watchExpenses(vid),
          builder: (context, snap) {
            final items = snap.data ?? const <Expense>[];
            final t = Theme.of(context).textTheme;
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No expenses yet. Tap Add expense for a service, WOF, rego, tyres, toll, parking or anything else. Imported maintenance records appear here too.',
                      textAlign: TextAlign.center),
                ),
              );
            }
            final kinds = [for (final k in expenseKinds.keys) if (items.any((e) => e.kind == k)) k];
            final years = items.map((e) => e.at.year).toSet().toList()..sort((a, b) => b.compareTo(a));
            if (_kind != null && !kinds.contains(_kind)) _kind = null;
            if (_expYear != null && !years.contains(_expYear)) _expYear = null;
            final shown = filterExpenses(items, kind: _kind, year: _expYear, query: _query.text, withDocs: _withDocs ? docs.keys.toSet() : null);
            final total = shown.fold(0.0, (a, e) => a + e.cost);
            Widget menu<T>(IconData icon, T value, List<T> values, String Function(T) label, void Function(T) set, bool on) => PopupMenuButton<T>(
                  initialValue: value,
                  onSelected: (v) => setState(() => set(v)),
                  itemBuilder: (_) => [for (final v in values) PopupMenuItem(value: v, child: Text(label(v)))],
                  child: Chip(
                    avatar: Icon(icon, size: 18),
                    label: Text(label(value)),
                    backgroundColor: on ? Theme.of(context).colorScheme.secondaryContainer : null,
                  ),
                );
            final filtered = _kind != null || _expYear != null || _withDocs || _query.text.trim().isNotEmpty;
            return ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    menu<String>(Icons.category_outlined, _kind ?? '', ['', ...kinds], (k) => k.isEmpty ? 'Any type' : expenseKinds[k]!, (v) => _kind = v.isEmpty ? null : v,
                        _kind != null),
                    menu<int>(Icons.date_range, _expYear ?? 0, [0, ...years], (y) => y == 0 ? 'Any year' : '$y', (v) => _expYear = v == 0 ? null : v, _expYear != null),
                    FilterChip(
                      avatar: const Icon(Icons.attach_file, size: 18),
                      label: const Text('With documents'),
                      selected: _withDocs,
                      onSelected: (v) => setState(() => _withDocs = v),
                    ),
                    IconButton(
                      tooltip: 'Search',
                      icon: Icon(_searching ? Icons.search_off : Icons.search),
                      onPressed: () => setState(() {
                        _searching = !_searching;
                        if (!_searching) _query.clear();
                      }),
                    ),
                  ]),
                ),
                if (_searching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Search description, place or notes', prefixIcon: Icon(Icons.search), isDense: true, border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text('${shown.length} expense${shown.length == 1 ? '' : 's'} · ${fmtMoney(total)}${filtered ? ' (filtered)' : ''}', style: t.bodySmall),
                ),
                if (shown.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No expenses match these filters.', textAlign: TextAlign.center)),
                for (final x in shown) ...[
                  ListTile(
                    leading: Icon(_iconFor(x.kind)),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExpenseDetailPage(expenseId: x.id))),
                    title: Row(children: [
                      Flexible(child: Text(x.description, overflow: TextOverflow.ellipsis)),
                      if (docs[x.id] != null) ...[const SizedBox(width: 4), Icon(Icons.attach_file, size: 16, semanticLabel: '${docs[x.id]} documents')],
                    ]),
                    subtitle: Text([
                      if (names != null) names[x.vehicleId] ?? '',
                      fmtDate(x.at),
                      if (x.odometerKm != null) '${fmtKm(x.odometerKm!)} km',
                      ?x.location,
                    ].join(' · ')),
                    trailing: Text(fmtMoney(x.cost), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: 1),
                ],
              ],
            );
          },
        );
      },
    );
  }

  IconData _iconFor(String kind) => switch (kind) {
        'insurance' => Icons.shield_outlined,
        'rego' => Icons.badge_outlined,
        'wof' => Icons.verified_outlined,
        'tyres' => Icons.tire_repair,
        'service' => Icons.build_outlined,
        'toll' || 'parking' => tollParkingIcon(kind),
        _ => Icons.receipt_long_outlined,
      };
}
