import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';
import '../domain/energy.dart';
import '../domain/loan.dart';
import '../trips/recorder.dart';
import 'format.dart';
import 'trip_detail_page.dart';
import 'trip_format.dart';

double? _num(TextEditingController c) => double.tryParse(c.text.replaceAll(r'$', '').replaceAll(',', '').trim());
String? _text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

/// Fuel gauge picker in eighths.
class FuelGauge extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  final String label;
  const FuelGauge({super.key, required this.value, required this.onChanged, this.label = 'Fuel level'});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label: ${value == null ? 'not set' : fuelLabel(value)}', style: t.bodyMedium),
      Slider(value: (value ?? 8).toDouble(), min: 0, max: 8, divisions: 8, label: fuelLabel(value ?? 8), onChanged: (v) => onChanged(v.round())),
    ]);
  }
}

/// Add or edit a loan or rental car.
class LoanCarPage extends StatefulWidget {
  final Vehicle? vehicle; // edit
  final String kind; // 'loan' or 'rental' for a new one
  const LoanCarPage({super.key, this.vehicle, this.kind = 'loan'});
  @override
  State<LoanCarPage> createState() => _LoanCarPageState();
}

class _LoanCarPageState extends State<LoanCarPage> {
  late final LoanDetails? _old = LoanDetails.decode(widget.vehicle?.loanJson);
  late String _kind = _old?.kind ?? widget.kind;
  late String _fuelKind = widget.vehicle?.kind ?? 'petrol';
  late final _make = TextEditingController(text: widget.vehicle?.make ?? '');
  late final _model = TextEditingController(text: widget.vehicle?.model ?? '');
  late final _name = TextEditingController(text: widget.vehicle?.name ?? '');
  late final _plate = TextEditingController(text: _old?.plate ?? '');
  late final _from = TextEditingController(text: _old?.from ?? '');
  late final _reason = TextEditingController(text: _old?.reason ?? '');
  late final _odo = TextEditingController(text: _old?.collectedKm?.round().toString() ?? '');
  late final _booking = TextEditingController(text: _old?.bookingRef ?? '');
  late final _pickup = TextEditingController(text: _old?.pickupPlace ?? '');
  late final _dropoff = TextEditingController(text: _old?.returnPlace ?? '');
  late final _cost = TextEditingController(text: _old?.totalCost?.toStringAsFixed(2) ?? '');
  late final _excess = TextEditingController(text: _old?.excess?.round().toString() ?? '');
  late final _allowance = TextEditingController(text: _old?.kmAllowance?.toString() ?? '');
  late final _notes = TextEditingController(text: _old?.notes ?? '');
  late DateTime _collected = _old?.collectedAt ?? DateTime.now();
  late DateTime? _dueBack = _old?.dueBackAt;
  late int? _fuel = _old?.collectedFuel ?? 8;
  late String _policy = _old?.fuelPolicy ?? 'full_to_full';
  late String? _forVehicle = _old?.forVehicleId;
  List<Vehicle> _own = const [];

