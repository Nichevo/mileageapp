import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/platform/location.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/home_status.dart';
import 'package:mileagelog/ui/notes_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'driving_insights_test.dart' show sim;
import 'trip_upgrades_test.dart' show saveTrip, shifted;

void main() {
  Future<void> io(WidgetTester tester, [int n = 10]) async {
    for (var i = 0; i < n; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
  });

  testWidgets('home shows WOF, rego and insurance dates and the last tyre check', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = (await tester.runAsync(() => repo.ensureVehicle()))!;
    await settings.setActiveVehicleId(v.id);
    final now = DateTime.now();
    await tester.runAsync(() async {
      await repo.upsertServiceItem(ServiceItemsCompanion.insert(
          id: 'w', vehicleId: v.id, name: 'WOF', kind: const Value('wof'), intervalMonths: const Value(12), lastDoneAt: Value(DateTime(now.year, now.month - 11, now.day))));
      await repo.upsertServiceItem(ServiceItemsCompanion.insert(id: 'r', vehicleId: v.id, name: 'Rego', kind: const Value('rego'), intervalMonths: const Value(12)));
      await repo.upsertPolicy(InsurancePoliciesCompanion.insert(
          id: 'p', vehicleId: v.id, insurer: 'Test Insurer', startAt: DateTime(now.year - 1, now.month, now.day), renewAt: Value(DateTime(now.year, now.month + 6, now.day))));
      await repo.upsertTyreSet(TyreSetsCompanion.insert(id: 's', vehicleId: v.id, name: 'Summer', recommendedFrontKpa: const Value(240), recommendedRearKpa: const Value(230)));
      await repo.upsertTyreCheck(TyreChecksCompanion.insert(
        id: 'c',
        vehicleId: v.id,
        tyreSetId: const Value('s'),
        at: DateTime(now.year, now.month, now.day - 3),
        foundFlKpa: const Value(200),
        leftFlKpa: const Value(240),
        foundFrKpa: const Value(238),
        foundRlKpa: const Value(230),
        foundRrKpa: const Value(229),
      ));
    });
    await settings.setPressurePsi(false);
    await tester.pumpWidget(AppScope(
        repo: repo, settings: settings, child: const MaterialApp(home: Scaffold(body: Column(children: [KeyDatesCard(), TyreHomeCard(), LiveTripCard()])))));
    await io(tester);
    expect(find.text('WOF due'), findsOneWidget);
    expect(find.textContaining('in '), findsWidgets);
    expect(find.text('Not recorded'), findsOneWidget); // rego never done
    expect(find.text('Insurance due'), findsOneWidget);
    expect(find.text('Checked 3 days ago'), findsOneWidget);
    expect(find.text('240'), findsOneWidget); // FL left at 240
    expect(find.text('was 200'), findsOneWidget);
    expect(find.text('238'), findsOneWidget);
    expect(find.text('Recording a trip'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });

  testWidgets('an incident keeps time and place from the start, and its details', (tester) async {
    currentFix = () async => (lat: -36.9, lon: 174.8, accuracyM: 6.0);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = (await tester.runAsync(() => repo.ensureVehicle()))!;
    await settings.setActiveVehicleId(v.id);
    tester.view.physicalSize = const Size(900, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: NotesPage())));
    await io(tester);
    await tester.tap(find.text('New'));
    await io(tester, 3);
    await tester.tap(find.text('Accident or incident'));
    await io(tester);
    expect(find.textContaining('call 111'), findsOneWidget);
    expect(find.text('${(-36.9).toStringAsFixed(5)}, ${174.8.toStringAsFixed(5)} (±6 m)'), findsOneWidget);
    var notes = (await tester.runAsync(() => db.select(db.carNotes).get()))!;
    expect(notes.single.kind, 'incident');
    expect(notes.single.lat, -36.9);
    await tester.enterText(find.widgetWithText(TextField, 'Their number plate'), 'ZZ9999');
    await tester.enterText(find.widgetWithText(TextField, 'What happened'), 'Hit from behind while stopped');
    await tester.tap(find.byType(BackButton));
    await io(tester);
    notes = (await tester.runAsync(() => db.select(db.carNotes).get()))!;
    expect(decodeFields(notes.single.fieldsJson)['otherPlate'], 'ZZ9999');
    expect(find.textContaining('Hit from behind'), findsOneWidget);
    final text = noteText(notes.single, 'My car', (d) => '$d');
    expect(text, contains('Their number plate: ZZ9999'));
    expect(text, contains('openstreetmap.org/?mlat=-36.9'));
    expect(jsonDecode(notes.single.fieldsJson!), isA<Map>());
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });

  testWidgets('home shows where the car was parked after the last trip', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = (await tester.runAsync(() => repo.ensureVehicle()))!;
    await settings.setActiveVehicleId(v.id);
    final start = DateTime.now().subtract(const Duration(hours: 1));
    await tester.runAsync(() => saveTrip(repo, v.id, 't', 'To town', shifted(sim([('go', 2000)]), start)));
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: Scaffold(body: ParkedCard()))));
    await io(tester);
    expect(find.textContaining('Parked '), findsOneWidget); // 'at' or 'on <date>' near midnight
    expect(find.text('Find car'), findsOneWidget);
    expect(ParkedCard.directions(-36.9, 174.8).toString(), contains('destination=-36.9,174.8&travelmode=walking'));
    await tester.tap(find.text('Hide'));
    await io(tester, 4);
    expect(find.text('Find car'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
