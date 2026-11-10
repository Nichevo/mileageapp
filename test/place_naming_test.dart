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
import 'package:mileagelog/domain/trip_stats.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/trip_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'road_match_test.dart' show drive;

void main() {
  testWidgets('either end of a trip can be named from the trip page', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false, 'weatherLookup': false});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final s = drive(174.70, 174.73);
    await repo.saveRecordedTrip(
      TripsCompanion.insert(id: 't', vehicleId: v.id, name: 'x', startAt: s.first.at, endAt: Value(s.last.at), status: const Value('done'), statsJson: Value(jsonEncode(computeTripStats(s).toJson()))),
      [for (final p in s) TripPointsCompanion.insert(tripId: 't', at: p.at, lat: p.lat, lon: p.lon, speedMps: Value(p.speedMps), accuracyM: Value(p.accuracyM))],
      const [],
    );
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: TripDetailPage(tripId: 't'))));
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Name the start'), findsOneWidget);
    await tester.tap(find.text('Name the destination'));
    await tester.pumpAndSettle();
    expect(find.text('Name where this trip ended'), findsOneWidget);
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect(settings.places.single.name, 'Work');
    expect(settings.places.single.lon, closeTo(s.last.lon, 1e-9));
    expect(find.text('To Work'), findsOneWidget);
    expect(find.text('Name the destination'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
