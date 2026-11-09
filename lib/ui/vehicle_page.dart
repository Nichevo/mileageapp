import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/carjam.dart';
import '../domain/energy.dart';
import '../vehicle/carjam_client.dart';
import 'format.dart';

class VehiclePage extends StatefulWidget {
  /// For tests: the HTTP client used for CarJam lookups.
  final http.Client? carjamClient;
  /// Add a new vehicle (and switch to it on save) instead of editing the current one.
  final bool isNew;
  const VehiclePage({super.key, this.carjamClient, this.isNew = false});
  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final _plate = TextEditingController();
  final _name = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _tank = TextEditingController();
  final _rated = TextEditingController();
  final _notes = TextEditingController();
  Vehicle? _v;
  String _kind = 'petrol';
  bool _loaded = false;
  CarDetails? _found;
  bool _looking = false;
  bool _datesApplied = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final scope = AppScope.of(context);
    if (widget.isNew) {
      setState(() => _loaded = true);
      return;
    }
    final v = await scope.repo.vehicle(scope.settings.activeVehicleId!);
    if (v == null || !mounted) return;
    setState(() {
      _v = v;
      _loaded = true;
      _kind = v.kind;
      _plate.text = scope.settings.plateFor(v.id) ?? '';
      _name.text = v.name;
      _make.text = v.make ?? '';
      _model.text = v.model ?? '';
      _year.text = v.year?.toString() ?? '';
      _tank.text = v.tankSize?.toString() ?? '';
      _rated.text = v.ratedEconomy?.toString() ?? '';
      _notes.text = v.notes ?? '';
    });
  }

  Future<void> _save() async {
    final scope = AppScope.of(context);
    final name = _name.text.trim().isEmpty ? 'My car' : _name.text.trim();
    _v ??= await scope.repo.addVehicle(name, _kind);
    await scope.settings.setPlate(_v!.id, normalisePlate(_plate.text));
    await scope.repo.saveVehicle(VehiclesCompanion(
      id: Value(_v!.id),
      name: Value(name),
      kind: Value(_kind),
      make: Value(_make.text.trim().isEmpty ? null : _make.text.trim()),
      model: Value(_model.text.trim().isEmpty ? null : _model.text.trim()),
      year: Value(int.tryParse(_year.text)),
      tankSize: Value(double.tryParse(_tank.text)),
      ratedEconomy: Value(double.tryParse(_rated.text)),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
      createdAt: Value(_v!.createdAt),
    ));
    if (widget.isNew) await scope.settings.setActiveVehicleId(_v!.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _lookup() async {
    final scope = AppScope.of(context);
    var key = scope.settings.carjamKey;
    if (key == null) {
      key = await _askKey();
      if (key == null || !mounted) return;
    }
    setState(() {
      _looking = true;
      _error = null;
    });
    try {
      final d = await CarJamClient.lookup(_plate.text, key, client: widget.carjamClient);
      if (_v != null) await scope.settings.setPlate(_v!.id, normalisePlate(_plate.text));
      if (!mounted) return;
      setState(() {
        _found = d;
        final f = d.fuelType?.toLowerCase() ?? '';
        if (f.contains('electric') && !f.contains('petrol')) {
          _kind = 'ev';
        } else if (f.contains('diesel')) {
          _kind = 'diesel';
        } else if (f.contains('plug')) {
          _kind = 'phev';
        } else if (f.contains('hybrid')) {
          _kind = 'hybrid';
        }
        _datesApplied = false;
        if (d.make != null) _make.text = d.summaryMake;
        if (d.model != null) _model.text = d.summaryModel;
        if (d.year != null) _year.text = '${d.year}';
        if (d.ratedPer100 != null && _rated.text.trim().isEmpty) _rated.text = d.ratedPer100!.toStringAsFixed(1);
        if (_name.text.trim().isEmpty || _name.text == 'My car') _name.text = [d.summaryMake, d.summaryModel].where((s) => s.isNotEmpty).join(' ');
      });
    } on CarJamException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _looking = false);
    }
  }

  Future<String?> _askKey() async {
    final scope = AppScope.of(context);
    final ctl = TextEditingController(text: scope.settings.carjamKey ?? '');
    final t = Theme.of(context).textTheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('CarJam API key'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Plate lookups use CarJam, which charges about 21c + GST a lookup (more when it checks the government register). '
              'To get a key:\n'
              '1. Register at carjam.co.nz (Members).\n'
              '2. On the developer page, apply for a Development Connection. CarJam approves it, usually within a business day.\n'
              '3. Generate an API key and paste it here.\n\n'
              'The key is kept on this phone only.',
              style: t.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(controller: ctl, decoration: const InputDecoration(labelText: 'API key', border: OutlineInputBorder())),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return null;
    await scope.settings.setCarjamKey(ctl.text);
    if (mounted) setState(() {});
    return scope.settings.carjamKey;
  }

  Future<void> _openCarJam() async {
    try {
      await const MethodChannel('mileagelog/trips').invokeMethod('openUrl', {'url': CarJamClient.pageFor(_plate.text).toString()});
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Couldn\'t open the browser')));
    }
  }

  /// Sets the WOF and rego items so they fall due on CarJam's expiry dates.
  Future<void> _applyDates() async {
    final d = _found!;
    final repo = AppScope.of(context).repo;
    await applyExpiryDates(repo, _v!.id, wofExpiry: d.wofExpiry, regoExpiry: d.licenceExpiry, oldCar: (d.year ?? 9999) < 2000);
    if (!mounted) return;
    setState(() => _datesApplied = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WOF and rego reminders updated')));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final hasKey = AppScope.of(context).settings.carjamKey != null;
    return Scaffold(
      appBar: AppBar(title: Text(widget.isNew ? 'Add a vehicle' : 'Vehicle')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Look up by number plate', style: t.titleSmall),
                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: TextField(
                      controller: _plate,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Plate', helperText: 'Kept on this phone', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: FilledButton.icon(
                      onPressed: _looking || normalisePlate(_plate.text).isEmpty ? null : _lookup,
                      icon: _looking
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.search),
                      label: const Text('Look up'),
                    ),
                  ),
                ]),
                Wrap(spacing: 4, children: [
                  TextButton(
                    onPressed: normalisePlate(_plate.text).isEmpty ? null : _openCarJam,
                    child: const Text('Open on CarJam (free)'),
                  ),
                  TextButton(onPressed: _askKey, child: Text(hasKey ? 'Change API key' : 'Set up API key')),
                ]),
                if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error))),
                if (_found != null) _foundCard(context, _found!),
                const SizedBox(height: 12),
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final k in vehicleKinds)
                    ChoiceChip(label: Text(vehicleKindLabel(k)), selected: _kind == k, onSelected: (_) => setState(() => _kind = k)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _make, decoration: const InputDecoration(labelText: 'Make', border: OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _model, decoration: const InputDecoration(labelText: 'Model', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _tank, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: _kind == 'ev' ? 'Battery (kWh)' : 'Tank size (L)', border: const OutlineInputBorder()))),
                ]),
                const SizedBox(height: 12),
                TextField(controller: _rated, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Rated economy (${Energy.primaryFor(_kind).per100})', helperText: 'The maker\'s figure, shown as a benchmark', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes (stay on this phone)', border: OutlineInputBorder())),
                const SizedBox(height: 20),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
    );
  }

  Widget _foundCard(BuildContext context, CarDetails d) {
    final t = Theme.of(context).textTheme;
    final lines = <String>[
      if (d.colour != null || d.bodyStyle != null) [d.colour, d.bodyStyle].whereType<String>().join(' ').toLowerCase(),
      if (d.firstRegisteredNz != null) 'First registered in NZ ${fmtDate(d.firstRegisteredNz!)}',
      if (d.wofExpiry != null) 'WOF expires ${fmtDate(d.wofExpiry!)}',
      if (d.licenceExpiry != null) 'Rego expires ${fmtDate(d.licenceExpiry!)}',
      if (d.odometerKm != null) 'Last odometer on record ${fmtKm(d.odometerKm!)} km',
      if (d.ratedPer100 != null) 'Rated ${d.ratedPer100!.toStringAsFixed(1)} L/100 km',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(d.summary, style: t.titleMedium),
          const SizedBox(height: 4),
          for (final l in lines) Text(l, style: t.bodySmall),
          const SizedBox(height: 4),
          Text('Filled in below. Check them and tap Save. Tank size isn\'t on the register, so add it yourself.', style: t.bodySmall),
          if (d.wofExpiry != null || d.licenceExpiry != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _datesApplied ? null : _applyDates,
                icon: Icon(_datesApplied ? Icons.check : Icons.event_available),
                label: Text(_datesApplied ? 'WOF and rego reminders updated' : 'Use these dates for WOF and rego reminders'),
              ),
            ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in [_plate, _name, _make, _model, _year, _tank, _rated, _notes]) {
      c.dispose();
    }
    super.dispose();
  }
}

