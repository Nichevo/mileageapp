import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/care.dart';
import 'package:mileagelog/domain/carjam.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/insights_page.dart' show ChartScale;
import 'package:mileagelog/ui/vehicle_page.dart';
import 'package:mileagelog/vehicle/carjam_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Field names as in CarJam's ABCD documentation; values made up.
final sample = {
  'plate': 'ZZ1234',
  'year_of_manufacture': 2015,
  'make': 'TOYOTA',
  'model': 'COROLLA',
  'submodel': 'GX',
  'cc_rating': 1798,
  'main_colour': 'SILVER',
  'body_style': 'HATCHBACK',
  'fuel_type': 'PETROL',
  'date_of_first_registration_in_nz': 1431907200, // 18 May 2015
  'expiry_date_of_last_successful_wof': '2027-05-18',
  'licence_expiry_date': 1798934400, // 2027-01-03 UTC
  'latest_odometer_reading': '142,315',
  'safety_economy': {'fuel_consumption': 6.4},
};

void main() {
  test('reads CarJam details', () {
    final d = CarDetails.fromJson(sample);
    expect(d.summary, '2015 Toyota Corolla GX, 1798 cc petrol');
    expect(d.summaryModel, 'Corolla GX');
    expect(d.wofExpiry, DateTime(2027, 5, 18));
    expect(d.licenceExpiry!.year, 2027);
    expect(d.firstRegisteredNz!.year, 2015);
    expect(d.odometerKm, 142315);
    expect(d.ratedPer100, 6.4);
    expect(parseCarJamDate('18/05/2027'), DateTime(2027, 5, 18));
    expect(parseCarJamDate(0), isNull);
    expect(normalisePlate(' zz 1234 '), 'ZZ1234');
  });

  test('last done date that lands on the expiry', () {
    expect(lastDoneForDue(DateTime(2027, 5, 18), 12), DateTime(2026, 5, 18));
    expect(lastDoneForDue(DateTime(2027, 2, 10), 6), DateTime(2026, 8, 10));
    expect(lastDoneForDue(DateTime(2027, 8, 31), 6), DateTime(2027, 2, 28));
  });

  test('client waits while CarJam is fetching, and reports a bad key', () async {
    var calls = 0;
    final ok = MockClient((req) async {
      expect(req.url.queryParameters['plate'], 'ZZ1234');
      expect(req.url.path, '/a/vehicle:abcd');
      calls++;
      return calls == 1 ? http.Response('null', 200, headers: {'refresh': '2'}) : http.Response(jsonEncode(sample), 200);
    });
    final d = await CarJamClient.lookup('zz 1234', 'k', client: ok, wait: (_) => Duration.zero);
    expect(d.make, 'TOYOTA');
    expect(calls, 2);

    final bad = MockClient((req) async => http.Response('', 403));
    expect(() => CarJamClient.lookup('ZZ1234', 'k', client: bad), throwsA(isA<CarJamException>().having((e) => e.message, 'message', contains('API key'))));
  });

  test('chart scale uses round numbers', () {
    final s = ChartScale.of(1234);
    expect(s.step, 500);
    expect(s.top, 1500);
    expect(s.ticks.map((t) => t.$1), [0, 500, 1000, 1500]);
    expect(s.label(1000), '1,000');
    final p = ChartScale.of(2.87);
    expect(p.step, 1);
    expect(ChartScale.of(0.9).label(0.25), '0.25');
    final l = ChartScale.of(25000, log: true);
    expect(l.top, 5);
    expect(l.ticks.length, 6);
    expect(l.label(10000), '10k');
    expect(l.pos(99), closeTo(2, 1e-9));

    // Typical weeks around 300 km; one 1,800 km road trip.
    expect(ChartScale.typicalCap([280, 310, 0, 295, 1800, 320, 305]), closeTo(307.5 * 2.5, 1e-9));
    expect(ChartScale.typicalCap([280, 310, 295, 320]), isNull); // nothing stands out
    expect(ChartScale.typicalCap([100, 5000]), isNull); // too few to judge
  });

  testWidgets('plate lookup fills the form and sets WOF and rego dates', (tester) async {
    SharedPreferences.setMockInitialValues({'carjamKey': 'test-key'});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final client = MockClient((req) async => http.Response(jsonEncode(sample), 200));
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: MaterialApp(home: VehiclePage(carjamClient: client))));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.enterText(find.widgetWithText(TextField, 'Plate'), 'zz1234');
    await tester.pump();
    await tester.tap(find.text('Look up'));
    // The HTTP mock answers on real async time.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.text('2015 Toyota Corolla GX, 1798 cc petrol'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Toyota'), findsOneWidget);
    expect(settings.plateFor(v.id), 'ZZ1234');

    await tester.tap(find.text('Use these dates for WOF and rego reminders'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    final items = await db.select(db.serviceItems).get();
    final wof = items.firstWhere((i) => i.kind == 'wof');
    final due = dueFor(lastDoneAt: wof.lastDoneAt, lastDoneKm: null, intervalMonths: wof.intervalMonths, intervalKm: null, currentKm: null, kmPerDay: null, now: DateTime(2026, 11, 8));
    expect(due.dueAt, DateTime(2027, 5, 18));
    expect(items.any((i) => i.kind == 'rego'), isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
