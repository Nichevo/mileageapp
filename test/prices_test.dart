import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/domain/prices.dart';
import 'package:mileagelog/prices/national_prices.dart';
import 'package:mileagelog/settings.dart';
import 'package:mileagelog/ui/prices_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Same shape as MBIE's weekly-table.csv (cents per litre).
const csv = '''Week,Date,Variable,Fuel,Value,Unit,Status
1,2026-10-02,Board price,Regular Petrol,270.1,NZc/L,Final
1,2026-10-02,Board price,Premium Petrol 95R,290.0,NZc/L,Final
1,2026-10-02,Board price,Diesel,200.0,NZc/L,Final
1,2026-10-02,Adjusted retail price,Regular Petrol,262.0,NZc/L,Final
1,2026-10-02,Dubai crude price,,80.1,USD/bbl,Final
2,2026-10-09,Board price,Regular Petrol,272.0,NZc/L,Final
3,2026-10-16,Board price,Regular Petrol,275.0,NZc/L,Final
4,2026-10-23,Board price,Regular Petrol,280.0,NZc/L,Provisional
4,2026-10-23,Board price,Premium Petrol 95R,300.0,NZc/L,Provisional
''';

FillInput fill(int day, double litres, double cost, String? station, [String? fuel]) =>
    (at: DateTime(2026, 10, day), litres: litres, cost: cost, station: station, fuelType: fuel);

void main() {
  test('parses board prices by fuel and week', () {
    final n = NationalPrices.parseMbie(csv.replaceAll('\n', '\r\n'));
    expect(n.byFuel[mbieRegular]!.length, 4);
    expect(n.byFuel.containsKey(''), isFalse);
    expect(n.latest(mbieRegular)!.centsPerL, 280.0);
    expect(n.latestChange(mbieRegular), closeTo(5.0, 0.001));
    expect(n.centsAt(mbieRegular, DateTime(2026, 10, 10)), 272.0); // nearest week
    expect(n.centsAt(mbieRegular, DateTime(2026, 12, 1)), isNull); // beyond the data
    expect(n.centsAt(mbiePremium, DateTime(2026, 10, 3)), 290.0);
    expect(NationalPrices.parseMbie('nonsense\n1,2').isEmpty, isTrue);
  });

  test('fuel types map to the MBIE series', () {
    expect(mbieFuelFor('91'), mbieRegular);
    expect(mbieFuelFor(null), mbieRegular);
    expect(mbieFuelFor('98'), mbiePremium);
    expect(mbieFuelFor('diesel'), mbieDiesel);
  });

  test('fills compared with the national average and stations ranked', () {
    final n = NationalPrices.parseMbie(csv);
    final priced = priceFills([
      fill(2, 40, 104.0, 'Cheap Co'), // 260c vs 270.1 → 10.1c under
      fill(16, 40, 106.0, 'cheap co '), // 265c vs 275 → 10c under
      fill(9, 40, 112.0, 'Dear Ltd'), // 280c vs 272 → 8c over
      fill(23, 40, 116.0, 'Dear Ltd'), // 290c vs 280 → 10c over
      fill(23, 30, 87.0, 'Premium Place', '95'), // 290c vs 300 → 10c under
      fill(23, 40, 0, 'Free?'), // no cost: skipped
      (at: DateTime(2025, 1, 1), litres: 40.0, cost: 100.0, station: 'Old', fuelType: null), // outside the data
    ], n);
    expect(priced.length, 5);
    expect(priced.first.at, DateTime(2026, 10, 2));
    expect(priced.first.diffCents, closeTo(-10.1, 0.001));
    expect(priced.first.diffDollars, closeTo(-4.04, 0.001));

    final ranked = rankStations(priced);
    expect(ranked.map((s) => s.name), ['cheap co', 'Dear Ltd']); // one-off stations left out
    expect(ranked.first.fills, 2);
    expect(ranked.first.avgDiffCents, closeTo(-10.05, 0.001));
    expect(ranked.last.avgDiffCents, closeTo(9, 0.001));

    expect(savedDollars(priced), closeTo(4.04 + 4.0 - 3.2 - 4.0 + 3.0, 0.001));
    expect(diffText(-6.4), '6c under the national average');
    expect(diffText(0.2), 'about the national average');
  });

  testWidgets('prices page shows national prices, savings and stations', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);
    final now = DateTime.now();
    final week = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 3));
    NationalPriceSource.setForTest(NationalPrices.parseMbie('Week,Date,Variable,Fuel,Value,Unit,Status\n'
        '1,${week.subtract(const Duration(days: 7)).toIso8601String().substring(0, 10)},Board price,Regular Petrol,270,NZc/L,Final\n'
        '2,${week.toIso8601String().substring(0, 10)},Board price,Regular Petrol,280,NZc/L,Final\n'));
    for (var i = 0; i < 3; i++) {
      await repo.upsertEvent(
        EnergyEventsCompanion.insert(
            id: 'f$i', vehicleId: v.id, at: week.add(Duration(hours: i)), odometerKm: 1000 + i * 400.0, quantity: 40, cost: 108, stationName: const Value('Corner Servo'), fuelType: const Value('91')),
        enqueue: false,
      );
    }
    await tester.pumpWidget(AppScope(repo: repo, settings: settings, child: const MaterialApp(home: PricesPage())));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.text('\$2.800/L'), findsOneWidget);
    expect(find.text('up 10c on last week'), findsOneWidget);
    expect(find.textContaining('averaged 10c under the national average'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Corner Servo'), 200);
    expect(find.text('−10c'), findsOneWidget);
    NationalPriceSource.setForTest(null);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(() => db.close());
  });
}
