import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../data/attachment_store.dart';
import '../data/database.dart';
import 'expense_page.dart' show ExpenseDetailPage;
import '../platform/location.dart';
import 'format.dart';

/// Where a picked file came from; tests replace this.
typedef FilePick = Future<String?> Function(BuildContext context, String source);

Future<String?> _defaultPick(BuildContext context, String source) async {
  switch (source) {
    case 'camera':
    case 'gallery':
      final x = await ImagePicker().pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );
      return x?.path;
    default:
      final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'heic']);
      return r?.files.single.path;
  }
}

FilePick filePick = _defaultPick;

/// Asks camera, photo or file, and returns the picked file's path.
Future<String?> pickDocumentFile(BuildContext context) async {
  final source = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (c) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Take a photo'), onTap: () => Navigator.pop(c, 'camera')),
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Choose a photo'), onTap: () => Navigator.pop(c, 'gallery')),
        ListTile(leading: const Icon(Icons.picture_as_pdf_outlined), title: const Text('Choose a PDF or file'), onTap: () => Navigator.pop(c, 'file')),
      ]),
    ),
  );
  if (source == null || !context.mounted) return null;
  try {
    return await filePick(context, source);
  } catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t get the file: $e')));
    return null;
  }
}

/// A small preview: the photo, or a PDF/file icon.
class AttachmentThumb extends StatelessWidget {
  final Attachment a;
  final AttachmentStore store;
  final double size;
  const AttachmentThumb({super.key, required this.a, required this.store, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = Icon(a.mimeType == 'application/pdf' ? Icons.picture_as_pdf_outlined : Icons.insert_drive_file_outlined, color: cs.primary);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        color: cs.surfaceContainerHighest,
        child: isImage(a)
            ? Image.file(store.file(a), fit: BoxFit.cover, cacheWidth: (size * 3).round(), errorBuilder: (_, _, _) => icon)
            : Center(child: icon),
      ),
    );
  }
}

/// Photos and PDFs attached to one record, with a button to add more.
class AttachmentStrip extends StatefulWidget {
  final String vehicleId, ownerKind, ownerId, docType;
  /// Notes and incidents: record where each photo was taken.
  final bool withLocation;
  final String? heading;
  const AttachmentStrip(
      {super.key, required this.vehicleId, required this.ownerKind, required this.ownerId, this.docType = 'other', this.withLocation = false, this.heading = 'Photos and documents'});
  @override
  State<AttachmentStrip> createState() => _AttachmentStripState();
}

class _AttachmentStripState extends State<AttachmentStrip> {
  AttachmentStore? _store;

  @override
  void initState() {
    super.initState();
    AttachmentStore.get().then((s) {
      if (mounted) setState(() => _store = s);
    }, onError: (_) {}); // no storage (tests): the strip stays empty
  }

  Future<void> _add() async {
    final scope = AppScope.of(context);
    final path = await pickDocumentFile(context);
    if (path == null || _store == null) return;
    final a = await _store!.add(scope.repo,
        sourcePath: path, vehicleId: widget.vehicleId, ownerKind: widget.ownerKind, ownerId: widget.ownerId, docType: widget.docType);
    if (widget.withLocation) {
      final fix = await currentFix();
      if (fix != null) await scope.repo.setAttachmentPlace(a.id, fix.lat, fix.lon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final store = _store;
    if (store == null) return const SizedBox(height: 48);
    return StreamBuilder<List<Attachment>>(
      stream: scope.repo.watchAttachmentsOf(widget.ownerKind, widget.ownerId),
      builder: (context, snap) {
        final list = snap.data ?? const <Attachment>[];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.heading != null) ...[Text(widget.heading!, style: t.titleSmall), const SizedBox(height: 8)],
          Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            for (final a in list)
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttachmentViewer(attachment: a, store: store))),
                child: AttachmentThumb(a: a, store: store),
              ),
            OutlinedButton.icon(onPressed: _add, icon: const Icon(Icons.attach_file), label: Text(list.isEmpty ? 'Attach photo or PDF' : 'Add another')),
          ]),
        ]);
      },
    );
  }
}

/// Full-screen photo (pinch to zoom), or a PDF with an Open button.
class AttachmentViewer extends StatelessWidget {
  final Attachment attachment;
  final AttachmentStore store;
  const AttachmentViewer({super.key, required this.attachment, required this.store});

  Future<void> _share() => SharePlus.instance.share(ShareParams(files: [XFile(store.file(attachment).path, mimeType: attachment.mimeType)]));

