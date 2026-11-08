/// Service schedule, reminders and tyre pressure helpers. Pure functions so
/// they can be tested without the database.
library;

import 'stats.dart';

/// A suggested schedule item. Intervals are typical for a petrol car in NZ;
/// the owner's manual wins where it differs.
class ServiceTemplate {
  final String name, kind;
  final int? months, km;
  final String? note;
  /// Words that identify past records of this job in imported history.
  final List<String> matches;
  const ServiceTemplate(this.name, this.kind, {this.months, this.km, this.note, this.matches = const []});
}

const recommendedServices = <ServiceTemplate>[
  ServiceTemplate('Warrant of Fitness', 'wof', months: 12,
      note: 'Every 6 months if the car was first registered before 2000', matches: ['wof', 'warrant']),
  ServiceTemplate('Registration', 'rego', months: 12, matches: ['rego', 'registration', 'licen']),
  ServiceTemplate('Oil and filter change', 'service', months: 12, km: 10000, matches: ['oil', 'service']),
  ServiceTemplate('Tyre rotation', 'tyres', km: 10000, matches: ['rotat']),
  ServiceTemplate('Wheel alignment', 'tyres', months: 24, km: 20000, matches: ['align']),
  ServiceTemplate('Air filter', 'service', months: 24, km: 30000, matches: ['air filter']),
  ServiceTemplate('Cabin (pollen) filter', 'service', months: 12, km: 15000, matches: ['cabin', 'pollen']),
  ServiceTemplate('Brake fluid', 'service', months: 24, matches: ['brake fluid']),
  ServiceTemplate('Coolant', 'service', months: 60, km: 100000, matches: ['coolant']),
  ServiceTemplate('Spark plugs', 'service', km: 100000, matches: ['spark']),
  ServiceTemplate('Timing belt', 'service', months: 60, km: 100000,
      note: 'Only if the engine has a belt rather than a chain', matches: ['timing']),
  ServiceTemplate('Battery test', 'other', months: 12, matches: ['battery']),
  ServiceTemplate('Wiper blades', 'other', months: 12, matches: ['wiper']),
];

enum DueState { overdue, soon, ok, unknown }

class DueInfo {
  final DateTime? dueAt; // by date
  final double? dueKm; // by odometer
  /// Earliest of the date due and the date the km are expected to be reached.
  final DateTime? expectedAt;
  final double? kmLeft;
  final DueState state;
  const DueInfo({this.dueAt, this.dueKm, this.expectedAt, this.kmLeft, required this.state});

  int? daysLeft(DateTime now) => expectedAt?.difference(DateTime(now.year, now.month, now.day)).inDays;
}

DateTime addMonths(DateTime d, int months) {
  final y = d.year + (d.month - 1 + months) ~/ 12;
  final m = (d.month - 1 + months) % 12 + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, d.day > lastDay ? lastDay : d.day);
}

/// When something is next due, from when it was last done and its interval.
/// "Soon" means within [soonDays] days or [soonKm] km.
DueInfo dueFor({
  required DateTime? lastDoneAt,
  required double? lastDoneKm,
  required int? intervalMonths,
  required int? intervalKm,
  required double? currentKm,
  required double? kmPerDay,
  required DateTime now,
  int soonDays = 30,
  double soonKm = 1000,
}) {
  final dueAt = lastDoneAt != null && intervalMonths != null ? addMonths(lastDoneAt, intervalMonths) : null;
  final dueKm = lastDoneKm != null && intervalKm != null ? lastDoneKm + intervalKm : null;
  final kmLeft = dueKm != null && currentKm != null ? dueKm - currentKm : null;
  DateTime? kmDate;
  if (kmLeft != null && kmPerDay != null && kmPerDay > 0) {
    kmDate = now.add(Duration(days: (kmLeft / kmPerDay).round()));
  }
  final candidates = [?dueAt, ?kmDate]..sort();
  final expectedAt = candidates.isEmpty ? null : candidates.first;
  if (dueAt == null && dueKm == null) return const DueInfo(state: DueState.unknown);

  final today = DateTime(now.year, now.month, now.day);
  final overdue = (dueAt != null && !dueAt.isAfter(today)) || (kmLeft != null && kmLeft <= 0);
  final soon = (expectedAt != null && expectedAt.difference(today).inDays <= soonDays) || (kmLeft != null && kmLeft <= soonKm);
  return DueInfo(
    dueAt: dueAt,
    dueKm: dueKm,
    expectedAt: expectedAt,
    kmLeft: kmLeft,
    state: overdue ? DueState.overdue : (soon ? DueState.soon : DueState.ok),
  );
}

/// Average km per day over the fills in the last [days] days (at least two
/// fills needed). Used to turn "due at 160,000 km" into an expected date.
double? recentKmPerDay(List<FuelRow> rows, {DateTime? now, int days = 180}) {
  final n = now ?? DateTime.now();
  final cutoff = n.subtract(Duration(days: days));
  final recent = rows.where((r) => r.at.isAfter(cutoff)).toList()..sort((a, b) => a.at.compareTo(b.at));
  final use = recent.length >= 2 ? recent : ([...rows]..sort((a, b) => a.at.compareTo(b.at)));
  if (use.length < 2) return null;
  final span = use.last.at.difference(use.first.at).inHours / 24;
  if (span < 7) return null;
  return (use.last.odometerKm - use.first.odometerKm) / span;
}

/// Best guess at today's odometer: the last reading plus typical driving since.
double? estimatedOdometer(List<FuelRow> rows, {DateTime? now}) {
  if (rows.isEmpty) return null;
  final last = rows.reduce((a, b) => a.odometerKm >= b.odometerKm ? a : b);
  final perDay = recentKmPerDay(rows, now: now);
  final n = now ?? DateTime.now();
  final days = n.difference(last.at).inHours / 24;
  if (perDay == null || days <= 0) return last.odometerKm;
  return last.odometerKm + perDay * days;
}

// ---- tyres ---------------------------------------------------------------

const double kpaPerPsi = 6.894757;
double psiToKpa(double psi) => psi * kpaPerPsi;
double kpaToPsi(double kpa) => kpa / kpaPerPsi;

/// Display a stored kPa value in the chosen unit.
String fmtPressure(double? kpa, {required bool psi}) {
  if (kpa == null) return '—';
  return psi ? kpaToPsi(kpa).toStringAsFixed(0) : kpa.toStringAsFixed(0);
}

/// How far each tyre was below the recommended pressure, as a fraction
/// (0.1 = 10% low). Null where either value is missing.
double? underInflation(double? foundKpa, double? recommendedKpa) {
  if (foundKpa == null || recommendedKpa == null || recommendedKpa <= 0) return null;
  return (recommendedKpa - foundKpa) / recommendedKpa;
}

/// Tyre checks are suggested monthly.
const tyreCheckEveryDays = 30;