/// Makes the WOF and rego service items fall due on the given expiry dates,
/// creating them if they don't exist yet.
Future<void> applyExpiryDates(Repository repo, String vehicleId, {DateTime? wofExpiry, DateTime? regoExpiry, bool oldCar = false}) async {
  final db = repo.db;
  final items = await (db.select(db.serviceItems)..where((s) => s.vehicleId.equals(vehicleId))).get();
  for (final (kind, name, expiry, defaultMonths) in [
    ('wof', 'Warrant of Fitness', wofExpiry, oldCar ? 6 : 12),
    ('rego', 'Registration', regoExpiry, 12),
  ]) {
    if (expiry == null) continue;
    final existing = items.where((i) => i.kind == kind && i.active).firstOrNull;
    final months = existing?.intervalMonths ?? defaultMonths;
    await repo.upsertServiceItem(ServiceItemsCompanion(
      id: Value(existing?.id ?? newId()),
      vehicleId: Value(vehicleId),
      name: Value(existing?.name ?? name),
      kind: Value(kind),
      intervalMonths: Value(months),
      intervalKm: Value(existing?.intervalKm),
      lastDoneAt: Value(lastDoneForDue(expiry, months)),
      lastDoneKm: Value(existing?.lastDoneKm),
      notes: Value(existing?.notes),
      active: const Value(true),
    ));
  }
}

/// Bottom sheet listing your vehicles: tap one to switch, or add another.
Future<void> showVehicleSwitcher(BuildContext context) async {
  final scope = AppScope.of(context);
  final vehicles = await scope.repo.vehicles();
  if (!context.mounted) return;
  vehicles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final picked = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: ListView(shrinkWrap: true, children: [
        for (final v in vehicles)
          ListTile(
            leading: Icon(v.kind == 'ev' ? Icons.electric_car : Icons.directions_car),
            title: Text(v.name),
            subtitle: Text([vehicleKindLabel(v.kind), ?v.make, ?v.model].join(' · ')),
            trailing: v.id == scope.settings.activeVehicleId ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(c, v.id),
          ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Add a vehicle'),
          subtitle: const Text('Petrol, diesel, hybrid, plug-in hybrid or electric'),
          onTap: () => Navigator.pop(c, '+'),
        ),
      ]),
    ),
  );
  if (picked == null || !context.mounted) return;
  if (picked == '+') {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VehiclePage(isNew: true)));
  } else if (picked != scope.settings.activeVehicleId) {
    await scope.settings.setActiveVehicleId(picked);
  }
}