  @override
  Widget build(BuildContext context) {
    final a = attachment;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(a.title ?? docTypes[a.docType] ?? 'Document'),
        actions: [
          IconButton(tooltip: 'Edit details', icon: const Icon(Icons.edit_outlined), onPressed: () async {
              if (await editAttachmentDetails(context, a) && context.mounted) Navigator.of(context).pop();
            }),
          IconButton(tooltip: 'Share or open in another app', icon: const Icon(Icons.share_outlined), onPressed: _share),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final repo = AppScope.of(context).repo;
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete this document?'),
                  content: const Text('The photo or file is removed from the phone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (ok != true) return;
              await store.remove(repo, a);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            [
              'Added ${fmtDate(a.addedAt)} ${TimeOfDay.fromDateTime(a.addedAt).format(context)}',
              if (a.lat != null) 'at ${a.lat!.toStringAsFixed(5)}, ${a.lon!.toStringAsFixed(5)}',
            ].join(' '),
            style: t.bodySmall,
          ),
        ),
      ),
      body: isImage(a)
          ? InteractiveViewer(maxScale: 6, child: Center(child: Image.file(store.file(a))))
          : Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.picture_as_pdf_outlined, size: 72),
                const SizedBox(height: 12),
                Text('${docTypes[a.docType]}, ${(a.sizeBytes / 1024).ceil()} KB', style: t.bodyMedium),
                const SizedBox(height: 16),
                FilledButton.icon(onPressed: _share, icon: const Icon(Icons.open_in_new), label: const Text('Open in another app')),
              ]),
            ),
    );
  }
}

/// Type, title and date of a document.
Future<bool> editAttachmentDetails(BuildContext context, Attachment a) async {
  final repo = AppScope.of(context).repo;
  final r = await _askDetails(context, docType: a.docType, title: a.title, date: a.docDate);
  if (r == null) return false;
  await repo.updateAttachment(a.id, docType: r.docType, title: r.title, docDate: r.date);
  return true;
}

Future<({String docType, String? title, DateTime? date})?> _askDetails(BuildContext context, {String docType = 'other', String? title, DateTime? date}) {
  final ctl = TextEditingController(text: title ?? '');
  var type = docType;
  var d = date;
  return showDialog<({String docType, String? title, DateTime? date})>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, set) => AlertDialog(
        title: const Text('Document details'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
            items: [for (final e in docTypes.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
            onChanged: (v) => set(() => type = v ?? 'other'),
          ),
          const SizedBox(height: 12),
          TextField(controller: ctl, decoration: const InputDecoration(labelText: 'Title (optional)', hintText: 'e.g. WOF certificate', border: OutlineInputBorder())),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(d == null ? 'Date (optional)' : fmtDate(d!)),
            onTap: () async {
              final p = await showDatePicker(context: c, initialDate: d ?? DateTime.now(), firstDate: DateTime(1990), lastDate: DateTime(2100));
              if (p != null) set(() => d = p);
            },
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(c, (docType: type, title: ctl.text.trim().isEmpty ? null : ctl.text.trim(), date: d)),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

/// Every document for the current vehicle, by type.
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});
  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  AttachmentStore? _store;

  @override
  void initState() {
    super.initState();
    AttachmentStore.get().then((s) {
      if (mounted) setState(() => _store = s);
    }, onError: (_) {}); // no storage (tests): the strip stays empty
  }

  Future<void> _add() async {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    final path = await pickDocumentFile(context);
    if (path == null || _store == null || !mounted) return;
    final d = await _askDetails(context, date: DateTime.now());
    if (d == null) return;
    await _store!.add(scope.repo, sourcePath: path, vehicleId: vid, ownerKind: 'vehicle', ownerId: vid, docType: d.docType, title: d.title, docDate: d.date);
  }

  static const _from = {'expense': 'On an expense', 'policy': 'From an insurance policy', 'note': 'In a note or incident'};

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final store = _store;
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add document')),
      body: store == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Attachment>>(
              stream: scope.repo.watchVehicleAttachments(scope.settings.activeVehicleId!),
              builder: (context, snap) {
                final list = snap.data ?? const <Attachment>[];
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No documents yet. Add a photo of a WOF sheet, service invoice, insurance schedule or rego papers. '
                        'You can also attach them to service records and insurance policies in Car care. They stay on this phone and go in the backup file.'),
                  );
                }
                return ListView(padding: const EdgeInsets.only(bottom: 88), children: [
                  for (final type in docTypes.keys)
                    if (list.any((a) => a.docType == type)) ...[
                      Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 4), child: Text(docTypes[type]!, style: t.titleSmall)),
                      for (final a in list.where((a) => a.docType == type))
                        ListTile(
                          leading: AttachmentThumb(a: a, store: store, size: 48),
                          title: Text(a.title ?? docTypes[a.docType]!),
                          subtitle: Text([fmtDate(a.docDate ?? a.addedAt), if (_from[a.ownerKind] != null) _from[a.ownerKind]!].join(' · ')),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttachmentViewer(attachment: a, store: store))),
                          trailing: a.ownerKind == 'expense'
                              ? IconButton(
                                  tooltip: 'Open the expense',
                                  icon: const Icon(Icons.receipt_long_outlined),
                                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExpenseDetailPage(expenseId: a.ownerId))),
                                )
                              : null,
                        ),
                    ],
                ]);
              },
            ),
    );
  }
}
