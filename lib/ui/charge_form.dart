import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/energy.dart';
import 'format.dart';

/// Log (or edit) an EV / plug-in hybrid charge. Home charges are costed
/// from your power rate, so only the kWh is needed.
class ChargeForm extends StatefulWidget {
  final EnergyEvent? existing;
  const ChargeForm({super.key, this.existing});
  @override
  State<ChargeForm> createState() => _ChargeFormState();
}

class _ChargeFormState extends State<ChargeForm> {
  final _formKey = GlobalKey<FormState>();
  final _odo = TextEditingController();
  final _kwh = TextEditingController();
  final _cost = TextEditingController();
  final _pctStart = TextEditingController();
  final _pctEnd = TextEditingController();
  final _station = TextEditingController();
  final _notes = TextEditingController();
  DateTime _at = DateTime.now();
  String _place = 'home';
  bool _costEdited = false;
  Vehicle? _vehicle;
  EnergyEvent? _previous;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _odo.text = _trim(e.odometerKm);
      _kwh.text = _trim(e.quantity);
      _cost.text = e.cost.toStringAsFixed(2);
      _pctStart.text = e.batteryPctStart == null ? '' : _trim(e.batteryPctStart!);
      _pctEnd.text = e.batteryPctEnd == null ? '' : _trim(e.batteryPctEnd!);
      _station.text = e.stationName ?? '';
      _notes.text = e.notes ?? '';
      _at = e.at;
      _place = e.chargerType ?? 'home';
      _costEdited = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  static String _trim(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _load() async {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    final v = await scope.repo.vehicle(vid);
    final prev = await scope.repo.latestEvent(vid, kind: 'charge');
    if (!mounted) return;
    setState(() {
      _vehicle = v;
      _previous = prev;
    });
  }

  double? _num(TextEditingController c) => double.tryParse(c.text.replaceAll(r'$', '').replaceAll(',', '').trim());

  double get _kwhValue => chargeKwh(meterKwh: _num(_kwh), pctStart: _num(_pctStart), pctEnd: _num(_pctEnd), batteryKwh: _vehicle?.tankSize);

  /// Home charges are costed from the power rate unless you typed a cost.
  void _autoCost() {
    if (_costEdited || _place != 'home') return;
    final kwh = _kwhValue;
    _cost.text = kwh > 0 ? (kwh * AppScope.of(context).settings.homeRateCents / 100).toStringAsFixed(2) : '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    final station = _station.text.trim();
    await scope.repo.upsertEvent(
      EnergyEventsCompanion(
        id: Value(widget.existing?.id ?? newId()),
        vehicleId: Value(vid),
        kind: const Value('charge'),
        at: Value(_at),
        odometerKm: Value(_num(_odo)!),
        quantity: Value(_kwhValue),
        cost: Value(_num(_cost) ?? 0),
        isFull: const Value(true),
        chargerType: Value(_place),
        batteryPctStart: Value(_num(_pctStart)),
        batteryPctEnd: Value(_num(_pctEnd)),
        stationName: Value(_place == 'home' || station.isEmpty ? null : station),
        notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
        source: Value(widget.existing?.source ?? 'app'),
        updatedAt: Value(DateTime.now()),
      ),
      enqueue: false, // the Google Sheet only takes fuel fill-ups
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this charge?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await AppScope.of(context).repo.deleteEvent(widget.existing!.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final settings = AppScope.of(context).settings;
    final kwh = _kwhValue;
    final cost = _num(_cost);
    final prev = _previous;
    final odo = _num(_odo);
    final km = prev != null && odo != null && odo > prev.odometerKm ? odo - prev.odometerKm : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New charge' : 'Edit charge'),
        actions: [if (widget.existing != null) IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text('${fmtDate(_at)} ${TimeOfDay.fromDateTime(_at).format(context)}'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 1)));
              if (d == null || !context.mounted) return;
              final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
              setState(() => _at = DateTime(d.year, d.month, d.day, tm?.hour ?? _at.hour, tm?.minute ?? _at.minute));
            },
          ),
          Wrap(spacing: 6, children: [
            for (final p in chargePlaces)
              ChoiceChip(
                label: Text(chargePlaceLabel(p)),
                selected: _place == p,
                onSelected: (_) => setState(() {
                  _place = p;
                  if (p != 'home' && !_costEdited) _cost.clear();
                  _autoCost();
                }),
              ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _odo,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Odometer (km)',
              helperText: prev == null ? null : 'Last: ${fmtKm(prev.odometerKm)} km${km == null ? '' : ' · ${fmtKm1(km)} km since'}',
              border: const OutlineInputBorder(),
            ),
            validator: (v) => (double.tryParse((v ?? '').replaceAll(',', '')) ?? 0) > 0 ? null : 'Enter the odometer reading',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _pctStart,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Battery before %', border: OutlineInputBorder()),
                onChanged: (_) => setState(_autoCost),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _pctEnd,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Battery after %', border: OutlineInputBorder()),
                onChanged: (_) => setState(_autoCost),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _kwh,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'kWh',
                  helperText: _num(_kwh) == null && kwh > 0 ? 'About ${kwh.toStringAsFixed(1)} from the battery %' : 'From the charger or app',
                  border: const OutlineInputBorder(),
                ),
                validator: (_) => _kwhValue > 0 ? null : 'kWh, or battery % with the battery size set',
                onChanged: (_) => setState(_autoCost),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cost,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Cost \$',
                  helperText: _place == 'home' && !_costEdited ? 'At ${settings.homeRateCents.toStringAsFixed(0)}c/kWh' : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => _costEdited = true),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text(
            [
              if (kwh > 0 && cost != null && cost > 0) '\$${(cost / kwh).toStringAsFixed(2)}/kWh',
              if (km != null && kwh > 0) '${(kwh / km * 100).toStringAsFixed(1)} kWh/100 km since last',
            ].join(' · '),
            style: t.bodySmall,
          ),
          if (_place != 'home') ...[
            const SizedBox(height: 12),
            TextField(controller: _station, decoration: const InputDecoration(labelText: 'Charger (e.g. ChargeNet Taupō)', border: OutlineInputBorder())),
          ],
          const SizedBox(height: 12),
          TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.bolt),
              label: Text('Home power rate: ${settings.homeRateCents.toStringAsFixed(0)}c/kWh'),
              onPressed: () async {
                await editHomeRate(context);
                setState(_autoCost);
              },
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _saving ? null : _save,
            child: Text(widget.existing == null ? 'Save charge' : 'Save changes'),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in [_odo, _kwh, _cost, _pctStart, _pctEnd, _station, _notes]) {
      c.dispose();
    }
    super.dispose();
  }
}

/// Asks for the home electricity rate (cents per kWh, including GST).
Future<void> editHomeRate(BuildContext context) async {
  final settings = AppScope.of(context).settings;
  final ctl = TextEditingController(text: settings.homeRateCents.toStringAsFixed(1));
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Home power rate'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('What you pay per kWh, including GST. Use your night or EV rate if you charge overnight.'),
        const SizedBox(height: 12),
        TextField(
          controller: ctl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cents per kWh', border: OutlineInputBorder()),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
      ],
    ),
  );
  final v = double.tryParse(ctl.text);
  if (ok == true && v != null && v > 0) await settings.setHomeRateCents(v);
}
