import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/care.dart';
import 'format.dart';
import 'service_page.dart' show drivingNow;

const _wheels = ['Front left', 'Front right', 'Rear left', 'Rear right', 'Spare'];
const _short = ['FL', 'FR', 'RL', 'RR', 'Spare'];

List<double?> foundOf(TyreCheck c) => [c.foundFlKpa, c.foundFrKpa, c.foundRlKpa, c.foundRrKpa, c.foundSpareKpa];
List<double?> leftOf(TyreCheck c) => [c.leftFlKpa, c.leftFrKpa, c.leftRlKpa, c.leftRrKpa, c.leftSpareKpa];

class TyresPage extends StatefulWidget {
  const TyresPage({super.key});
  @override
  State<TyresPage> createState() => _TyresPageState();
}

class _TyresPageState extends State<TyresPage> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    final psi = scope.settings.pressurePsi;
    final unit = psi ? 'psi' : 'kPa';
    final t = Theme.of(context).textTheme;
    return StreamBuilder<List<TyreSet>>(
      stream: scope.repo.watchTyreSets(vid),
      builder: (context, setsSnap) {
        final sets = setsSnap.data ?? const <TyreSet>[];
        final current = sets.where((s) => s.removedAt == null).firstOrNull;
        return StreamBuilder<List<TyreCheck>>(
          stream: scope.repo.watchTyreChecks(vid),
          builder: (context, snap) {
            final checks = snap.data ?? const <TyreCheck>[];
            final last = checks.firstOrNull;
            final daysSince = last == null ? null : DateTime.now().difference(last.at).inDays;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Tyres'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await scope.settings.setPressurePsi(!psi);
                      setState(() {});
                    },
                    child: Text('Show ${psi ? 'kPa' : 'psi'}'),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TyreCheckForm(tyreSet: current))),
                icon: const Icon(Icons.tire_repair),
                label: const Text('Check tyres'),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  Card(
                    child: ListTile(
                      title: Text(current?.name ?? 'Current tyres'),
                      subtitle: Text(current == null
                          ? 'Add the tyre size and the recommended pressures from the door-pillar sticker'
                          : [
                              if (current.size != null) current.size!,
                              if (current.recommendedFrontKpa != null || current.recommendedRearKpa != null)
                                'recommended ${fmtPressure(current.recommendedFrontKpa, psi: psi)} front, ${fmtPressure(current.recommendedRearKpa, psi: psi)} rear $unit',
                              if (current.fittedAt != null) 'fitted ${fmtDate(current.fittedAt!)}${current.fittedOdometerKm == null ? '' : ' at ${fmtKm(current.fittedOdometerKm!)} km'}',
                            ].join('\n')),
                      isThreeLine: current != null,
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TyreSetForm(tyreSet: current))),
                    ),
                  ),
                  if (last != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Last checked ${daysSince == 0 ? 'today' : '$daysSince days ago'}'
                        '${daysSince != null && daysSince > tyreCheckEveryDays ? '. A monthly check is recommended.' : ''}',
                        style: t.bodyMedium?.copyWith(color: daysSince != null && daysSince > tyreCheckEveryDays ? Colors.orange.shade800 : null),
                      ),
                    ),
                  if (checks.isEmpty && snap.hasData)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No checks yet. Each check records what you found in each tyre and, if you added air, what you left them at.'),
                    ),
                  if (checks.isNotEmpty) Text('Checks ($unit, found → left)', style: t.titleSmall),
                  for (final c in checks) _checkTile(context, c, current, psi),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _checkTile(BuildContext context, TyreCheck c, TyreSet? set, bool psi) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final found = foundOf(c), left = leftOf(c);
    final rec = [set?.recommendedFrontKpa, set?.recommendedFrontKpa, set?.recommendedRearKpa, set?.recommendedRearKpa, null];
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TyreCheckForm(check: c, tyreSet: set))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${fmtDate(c.at)}${c.odometerKm == null ? '' : ' · ${fmtKm(c.odometerKm!)} km'}${c.airAdded ? ' · air added' : ''}',
                style: t.labelLarge,
              ),
              const SizedBox(height: 6),
              Wrap(spacing: 14, runSpacing: 4, children: [
                for (var i = 0; i < 5; i++)
                  if (found[i] != null || left[i] != null)
                    Text.rich(TextSpan(children: [
                      TextSpan(text: '${_short[i]} ', style: t.bodySmall),
                      TextSpan(
                        text: fmtPressure(found[i], psi: psi),
                        style: t.bodyMedium?.copyWith(
                          color: (underInflation(found[i], rec[i]) ?? 0) >= 0.1 ? cs.error : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (left[i] != null && left[i] != found[i]) TextSpan(text: ' → ${fmtPressure(left[i], psi: psi)}', style: t.bodyMedium),
                    ])),
              ]),
              if (c.notes != null) ...[const SizedBox(height: 4), Text(c.notes!, style: t.bodySmall)],
            ],
          ),
        ),
      ),
    );
  }
}

