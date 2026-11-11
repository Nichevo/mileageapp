/// Home page extras: WOF, rego and insurance dates at a glance, the last
/// tyre check with all four pressures, and the trip being recorded.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../data/database.dart';
import 'package:flutter/services.dart';

import '../domain/care.dart';
import '../domain/places.dart';
import '../domain/trip_stats.dart';
import '../trips/recorder.dart';
import 'format.dart';
import 'insurance_page.dart';
import 'service_page.dart';
import 'trip_format.dart';
import 'trip_map.dart';
import 'tyres_page.dart';

Color dueColor(DueState s, ColorScheme cs) => switch (s) {
      DueState.overdue => cs.error,
      DueState.soon => Colors.orange.shade800,
      _ => cs.onSurface,
    };

/// WOF, rego and insurance: when each is next due.
class KeyDatesCard extends StatelessWidget {
  const KeyDatesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<List<ServiceItem>>(
      stream: scope.repo.watchServiceItems(vid),
      builder: (context, items) => StreamBuilder<List<InsurancePolicy>>(
        stream: scope.repo.watchPolicies(vid),
        builder: (context, policies) => StreamBuilder<List<EnergyEvent>>(
          stream: scope.repo.watchEvents(vid, kind: null),
          builder: (context, events) {
            if (!items.hasData || !policies.hasData || !events.hasData) return const SizedBox.shrink();
            final driving = drivingNow(events.data!);
            final today = DateTime.now();
            ({String value, String sub, DueState state})? item(String kind) {
              final i = items.data!.where((x) => x.kind == kind && x.active).firstOrNull;
              if (i == null) return null;
              final d = dueOf(i, driving);
              final at = d.dueAt ?? d.expectedAt;
              if (at == null) return (value: 'Not recorded', sub: 'Tap to add when it was last done', state: DueState.unknown);
              final days = DateTime(at.year, at.month, at.day).difference(DateTime(today.year, today.month, today.day)).inDays;
              return (value: fmtDate(at), sub: days < 0 ? '${-days} days overdue' : (days == 0 ? 'Today' : 'in $days days'), state: d.state);
            }

            final p = policies.data!.firstOrNull;
            final entries = <(String, IconData, ({String value, String sub, DueState state})?, WidgetBuilder)>[
              ('WOF', Icons.verified_outlined, item('wof'), (_) => const ServicePage()),
              ('Rego', Icons.badge_outlined, item('rego'), (_) => const ServicePage()),
              if (p?.renewAt != null)
                (
                  'Insurance',
                  Icons.shield_outlined,
                  () {
                    final days = p!.renewAt!.difference(today).inDays;
                    return (
                      value: fmtDate(p.renewAt!),
                      sub: days < 0 ? 'renewal passed' : 'renews in $days days',
                      state: days < 0 ? DueState.overdue : (days <= 30 ? DueState.soon : DueState.ok),
                    );
                  }(),
                  (_) => const InsurancePage(),
                ),
            ];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  for (final (label, icon, d, open) in entries)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: open)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(icon, size: 16, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Flexible(child: Text('$label due', style: t.bodySmall, overflow: TextOverflow.ellipsis)),
                            ]),
                            const SizedBox(height: 2),
                            Text(d?.value ?? 'Not set up', style: t.titleSmall?.copyWith(color: d == null ? cs.onSurfaceVariant : dueColor(d.state, cs))),
                            Text(d?.sub ?? 'Add it in Car care', style: t.bodySmall?.copyWith(color: d == null ? cs.onSurfaceVariant : dueColor(d.state, cs))),
                          ]),
                        ),
                      ),
                    ),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The last tyre check: when, and the four pressures laid out like the car.
