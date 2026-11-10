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
import 'package:mileagelog/ui/vehicle_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'road_match_test.dart' show drive;

void main() {
  test('each vehicle has its own Bluetooth, and one Bluetooth has one vehicle', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await Settings.load();
    await s.setVehicleCar('a', (address: 'AA:BB:CC:00:00:01', name: 'Toyota stereo'));
    await s.setVehicleCar('b', (address: 'AA:BB:CC:00:00:02', name: 'EV hands-free'));
    expect(s.vehicleForCar('aa:bb:cc:00:00:01'), 'a');
    expect(s.vehicleForCar('AA:BB:CC:00:00:02'), 'b');
    expect(s.vehicleForCar('11:22:33:44:55:66'), isNull);
    expect(s.vehicleForCar(null), isNull);
    // Linking the first Bluetooth to vehicle b takes it off vehicle a.
    await s.setVehicleCar('b', (address: 'AA:BB:CC:00:00:01', name: 'Toyota stereo'));
    expect(s.vehicleCars.keys, ['b']);
    await s.setVehicleCar('b', null);
    expect(s.vehicleCars, isEmpty);
  });

  testWidgets('a trip shows its vehicle and can be moved to another', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false, 'weatherLookup': false});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => Directory.systemTemp.path);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = (await tester.runAsync(() => repo.ensureVehicle(name: 'Petrol car')))!;
    await tester.runAsync(() => db.into(db.vehicles).insert(VehiclesCompanion.insert(id: 'ev', name: 'Electric car', kind: const Value('ev'))));
    await settings.setActiveVehicleId(v.id);
    final s = drive(174.70, 174.73);
    await tester.runAsync(() => repo.saveRecordedTrip(
          TripsCompanion.insert(id: 't', vehicleId: v.id, name: 'x', startAt: s.first.at, endAt: Value(s.last.at), status: const Value('done'), statsJson: Value(jsonEncode(computeTripStats(s).toJson()))),
          [for (final p in s) TripPointsCompanion.insert(tripId: 't', at: p.at, lat: p.lat, lon: p.lon, speedMps: Value(p.speedMps), accuracyM: Value(p.accuracyM))],
          const [],
        ));
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<void> io() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.pumpWidget(AppScope(
      repo: repo,
      settings: settings,
      child: const MaterialApp(home: Scaffold(appBar: _Bar(), body: TripDetailPage(tripId: 't'))),
    ));
    await io();
    expect(find.text('Petrol car'), findsNWidgets(2)); // app bar chip and on the trip
    await tester.tap(find.descendant(of: find.byType(TripDetailPage), matching: find.text('Petrol car')));
    await tester.pumpAndSettle();
    expect(find.text('Which vehicle was this trip in?'), findsOneWidget);
    await tester.tap(find.text('Electric car'));
    await io();
    final t = (await tester.runAsync(() => repo.trip('t')))!;
    expect(t.vehicleId, 'ev');
    expect(find.text('Trip moved to Electric car'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}

class _Bar extends StatelessWidget implements PreferredSizeWidget {
  const _Bar();
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) => AppBar(actions: const [VehicleChip()]);
}