class TyreSetForm extends StatefulWidget {
  final TyreSet? tyreSet;
  const TyreSetForm({super.key, this.tyreSet});
  @override
  State<TyreSetForm> createState() => _TyreSetFormState();
}

class _TyreSetFormState extends State<TyreSetForm> {
  late bool _psi;
  late final TextEditingController _name, _size, _front, _rear, _odo, _cost;
  DateTime? _fitted;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initDone) return;
    _initDone = true;
    _psi = AppScope.of(context).settings.pressurePsi;
    final s = widget.tyreSet;
    String p(double? kpa) => kpa == null ? '' : fmtPressure(kpa, psi: _psi);
    _name = TextEditingController(text: s?.name ?? 'Current tyres');
    _size = TextEditingController(text: s?.size ?? '');
    _front = TextEditingController(text: p(s?.recommendedFrontKpa));
    _rear = TextEditingController(text: p(s?.recommendedRearKpa));
    _odo = TextEditingController(text: s?.fittedOdometerKm?.round().toString() ?? '');
    _cost = TextEditingController(text: s?.cost?.toString() ?? '');
    _fitted = s?.fittedAt;
  }

  bool _initDone = false;

  double? _kpa(TextEditingController c) {
    final v = double.tryParse(c.text.trim());
    return v == null ? null : (_psi ? psiToKpa(v) : v);
  }

  Future<void> _save({bool replace = false}) async {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    if (replace && widget.tyreSet != null) {
      // Retire the old set and start a new one with the same pressures.
      await scope.repo.upsertTyreSet(widget.tyreSet!.toCompanion(true).copyWith(removedAt: Value(_fitted ?? DateTime.now())));
    }
    await scope.repo.upsertTyreSet(TyreSetsCompanion.insert(
      id: replace || widget.tyreSet == null ? newId() : widget.tyreSet!.id,
      vehicleId: vid,
      name: _name.text.trim().isEmpty ? 'Tyres' : _name.text.trim(),
      size: Value(_size.text.trim().isEmpty ? null : _size.text.trim()),
      recommendedFrontKpa: Value(_kpa(_front)),
      recommendedRearKpa: Value(_kpa(_rear)),
      fittedAt: Value(_fitted),
      fittedOdometerKm: Value(double.tryParse(_odo.text.replaceAll(',', ''))),
      cost: Value(double.tryParse(_cost.text.replaceAll(r'$', '').replaceAll(',', ''))),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    final unit = _psi ? 'psi' : 'kPa';
    return Scaffold(
      appBar: AppBar(title: const Text('Tyres fitted')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name (brand or model)', border: border)),
          const SizedBox(height: 12),
          TextField(controller: _size, decoration: const InputDecoration(labelText: 'Size, e.g. 205/55R16', border: border)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _front, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Recommended front $unit', border: border))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _rear, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Recommended rear $unit', border: border))),
          ]),
          const SizedBox(height: 4),
          Text('The sticker is usually on the driver\'s door pillar or inside the fuel flap.', style: Theme.of(context).textTheme.bodySmall),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(_fitted == null ? 'Date fitted: not set' : 'Fitted ${fmtDate(_fitted!)}'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _fitted ?? DateTime.now(), firstDate: DateTime(1990), lastDate: DateTime.now());
              if (d != null) setState(() => _fitted = d);
            },
          ),
          Row(children: [
            Expanded(child: TextField(controller: _odo, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer when fitted', border: border))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _cost, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cost \$', border: border))),
          ]),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
          if (widget.tyreSet != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _save(replace: true),
              child: const Text('Save as a new set (new tyres fitted)'),
            ),
          ],
        ],
      ),
    );
  }
}

/// One check: pressures found and, if air was added, what they were left at.
/// Found and left share the same date, so both go in one record.
class TyreCheckForm extends StatefulWidget {
  final TyreCheck? check;
  final TyreSet? tyreSet;
  const TyreCheckForm({super.key, this.check, this.tyreSet});
  @override
  State<TyreCheckForm> createState() => _TyreCheckFormState();
}

