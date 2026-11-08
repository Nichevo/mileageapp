import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/domain/care.dart';
import 'package:mileagelog/domain/stats.dart';

void main() {
  final now = DateTime(2026, 11, 8);

  test('addMonths clamps to the end of short months', () {
    expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
    expect(addMonths(DateTime(2025, 11, 15), 12), DateTime(2026, 11, 15));
    expect(addMonths(DateTime(2026, 12, 1), 6), DateTime(2027, 6, 1));
  });

  test('date-based item due soon and overdue', () {
    final soon = dueFor(lastDoneAt: DateTime(2025, 11, 20), lastDoneKm: null, intervalMonths: 12, intervalKm: null, currentKm: null, kmPerDay: null, now: now);
    expect(soon.state, DueState.soon);
    expect(soon.daysLeft(now), 12);
    final over = dueFor(lastDoneAt: DateTime(2025, 10, 1), lastDoneKm: null, intervalMonths: 12, intervalKm: null, currentKm: null, kmPerDay: null, now: now);
    expect(over.state, DueState.overdue);
  });

  test('km-based item uses driving rate for the expected date', () {
    final d = dueFor(lastDoneAt: DateTime(2026, 6, 1), lastDoneKm: 140000, intervalMonths: 12, intervalKm: 10000, currentKm: 146000, kmPerDay: 40, now: now);
    expect(d.kmLeft, 4000);
    expect(d.expectedAt, now.add(const Duration(days: 100))); // km come before June 2027
    expect(d.state, DueState.ok);
    final close = dueFor(lastDoneAt: null, lastDoneKm: 140000, intervalMonths: null, intervalKm: 10000, currentKm: 149500, kmPerDay: 40, now: now);
    expect(close.state, DueState.soon);
  });

  test('nothing known means unknown', () {
    expect(dueFor(lastDoneAt: null, lastDoneKm: null, intervalMonths: 12, intervalKm: 10000, currentKm: 1, kmPerDay: 1, now: now).state, DueState.unknown);
  });

  test('km per day and estimated odometer', () {
    final rows = [
      FuelRow(at: DateTime(2026, 8, 1), odometerKm: 140000, quantity: 40, cost: 100),
      FuelRow(at: DateTime(2026, 10, 30), odometerKm: 143600, quantity: 40, cost: 100),
    ];
    expect(recentKmPerDay(rows, now: now), closeTo(40, 0.01));
    expect(estimatedOdometer(rows, now: now), closeTo(143600 + 40 * 9, 1));
  });

  test('pressure conversions', () {
    expect(psiToKpa(32), closeTo(220.6, 0.1));
    expect(fmtPressure(220.6, psi: true), '32');
    expect(underInflation(200, 220)!, closeTo(0.0909, 0.001));
  });
}
