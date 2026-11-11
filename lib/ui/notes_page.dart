/// Notes and incidents: a quick note, or an accident record with the other
/// driver's details, photos, and when and where it happened.
library;

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../data/attachment_store.dart';
import '../data/database.dart';
import '../data/repository.dart' show newId;
import '../platform/location.dart';
import 'attachments.dart';
import 'format.dart';
import 'trip_map.dart';

/// What to write down after an accident.
const incidentFields = [
  ('otherName', 'Other driver\'s name'),
  ('otherPhone', 'Their phone'),
  ('otherAddress', 'Their address'),
  ('otherPlate', 'Their number plate'),
  ('otherCar', 'Their car (make, model, colour)'),
  ('otherOwner', 'Owner, if not the driver'),
  ('otherInsurer', 'Their insurer'),
  ('otherLicence', 'Their licence number'),
  ('witnesses', 'Witnesses (names and phone numbers)'),
  ('police', 'Police officer or event number'),
  ('damageMine', 'Damage to your car'),
  ('damageTheirs', 'Damage to their car or property'),
  ('injuries', 'Injuries'),
  ('conditions', 'Road, weather and light'),
];

Map<String, String> decodeFields(String? json) => json == null || json.isEmpty ? {} : (jsonDecode(json) as Map).map((k, v) => MapEntry(k as String, '$v'));

String fmtWhen(BuildContext context, DateTime d) => '${fmtDate(d)} ${TimeOfDay.fromDateTime(d).format(context)}';

/// Plain-text record of a note, for sharing with an insurer.
String noteText(CarNote n, String vehicleName, String Function(DateTime) when) {
  final f = decodeFields(n.fieldsJson);
  return [
    '${n.kind == 'incident' ? 'Incident' : 'Note'}: ${n.title ?? ''}'.trim(),
    'Vehicle: $vehicleName',
    'When: ${when(n.at)}',
    if (n.lat != null)
      'Where: ${n.lat!.toStringAsFixed(5)}, ${n.lon!.toStringAsFixed(5)}'
          '${n.accuracyM == null ? '' : ' (±${n.accuracyM!.round()} m)'} https://www.openstreetmap.org/?mlat=${n.lat}&mlon=${n.lon}#map=18/${n.lat}/${n.lon}',
    if ((n.body ?? '').trim().isNotEmpty) '\n${n.body!.trim()}',
    for (final (k, label) in incidentFields)
      if ((f[k] ?? '').trim().isNotEmpty) '$label: ${f[k]!.trim()}',
  ].join('\n');
}

