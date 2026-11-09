import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import 'format.dart';

const sharetankFuels = ['91', '95', 'diesel'];

/// Z Sharetank: fuel bought ahead at a locked price. Shows the balance,
/// what it's worth, and what using it has saved against the pump.
class SharetankPage extends StatelessWidget {
  const SharetankPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppScope.of(context).repo;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Z Sharetank')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => editFuelCredit(context),
        icon: const Icon(Icons.add),
        label: const Text('Add a purchase'),
      ),
      body: StreamBuilder<List<FuelCredit>>(
        stream: repo.watchFuelCredits(),
        builder: (context, cs) => StreamBuilder<List<EnergyEvent>>(
          stream: repo.watchSharetankFills(),
          builder: (context, fs) {
            final credits = cs.data ?? const <FuelCredit>[];
            final fills = fs.data ?? const <EnergyEvent>[];
            final ledger = Repository.ledger(credits, fills);
            final priced = fills.where((f) => f.listCost != null).toList();
            final saved = priced.fold(0.0, (a, f) => a + f.listCost! - f.cost);
            final used = fills.fold(0.0, (a, f) => a + (f.sharetankLitres ?? 0));
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Balance', style: t.labelLarge),
                      Text('${ledger.balance.toStringAsFixed(1)} L', style: t.headlineMedium),
                      if (ledger.balance > 0) Text('Worth ${fmtMoney(ledger.value)} at ${fmtPrice(ledger.averagePrice)} on average'),
                      const SizedBox(height: 8),
                      Text(
                        [
                          '${used.toStringAsFixed(0)} L used so far',
                          if (priced.isNotEmpty) 'saved ${fmtMoney(saved)} against the pump on ${priced.length} fill${priced.length == 1 ? '' : 's'}',
                        ].join(', '),
                        style: t.bodySmall,
                      ),
                      if (ledger.uncovered > 0.05)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${ledger.uncovered.toStringAsFixed(1)} L of fill-ups came from Sharetank before any purchase covers them. Add older purchases from the Z app to cost them properly.',
                            style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Pick "Sharetank" as the payment on a fill-up, and it is costed at the price you locked in (oldest litres first).', style: t.bodySmall),
                const SizedBox(height: 16),
                Text('Purchases', style: t.titleMedium),
                if (credits.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('None yet. Your Z app lists past Sharetank purchases.')),
                for (final c in credits)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.savings_outlined),
                    title: Text('${c.litres.toStringAsFixed(1)} L${c.fuelType == null ? '' : ' of ${c.fuelType}'} at ${fmtPrice(c.litres > 0 ? c.cost / c.litres : null)}'),
                    subtitle: Text('${fmtDate(c.at)} · ${fmtMoney(c.cost)}${c.notes == null ? '' : ' · ${c.notes}'}'),
                    onTap: () => editFuelCredit(context, existing: c),
                  ),
                if (fills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Used on fill-ups', style: t.titleMedium),
                  for (final f in fills.take(30))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.local_gas_station_outlined),
                      title: Text('${f.sharetankLitres!.toStringAsFixed(1)} L · cost ${fmtMoney(ledger.drawCost[f.id] ?? f.cost)}'),
                      subtitle: Text([
                        fmtDate(f.at),
                        if (f.stationName != null) f.stationName!,
                        if (f.listCost != null) 'saved ${fmtMoney(f.listCost! - f.cost)}',
                      ].join(' · ')),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Add or edit a Sharetank purchase.
Future<void> editFuelCredit(BuildContext context, {FuelCredit? existing}) async {
  final repo = AppScope.of(context).repo;
  final litres = TextEditingController(text: existing == null ? '' : existing.litres.toString());
  final cost = TextEditingController(text: existing == null ? '' : existing.cost.toStringAsFixed(2));
  final notes = TextEditingController(text: existing?.notes ?? '');
  var at = existing?.at ?? DateTime.now();
  String? fuel = existing?.fuelType ?? '91';
  final result = await showDialog<String>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) {
        final l = double.tryParse(litres.text), d = double.tryParse(cost.text.replaceAll(r'$', ''));
        return AlertDialog(
          title: Text(existing == null ? 'Sharetank purchase' : 'Edit purchase'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(fmtDate(at)),
                onTap: () async {
                  final p = await showDatePicker(context: c, initialDate: at, firstDate: DateTime(2015), lastDate: DateTime.now());
                  if (p != null) setState(() => at = p);
                },
              ),
              Wrap(spacing: 6, children: [
                for (final f in sharetankFuels) ChoiceChip(label: Text(f), selected: fuel == f, onSelected: (_) => setState(() => fuel = f)),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: litres,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Litres', border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cost,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Paid \$',
                  helperText: l != null && l > 0 && d != null ? fmtPrice(d / l) : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder())),
            ]),
          ),
          actions: [
            if (existing != null) TextButton(onPressed: () => Navigator.pop(c, 'delete'), child: const Text('Delete')),
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            FilledButton(onPressed: l != null && l > 0 && d != null && d >= 0 ? () => Navigator.pop(c, 'save') : null, child: const Text('Save')),
          ],
        );
      },
    ),
  );
  if (result == 'delete') {
    await repo.deleteFuelCredit(existing!.id);
    await repo.recostSharetank();
  } else if (result == 'save') {
    await repo.upsertFuelCredit(FuelCreditsCompanion(
      id: Value(existing?.id ?? newId()),
      at: Value(at),
      fuelType: Value(fuel),
      litres: Value(double.parse(litres.text)),
      cost: Value(double.parse(cost.text.replaceAll(r'$', ''))),
      notes: Value(notes.text.trim().isEmpty ? null : notes.text.trim()),
    ));
    await repo.recostSharetank();
  }
}
