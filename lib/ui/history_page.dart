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

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int? _year;
  int _tab = 0; // 0 fills, 1 expenses

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
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
          Expanded(child: _tab == 0 ? _fills(scope, vid) : _expenses(scope, vid)),
        ],
      ),
    );
  }

  Widget _fills(AppScope scope, String vid) {
    return StreamBuilder<List<EnergyEvent>>(
      stream: scope.repo.watchEvents(vid, kind: null),
      builder: (context, snap) {
        final events = snap.data ?? const <EnergyEvent>[];
        if (events.isEmpty) return const Center(child: Text('Nothing logged yet'));
        // Economy is worked out separately for fill-ups and charges.
        final byId = {
          for (final kind in ['fuel', 'charge'])
            for (final s in tankStats(Repository.toFuelRows(events, kind: kind))) (kind, s.fill.odometerKm): s,
        };
        final years = events.map((e) => e.at.year).toSet().toList()..sort((a, b) => b.compareTo(a));
        final shown = _year == null ? events : events.where((e) => e.at.year == _year).toList();
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
                  final s = byId[(e.kind, e.odometerKm)];
                  final energy = e.kind == 'charge' ? Energy.charge : Energy.fuel;
                  final tags = [
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

  Widget _expenses(AppScope scope, String vid) {
    return StreamBuilder<List<Expense>>(
      stream: scope.repo.watchExpenses(vid),
      builder: (context, snap) {
        final items = snap.data ?? const <Expense>[];
        final add = Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => editTollParking(context, kind: 'parking'),
              icon: const Icon(Icons.local_parking),
              label: const Text('Add toll or parking'),
            ),
          ),
        );
        if (items.isEmpty) {
          return Column(children: [add, const Expanded(child: Center(child: Text('No expenses yet. Imported maintenance records appear here.')))]);
        }
        return Column(children: [add, Expanded(child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final x = items[i];
            return ListTile(
              leading: Icon(_iconFor(x.kind)),
              onTap: x.kind == 'toll' || x.kind == 'parking' ? () => editTollParking(context, existing: x) : null,
              title: Text(x.description),
              subtitle: Text('${fmtDate(x.at)}${x.odometerKm == null ? '' : ' · ${fmtKm(x.odometerKm!)} km'}${x.location == null ? '' : ' · ${x.location}'}'),
              trailing: Text(fmtMoney(x.cost), style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          },
        ))]);
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
