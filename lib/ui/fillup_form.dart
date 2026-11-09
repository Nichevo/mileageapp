import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/prices.dart';
import '../domain/sharetank.dart';
import '../prices/national_prices.dart';
import 'format.dart';
import 'prices_page.dart' show openGaspy, gaspyAvailable;

const fuelTypes = ['91', '95', '98', 'diesel'];
const paymentTags = ['Pump price', 'Sharetank', 'AA Smartfuel', 'Voucher'];

/// Create or edit a fill-up. Keyboard opens on Odometer; trip km and price
/// per litre are shown as you type.
class FillUpForm extends StatefulWidget {
  final EnergyEvent? existing;
  const FillUpForm({super.key, this.existing});

  @override
  State<FillUpForm> createState() => _FillUpFormState();
}

class _FillUpFormState extends State<FillUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _odo = TextEditingController();
  final _litres = TextEditingController();
  final _cost = TextEditingController();
  final _notes = TextEditingController();
  final _stationCtl = TextEditingController();
  final _shareL = TextEditingController();
  final _pump = TextEditingController();
  ShareLedger? _ledger;
  bool _costEdited = false;
  DateTime _at = DateTime.now();
  bool _full = true;
  String? _fuelType;
  String? _payment;
  EnergyEvent? _previous;
  Position? _fix;
  bool _locating = false;
  bool _saving = false;
  List<Station> _stations = const [];
  NationalPrices? _national;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _odo.text = _trim(e.odometerKm);
      _litres.text = _trim(e.quantity);
      _cost.text = _trim(e.cost);
      _notes.text = e.notes ?? '';
      _stationCtl.text = e.stationName ?? '';
      _at = e.at;
      _full = e.isFull;
      _fuelType = e.fuelType;
      _payment = e.paymentNote;
      if (e.sharetankLitres != null) _shareL.text = _trim(e.sharetankLitres!);
      if (e.listCost != null && e.quantity > 0) _pump.text = (e.listCost! / e.quantity).toStringAsFixed(3);
      _costEdited = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  static String _trim(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  Future<void> _load() async {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    final prev = await scope.repo.latestEvent(vid);
    final stations = await scope.repo.watchStations().first;
    if (!mounted) return;
    setState(() {
      _previous = prev;
      _stations = stations;
      if (widget.existing == null) {
        _fuelType ??= scope.settings.lastFuelType;
        if (_stationCtl.text.isEmpty) _stationCtl.text = scope.settings.lastStation ?? '';
      }
    });
    await _loadLedger();
    if (widget.existing == null && scope.settings.useGps) _locate();
    try {
      final n = await NationalPriceSource.load();
      if (mounted) setState(() => _national = n);
    } catch (_) {}
  }

  Future<void> _loadLedger() async {
    final l = await AppScope.of(context).repo.sharetankLedger(fuelType: _fuelType, excludeEventId: widget.existing?.id);
    if (!mounted) return;
    setState(() {
      _ledger = l;
      _autoCost();
    });
  }

  bool get _isShare => _payment == 'Sharetank';
  double? get _pumpPrice {
    final v = double.tryParse(_pump.text.replaceAll(r'$', '').trim());
    return v != null && v > 0 ? v : null;
  }

  /// Litres taken from Sharetank: as typed, or the whole fill (up to the
  /// balance, when purchases have been entered).
  double get _shareLitres {
    final typed = double.tryParse(_shareL.text);
    if (typed != null) return typed;
    final l = _litresValue ?? 0;
    final bal = _ledger?.balance ?? 0;
    return bal > 0 && bal < l ? bal : l;
  }

  /// Sharetank litres at their locked price, plus the rest at the pump.
  ({double cost, double short})? get _shareCost {
    final litres = _litresValue;
    if (!_isShare || litres == null || litres <= 0) return null;
    final share = _shareLitres.clamp(0, litres).toDouble();
    final locked = (_ledger ?? const ShareLedger([], {})).costOf(share);
    final pump = _pumpPrice;
    final cost = sharetankFillCost(litres: litres, shareLitres: share - locked.short, shareCost: locked.cost, pumpPrice: pump);
    return (cost: cost, short: locked.short);
  }

  void _autoCost() {
    if (_costEdited) return;
    final c = _shareCost;
    if (c != null) _cost.text = c.cost.toStringAsFixed(2);
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      final fix = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      if (!mounted) return;
      setState(() => _fix = fix);
      // Match to a known station within 150 m.
      Station? best;
      double bestD = 150;
      for (final s in _stations) {
        if (s.lat == null || s.lon == null) continue;
        final d = Geolocator.distanceBetween(fix.latitude, fix.longitude, s.lat!, s.lon!);
        if (d < bestD) {
          bestD = d;
          best = s;
        }
      }
      if (best != null && mounted) setState(() => _stationCtl.text = best!.name);
    } catch (_) {
      // No fix: carry on without it.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  double? get _odoValue => double.tryParse(_odo.text.replaceAll(',', ''));
  double? get _litresValue => double.tryParse(_litres.text);
  double? get _costValue => double.tryParse(_cost.text.replaceAll(r'$', ''));

  double? get _tripKm {
    final o = _odoValue;
    if (o == null) return null;
    final prev = _previous;
    if (prev == null || (widget.existing != null && prev.id == widget.existing!.id)) return null;
    final d = o - prev.odometerKm;
    return d > 0 ? d : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final scope = AppScope.of(context);
    final repo = scope.repo;
    final vid = scope.settings.activeVehicleId!;
    final stationName = _stationCtl.text.trim();
    Station? station;
    if (stationName.isNotEmpty) {
      station = await repo.stationByName(stationName, lat: _fix?.latitude, lon: _fix?.longitude);
    }
    final id = widget.existing?.id ?? newId();
    await repo.upsertEvent(EnergyEventsCompanion(
      id: Value(id),
      vehicleId: Value(vid),
      kind: const Value('fuel'),
      at: Value(_at),
      odometerKm: Value(_odoValue!),
      tripKm: Value(_tripKm ?? widget.existing?.tripKm),
      quantity: Value(_litresValue!),
      cost: Value(_costValue!),
      isFull: Value(_full),
      stationId: Value(station?.id),
      stationName: Value(stationName.isEmpty ? null : stationName),
      fuelType: Value(_fuelType),
      paymentNote: Value(_payment),
      sharetankLitres: Value(_isShare ? _shareLitres.clamp(0, _litresValue!).toDouble() : null),
      listCost: Value(_pumpPrice == null ? null : _pumpPrice! * _litresValue!),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
      lat: Value(_fix?.latitude ?? widget.existing?.lat),
      lon: Value(_fix?.longitude ?? widget.existing?.lon),
      source: Value(widget.existing?.source ?? 'app'),
      sourceRef: Value(widget.existing?.sourceRef),
      updatedAt: Value(DateTime.now()),
    ));
    await scope.settings.setLastStation(stationName.isEmpty ? null : stationName);
    await scope.settings.setLastFuelType(_fuelType);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this fill-up?'),
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
    final litres = _litresValue, cost = _costValue;
    final price = (litres != null && litres > 0 && cost != null) ? cost / litres : null;
    final trip = _tripKm;
    final per100 = (trip != null && litres != null && _full) ? litres / trip * 100 : null;
    final prev = _previous;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New fill-up' : 'Edit fill-up'),
        actions: [
          if (widget.existing != null) IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text('${fmtDate(_at)} ${TimeOfDay.fromDateTime(_at).format(context)}'),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 1)));
                if (d == null || !mounted) return;
                if (!context.mounted) return;
                final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
                setState(() => _at = DateTime(d.year, d.month, d.day, t?.hour ?? _at.hour, t?.minute ?? _at.minute));
              },
            ),
            TextFormField(
              controller: _odo,
              autofocus: widget.existing == null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Odometer (km)',
                helperText: prev == null
                    ? null
                    : 'Last: ${fmtKm(prev.odometerKm)} km${trip == null ? '' : ' · trip ${fmtKm1(trip)} km'}',
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final n = double.tryParse((v ?? '').replaceAll(',', ''));
                if (n == null || n <= 0) return 'Enter the odometer reading';
                if (prev != null && widget.existing == null && n < prev.odometerKm) return 'Lower than the last reading (${fmtKm(prev.odometerKm)})';
                if (prev != null && widget.existing == null && n - prev.odometerKm > 1500) return 'More than 1,500 km since last fill, is that right?';
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _litres,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Litres', border: OutlineInputBorder()),
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) > 0 ? null : 'Litres',
                  onChanged: (_) => setState(_autoCost),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cost,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Total \$', border: OutlineInputBorder()),
                  validator: (v) => (double.tryParse((v ?? '').replaceAll(r'$', '')) ?? -1) >= 0 ? null : 'Cost',
                  onChanged: (_) => setState(() => _costEdited = true),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              [
                if (price != null) fmtPrice(price),
                if (per100 != null) '${fmtPer100(per100)} L/100 km this tank',
                if (price == null && per100 == null) 'Price/L and L/100 km appear once litres and cost are entered',
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_nationalLine(price) != null || gaspyAvailable)
              Row(children: [
                Expanded(child: Text(_nationalLine(price) ?? '', style: Theme.of(context).textTheme.bodySmall)),
                if (gaspyAvailable)
                  TextButton.icon(onPressed: () => openGaspy(context), icon: const Icon(Icons.open_in_new, size: 16), label: const Text('Gaspy')),
              ]),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Filled to full'),
              subtitle: const Text('Economy is only worked out between two full tanks'),
              value: _full,
              onChanged: (v) => setState(() => _full = v),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Autocomplete<String>(
                  initialValue: TextEditingValue(text: _stationCtl.text),
                  optionsBuilder: (v) => _stations.map((s) => s.name).where((n) => n.toLowerCase().contains(v.text.toLowerCase())),
                  onSelected: (v) => _stationCtl.text = v,
                  fieldViewBuilder: (context, ctl, focus, onSubmit) {
                    ctl.addListener(() => _stationCtl.text = ctl.text);
                    return TextField(
                      controller: ctl,
                      focusNode: focus,
                      decoration: InputDecoration(
                        labelText: 'Station',
                        border: const OutlineInputBorder(),
                        suffixIcon: _locating
                            ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                            : IconButton(icon: Icon(_fix == null ? Icons.gps_not_fixed : Icons.gps_fixed), onPressed: _locate, tooltip: 'Use GPS'),
                      ),
                    );
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: [
                for (final f in fuelTypes)
                  ChoiceChip(
                    label: Text(f),
                    selected: _fuelType == f,
                    onSelected: (s) {
                      setState(() => _fuelType = s ? f : null);
                      _loadLedger();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                for (final p in paymentTags)
                  ChoiceChip(
                    label: Text(p),
                    selected: _payment == p,
                    onSelected: (s) => setState(() {
                      _payment = s ? p : null;
                      if (_payment == 'Sharetank' && widget.existing == null) _costEdited = false;
                      _autoCost();
                    }),
                  ),
              ],
            ),
            if (_isShare) ..._sharetankFields(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _saving ? null : _save,
              child: Text(widget.existing == null ? 'Save fill-up' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sharetankFields() {
    final litres = _litresValue;
    final c = _shareCost;
    final pump = _pumpPrice;
    final l = _ledger;
    final t = Theme.of(context).textTheme;
    return [
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _shareL,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'From Sharetank (L)',
              hintText: litres == null ? null : _shareLitres.toStringAsFixed(2),
              helperText: 'Blank for all of it',
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(_autoCost),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _pump,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Pump price \$/L', helperText: 'To see what you saved', border: OutlineInputBorder()),
            onChanged: (_) => setState(_autoCost),
          ),
        ),
      ]),
      const SizedBox(height: 6),
      Text(
        [
          if (l != null && l.balance > 0) 'Sharetank has ${l.balance.toStringAsFixed(1)} L at ${fmtPrice(l.averagePrice)} on average',
          if (l == null || l.balance <= 0) 'No Sharetank purchases entered yet: add them in More > Z Sharetank to cost this fill at the locked price',
          if (c != null && c.short > 0.01 && (l?.balance ?? 0) > 0) '${c.short.toStringAsFixed(1)} L more than the balance${pump == null ? '' : ', costed at the pump price'}',
          if (c != null && pump != null && litres != null && litres > 0 && c.short < _shareLitres - 0.01)
            'Saved ${fmtMoney(pump * litres - c.cost)} against the pump',
        ].join('. '),
        style: t.bodySmall,
      ),
    ];
  }

  /// "National average $2.79/L that week · you paid 6c under".
  String? _nationalLine(double? price) {
    final cents = _national?.centsAt(mbieFuelFor(_fuelType), _at);
    if (cents == null) return null;
    final base = 'National average ${fmtPrice(cents / 100)} that week';
    if (price == null) return base;
    final diff = price * 100 - cents;
    return diff.round() == 0 ? '$base · about the same' : '$base · you paid ${diff.abs().round()}c ${diff < 0 ? 'less' : 'more'}';
  }

  @override
  void dispose() {
    _odo.dispose();
    _litres.dispose();
    _cost.dispose();
    _notes.dispose();
    _stationCtl.dispose();
    _shareL.dispose();
    _pump.dispose();
    super.dispose();
  }
}
