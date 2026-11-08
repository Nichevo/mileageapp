import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/domain/stats.dart';

FuelRow fill(DateTime at, double odo, double l, double cost) =>
    FuelRow(at: at, odometerKm: odo, quantity: l, cost: cost, isFull: true);

void main() {
  final rows = [
    fill(DateTime(2026, 1, 20), 1000, 40, 100),
    fill(DateTime(2026, 3, 1), 1400, 40, 120), // 400 km over 40 days, Jan 20 to Mar 1
    fill(DateTime(2026, 3, 11), 1800, 38, 110), // 400 km over 10 days in March
  ];

  test('monthly spreads a tank over the days it covered', () {
    final m = periodTotals(rows, Period.month);
    expect(m.map((t) => t.start.month), [1, 2, 3]);
    expect(m[0].km, closeTo(400 * 12 / 40, 0.01)); // Jan 20..31
    expect(m[1].km, closeTo(400 * 28 / 40, 0.01)); // all of Feb
    expect(m[2].km, closeTo(400, 0.01)); // Mar 1..10
    expect(m.fold<double>(0, (a, t) => a + t.km), closeTo(800, 0.01));
    expect(m[1].pricePerUnit, isNull); // no fill in February
    expect(m[2].pricePerUnit, closeTo(230 / 78, 1e-9));
  });

  test('weekly periods start on Monday and include empty weeks', () {
    final w = periodTotals(rows, Period.week);
    expect(w.first.start, DateTime(2026, 1, 19));
    expect(w.every((t) => t.start.weekday == DateTime.monday), isTrue);
    expect(w.fold<double>(0, (a, t) => a + t.km), closeTo(800, 0.01));
  });

  test('range cut keeps later periods only', () {
    final m = periodTotals(rows, Period.month, from: DateTime(2026, 2, 15));
    expect(m.map((t) => t.start.month), [2, 3]);
  });

  test('yearly matches the total', () {
    final y = periodTotals(rows, Period.year);
    expect(y.single.km, closeTo(800, 0.01));
    expect(y.single.costPer100, closeTo(230 / 800 * 100, 1e-6));
  });
}
