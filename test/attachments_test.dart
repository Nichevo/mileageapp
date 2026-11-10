import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/backup/backup.dart';
import 'package:mileagelog/data/attachment_store.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/attachments.dart';
import 'package:mileagelog/ui/service_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1x1 PNG.
final png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

Future<String> sample(Directory dir, String name, List<int> bytes) async {
  final f = File('${dir.path}/$name');
  await f.writeAsBytes(bytes);
  return f.path;
}

void main() {
  test('documents are copied in, removed with their record, and go in the backup', () async {
    final tmp = await Directory.systemTemp.createTemp('mileage_att');
    final store = AttachmentStore(Directory('${tmp.path}/attachments'));
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final v = await repo.ensureVehicle();
    final photo = await sample(tmp, 'wof.JPG', png);
    final pdf = await sample(tmp, 'invoice.pdf', utf8.encode('%PDF-1.4 test'));
    final a = await store.add(repo, sourcePath: photo, vehicleId: v.id, ownerKind: 'expense', ownerId: 'e1', docType: 'wof');
    final b = await store.add(repo, sourcePath: pdf, vehicleId: v.id, ownerKind: 'vehicle', ownerId: v.id, docType: 'rego', title: 'Rego papers');
    expect(a.mimeType, 'image/jpeg');
    expect(b.mimeType, 'application/pdf');
    expect(store.file(a).readAsBytesSync(), png);
    expect(await File(photo).exists(), isTrue); // original left alone

    // Backup with files, restored onto a fresh phone.
    final json = await exportBackupJson(db, attachmentsDir: store.dir);
    final db2 = AppDatabase(NativeDatabase.memory());
    final dir2 = Directory('${tmp.path}/phone2');
    final summary = await restoreBackupJson(db2, json, attachmentsDir: dir2);
    expect(summary.rows['attachments'], 2);
    expect(summary.rows['document files'], 2);
    final restored = await db2.select(db2.attachments).get();
    expect(restored.map((x) => x.title), contains('Rego papers'));
    expect(File('${dir2.path}/${b.fileName}').readAsStringSync(), '%PDF-1.4 test');

    await store.removeOwner(repo, 'expense', 'e1');
    expect(await store.file(a).exists(), isFalse);
    expect((await db.select(db.attachments).get()).single.id, b.id);
    expect(docTypeForExpense('wof'), 'wof');
    expect(docTypeForExpense('parking'), 'other');
    await db.close();
    await db2.close();
    await tmp.delete(recursive: true);
  });

  testWidgets('a photo attached while logging a service stays with the record', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final tmp = (await tester.runAsync(() => Directory.systemTemp.createTemp('mileage_att_ui')))!;
    AttachmentStore.instance = AttachmentStore(Directory('${tmp.path}/attachments'));
    final photo = (await tester.runAsync(() => sample(tmp, 'invoice.png', png)))!;
    filePick = (context, source) async => photo;
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = (await tester.runAsync(() => repo.ensureVehicle()))!;
    await settings.setActiveVehicleId(v.id);
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<void> io() async {
      for (var i = 0; i < 12; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.pumpWidget(AppScope(
      repo: repo,
      settings: settings,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(children: [
              TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LogServiceForm())), child: const Text('log')),
              TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentsPage())), child: const Text('docs')),
            ]),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('log'));
    await tester.pumpAndSettle();
    await io();
    await tester.tap(find.text('Attach photo or PDF'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a photo'));
    await tester.pumpAndSettle();
    await io();
    expect(find.text('Add another'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Description (optional)'), 'Full service');
    await tester.tap(find.text('Save'));
    await io();
    await tester.pumpAndSettle();
    final e = (await tester.runAsync(() => db.select(db.expenses).getSingle()))!;
    final atts = (await tester.runAsync(() => db.select(db.attachments).get()))!;
    expect(atts.single.ownerId, e.id);
    expect(atts.single.docType, 'service');

    // It shows up in Documents.
    await tester.tap(find.text('docs'));
    await tester.pumpAndSettle();
    await io();
    expect(find.text('Service invoice'), findsWidgets);
    expect(find.textContaining('On an expense'), findsOneWidget);

    // And a stand-alone document can be added there.
    await tester.tap(find.text('Add document'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a PDF or file'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title (optional)'), 'WOF sheet');
    await tester.tap(find.text('Save'));
    await io();
    expect(find.text('WOF sheet'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() async {
      await db.close();
      await tmp.delete(recursive: true);
    });
  });
}