class _TyreCheckFormState extends State<TyreCheckForm> {
  late bool _psi;
  late DateTime _at;
  late bool _air;
  late final List<TextEditingController> _found, _left;
  late final TextEditingController _odo, _notes;
  bool _spare = false;
  bool _initDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initDone) return;
    _initDone = true;
    _psi = AppScope.of(context).settings.pressurePsi;
    final c = widget.check;
    String p(double? kpa) => kpa == null ? '' : fmtPressure(kpa, psi: _psi);
    _at = c?.at ?? DateTime.now();
    _air = c?.airAdded ?? false;
    _found = [for (final v in c == null ? List<double?>.filled(5, null) : foundOf(c)) TextEditingController(text: p(v))];
    final rec = [widget.tyreSet?.recommendedFrontKpa, widget.tyreSet?.recommendedFrontKpa, widget.tyreSet?.recommendedRearKpa, widget.tyreSet?.recommendedRearKpa, null];
    _left = [
      for (var i = 0; i < 5; i++) TextEditingController(text: p(c == null ? rec[i] : leftOf(c)[i])),
    ];
    _spare = c?.foundSpareKpa != null;
    _odo = TextEditingController(text: c?.odometerKm?.round().toString() ?? '');
    _notes = TextEditingController(text: c?.notes ?? '');
    if (c == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final scope = AppScope.of(context);
        final events = await scope.repo.events(scope.settings.activeVehicleId!);
        final km = drivingNow(events).km;
        if (mounted && km != null && _odo.text.isEmpty) _odo.text = km.round().toString();
      });
    }
  }

  double? _kpa(TextEditingController c) {
    final v = double.tryParse(c.text.trim());
    return v == null ? null : (_psi ? psiToKpa(v) : v);
  }

  Future<void> _save() async {
    final scope = AppScope.of(context);
    final f = [for (final c in _found) _kpa(c)];
    final l = _air ? [for (final c in _left) _kpa(c)] : List<double?>.filled(5, null);
    if (!_spare) {
      f[4] = null;
      l[4] = null;
    }
    await scope.repo.upsertTyreCheck(TyreChecksCompanion.insert(
      id: widget.check?.id ?? newId(),
      vehicleId: scope.settings.activeVehicleId!,
      tyreSetId: Value(widget.tyreSet?.id),
      at: _at,
      odometerKm: Value(double.tryParse(_odo.text.replaceAll(',', ''))),
      foundFlKpa: Value(f[0]),
      foundFrKpa: Value(f[1]),
      foundRlKpa: Value(f[2]),
      foundRrKpa: Value(f[3]),
      foundSpareKpa: Value(f[4]),
      leftFlKpa: Value(l[0]),
      leftFrKpa: Value(l[1]),
      leftRlKpa: Value(l[2]),
      leftRrKpa: Value(l[3]),
      leftSpareKpa: Value(l[4]),
      airAdded: Value(_air),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await AppScope.of(context).repo.deleteTyreCheck(widget.check!.id);
    if (mounted) Navigator.of(context).pop();
  }

  void _copyFirstFound() {
    final v = _found[0].text;
    for (var i = 1; i < 4; i++) {
      if (_found[i].text.isEmpty) _found[i].text = v;
    }
  }

  Widget _pressureRow(int i) {
    const border = OutlineInputBorder();
    final unit = _psi ? 'psi' : 'kPa';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 90, child: Text(_wheels[i])),
        Expanded(
          child: TextField(
            controller: _found[i],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Found $unit', border: border, isDense: true),
          ),
        ),
        if (_air) ...[
          const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_forward, size: 18)),
          Expanded(
            child: TextField(
              controller: _left[i],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Left at', border: border, isDense: true),
            ),
          ),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    final rec = widget.tyreSet;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.check == null ? 'Tyre check' : 'Edit tyre check'),
        actions: [if (widget.check != null) IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: _delete)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text('${fmtDate(_at)} ${TimeOfDay.fromDateTime(_at).format(context)}'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(1990), lastDate: DateTime.now());
              if (d != null) setState(() => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute));
            },
          ),
          if (rec != null && (rec.recommendedFrontKpa != null || rec.recommendedRearKpa != null))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Recommended: ${fmtPressure(rec.recommendedFrontKpa, psi: _psi)} front, ${fmtPressure(rec.recommendedRearKpa, psi: _psi)} rear ${_psi ? 'psi' : 'kPa'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          for (var i = 0; i < 4; i++) _pressureRow(i),
          if (_spare) _pressureRow(4),
          Row(children: [
            TextButton.icon(onPressed: () => setState(_copyFirstFound), icon: const Icon(Icons.copy_all, size: 18), label: const Text('Same for all')),
            const Spacer(),
            TextButton(onPressed: () => setState(() => _spare = !_spare), child: Text(_spare ? 'Remove spare' : 'Add spare')),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Added air'),
            subtitle: const Text('Record what each tyre was left at. Pre-filled with the recommended pressure.'),
            value: _air,
            onChanged: (v) => setState(() => _air = v),
          ),
          const SizedBox(height: 8),
          TextField(controller: _odo, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer (km)', border: border)),
          const SizedBox(height: 12),
          TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes, e.g. slow leak rear left', border: border)),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
