/// One expense in full (service, WOF, rego, insurance, tyres, toll,
/// parking, other) with its photos and documents, plus the filters used on
/// the History > Expenses list.
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../app.dart';
import '../data/attachment_store.dart';
import '../data/database.dart';
import '../data/repository.dart' show newId;
import 'attachments.dart';
import 'format.dart';
import 'service_page.dart' show expenseKinds, deleteServiceRecord, LogServiceForm;
import 'toll_form.dart';
import 'trip_detail_page.dart';

/// Expenses matching every filter given. [query] looks in the description,
/// place and notes; [withDocs] keeps only those with a photo or document.
List<Expense> filterExpenses(List<Expense> items, {String? kind, int? year, String query = '', Set<String>? withDocs}) {
  final q = query.trim().toLowerCase();
  return [
    for (final e in items)
      if ((kind == null || e.kind == kind) &&
          (year == null || e.at.year == year) &&
          (withDocs == null || withDocs.contains(e.id)) &&
          (q.isEmpty || [e.description, e.location ?? '', e.notes ?? ''].any((s) => s.toLowerCase().contains(q))))
        e,
  ];
}

class ExpenseDetailPage extends StatelessWidget {
  final String expenseId;
  const ExpenseDetailPage({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    return StreamBuilder<Expense?>(
      stream: scope.repo.watchExpense(expenseId),
      builder: (context, snap) {
        final e = snap.data;
        if (e == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: snap.connectionState == ConnectionState.waiting ? const CircularProgressIndicator() : const Text('This expense was deleted')),
          );
        }
        Widget row(String label, String value, {VoidCallback? onTap}) => InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 110, child: Text(label, style: t.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                  Expanded(child: Text(value, style: onTap == null ? t.bodyMedium : t.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary))),
                  if (onTap != null) const Icon(Icons.chevron_right, size: 18),
                ]),
              ),
            );
        final tollOrParking = e.kind == 'toll' || e.kind == 'parking';
        return Scaffold(
          appBar: AppBar(
            title: Text(expenseKinds[e.kind] ?? 'Expense'),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => tollOrParking
                    ? editTollParking(context, existing: e)
                    : Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExpenseEditPage(expense: e))),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete this expense?'),
                      content: const Text('Its photos and documents are deleted too.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  await deleteServiceRecord(scope, e.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(e.description, style: t.headlineSmall),
              const SizedBox(height: 4),
              Text(fmtMoney(e.cost), style: t.titleLarge),
              const SizedBox(height: 12),
              row('Type', expenseKinds[e.kind] ?? e.kind),
              row('Date', fmtDate(e.at)),
              if (e.odometerKm != null) row('Odometer', '${fmtKm(e.odometerKm!)} km'),
              if (e.location != null) row('Where', e.location!),
              if (e.notes != null) row('Notes', e.notes!),
              if (e.reminderMonths != null || e.reminderKm != null)
                row('Repeat every', [if (e.reminderMonths != null) '${e.reminderMonths} months', if (e.reminderKm != null) '${fmtKm(e.reminderKm!)} km'].join(' or ')),
              if (e.source != 'app') row('Added from', e.source == 'roadtrip' ? 'Road Trip import' : 'Import'),
              if (e.tripId != null)
                row('Trip', 'Open the trip', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripDetailPage(tripId: e.tripId!)))),
              const SizedBox(height: 20),
              AttachmentStrip(vehicleId: e.vehicleId, ownerKind: 'expense', ownerId: e.id, docType: docTypeForExpense(e.kind)),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.link),
                  label: const Text('Link a document from Documents'),
                  onPressed: () => _linkExisting(context, e),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Moves a stand-alone document (More > Documents) onto this expense.
  Future<void> _linkExisting(BuildContext context, Expense e) async {
    final scope = AppScope.of(context);
    final loose = (await scope.repo.watchVehicleAttachments(e.vehicleId).first).where((a) => a.ownerKind == 'vehicle').toList();
    if (!context.mounted) return;
    if (loose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No unlinked documents. Add one here with Attach, or under More > Documents.')));
      return;
    }
    AttachmentStore? store;
    try {
      store = await AttachmentStore.get();
    } catch (_) {}
    if (!context.mounted) return;
    final picked = await showModalBottomSheet<Attachment>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text('Documents not linked to anything yet')),
          for (final a in loose)
            ListTile(
              leading: store == null ? const Icon(Icons.description_outlined) : AttachmentThumb(a: a, store: store, size: 40),
              title: Text(a.title ?? docTypes[a.docType] ?? 'Document'),
              subtitle: Text(fmtDate(a.docDate ?? a.addedAt)),
              onTap: () => Navigator.pop(c, a),
            ),
        ]),
      ),
    );
    if (picked != null) await scope.repo.relinkAttachment(picked.id, 'expense', e.id);
  }
}

/// Add or edit any expense other than tolls and parking (they have their
/// own form). New expenses go to the active vehicle.
class ExpenseEditPage extends StatefulWidget {
  final Expense? expense;
  final String kind;
  const ExpenseEditPage({super.key, this.expense, this.kind = 'other'});
  @override
  State<ExpenseEditPage> createState() => _ExpenseEditPageState();
}