  bool get _rental => _kind == 'rental';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final all = await AppScope.of(context).repo.liveVehicles();
      if (mounted) setState(() => _own = [for (final v in all) if (v.ownership == 'own') v]);
    });
  }

  String get _defaultName {
    final car = [_text(_make), _text(_model)].whereType<String>().join(' ');
    return '${_rental ? 'Rental' : 'Loan'} ${car.isEmpty ? 'car' : car}';
  }

  LoanDetails _details() => LoanDetails(
        kind: _kind,
        collectedAt: _collected,
        from: _text(_from),
        reason: _text(_reason),
        plate: _text(_plate)?.toUpperCase(),
        forVehicleId: _forVehicle,
        notes: _text(_notes),
        collectedKm: _num(_odo),
        collectedFuel: _fuel,
        returnedAt: _old?.returnedAt,
        returnedKm: _old?.returnedKm,
        returnedFuel: _old?.returnedFuel,
        bookingRef: _rental ? _text(_booking) : null,
        pickupPlace: _rental ? _text(_pickup) : null,
        returnPlace: _rental ? _text(_dropoff) : null,
        fuelPolicy: _rental ? _policy : null,
        dueBackAt: _rental ? _dueBack : null,
        totalCost: _rental ? _num(_cost) : null,
        excess: _rental ? _num(_excess) : null,
        kmAllowance: _rental ? _num(_allowance)?.round() : null,
      );

  Future<void> _save() async {
    final scope = AppScope.of(context);
    final v = await scope.repo.saveLoanCar(
      id: widget.vehicle?.id,
      name: _text(_name) ?? _defaultName,
      kind: _fuelKind,
      make: _text(_make),
      model: _text(_model),
      loan: _details(),
    );
    if (widget.vehicle == null) await scope.settings.setActiveVehicleId(v.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<DateTime?> _pickDate(DateTime initial) async {
    final d = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d == null || !mounted) return null;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    return DateTime(d.year, d.month, d.day, t?.hour ?? initial.hour, t?.minute ?? initial.minute);
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    const gap = SizedBox(height: 12);
    final t = Theme.of(context).textTheme;
    Widget field(TextEditingController c, String label, {TextInputType? type, String? hint, ValueChanged<String>? onChanged}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: c,
            keyboardType: type,
            onChanged: onChanged,
            decoration: InputDecoration(labelText: label, hintText: hint, border: border),
          ),
        );
    const money = TextInputType.numberWithOptions(decimal: true);
    return Scaffold(
      appBar: AppBar(title: Text(widget.vehicle == null ? (_rental ? 'Rental car' : 'Loan car') : 'Edit ${_rental ? 'rental' : 'loan car'}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'loan', label: Text('Loan car'), icon: Icon(Icons.car_rental)),
            ButtonSegment(value: 'rental', label: Text('Rental'), icon: Icon(Icons.receipt_long_outlined)),
          ],
          selected: {_kind},
          onSelectionChanged: (s) => setState(() => _kind = s.first),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: field(_make, 'Make', hint: 'e.g. Toyota', onChanged: (_) => setState(() {}))),
          const SizedBox(width: 12),
          Expanded(child: field(_model, 'Model', hint: 'e.g. Corolla', onChanged: (_) => setState(() {}))),
        ]),
        field(_name, 'Name in the app', hint: _defaultName),
        Wrap(spacing: 8, runSpacing: 4, children: [
          for (final k in vehicleKinds)
            ChoiceChip(label: Text(vehicleKindLabel(k)), selected: _fuelKind == k, onSelected: (_) => setState(() => _fuelKind = k)),
        ]),
        gap,
        field(_plate, 'Plate (optional)'),
        field(_from, _rental ? 'Rental company' : 'Loaned by', hint: _rental ? 'e.g. the rental firm' : 'e.g. the garage, insurer or a friend'),
        if (!_rental) ...[
          field(_reason, 'Why (optional)', hint: 'e.g. my car is in for a service'),
          if (_own.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String?>(
                initialValue: _forVehicle,
                decoration: const InputDecoration(labelText: 'Instead of', border: border),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None of my cars')),
                  for (final v in _own) DropdownMenuItem(value: v.id, child: Text(v.name)),
                ],
                onChanged: (v) => setState(() => _forVehicle = v),
              ),
            ),
        ],
        Text('Collected', style: t.titleSmall),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event),
          title: Text('${fmtDate(_collected)}, ${TimeOfDay.fromDateTime(_collected).format(context)}'),
          trailing: const Icon(Icons.edit_calendar_outlined),
          onTap: () async {
            final d = await _pickDate(_collected);
            if (d != null) setState(() => _collected = d);
          },
        ),
        field(_odo, 'Odometer at pick-up (km)', type: TextInputType.number),
        FuelGauge(value: _fuel, onChanged: (v) => setState(() => _fuel = v), label: 'Fuel at pick-up'),
        if (_rental) ...[
          const SizedBox(height: 8),
          Text('Booking', style: t.titleSmall),
          const SizedBox(height: 8),
          field(_booking, 'Booking reference'),
          Row(children: [
            Expanded(child: field(_pickup, 'Pick-up location')),
            const SizedBox(width: 12),
            Expanded(child: field(_dropoff, 'Return location')),
          ]),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available),
            title: Text(_dueBack == null ? 'Due back: not set' : 'Due back ${fmtDate(_dueBack!)}, ${TimeOfDay.fromDateTime(_dueBack!).format(context)}'),
            subtitle: const Text('You get a reminder the day before'),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final d = await _pickDate(_dueBack ?? _collected.add(const Duration(days: 3)));
              if (d != null) setState(() => _dueBack = d);
            },
          ),
          Row(children: [
            Expanded(child: field(_cost, 'Total cost \$', type: money)),
            const SizedBox(width: 12),
            Expanded(child: field(_excess, 'Insurance excess \$', type: money)),
          ]),
          field(_allowance, 'Km included (blank = unlimited)', type: TextInputType.number),
          DropdownButtonFormField<String>(
            initialValue: _policy,
            decoration: const InputDecoration(labelText: 'Fuel policy', border: border),
            items: [for (final e in fuelPolicies.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => setState(() => _policy = v ?? 'none'),
          ),
          gap,
        ],
        field(_notes, 'Notes (optional)'),
        Text(
          'Trips and fill-ups go to this car while it\'s selected. It has no service reminders and isn\'t sent to Google Sheets. '
          'To start trips by its Bluetooth, link it under Trips > car settings; handing it back removes the link.',
          style: t.bodySmall,
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: Text(widget.vehicle == null ? 'Start using this car' : 'Save')),
      ]),
    );
  }
}

