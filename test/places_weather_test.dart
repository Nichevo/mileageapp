import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/places.dart';
import 'package:mileagelog/domain/trip_stats.dart';
import 'package:mileagelog/domain/trip_weather.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/trips/recorder.dart';
import 'package:mileagelog/trips/weather_lookup.dart';
import 'package:mileagelog/ui/trips_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'road_match_test.dart' show drive, lat0;

Future<void> settle(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

List<GpsSample> shifted(List<GpsSample> s, DateTime start, {bool back = false}) {
  final d = start.difference(s.first.at);
  final out = [for (final p in s) GpsSample(p.at.add(d), p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM)];
  if (!back) return out;
  // Same times, route driven the other way.
  final rev = out.reversed.toList();
  return [for (var i = 0; i < out.length; i++) GpsSample(out[i].at, rev[i].lat, rev[i].lon, speedMps: out[i].speedMps, accuracyM: out[i].accuracyM)];
}

Map<String, Object?> hourly(String day) => {
      'hourly': {
        'time': [for (var h = 0; h < 24; h++) '${day}T${h.toString().padLeft(2, '0')}:00'],
        'temperature_2m': [for (var h = 0; h < 24; h++) 10.0 + h / 2],
        'precipitation': [for (var h = 0; h < 24; h++) h == 19 ? 1.6 : 0.0],
        'weather_code': [for (var h = 0; h < 24; h++) h == 19 ? 63 : 2],
        'wind_speed_10m': [for (var h = 0; h < 24; h++) 22.0],
        'wind_direction_10m': [for (var h = 0; h < 24; h++) 90.0],
      },
    };

void main() {
  test('places: matching, suggestions and trip titles', () {
    const home = Place('h', 'Home', -41.2, 174.7);
    const work = Place('w', 'Work', -41.25, 174.78);
    expect(placeAt((lat: -41.2005, lon: 174.7005), [home, work])?.name, 'Home');
    expect(placeAt((lat: -41.21, lon: 174.7), [home, work]), isNull);
    expect(placeTitle(home, work), 'Home → Work');
    expect(placeTitle(home, home), 'Round trip from Home');
    expect(placeTitle(null, work), 'To Work');
    expect(placeTitle(null, null), isNull);

    final ends = [
      for (var i = 0; i < 4; i++) (lat: -41.30 + i * 0.0002, lon: 174.80),
      (lat: -41.2, lon: 174.7), // at Home already
      (lat: -41.5, lon: 175.0),
    ];
    final s = suggestPlaces(ends, [home]);
    expect(s.single.count, 4);
    expect(s.single.at.lat, closeTo(-41.2997, 1e-4));
    expect(Place.listFromJson(Place.listToJson([home, work])).last.name, 'Work');
  });

  test('weather: nearest hour, words and wind', () {
    final w = weatherAt(hourly('2026-11-08'), DateTime.utc(2026, 11, 8, 19, 20))!;
    expect(w.tempC, 19.5);
    expect(w.code, 63);
    expect(weatherLabel(63, 1.6), 'rain');
    expect(weatherLabel(61, 0.2), 'light rain');
    expect(weatherLabel(0, 0), 'clear');
    expect(windRelative(90, 80), 'headwind');
    expect(windRelative(90, 270), 'tailwind');
    expect(windRelative(90, 0), 'crosswind');
    expect(w.describe(headingDeg: 85), '20°C, rain, 22 km/h headwind');
    expect(weatherAt(hourly('2026-11-08'), DateTime.utc(2026, 11, 10, 9)), isNull); // wrong day
    final heading = overallHeading(drive(174.70, 174.73))!;
    expect(heading, closeTo(90, 1)); // driving east
    expect(TripWeather.fromJson(w.toJson())!.windKmh, 22);
  });

  test('elevation: points along the route, climb and descent', () {
    final pts = elevationPoints(drive(174.70, 174.73)); // about 2.5 km
    expect(pts.first.km, 0);
    expect(pts.length, inInclusiveRange(12, 15));
    final e = TripElevation.fromHeights([0, 1, 2, 3, 4], [10, 30, 30.5, 20, 25]);
    expect(e.gainM, 25);
    expect(e.lossM, closeTo(10, 1e-9)); // 30.5 is within the 1 m deadband
    expect(e.maxM, 30.5);
    expect(TripElevation.fromJson(e.toJson())!.profile.length, 5);
  });

  test('weather lookup saves weather and elevation on the trip', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final v = await repo.ensureVehicle();
    final s = shifted(drive(174.70, 174.73), DateTime.utc(2026, 11, 8, 19).toLocal());
    await repo.saveRecordedTrip(
      TripsCompanion.insert(id: 't', vehicleId: v.id, name: 'x', startAt: s.first.at, status: const Value('done'), statsJson: Value(jsonEncode({...computeTripStats(s).toJson(), 'road': {'roadKm': {}}}))),
      [for (final p in s) TripPointsCompanion.insert(tripId: 't', at: p.at, lat: p.lat, lon: p.lon, speedMps: Value(p.speedMps), accuracyM: Value(p.accuracyM))],
      const [],
    );
    final asked = <Uri>[];
    final client = MockClient((req) async {
      asked.add(req.url);
      if (req.url.path.contains('elevation')) {
        final n = req.url.queryParameters['latitude']!.split(',').length;
        return http.Response(jsonEncode({'elevation': [for (var i = 0; i < n; i++) 10.0 + i * 2]}), 200);
      }
      return http.Response(jsonEncode(hourly('2026-11-08')), 200);
    });
    final r = await WeatherLookup.analyse(repo, 't', client: client);
    expect(r!.weather!.code, 63);
    expect(r.elev!.gainM, greaterThan(10));
    // Weather location is rounded to 2 decimals.
    expect(asked.first.queryParameters['latitude'], lat0.toStringAsFixed(2));
    final stats = jsonDecode((await repo.trip('t'))!.statsJson!) as Map<String, Object?>;
    expect(stats.containsKey('road'), isTrue); // kept
    expect(TripWeather.fromJson(stats['weather'])!.tempC, closeTo(19.5, 0.6));
    expect(TripElevation.fromJson(stats['elev']), isNotNull);
    expect(WeatherLookup.done((await repo.trip('t'))!.statsJson), isTrue);
    await db.close();
  });

  testWidgets('trips page asks to name a place and titles trips with it', (tester) async {
    SharedPreferences.setMockInitialValues({'roadLookup': false, 'weatherLookup': false});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final today = DateTime.now();
    for (var i = 0; i < 3; i++) {
      final s = shifted(drive(174.70, 174.73), DateTime(today.year, today.month, today.day - i - 1, 8), back: i.isOdd);
      await repo.saveRecordedTrip(
        TripsCompanion.insert(
          id: 't$i',
          vehicleId: v.id,
          name: TripRecorder.defaultName(s.first.at),
          startAt: s.first.at,
          endAt: Value(s.last.at),
          status: const Value('done'),
          statsJson: Value(jsonEncode(computeTripStats(s).toJson())),
        ),
        [for (final p in s) TripPointsCompanion.insert(tripId: 't$i', at: p.at, lat: p.lat, lon: p.lon, speedMps: Value(p.speedMps), accuracyM: Value(p.accuracyM))],
        const [],
      );
    }
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: TripsPage())));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await settle(tester);
    // Each end of the route has 3 trip ends, so the first one is offered.
    expect(find.text('Name this place?'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(settings.places.single.name, 'Home');
    expect(find.text('Name this place?'), findsOneWidget); // the other end
    await tester.tap(find.text('Work'));
    await settle(tester);
    expect(settings.places.length, 2);
    final firstPlace = settings.places.first;
    final westIsHome = firstPlace.lon < 174.715;
    expect(find.text(westIsHome ? 'Home → Work' : 'Work → Home'), findsNWidgets(2));
    expect(find.text(westIsHome ? 'Work → Home' : 'Home → Work'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
