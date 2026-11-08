import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/care.dart';
import 'format.dart';

/// Kind of record, as stored on expenses and service items.
const expenseKinds = <String, String>{
  'service': 'Service',
  'wof': 'WOF',
  'rego': 'Registration',
  'tyres': 'Tyres',
  'insurance': 'Insurance',
  'other': 'Other',
};

IconData kindIcon(String kind) => switch (kind) {
      'wof' => Icons.verified_outlined,
      'rego' => Icons.badge_outlined,
      'tyres' => Icons.tire_repair,
      'insurance' => Icons.shield_outlined,
      'service' => Icons.build_outlined,
      _ => Icons.receipt_long_outlined,
    };

/// Odometer now (estimated) and typical km per day, from fill-ups.
({double? km, double? perDay}) drivingNow(List<EnergyEvent> events) {
  final rows = Repository.toFuelRows(events);
  return (km: estimatedOdometer(rows), perDay: recentKmPerDay(rows));
}

DueInfo dueOf(ServiceItem i, ({double? km, double? perDay}) d) => dueFor(
      lastDoneAt: i.lastDoneAt,
      lastDoneKm: i.lastDoneKm,
      intervalMonths: i.intervalMonths,
      intervalKm: i.intervalKm,
      currentKm: d.km,
      kmPerDay: d.perDay,
      now: DateTime.now(),
    );

String intervalText(int? months, int? km) => [
      if (months != null) months % 12 == 0 ? 'every ${months ~/ 12 == 1 ? 'year' : '${months ~/ 12} years'}' : 'every $months months',
      if (km != null) '${fmtKm(km)} km',
    ].join(' or ');

String dueText(DueInfo d) {
  if (d.state == DueState.unknown) return 'Set when it was last done';
  final now = DateTime.now();
  final parts = <String>[];
  if (d.dueAt != null) parts.add(fmtDate(d.dueAt!));
  if (d.dueKm != null) parts.add('${fmtKm(d.dueKm!)} km');
  final days = d.daysLeft(now);
  final when = days == null
      ? ''
      : days < 0
          ? ' · ${-days} days overdue'
          : days == 0
              ? ' · today'
              : ' · in $days days';
  final km = d.kmLeft == null ? '' : (d.kmLeft! < 0 ? ' · ${fmtKm(-d.kmLeft!)} km over' : ' · ${fmtKm(d.kmLeft!)} km to go');
  return 'Due ${parts.join(' or ')}$when${d.dueAt == null ? km : ''}';
}

Color dueColor(BuildContext context, DueState s) {
  final cs = Theme.of(context).colorScheme;
  return switch (s) {
    DueState.overdue => cs.error,
    DueState.soon => Colors.orange.shade700,
    DueState.ok => cs.primary,
    DueState.unknown => cs.outline,
  };
}

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    return StreamBuilder<List<EnergyEvent>>(
      stream: scope.repo.watchEvents(vid),
      builder: (context, ev) {
        final driving = drivingNow(ev.data ?? const []);
        return StreamBuilder<List<ServiceItem>>(
          stream: scope.repo.watchServiceItems(vid),
          builder: (context, snap) {
            final items = [...(snap.data ?? const <ServiceItem>[])];
            final dues = {for (final i in items) i.id: dueOf(i, driving)};
            int rank(ServiceItem i) => dues[i.id]!.state.index;
            items.sort((a, b) {
              final r = rank(a).compareTo(rank(b));
              if (r != 0) return r;
              final ea = dues[a.id]!.expectedAt, eb = dues[b.id]!.expectedAt;
              if (ea == null || eb == null) return ea == null ? 1 : -1;
              return ea.compareTo(eb);
            });
            return Scaffold(
              appBar: AppBar(
                title: const Text('Service schedule'),
                actions: [
                  IconButton(
                    tooltip: 'Add an item',
                    icon: const Icon(Icons.add),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServiceItemForm())),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LogServiceForm(currentKm: driving.km))),
                icon: const Icon(Icons.build),
                label: const Text('Log a service'),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  if (driving.km != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Odometer about ${fmtKm(driving.km!)} km'
                        '${driving.perDay == null ? '' : ', driving about ${driving.perDay!.round()} km a day'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (snap.hasData && items.isEmpty) _emptyState(context),
                  for (final i in items)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(kindIcon(i.kind), color: dueColor(context, dues[i.id]!.state)),
                        title: Text(i.name),
                        subtitle: Text(
                          '${dueText(dues[i.id]!)}\n'
                          '${intervalText(i.intervalMonths, i.intervalKm)}'
                          '${i.lastDoneAt == null ? '' : ' · last ${fmtDate(i.lastDoneAt!)}${i.lastDoneKm == null ? '' : ' at ${fmtKm(i.lastDoneKm!)} km'}'}',
                        ),
                        isThreeLine: true,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceItemForm(item: i))),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _History(vehicleId: vid),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('No schedule yet. Start from the usual NZ list (WOF, rego, oil changes and so on), then adjust the intervals to match your owner\'s manual.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecommendedServicesPage())),
                icon: const Icon(Icons.playlist_add),
                label: const Text('Add recommended schedule'),
              ),
            ],
          ),
        ),
      );
}

