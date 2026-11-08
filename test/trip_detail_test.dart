import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/road_match.dart';
import 'package:mileagelog/domain/trip_stats.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/trip_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'road_match_test.dart' show drive, area;

void main() {
  testWidgets('trip page shows road types and traffic lights', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final samples = drive(174.700, 174.730, stopAt: [174.7097]);
    final json = computeTripStats(samples).toJson()
      ..['road'] = matchRoads(samples, area()).toJson()
      ..['battery'] = {'start': 80, 'end': 76, 'charging': false};
    await repo.saveRecordedTrip(
      TripsCompanion.insert(id: 't1', vehicleId: v.id, name: 'Morning drive', startAt: samples.first.at, status: const Value('done'), statsJson: Value(jsonEncode(json))),
      [for (final s in samples) TripPointsCompanion.insert(tripId: 't1', at: s.at, lat: s.lat, lon: s.lon, speedMps: Value(s.speedMps), accuracyM: Value(s.accuracyM))],
      const [],
    );
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: TripDetailPage(tripId: 't1'))));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.scrollUntilVisible(find.text('Road types'), 200);
    expect(find.text('1 red of 2'), findsOneWidget);
    expect(find.text('4%'), findsOneWidget);
    expect(find.textContaining('Highway / main road 100%'), findsOneWidget);
    expect(find.textContaining('stopped at 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