/// Card on Home while a loan or rental car is the current vehicle.
class LoanBanner extends StatelessWidget {
  final Vehicle vehicle;
  const LoanBanner({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final l = LoanDetails.decode(vehicle.loanJson);
    if (l == null || vehicle.archivedAt != null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final overdue = l.dueBackAt != null && DateTime.now().isAfter(l.dueBackAt!);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: overdue ? cs.errorContainer : cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${l.label}${l.from == null ? '' : ' from ${l.from}'}', style: Theme.of(context).textTheme.titleSmall),
          Text([
            'Since ${fmtDate(l.collectedAt)}',
            if (l.dueBackAt != null) '${overdue ? 'was due back' : 'due back'} ${fmtDate(l.dueBackAt!)}',
            if (l.plate != null) l.plate!,
          ].join(' · ')),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoanCarPage(vehicle: vehicle))),
              child: const Text('Details'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HandBackPage(vehicle: vehicle))),
              child: const Text('Hand back'),
            ),
          ]),
        ]),
      ),
    );
  }
}

/// Return details, then a summary, then the car is archived and the app goes
/// back to your own car.
class HandBackPage extends StatefulWidget {
  final Vehicle vehicle;
  const HandBackPage({super.key, required this.vehicle});
  @override
  State<HandBackPage> createState() => _HandBackPageState();
}

class _HandBackPageState extends State<HandBackPage> {
  late final LoanDetails _l = LoanDetails.decode(widget.vehicle.loanJson)!;
  DateTime _at = DateTime.now();
  final _odo = TextEditingController();
  late int? _fuel = _l.collectedFuel;
  final _notes = TextEditingController();

  Future<void> _done() async {
    final scope = AppScope.of(context);
    final returned = _l.handBack(at: _at, km: _num(_odo), fuel: _fuel, notes: _text(_notes));
    final summary = await scope.repo.loanSummary(widget.vehicle.id, returned);
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Hand back ${widget.vehicle.name}?'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final line in summary.lines(returned, fmtMoney)) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $line')),
          const SizedBox(height: 8),
          const Text('It moves to Past loan and rental cars, with its trips. The app switches back to your own car.'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Not yet')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Hand back')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await scope.repo.handBack(widget.vehicle.id, returned);
    if (scope.settings.vehicleCars.containsKey(widget.vehicle.id)) {
      await scope.settings.setVehicleCar(widget.vehicle.id, null);
      await TripRecorder.syncCars(scope.settings);
    }
    if (scope.settings.activeVehicleId == widget.vehicle.id) {
      final live = await scope.repo.liveVehicles();
      final back = live.where((v) => v.id == _l.forVehicleId).firstOrNull ?? live.where((v) => v.ownership == 'own').firstOrNull ?? live.firstOrNull;
      if (back != null) await scope.settings.setActiveVehicleId(back.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Hand back ${widget.vehicle.name}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event),
          title: Text('${fmtDate(_at)}, ${TimeOfDay.fromDateTime(_at).format(context)}'),
          trailing: const Icon(Icons.edit_calendar_outlined),
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _at, firstDate: _l.collectedAt, lastDate: DateTime.now().add(const Duration(days: 1)));
            if (d != null) setState(() => _at = DateTime(d.year, d.month, d.day, _at.hour, _at.minute));
          },
        ),
        TextField(
          controller: _odo,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Odometer now (km)',
            helperText: _l.collectedKm == null ? null : 'It was ${fmtKm(_l.collectedKm!)} km at pick-up',
            border: border,
          ),
        ),
        const SizedBox(height: 12),
        FuelGauge(value: _fuel, onChanged: (v) => setState(() => _fuel = v), label: 'Fuel now'),
        if (_l.collectedFuel != null) Text('It was ${fuelLabel(_l.collectedFuel)} at pick-up${_l.fuelPolicy == 'full_to_full' ? ', and the rental is full to full' : ''}.', style: t.bodySmall),
        const SizedBox(height: 12),
        TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'e.g. small scratch noted at return', border: border)),
        const SizedBox(height: 20),
        FilledButton(onPressed: _done, child: const Text('Hand back')),
      ]),
    );
  }
}