/// Past service, WOF, rego and other records (including the old app's).
class _History extends StatelessWidget {
  final String vehicleId;
  const _History({required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    return StreamBuilder<List<Expense>>(
      stream: scope.repo.watchExpenses(vehicleId),
      builder: (context, snap) {
        final list = (snap.data ?? const <Expense>[]).where((e) => e.kind != 'insurance').toList();
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Records', style: t.titleSmall),
            for (final e in list.take(40))
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(kindIcon(e.kind)),
                title: Text(e.description),
                subtitle: Text([
                  fmtDate(e.at),
                  if (e.odometerKm != null) '${fmtKm(e.odometerKm!)} km',
                  if (e.location != null) e.location!,
                ].join(' · ')),
                trailing: Text(fmtMoney(e.cost)),
                onLongPress: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete this record?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) await scope.repo.deleteExpense(e.id);
                },
              ),
            if (list.length > 40) Text('and ${list.length - 40} older', style: t.bodySmall),
          ],
        );
      },
    );
  }
}

/// Pick from the typical NZ schedule. "Last done" is filled in from history
/// where a matching record exists.
class RecommendedServicesPage extends StatefulWidget {
  const RecommendedServicesPage({super.key});
  @override
  State<RecommendedServicesPage> createState() => _RecommendedServicesPageState();
}

class _RecommendedServicesPageState extends State<RecommendedServicesPage> {
  final _picked = <int>{for (var i = 0; i < recommendedServices.length; i++) if (recommendedServices[i].name != 'Timing belt') i};
  List<Expense> _history = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scope = AppScope.of(context);
      final h = await scope.repo.expenses(scope.settings.activeVehicleId!);
      if (mounted) {
        setState(() {
          _history = h;
          _loaded = true;
        });
      }
    });
  }

  Expense? _lastMatch(ServiceTemplate t) {
    for (final e in _history) {
      final d = e.description.toLowerCase();
      if (e.kind == t.kind && (t.kind == 'wof' || t.kind == 'rego')) return e;
      if (t.matches.any(d.contains)) return e;
    }
    return null;
  }

  Future<void> _save() async {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    for (final i in _picked) {
      final t = recommendedServices[i];
      final last = _lastMatch(t);
      await scope.repo.upsertServiceItem(ServiceItemsCompanion.insert(
        id: newId(),
        vehicleId: vid,
        name: t.name,
        kind: Value(t.kind),
        intervalMonths: Value(t.months),
        intervalKm: Value(t.km),
        lastDoneAt: Value(last?.at),
        lastDoneKm: Value(last?.odometerKm),
        notes: Value(t.note),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommended schedule')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(onPressed: _picked.isEmpty || !_loaded ? null : _save, child: Text('Add ${_picked.length} items')),
        ),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Typical intervals for a petrol car. You can change any of them afterwards. "Last done" comes from your imported records where one matches.'),
          ),
          for (var i = 0; i < recommendedServices.length; i++)
            Builder(builder: (context) {
              final t = recommendedServices[i];
              final last = _lastMatch(t);
              return CheckboxListTile(
                value: _picked.contains(i),
                onChanged: (v) => setState(() => v == true ? _picked.add(i) : _picked.remove(i)),
                title: Text(t.name),
                subtitle: Text([
                  intervalText(t.months, t.km),
                  if (last != null) 'last done ${fmtDate(last.at)}',
                  if (t.note != null) t.note!,
                ].join('\n')),
              );
            }),
        ],
      ),
    );
  }
}

class ServiceItemForm extends StatefulWidget {
  final ServiceItem? item;
  const ServiceItemForm({super.key, this.item});
  @override
  State<ServiceItemForm> createState() => _ServiceItemFormState();
}

class _ServiceItemFormState extends State<ServiceItemForm> {
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late final _months = TextEditingController(text: widget.item?.intervalMonths?.toString() ?? '');
  late final _km = TextEditingController(text: widget.item?.intervalKm?.toString() ?? '');
  late final _lastKm = TextEditingController(text: widget.item?.lastDoneKm?.round().toString() ?? '');
  late final _notes = TextEditingController(text: widget.item?.notes ?? '');
  late String _kind = widget.item?.kind ?? 'service';
  late DateTime? _lastAt = widget.item?.lastDoneAt;