/// Start a note: incident or plain note.
Future<void> newNote(BuildContext context) async {
  final kind = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.car_crash_outlined),
            title: const Text('Accident or incident'),
            subtitle: const Text('Time and place saved now; photos, the other driver and witnesses'),
            onTap: () => Navigator.pop(c, 'incident'),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Note'),
            subtitle: const Text('Anything else, with photos and where you are'),
            onTap: () => Navigator.pop(c, 'note'),
          ),
        ],
      ),
    ),
  );
  if (kind == null || !context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditPage(kind: kind)));
}

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    return Scaffold(
      appBar: AppBar(title: const Text('Notes and incidents')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => newNote(context), icon: const Icon(Icons.add), label: const Text('New')),
      body: StreamBuilder<List<CarNote>>(
        stream: scope.repo.watchNotes(vid),
        builder: (context, snap) {
          final list = snap.data ?? const <CarNote>[];
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nothing yet. If you have an accident, tap New > Accident or incident: the time and place are saved straight away, '
                  'then add photos and the other driver\'s details. Notes stay on this phone and go in the backup.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final n in list)
                ListTile(
                  leading: Icon(n.kind == 'incident' ? Icons.car_crash_outlined : Icons.edit_note),
                  title: Text(n.title?.isNotEmpty == true ? n.title! : (n.kind == 'incident' ? 'Incident' : 'Note')),
                  subtitle: Text(
                    [fmtWhen(context, n.at), if ((n.body ?? '').isNotEmpty) n.body!.split('\n').first].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteEditPage(note: n))),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// New or existing note. A new one is saved as soon as it opens, so the
/// time and place are kept even if you get interrupted.
class NoteEditPage extends StatefulWidget {
  final CarNote? note;
  final String kind;
  const NoteEditPage({super.key, this.note, this.kind = 'note'});
  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late final String _id = widget.note?.id ?? newId();
  late String _kind = widget.note?.kind ?? widget.kind;
  late DateTime _at = widget.note?.at ?? DateTime.now();
  late final _title = TextEditingController(text: widget.note?.title ?? '');
  late final _body = TextEditingController(text: widget.note?.body ?? '');
  late final Map<String, TextEditingController> _fields = {
    for (final (k, _) in incidentFields) k: TextEditingController(text: decodeFields(widget.note?.fieldsJson)[k] ?? ''),
  };
  double? _lat, _lon, _acc;
  bool _locating = false;
  late String _vid;
  AppScope? _scope;

  @override
  void initState() {
    super.initState();
    _lat = widget.note?.lat;
    _lon = widget.note?.lon;
    _acc = widget.note?.accuracyM;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scope != null) return;
    _scope = AppScope.of(context);
    _vid = widget.note?.vehicleId ?? _scope!.settings.activeVehicleId!;
    if (widget.note == null) {
      _save();
      _locate();
    }
  }

  @override
  void dispose() {
    if (!_deleted) _save();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    final fix = await currentFix();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (fix != null) {
        _lat = fix.lat;
        _lon = fix.lon;
        _acc = fix.accuracyM;
      }
    });
    if (fix != null) await _save();
  }

  String? _opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    final f = {
      for (final e in _fields.entries)
        if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
    };
    await _scope!.repo.upsertNote(
      CarNotesCompanion(
        id: Value(_id),
        vehicleId: Value(_vid),
        at: Value(_at),
        kind: Value(_kind),
        title: Value(_opt(_title)),
        body: Value(_opt(_body)),
        fieldsJson: Value(f.isEmpty ? null : jsonEncode(f)),
        lat: Value(_lat),
        lon: Value(_lon),
        accuracyM: Value(_acc),
      ),
    );
  }

  Future<void> _share() async {
    await _save();
    final repo = _scope!.repo;
    final n = (await repo.watchNote(_id).first)!;
    final v = await repo.vehicle(_vid);
    if (!mounted) return;
    final text = noteText(n, v?.name ?? '', (d) => fmtWhen(context, d));
    final files = <XFile>[];
    try {
      final store = await AttachmentStore.get();
      for (final a in await repo.attachmentsOf('note', _id)) {
        files.add(XFile(store.file(a).path, mimeType: a.mimeType));
      }
    } catch (_) {}
    await SharePlus.instance.share(ShareParams(text: text, files: files.isEmpty ? null : files));
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this note?'),
        content: const Text('Its photos are deleted too.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = _scope!.repo;
    await AttachmentStore.get().then((s) => s.removeOwner(repo, 'note', _id), onError: (_) {});
    await repo.deleteNote(_id);
    _deleted = true;
    if (mounted) Navigator.of(context).pop();
  }

  bool _deleted = false;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    final t = Theme.of(context).textTheme;
    final incident = _kind == 'incident';
    return Scaffold(
      appBar: AppBar(
        title: Text(incident ? 'Incident' : 'Note'),
        actions: [
          IconButton(tooltip: 'Share', icon: const Icon(Icons.share_outlined), onPressed: _share),
          IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (incident && widget.note == null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'If anyone is hurt, call 111 first. The time and place are saved already. '
                  'Take photos of every vehicle, the number plates, the damage and the scene, then fill in what you can.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'incident', label: Text('Incident'), icon: Icon(Icons.car_crash_outlined)),
              ButtonSegment(value: 'note', label: Text('Note'), icon: Icon(Icons.edit_note)),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(fmtWhen(context, _at)),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _at, firstDate: DateTime(2000), lastDate: DateTime.now());
              if (d == null || !mounted) return;
              final tm = await showTimePicker(context: this.context, initialTime: TimeOfDay.fromDateTime(_at));
              setState(() => _at = DateTime(d.year, d.month, d.day, tm?.hour ?? _at.hour, tm?.minute ?? _at.minute));
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(
              _lat == null
                  ? (_locating ? 'Finding where you are…' : 'No location')
                  : '${_lat!.toStringAsFixed(5)}, ${_lon!.toStringAsFixed(5)}${_acc == null ? '' : ' (±${_acc!.round()} m)'}',
            ),
            trailing: TextButton(onPressed: _locating ? null : _locate, child: Text(_lat == null ? 'Get location' : 'Update')),
          ),
          if (_lat != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(height: 160, child: TripMap(route: [LatLng(_lat!, _lon!)], follow: true)),
            ),
          const SizedBox(height: 12),
          AttachmentStrip(vehicleId: _vid, ownerKind: 'note', ownerId: _id, withLocation: true, heading: 'Photos (each saves where it was taken)'),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: incident ? 'Short title, e.g. "Rear-ended at lights"' : 'Title', border: border),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            minLines: 3,
            maxLines: 10,
            decoration: InputDecoration(labelText: incident ? 'What happened' : 'Note', alignLabelWithHint: true, border: border),
          ),
          if (incident) ...[
            const SizedBox(height: 16),
            Text('Details', style: t.titleSmall),
            const SizedBox(height: 8),
            for (final (k, label) in incidentFields) ...[
              TextField(
                controller: _fields[k],
                maxLines: k.startsWith('damage') || k == 'witnesses' ? 3 : 1,
                minLines: 1,
                keyboardType: k == 'otherPhone' ? TextInputType.phone : TextInputType.text,
                textCapitalization: k == 'otherPlate' ? TextCapitalization.characters : TextCapitalization.sentences,
                decoration: InputDecoration(labelText: label, border: border, isDense: true),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 8),
          Text('Saved as you go. Share sends the details, a map link and the photos, for example to your insurer.', style: t.bodySmall),
        ],
      ),
    );
  }
}
