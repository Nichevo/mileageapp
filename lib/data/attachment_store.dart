import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'repository.dart';

/// Kinds of document, for labels and grouping.
const docTypes = {
  'wof': 'WOF',
  'service': 'Service invoice',
  'insurance': 'Insurance',
  'rego': 'Registration',
  'tyres': 'Tyres',
  'other': 'Other',
};

/// The document type that fits an expense kind.
String docTypeForExpense(String kind) => docTypes.containsKey(kind) ? kind : 'other';

String mimeForPath(String path) => switch (p.extension(path).toLowerCase()) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.heic' => 'image/heic',
      '.pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };

bool isImage(Attachment a) => a.mimeType.startsWith('image/');

/// Photos and PDFs kept in the app's private storage. They stay through app
/// updates, and go into the backup file.
class AttachmentStore {
  final Directory dir;
  AttachmentStore(this.dir);

  static AttachmentStore? _instance;
  static set instance(AttachmentStore s) => _instance = s;
  static Future<AttachmentStore> get() async {
    if (_instance != null) return _instance!;
    final base = await getApplicationSupportDirectory();
    final d = Directory(p.join(base.path, 'attachments'));
    await d.create(recursive: true);
    return _instance = AttachmentStore(d);
  }

  File file(Attachment a) => File(p.join(dir.path, a.fileName));

  /// Copies [sourcePath] in and records it.
  Future<Attachment> add(
    Repository repo, {
    required String sourcePath,
    required String vehicleId,
    required String ownerKind,
    required String ownerId,
    String docType = 'other',
    String? title,
    DateTime? docDate,
  }) async {
    final id = newId();
    var ext = p.extension(sourcePath).toLowerCase();
    if (ext.isEmpty) ext = '.bin';
    final name = '$id$ext';
    await dir.create(recursive: true);
    final copy = await File(sourcePath).copy(p.join(dir.path, name));
    final row = AttachmentsCompanion.insert(
      id: id,
      vehicleId: vehicleId,
      ownerKind: ownerKind,
      ownerId: ownerId,
      docType: Value(docType),
      title: Value(title),
      fileName: name,
      mimeType: mimeForPath(sourcePath),
      sizeBytes: Value(await copy.length()),
      docDate: Value(docDate),
    );
    await repo.db.into(repo.db.attachments).insert(row);
    return (await (repo.db.select(repo.db.attachments)..where((a) => a.id.equals(id))).getSingle());
  }

  Future<void> remove(Repository repo, Attachment a) async {
    await (repo.db.delete(repo.db.attachments)..where((x) => x.id.equals(a.id))).go();
    final f = file(a);
    if (await f.exists()) await f.delete();
  }

  /// Removes everything attached to a record that is being deleted.
  Future<void> removeOwner(Repository repo, String ownerKind, String ownerId) async {
    for (final a in await repo.attachmentsOf(ownerKind, ownerId)) {
      await remove(repo, a);
    }
  }
}
