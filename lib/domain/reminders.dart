/// Turns "things that will be due" into phone notification times, and spots
/// tanks that used unusually much fuel. Pure functions, tested directly.
library;

import 'stats.dart';

/// Something with a date it's expected to be due.
class ReminderSource {
  /// Stable id of the thing (service item id, policy id…). Notification keys
  /// are built from it so the same reminder never fires twice.
  final String id;
  final String title;
  final String body;
  final DateTime dueOn;
  /// Give a month's notice as well (WOF, rego, insurance).
  final bool longLead;
  const ReminderSource({required this.id, required this.title, required this.body, required this.dueOn, this.longLead = false});
}

class PlannedReminder {
  final String key;
  final DateTime at;
  final String title, body;
  const PlannedReminder(this.key, this.at, this.title, this.body);
  Map<String, Object> toJson() => {'key': key, 'at': at.millisecondsSinceEpoch, 'title': title, 'body': body};
}

DateTime _atHour(DateTime day, int hour, int minute) => DateTime(day.year, day.month, day.day, hour, minute);

/// Notification times for each source: 30 days before (long-lead items
/// only), 7 days before and on the day, at [hour]:[minute]. Times already
/// past are dropped, except that an item already due gets one "overdue"
/// reminder at the next notification time. The key includes the due date,
/// so a reminder fires again for the next due date after the job is done.
List<PlannedReminder> planReminders(List<ReminderSource> sources, {required DateTime now, int hour = 9, int minute = 0}) {
  final out = <PlannedReminder>[];
  var next = _atHour(now, hour, minute);
  if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
  for (final s in sources) {
    final due = DateTime(s.dueOn.year, s.dueOn.month, s.dueOn.day);
    final tag = '${s.id}@${due.year}-${due.month}-${due.day}';
    final stages = <(String, int)>[if (s.longLead) ('d30', 30), ('d7', 7), ('d0', 0)];
    var any = false;
    for (final (name, days) in stages) {
      final at = _atHour(due.subtract(Duration(days: days)), hour, minute);
      if (at.isAfter(now)) {
        out.add(PlannedReminder('$tag:$name', at, s.title, s.body));
        any = true;
      }
    }
    if (!any) out.add(PlannedReminder('$tag:over', next, s.title, s.body));
  }
  out.sort((a, b) => a.at.compareTo(b.at));
  return out;
}

/// The date the tank is expected to get down to [lowKm] of range, given
/// typical daily driving. Null when tank size or economy isn't known.
DateTime? fuelLowOn({
  required FuelRow lastFill,
  required double? tankLitres,
  required double? per100,
  required double? kmPerDay,
  double lowKm = 80,
}) {
  if (tankLitres == null || per100 == null || per100 <= 0 || kmPerDay == null || kmPerDay <= 0) return null;
  final fullRange = tankLitres / per100 * 100;
  final usable = fullRange - lowKm;
  if (usable <= 0) return null;
  return lastFill.at.add(Duration(hours: (usable / kmPerDay * 24).round()));
}

/// How much more (positive) or less fuel the latest tank used than the
/// median of the previous [window] tanks, as a fraction. Null when there
/// isn't enough history.
double? latestEconomyChange(List<TankStat> stats, {int window = 6}) {
  final with100 = stats.where((s) => s.litresPer100 != null).toList();
  if (with100.length < 4) return null;
  final latest = with100.last.litresPer100!;
  final prev = with100.sublist((with100.length - 1 - window).clamp(0, with100.length - 1), with100.length - 1)
      .map((s) => s.litresPer100!)
      .toList()
    ..sort();
  final mid = prev.length ~/ 2;
  final median = prev.length.isOdd ? prev[mid] : (prev[mid - 1] + prev[mid]) / 2;
  if (median <= 0) return null;
  return (latest - median) / median;
}