/// Loan and rental cars you've handed back, and vehicles you've archived.
class PastVehiclesPage extends StatelessWidget {
  const PastVehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Past vehicles')),
      body: StreamBuilder<List<Vehicle>>(
        stream: scope.repo.watchArchivedVehicles(),
        builder: (context, snap) {
          final list = snap.data ?? const <Vehicle>[];
          if (list.isEmpty) {
            return const Padding(padding: EdgeInsets.all(24), child: Text('Loan and rental cars you hand back, and vehicles you archive, are kept here with their trips.'));
          }
          return ListView(children: [
            for (final v in list)
              ListTile(
                leading: Icon(v.ownership == 'own' ? Icons.directions_car_outlined : Icons.car_rental),
                title: Text(v.name),
                subtitle: Text(() {
                  final l = LoanDetails.decode(v.loanJson);
                  if (l == null) return 'Archived ${fmtDate(v.archivedAt!)}';
                  return '${l.label}${l.from == null ? '' : ' from ${l.from}'} · ${fmtDate(l.collectedAt)} to ${fmtDate(l.returnedAt ?? v.archivedAt!)}';
                }()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PastVehiclePage(vehicle: v))),
              ),
          ]);
        },
      ),
    );
  }
}

/// One past vehicle: summary, its trips, and a way to bring it back.
class PastVehiclePage extends StatelessWidget {
  final Vehicle vehicle;
  const PastVehiclePage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final l = LoanDetails.decode(vehicle.loanJson);
    return Scaffold(
      appBar: AppBar(title: Text(vehicle.name)),
      body: FutureBuilder(
        future: Future.wait([
          if (l != null) scope.repo.loanSummary(vehicle.id, l) else Future.value(null),
          scope.repo.doneTrips(vehicle.id),
        ]),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final summary = snap.data![0] as LoanSummary?;
          final trips = snap.data![1] as List<Trip>;
          return ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text([vehicleKindLabel(vehicle.kind), ?vehicle.make, ?vehicle.model, ?l?.plate].join(' · '), style: t.bodyMedium),
                if (l != null) ...[
                  const SizedBox(height: 8),
                  Text('${l.label}${l.from == null ? '' : ' from ${l.from}'}', style: t.titleSmall),
                  if (l.reason != null) Text(l.reason!),
                  Text('Collected ${fmtDate(l.collectedAt)}${l.collectedKm == null ? '' : ' at ${fmtKm(l.collectedKm!)} km'}, fuel ${fuelLabel(l.collectedFuel)}'),
                  if (l.returnedAt != null)
                    Text('Returned ${fmtDate(l.returnedAt!)}${l.returnedKm == null ? '' : ' at ${fmtKm(l.returnedKm!)} km'}, fuel ${fuelLabel(l.returnedFuel)}'),
                  if (l.bookingRef != null) Text('Booking ${l.bookingRef}'),
                  if (l.notes != null) Text(l.notes!),
                  const SizedBox(height: 8),
                  for (final line in summary!.lines(l, fmtMoney)) Text('• $line'),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.unarchive_outlined),
                  label: const Text('Bring back to my vehicles'),
                  onPressed: () async {
                    await scope.repo.setArchived(vehicle.id, false);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 16),
                Text('Trips', style: t.titleSmall),
              ]),
            ),
            if (trips.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No trips recorded.')),
            for (final trip in trips)
              ListTile(
                leading: const Icon(Icons.route),
                title: Text(trip.name),
                subtitle: Text([fmtDate(trip.startAt), if (trip.gpsDistanceKm != null) '${fmtKm1(trip.gpsDistanceKm!)} km', if (trip.endAt != null) fmtDuration(trip.endAt!.difference(trip.startAt))].join(' · ')),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripDetailPage(tripId: trip.id))),
              ),
          ]);
        },
      ),
    );
  }
}