class _ExpenseEditPageState extends State<ExpenseEditPage> {
  Expense? get _e => widget.expense;
  late final String _id = _e?.id ?? newId();
  late DateTime _at = _e?.at ?? DateTime.now();
  late String _kind = () {
    final k = _e?.kind ?? widget.kind;
    return expenseKinds.containsKey(k) && k != 'toll' && k != 'parking' ? k : 'other';
  }();
  late final _desc = TextEditingController(text: _e?.description ?? '');
  late final _cost = TextEditingController(text: _e?.cost.toStringAsFixed(2) ?? '');
  late final _odo = TextEditingController(text: _e?.odometerKm?.round().toString() ?? '');
  late final _where = TextEditingController(text: _e?.location ?? '');
  late final _notes = TextEditingController(text: _e?.notes ?? '');
  var _saved = false;
  AppScope? _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = AppScope.of(context);
  }

  @override
  void dispose() {
    final scope = _scope;
    // Photos added to a new expense that was never saved.
    if (_e == null && !_saved && scope != null) AttachmentStore.get().then((s) => s.removeOwner(scope.repo, 'expense', _id), onError: (_) {});
    super.dispose();
  }

  String? _opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    final scope = AppScope.of(context);
    final cost = double.tryParse(_cost.text.replaceAll(r'$', '').replaceAll(',', ''));
    if (cost == null && _e == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the cost')));
      return;
    }
    final c = ExpensesCompanion(
      id: Value(_id),
      vehicleId: Value(_e?.vehicleId ?? scope.settings.activeVehicleId!),
      at: Value(_at),
      kind: Value(_kind),
      description: Value(_opt(_desc) ?? expenseKinds[_kind]!),
      cost: Value(cost ?? _e!.cost),
      odometerKm: Value(double.tryParse(_odo.text.replaceAll(',', ''))),
      location: Value(_opt(_where)),
      notes: Value(_opt(_notes)),
    );
    await scope.repo.upsertExpense(_e == null ? c : _e!.toCompanion(true).copyWith(
          at: c.at,
          kind: c.kind,
          description: c.description,
          cost: c.cost,
          odometerKm: c.odometerKm,
          location: c.location,
          notes: c.notes,
        ));
    _saved = true;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_e == null ? 'Add an expense' : 'Edit expense')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event),
          title: Text(fmtDate(_at)),
          trailing: const Icon(Icons.edit_calendar_outlined),
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(1990), lastDate: DateTime.now().add(const Duration(days: 366)));
            if (d != null) setState(() => _at = d);
          },
        ),
        DropdownButtonFormField<String>(
          initialValue: _kind,
          decoration: const InputDecoration(labelText: 'Type', border: border),
          items: [
            for (final k in expenseKinds.entries)
              if (k.key != 'toll' && k.key != 'parking') DropdownMenuItem(value: k.key, child: Text(k.value)),
          ],
          onChanged: (v) => setState(() => _kind = v ?? 'other'),
        ),
        const SizedBox(height: 12),
        TextField(controller: _desc, decoration: InputDecoration(labelText: _e == null ? 'Description (optional)' : 'Description', border: border)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(controller: _cost, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Cost \$', border: border)),
          ),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: _odo, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Odometer (km)', border: border))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: _where, decoration: const InputDecoration(labelText: 'Where (optional)', border: border)),
        const SizedBox(height: 12),
        TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes (optional)', border: border)),
        if (_e == null) ...[
          const SizedBox(height: 16),
          AttachmentStrip(vehicleId: scope.settings.activeVehicleId!, ownerKind: 'expense', ownerId: _id, docType: docTypeForExpense(_kind)),
        ],
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ]),
    );
  }
}

/// "Add an expense": choose what it was, then the right form.
Future<void> addExpense(BuildContext context) async {
  final picked = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: ListView(shrinkWrap: true, children: [
        const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text('What was it?')),
        for (final (k, icon, sub) in const [
          ('service', Icons.build_outlined, 'Ticks off items on your service schedule'),
          ('wof', Icons.verified_outlined, null),
          ('rego', Icons.badge_outlined, null),
          ('tyres', Icons.tire_repair, null),
          ('insurance', Icons.shield_outlined, 'A payment. Policies themselves are in More > Car care'),
          ('toll', Icons.toll_outlined, null),
          ('parking', Icons.local_parking, null),
          ('other', Icons.receipt_long_outlined, 'Repairs, cleaning, accessories, anything else'),
        ])
          ListTile(leading: Icon(icon), title: Text(expenseKinds[k]!), subtitle: sub == null ? null : Text(sub), onTap: () => Navigator.pop(c, k)),
      ]),
    ),
  );
  if (picked == null || !context.mounted) return;
  if (picked == 'toll' || picked == 'parking') {
    await editTollParking(context, kind: picked);
  } else if (picked == 'service' || picked == 'wof') {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => LogServiceForm(kind: picked)));
  } else {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExpenseEditPage(kind: picked)));
  }
}
