import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:drift/drift.dart' hide Column;

import '../data/repository.dart';
import '../domain/care.dart';
import '../domain/energy.dart';
import '../domain/reminders.dart';
import '../trips/road_lookup.dart';
import '../domain/stats.dart';
import '../domain/trip_stats.dart';
import '../settings.dart';
import '../ui/format.dart';

/// Keeps the home screen widgets and the scheduled reminders in step with
/// the data. Everything is worked out here; the Android side only displays
/// text and fires notifications at the given times.
class HomeSync {
  static const _ch = MethodChannel('mileagelog/trips');
  static bool get supported => Platform.isAndroid;

  /// What the widgets show and which reminders are due, from the database.
  static Future<({Map<String, String> snapshot, List<PlannedReminder> reminders})> build(Repository repo, Settings settings, {DateTime? now}) async {
    final n = now ?? DateTime.now();
    final vid = settings.activeVehicleId!;
    final db = repo.db;
    final vehicle = await repo.vehicle(vid);
    final events = await repo.events(vid, kind: null);
    final energy = Energy.primaryFor(vehicle?.kind);
    final rows = Repository.toFuelRows(events, kind: energy.eventKind);
    final allRows = Repository.toFuelRows(events, kind: null);
    final tanks = tankStats(rows);
    final rolling = rollingPer100(tanks);
    final per100 = rolling.lastWhere((v) => v != null, orElse: () => null);
    final perDay = recentKmPerDay(allRows, now: n);
    final odo = estimatedOdometer(allRows, now: n);
    final items = await (db.select(db.serviceItems)..where((s) => s.vehicleId.equals(vid) & s.active.equals(true))).get();
    final policies = await (db.select(db.insurancePolicies)..where((p) => p.vehicleId.equals(vid))).get()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    final checks = await (db.select(db.tyreChecks)..where((t) => t.vehicleId.equals(vid))).get()
      ..sort((a, b) => b.at.compareTo(a.at));
    final trips = await (db.select(db.trips)..where((t) => t.vehicleId.equals(vid) & t.status.equals('done'))).get()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));

    // ---- reminder sources ----
    final sources = <ReminderSource>[];
    for (final i in items) {
      final d = dueFor(
        lastDoneAt: i.lastDoneAt,
        lastDoneKm: i.lastDoneKm,
        intervalMonths: i.intervalMonths,
        intervalKm: i.intervalKm,
        currentKm: odo,
        kmPerDay: perDay,
        now: n,
      );
      if (d.expectedAt == null) continue;
      sources.add(ReminderSource(
        id: i.id,
        title: '${i.name} due',
        body: [
          if (d.dueAt != null) 'Due ${fmtDate(d.dueAt!)}',
          if (d.dueKm != null) 'due at ${fmtKm(d.dueKm!)} km',
          if (d.kmLeft != null && d.kmLeft! > 0) 'about ${fmtKm(d.kmLeft!)} km to go',
        ].join(', '),
        dueOn: d.expectedAt!,
        longLead: i.kind == 'wof' || i.kind == 'rego',
      ));
    }
    final policy = policies.firstOrNull;
    if (policy?.renewAt != null) {
      sources.add(ReminderSource(
        id: policy!.id,
        title: 'Insurance renewal',
        body: '${policy.insurer} renews ${fmtDate(policy.renewAt!)}. A good time to check the insured value.',
        dueOn: policy.renewAt!,
        longLead: true,
      ));
    }
    if (checks.isNotEmpty) {
      sources.add(ReminderSource(
        id: 'tyres',
        title: 'Check tyre pressures',
        body: 'Last checked ${fmtDate(checks.first.at)}.',
        dueOn: checks.first.at.add(const Duration(days: tyreCheckEveryDays)),
      ));
    }
    final lastFill = rows.isEmpty ? null : rows.reduce((a, b) => a.odometerKm >= b.odometerKm ? a : b);
    final lastEvent = events.where((e) => e.kind == energy.eventKind).firstOrNull;
    if (settings.fuelReminders && !energy.isCharge && lastFill != null && lastEvent != null) {
      final low = fuelLowOn(lastFill: lastFill, tankLitres: vehicle?.tankSize, per100: per100, kmPerDay: perDay);
      if (low != null) {
        sources.add(ReminderSource(
          id: 'fuel-${lastEvent.id}',
          title: 'Fuel probably getting low',
          body: 'From your usual driving, about 80 km of range is left since filling up on ${fmtDate(lastFill.at)}.',
          dueOn: low,
        ));
      }
    }
    // Toll roads used in the last week with no toll logged for the trip.
    final unpaid = <({String tripId, String road, DateTime at})>[];
    if (settings.tollReminders) {
      final recent = trips.where((t) => t.startAt.isAfter(n.subtract(const Duration(days: tollPayDays + 2)))).toList();
      if (recent.isNotEmpty) {
        final paid = (await (db.select(db.expenses)..where((e) => e.kind.equals('toll') & e.tripId.isIn(recent.map((t) => t.id)))).get())
            .map((e) => e.tripId)
            .toSet();
        for (final t in recent) {
          final tolls = RoadLookup.stored(t.statsJson)?.tolls ?? const [];
          if (tolls.isEmpty || paid.contains(t.id)) continue;
          unpaid.add((tripId: t.id, road: tolls.map((x) => x.name).join(', '), at: t.startAt));
        }
      }
    }
    final reminders = settings.remindersEnabled
        ? ([
            ...planReminders(sources, now: n, hour: settings.reminderHour, minute: settings.reminderMinute),
            ...planTollReminders(unpaid, now: n, hour: settings.reminderHour, minute: settings.reminderMinute),
          ]..sort((a, b) => a.at.compareTo(b.at)))
        : const <PlannedReminder>[];

    // ---- widget text ----
    final snap = <String, String>{};
    if (lastFill != null && lastEvent != null) {
      final range = rangeLeftKm(tankSize: vehicle?.tankSize, recentPer100: per100, kmSinceFill: odo == null ? 0 : odo - lastFill.odometerKm);
      snap['fill'] = [
        'Last ${DateFormat('d MMM').format(lastFill.at)}',
        if (per100 != null) '${per100.toStringAsFixed(1)} ${energy.per100}',
        if (range != null) '~${fmtKm(range)} km left',
      ].join(' · ');
    }
    final year = yearlyTotals(rows)[n.year];
    snap['yearTitle'] = '${n.year} so far';
    snap['year'] = year == null ? 'No ${energy.nounPlural} yet this year' : '${fmtKm(year.km)} km · ${fmtMoney0(year.cost)}';
    if (year?.per100 != null) snap['economy'] = '${year!.per100!.toStringAsFixed(1)} ${energy.per100} average';
    final upcoming = sources.where((s) => !s.id.startsWith('fuel-')).toList()..sort((a, b) => a.dueOn.compareTo(b.dueOn));
    if (upcoming.isNotEmpty) {
      final s = upcoming.first;
      final days = DateTime(s.dueOn.year, s.dueOn.month, s.dueOn.day).difference(DateTime(n.year, n.month, n.day)).inDays;
      final name = s.title.replaceAll(RegExp(r' due$'), '');
      snap['next'] = days < 0 ? '$name overdue' : (days == 0 ? '$name due today' : '$name in $days days');
    }
    final lastTrip = trips.firstOrNull;
    if (lastTrip != null) {
      final km = lastTrip.statsJson == null
          ? lastTrip.gpsDistanceKm
          : TripStats.fromJson(jsonDecode(lastTrip.statsJson!) as Map<String, Object?>).distanceKm;
      snap['trip'] = 'Last: ${km == null ? '' : '${fmtKm1(km)} km · '}${DateFormat('EEE d MMM').format(lastTrip.startAt)}';
    }
    return (snapshot: snap, reminders: reminders);
  }

  static Future<void> refresh(Repository repo, Settings settings) async {
    if (!supported || settings.activeVehicleId == null) return;
    final r = await build(repo, settings);
    await _ch.invokeMethod('updateWidgets', {'json': jsonEncode(r.snapshot)});
    await _ch.invokeMethod('scheduleReminders', {'json': jsonEncode([for (final x in r.reminders) x.toJson()])});
  }

  static Future<String?> consumeLaunchAction() async => supported ? await _ch.invokeMethod<String>('consumeLaunchAction') : null;
}

/// Calls [HomeSync.refresh] shortly after any relevant data changes.
class HomeSyncWatcher {
  final Repository repo;
  final Settings settings;
  final _subs = <StreamSubscription<Object?>>[];
  Timer? _debounce;

  HomeSyncWatcher(this.repo, this.settings);

  void start() {
    if (!HomeSync.supported) return;
    final vid = settings.activeVehicleId!;
    final streams = <Stream<Object?>>[
      repo.watchEvents(vid, kind: null),
      repo.watchServiceItems(vid),
      repo.watchPolicies(vid),
      repo.watchTyreChecks(vid),
      repo.watchTrips(vid),
      repo.watchExpenses(vid),
      repo.watchVehicles(),
    ];
    for (final s in streams) {
      _subs.add(s.listen((_) => poke()));
    }
  }

  void poke() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      HomeSync.refresh(repo, settings).catchError((_) {});
    });
  }

  void stop() {
    _debounce?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }
}