class TyreHomeCard extends StatelessWidget {
  const TyreHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final psi = scope.settings.pressurePsi;
    return StreamBuilder<List<TyreCheck>>(
      stream: scope.repo.watchTyreChecks(vid),
      builder: (context, checks) => StreamBuilder<List<TyreSet>>(
        stream: scope.repo.watchTyreSets(vid),
        builder: (context, sets) {
          if (!checks.hasData || !sets.hasData) return const SizedBox.shrink();
          final set = sets.data!.where((s) => s.removedAt == null).firstOrNull;
          final c = checks.data!.firstOrNull;
          void check() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TyreCheckForm(tyreSet: set)));
          if (c == null) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.tire_repair),
                title: const Text('Tyre pressures'),
                subtitle: const Text('No checks yet. Log what you find and what you set them to.'),
                trailing: TextButton(onPressed: check, child: const Text('Check')),
              ),
            );
          }
          final today = DateTime.now();
          final days = DateTime(today.year, today.month, today.day).difference(DateTime(c.at.year, c.at.month, c.at.day)).inDays;
          final found = foundOf(c), left = leftOf(c);
          final rec = [set?.recommendedFrontKpa, set?.recommendedFrontKpa, set?.recommendedRearKpa, set?.recommendedRearKpa];
          Widget wheel(int i, String label) {
            final now = left[i] ?? found[i];
            final low = (underInflation(found[i], rec[i]) ?? 0) >= 0.1;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                child: Column(children: [
                  Text(label, style: t.labelSmall),
                  Text(fmtPressure(now, psi: psi), style: t.titleMedium),
                  if (left[i] != null && found[i] != null && left[i] != found[i])
                    Text('was ${fmtPressure(found[i], psi: psi)}', style: t.labelSmall?.copyWith(color: low ? cs.error : cs.onSurfaceVariant)),
                ]),
              ),
            );
          }

          final overdue = days > tyreCheckEveryDays;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TyresPage())),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.tire_repair, size: 18),
                        const SizedBox(width: 6),
                        Text('Tyres · ${psi ? 'psi' : 'kPa'}', style: t.titleSmall),
                      ]),
                      const SizedBox(height: 2),
                      Text(
                        'Checked ${days == 0 ? 'today' : days == 1 ? 'yesterday' : '$days days ago'}${c.odometerKm == null ? '' : ' at ${fmtKm(c.odometerKm!)} km'}',
                        style: t.bodySmall?.copyWith(color: overdue ? Colors.orange.shade800 : null),
                      ),
                      if (set?.recommendedFrontKpa != null)
                        Text('Recommended ${fmtPressure(set!.recommendedFrontKpa, psi: psi)} front, ${fmtPressure(set.recommendedRearKpa, psi: psi)} rear',
                            style: t.bodySmall),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                        onPressed: check,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Check now'),
                      ),
                    ]),
                  ),
                  SizedBox(
                    width: 150,
                    child: Column(children: [
                      Row(children: [wheel(0, 'FL'), wheel(1, 'FR')]),
                      Row(children: [wheel(2, 'RL'), wheel(3, 'RR')]),
                    ]),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The trip being recorded right now, with a Stop button. Hidden when
/// nothing is recording.
class LiveTripCard extends StatefulWidget {
  const LiveTripCard({super.key});
  @override
  State<LiveTripCard> createState() => _LiveTripCardState();
}

class _LiveTripCardState extends State<LiveTripCard> {
  String? _id;
  List<GpsSample> _live = const [];
  Timer? _timer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (!TripRecorder.supported) return;
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    final id = await TripRecorder.currentTripId();
    final live = id == null ? const <GpsSample>[] : await TripRecorder.liveSamples(id);
    if (mounted) {
      setState(() {
        _id = id;
        _live = live;
      });
    }
  }

  Future<void> _stop() async {
    setState(() => _busy = true);
    await TripRecorder.stop();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _poll();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_id == null) return const SizedBox.shrink();
    final t = Theme.of(context).textTheme;
    final route = [for (final s in _live) if ((s.accuracyM ?? 0) <= maxAccuracyM) LatLng(s.lat, s.lon)];
    final km = liveDistanceKm(_live);
    final start = _live.isNotEmpty ? _live.first.at : null;
    final elapsed = start == null ? Duration.zero : DateTime.now().difference(start);
    final speed = _live.isNotEmpty && _live.last.speedMps != null ? _live.last.speedMps! * 3.6 : null;
    Widget fig(String v, String l) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(v, style: t.titleLarge), Text(l, style: t.bodySmall)]);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 180, child: TripMap(route: route, follow: true)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.fiber_manual_record, color: Colors.red.shade600, size: 14),
              const SizedBox(width: 6),
              Text('Recording a trip', style: t.labelLarge),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              fig('${fmtKm1(km)} km', 'distance'),
              fig(fmtDuration(elapsed), 'elapsed'),
              fig(fmtKmh(speed), 'now'),
              FilledButton.tonalIcon(onPressed: _busy ? null : _stop, icon: const Icon(Icons.stop), label: const Text('Stop')),
            ]),
          ]),
        ),
      ]),
    );
  }
}

/// Where the car was left: the end of the last trip, for up to three days,
/// with walking directions. Hidden while a trip is recording.
class ParkedCard extends StatefulWidget {
  const ParkedCard({super.key});

  static Uri directions(double lat, double lon) =>
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=walking');

  @override
  State<ParkedCard> createState() => _ParkedCardState();
}

class _ParkedCardState extends State<ParkedCard> {
  static Uri directions(double lat, double lon) => ParkedCard.directions(lat, lon);

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    final t = Theme.of(context).textTheme;
    return StreamBuilder<List<Trip>>(
      stream: scope.repo.watchTrips(vid),
      builder: (context, snap) {
        final last = snap.data?.where((x) => x.status != 'report').firstOrNull;
        if (last == null || last.status != 'done' || last.endAt == null) return const SizedBox.shrink();
        if (DateTime.now().difference(last.endAt!) > const Duration(days: 3) || scope.settings.parkedHidden == last.id) return const SizedBox.shrink();
        return FutureBuilder(
          key: ValueKey(last.id),
          future: scope.repo.tripEnds(last.id),
          builder: (context, ends) {
            final at = ends.data?.to;
            if (at == null) return const SizedBox.shrink();
            final place = placeAt(at, scope.settings.places);
            final today = DateTime.now();
            final end = last.endAt!;
            final sameDay = end.year == today.year && end.month == today.month && end.day == today.day;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(height: 150, child: TripMap(route: [LatLng(at.lat, at.lon)], follow: true)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                  child: Row(children: [
                    const Icon(Icons.local_parking, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Parked ${place == null ? '' : 'at ${place.name} '}${sameDay ? 'at' : 'on ${fmtDate(end)},'} ${TimeOfDay.fromDateTime(end).format(context)}',
                        style: t.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await scope.settings.setParkedHidden(last.id);
                        if (mounted) setState(() {});
                      },
                      child: const Text('Hide'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => const MethodChannel('mileagelog/trips').invokeMethod('openUrl', {'url': directions(at.lat, at.lon).toString()}),
                      icon: const Icon(Icons.directions_walk),
                      label: const Text('Find car'),
                    ),
                  ]),
                ),
              ]),
            );
          },
        );
      },
    );
  }
}
