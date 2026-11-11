import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../data/attachment_store.dart';
import 'attachments.dart';
import 'format.dart';

/// NZTA page for paying a toll (or opening a toll account).
const nztaTollUrl = 'https://www.nzta.govt.nz/roads-and-rail/toll-roads/';

Future<void> openTollPayment(BuildContext context) async {
  try {
    await const MethodChannel('mileagelog/trips').invokeMethod('openUrl', {'url': nztaTollUrl});
  } catch (_) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Couldn\'t open the browser')));
  }
}

IconData tollParkingIcon(String kind) => kind == 'toll' ? Icons.toll_outlined : Icons.local_parking;

/// Add or edit a toll or parking charge, optionally tied to a trip.
Future<void> editTollParking(
  BuildContext context, {
  Expense? existing,
  String kind = 'toll',
  String? tripId,
  DateTime? at,
  String? place,
}) async {
  final scope = AppScope.of(context);
  final repo = scope.repo;
  final vid = existing?.vehicleId ?? scope.settings.activeVehicleId!;
  var k = existing?.kind ?? kind;
  var when = existing?.at ?? at ?? DateTime.now();
  // Tolls cost the same each time, so start from the last one.
  final last = existing == null
      ? (await repo.expenses(vid)).where((e) => e.kind == k).firstOrNull
      : null;
  final cost = TextEditingController(text: existing?.cost.toStringAsFixed(2) ?? (k == 'toll' && last != null ? last.cost.toStringAsFixed(2) : ''));
  final where = TextEditingController(text: existing?.location ?? place ?? '');
  final notes = TextEditingController(text: existing?.notes ?? '');
  final id = existing?.id ?? newId();
  if (!context.mounted) return;
  final result = await showDialog<String>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) {
        final v = double.tryParse(cost.text.replaceAll(r'$', ''));
        return AlertDialog(
          title: Text(existing == null ? 'Toll or parking' : 'Edit ${k == 'toll' ? 'toll' : 'parking'}'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'toll', label: Text('Toll'), icon: Icon(Icons.toll_outlined)),
                  ButtonSegment(value: 'parking', label: Text('Parking'), icon: Icon(Icons.local_parking)),
                ],
                selected: {k},
                onSelectionChanged: (s) => setState(() => k = s.first),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text(fmtDate(when)),
                onTap: () async {
                  final p = await showDatePicker(context: c, initialDate: when, firstDate: DateTime(2015), lastDate: DateTime.now().add(const Duration(days: 1)));
                  if (p != null) setState(() => when = DateTime(p.year, p.month, p.day, when.hour, when.minute));
                },
              ),
              TextField(
                controller: cost,
                autofocus: existing == null,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cost \$', border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: where,
                decoration: InputDecoration(labelText: k == 'toll' ? 'Toll road' : 'Where', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              AttachmentStrip(vehicleId: vid, ownerKind: 'expense', ownerId: id, docType: 'other'),
            ]),
          ),
          actions: [
            if (existing != null) TextButton(onPressed: () => Navigator.pop(c, 'delete'), child: const Text('Delete')),
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            FilledButton(onPressed: v != null && v >= 0 ? () => Navigator.pop(c, 'save') : null, child: const Text('Save')),
          ],
        );
      },
    ),
  );
  Future<void> dropFiles() => AttachmentStore.get().then((s) => s.removeOwner(repo, 'expense', id), onError: (_) {});
  if (result == 'delete') {
    await dropFiles();
    await repo.deleteExpense(existing!.id);
  } else if (result != 'save' && existing == null) {
    await dropFiles(); // photos added to a toll or parking that was never saved
  } else if (result == 'save') {
    final place = where.text.trim();
    await repo.upsertExpense(ExpensesCompanion(
      id: Value(id),
      vehicleId: Value(vid),
      at: Value(when),
      kind: Value(k),
      description: Value(k == 'toll' ? (place.isEmpty ? 'Toll' : 'Toll: $place') : (place.isEmpty ? 'Parking' : 'Parking: $place')),
      cost: Value(double.parse(cost.text.replaceAll(r'$', ''))),
      location: Value(place.isEmpty ? null : place),
      notes: Value(notes.text.trim().isEmpty ? null : notes.text.trim()),
      tripId: Value(existing?.tripId ?? tripId),
    ));
  }
}
