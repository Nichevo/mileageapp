import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/domain/reminders.dart';
import 'package:mileagelog/domain/stats.dart';

void main() {
  final now = DateTime(2026, 11, 8, 14, 0);

  test('stages before the due date, at the chosen hour', () {
    final r = planReminders([
      ReminderSource(id: 'wof', title: 'WOF', body: 'due', dueOn: DateTime(2026, 12, 20), longLead: true),
    ], now: now);
    expect(r.map((x) => x.at), [DateTime(2026, 11, 20, 9), DateTime(2026, 12, 13, 9), DateTime(2026, 12, 20, 9)]);
    expect(r.map((x) => x.key.split(':').last), ['d30', 'd7', 'd0']);
  });

  test('past stages are dropped; overdue gets one reminder next morning', () {
    final soon = planReminders([ReminderSource(id: 'oil', title: 'Oil', body: '', dueOn: DateTime(2026, 11, 12))], now: now);
    expect(soon.single.at, DateTime(2026, 11, 12, 9));
    final over = planReminders([ReminderSource(id: 'oil', title: 'Oil', body: '', dueOn: DateTime(2026, 11, 1))], now: now);
    expect(over.single.key, endsWith(':over'));
    expect(over.single.at, DateTime(2026, 11, 9, 9));
    final sameDay = planReminders([ReminderSource(id: 'x', title: 'X', body: '', dueOn: DateTime(2026, 11, 1))], now: DateTime(2026, 11, 8, 7), hour: 9);
    expect(sameDay.single.at, DateTime(2026, 11, 8, 9));
  });

  test('keys change with the due date so the next cycle reminds again', () {
    final a = planReminders([ReminderSource(id: 'wof', title: '', body: '', dueOn: DateTime(2026, 12, 20))], now: now);
    final b = planReminders([ReminderSource(id: 'wof', title: '', body: '', dueOn: DateTime(2027, 12, 20))], now: now);
    expect(a.first.key == b.first.key, isFalse);
  });

  test('fuel low date from tank size and driving', () {
    final d = fuelLowOn(
      lastFill: FuelRow(at: DateTime(2026, 11, 1), odometerKm: 1, quantity: 40, cost: 1),
      tankLitres: 50,
      per100: 10, // 500 km per tank
      kmPerDay: 42, // 420 usable km / 42 = 10 days
    );
    expect(d, DateTime(2026, 11, 11));
    expect(fuelLowOn(lastFill: FuelRow(at: now, odometerKm: 1, quantity: 1, cost: 1), tankLitres: null, per100: 10, kmPerDay: 40), isNull);
  });

  test('economy change against the median of recent tanks', () {
    FuelRow f(int day, double odo, double l) => FuelRow(at: DateTime(2026, 1, day), odometerKm: odo, quantity: l, cost: l * 3);
    final rows = [f(1, 0, 40), f(8, 500, 45), f(15, 1000, 45), f(22, 1500, 45), f(29, 2000, 54)];
    final change = latestEconomyChange(tankStats(rows));
    expect(change, closeTo(0.2, 0.001)); // 10.8 vs 9.0 L/100 km
    expect(latestEconomyChange(tankStats(rows.take(3).toList())), isNull);
  });
}