  Future<void> _save() async {
    final scope = AppScope.of(context);
    if (_name.text.trim().isEmpty) return;
    await scope.repo.upsertServiceItem(ServiceItemsCompanion.insert(
      id: widget.item?.id ?? newId(),
      vehicleId: scope.settings.activeVehicleId!,
      name: _name.text.trim(),
      kind: Value(_kind),
      intervalMonths: Value(int.tryParse(_months.text)),
      intervalKm: Value(int.tryParse(_km.text.replaceAll(',', ''))),
      lastDoneAt: Value(_lastAt),
      lastDoneKm: Value(double.tryParse(_lastKm.text.replaceAll(',', ''))),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await AppScope.of(context).repo.deleteServiceItem(widget.item!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'New schedule item' : 'Edit schedule item'),
        actions: [if (widget.item != null) IconButton(tooltip: 'Remove', icon: const Icon(Icons.delete_outline), onPressed: _delete)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name', border: border)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _kind,
            decoration: const InputDecoration(labelText: 'Type', border: border),
            items: [for (final e in expenseKinds.entries) if (e.key != 'insurance') DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => setState(() => _kind = v ?? 'service'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _months, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Every … months', border: border))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _km, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'or every … km', border: border))),
          ]),
          const SizedBox(height: 4),
          Text('Leave either blank if it only goes by time or only by distance.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(_lastAt == null ? 'Last done: not set' : 'Last done ${fmtDate(_lastAt!)}'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _lastAt ?? DateTime.now(), firstDate: DateTime(1990), lastDate: DateTime.now());
              if (d != null) setState(() => _lastAt = d);
            },
          ),
          TextField(controller: _lastKm, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer when last done (km)', border: border)),
          const SizedBox(height: 12),
          TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes', border: border)),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}

/// Record a service (or WOF, rego, tyres…) and tick off what was done.
class LogServiceForm extends StatefulWidget {
  final double? currentKm;
  const LogServiceForm({super.key, this.currentKm});
  @override
  State<LogServiceForm> createState() => _LogServiceFormState();
}

class _LogServiceFormState extends State<LogServiceForm> {
  DateTime _at = DateTime.now();
  late final _odo = TextEditingController(text: widget.currentKm?.round().toString() ?? '');
  final _cost = TextEditingController();
  final _desc = TextEditingController();
  final _where = TextEditingController();
  final _notes = TextEditingController();
  String _kind = 'service';
  final _done = <String>{};

  Future<void> _save(List<ServiceItem> items) async {
    final scope = AppScope.of(context);
    final picked = items.where((i) => _done.contains(i.id)).toList();
    final desc = _desc.text.trim().isNotEmpty ? _desc.text.trim() : (picked.isEmpty ? expenseKinds[_kind]! : picked.map((i) => i.name).join(', '));
    await scope.repo.logService(
      vehicleId: scope.settings.activeVehicleId!,
      at: _at,
      odometerKm: double.tryParse(_odo.text.replaceAll(',', '')),
      kind: _kind,
      description: desc,
      cost: double.tryParse(_cost.text.replaceAll(r'$', '').replaceAll(',', '')) ?? 0,
      location: _where.text.trim().isEmpty ? null : _where.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      itemIds: picked.map((i) => i.id).toList(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    final scope = AppScope.of(context);
    return StreamBuilder<List<ServiceItem>>(
      stream: scope.repo.watchServiceItems(scope.settings.activeVehicleId!),
      builder: (context, snap) {
        final items = snap.data ?? const <ServiceItem>[];
        return Scaffold(
          appBar: AppBar(title: const Text('Log a service')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(fmtDate(_at)),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(1990), lastDate: DateTime.now());
                  if (d != null) setState(() => _at = d);
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Type', border: border),
                items: [for (final e in expenseKinds.entries) if (e.key != 'insurance') DropdownMenuItem(value: e.key, child: Text(e.value))],
                onChanged: (v) => setState(() => _kind = v ?? 'service'),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextField(controller: _odo, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer (km)', border: border))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _cost, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cost \$', border: border))),
              ]),
              const SizedBox(height: 12),
              if (items.isNotEmpty) ...[
                Text('What was done', style: Theme.of(context).textTheme.titleSmall),
                for (final i in items)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _done.contains(i.id),
                    title: Text(i.name),
                    onChanged: (v) => setState(() {
                      v == true ? _done.add(i.id) : _done.remove(i.id);
                      if (v == true && _done.length == 1) _kind = i.kind;
                    }),
                  ),
                const SizedBox(height: 8),
              ],
              TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description (optional)', border: border)),
              const SizedBox(height: 12),
              TextField(controller: _where, decoration: const InputDecoration(labelText: 'Where (optional)', border: border)),
              const SizedBox(height: 12),
              TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes (optional)', border: border)),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => _save(items), child: const Text('Save')),
            ],
          ),
        );
      },
    );
  }
}
