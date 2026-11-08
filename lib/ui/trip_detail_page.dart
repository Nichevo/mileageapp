import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/road_match.dart';
import '../domain/stats.dart';
import '../domain/trip_stats.dart';
import '../trips/road_lookup.dart';
import 'format.dart';
import 'trip_format.dart';
import 'trip_map.dart';
import 'trips_page.dart' show BandBar;

class TripDetailPage extends StatefulWidget {
  final String tripId;
  const TripDetailPage({super.key, required this.tripId});
  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  List<TripPoint>? _points;
  List<TripStop> _stops = const [];
  TripStats? _stats;
  ({double per100, double price})? _fuel;
  bool _roadBusy = false, _roadTried = false;
  String? _roadError;

  Future<void> _lookupRoads() async {
    final repo = AppScope.of(context).repo;
    setState(() {
      _roadBusy = true;
      _roadTried = true;
      _roadError = null;
    });
    String? error;
    try {
      final r = await RoadLookup.analyse(repo, widget.tripId);
      if (r == null) error = 'This trip is too short to look up.';
    } catch (_) {
      error = 'Couldn\'t reach OpenStreetMap. Check the connection and try again.';
    }
    if (!mounted) return;
    setState(() {
      _roadBusy = false;
      _roadError = error;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final scope = AppScope.of(context);
    final pts = await scope.repo.tripPoints(widget.tripId);
    final stops = await scope.repo.tripStops(widget.tripId);
    final samples = [
      for (final p in pts) GpsSample(p.at, p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM, altitudeM: p.altitudeM),
    ];
    final events = await scope.repo.events(scope.settings.activeVehicleId!);
    final tanks = tankStats(Repository.toFuelRows(events));
    final rolling = rollingPer100(tanks);
    final per100 = rolling.lastWhere((v) => v != null, orElse: () => null);
    if (!mounted) return;
    setState(() {
      _points = pts;
      _stops = stops;
      _stats = samples.length > 1 ? computeTripStats(samples) : null;
      _fuel = per100 == null || tanks.isEmpty ? null : (per100: per100, price: tanks.last.pricePerUnit);
    });
  }

  Future<void> _rename(Trip trip) async {
    final name = TextEditingController(text: trip.name);
    final notes = TextEditingController(text: trip.notes ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit trip'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await AppScope.of(context).repo.renameTrip(
          trip.id,
          name.text.trim().isEmpty ? trip.name : name.text.trim(),
          notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
        );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this trip?'),
        content: const Text('The route and its stats are removed from the phone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final repo = AppScope.of(context).repo;
    Navigator.of(context).pop();
    await repo.deleteTrip(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    return StreamBuilder<Trip?>(
      stream: scope.repo.watchTrip(widget.tripId),
      builder: (context, snap) {
        final trip = snap.data;
        final road = RoadLookup.stored(trip?.statsJson);
        if (trip != null && road == null && !_roadTried && _stats != null && scope.settings.roadLookup) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_roadTried) _lookupRoads();
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(trip?.name ?? 'Trip'),
            actions: [
              if (trip != null) IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined), onPressed: () => _rename(trip)),
              IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: _delete),
            ],
          ),
          body: trip == null || _points == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    if (_points!.isNotEmpty)
                      SizedBox(
                        height: 300,
                        child: TripMap(
                          route: [for (final p in _points!) if ((p.accuracyM ?? 0) <= maxAccuracyM) LatLng(p.lat, p.lon)],
                          stops: [for (final s in _stops) if (s.lat != null) LatLng(s.lat!, s.lon!)],
                          lights: [for (final l in road?.lights ?? const <LightPass>[]) (at: LatLng(l.lat, l.lon), stopped: l.stopped)],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${fmtDate(trip.startAt)}, ${TimeOfDay.fromDateTime(trip.startAt).format(context)}'
                            '${trip.endAt == null ? '' : ' to ${TimeOfDay.fromDateTime(trip.endAt!).format(context)}'}'
                            '${trip.startedBy == 'bluetooth' ? ' · started by Bluetooth' : ''}',
                            style: t.bodyMedium,
                          ),
                          if (trip.notes != null) ...[const SizedBox(height: 6), Text(trip.notes!, style: t.bodyMedium)],
                          const SizedBox(height: 16),
                          if (_stats != null) ..._statsSection(context, _stats!, road) else _reportSection(context, trip),
                          if (_stats != null) ...[const SizedBox(height: 20), _roadSection(context, road)],
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  List<Widget> _statsSection(BuildContext context, TripStats s, RoadStats? road) {
    final t = Theme.of(context).textTheme;
    final litres = _fuel == null ? null : s.distanceKm * _fuel!.per100 / 100;
    final tiles = <(String, String)>[
      ('Distance', '${fmtKm1(s.distanceKm)} km'),
      ('Total time', fmtDuration(s.total)),
      ('Moving time', fmtDuration(s.moving)),
      ('Stopped', fmtDuration(s.stopped)),
      ('Average speed', fmtKmh(s.avgKmh)),
      ('Moving average', fmtKmh(s.movingAvgKmh)),
      ('Top speed', fmtKmh(s.maxKmh)),
      ('Short stops', '${s.shortStops}'),
      ('Longer stops', '${s.stops.length}'),
      if (road != null && road.lightsPassed > 0) ...[
        ('Traffic lights', '${road.stoppedAtLights} red of ${road.lightsPassed}'),
        ('Waiting at lights', fmtDuration(road.waitAtLights)),
      ],
      ('Climb', '${s.elevationGainM.round()} m'),
      ('Harsh braking', '${s.harshBrakes}'),
      ('Hard acceleration', '${s.harshAccels}'),
      if (litres != null) ('Fuel (estimate)', '${litres.toStringAsFixed(1)} L · ${fmtMoney(litres * _fuel!.price)}'),
    ];
    return [
      LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth > 560 ? 4 : 2;
        final w = (c.maxWidth - (cols - 1) * 8) / cols;
        return Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (label, value) in tiles)
            SizedBox(
              width: w,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(label, style: t.bodySmall),
                    const SizedBox(height: 2),
                    Text(value, style: t.titleMedium),
                  ]),
                ),
              ),
            ),
        ]);
      }),
      const SizedBox(height: 16),
      Text('Where the kilometres were', style: t.titleSmall),
      const SizedBox(height: 8),
      BandBar(bandKm: s.bandKm),
      const SizedBox(height: 6),
      Text('Split by speed: urban under 60 km/h, open road 60–90, motorway 90 and over.', style: t.bodySmall),
      const SizedBox(height: 4),
      Text('Short stops are 5 seconds to 2 minutes stationary, mostly traffic lights and give-ways. Longer stops are marked on the map.', style: t.bodySmall),
      if (_fuel != null) ...[
        const SizedBox(height: 4),
        Text('Fuel estimate uses your recent ${_fuel!.per100.toStringAsFixed(1)} L/100 km and last price ${fmtPrice(_fuel!.price)}.', style: t.bodySmall),
      ],
    ];
  }

  Widget _roadSection(BuildContext context, RoadStats? road) {
    final t = Theme.of(context).textTheme;
    if (road == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Road types and traffic lights', style: t.titleSmall),
        const SizedBox(height: 8),
        if (_roadBusy)
          const Row(children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Looking up the roads on OpenStreetMap…'),
          ])
        else ...[
          if (_roadError != null) ...[Text(_roadError!, style: t.bodySmall), const SizedBox(height: 8)],
          OutlinedButton.icon(
            onPressed: _lookupRoads,
            icon: const Icon(Icons.traffic_outlined),
            label: Text(_roadError == null ? 'Look up road types and traffic lights' : 'Try again'),
          ),
        ],
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Road types', style: t.titleSmall),
      const SizedBox(height: 8),
      RoadBar(roadKm: road.roadKm),
      const SizedBox(height: 6),
      Text(
        road.lightsPassed == 0
            ? 'No traffic lights on this route.'
            : 'You went through ${road.lightsPassed} sets of traffic lights and stopped at ${road.stoppedAtLights}, '
                'waiting ${fmtDuration(road.waitAtLights)} in total. They are marked on the map: red where you stopped, green where you didn\'t.',
        style: t.bodySmall,
      ),
      const SizedBox(height: 4),
      Text('From OpenStreetMap. The first and last 300 m aren\'t looked up, so lights right next to the start or end aren\'t counted.', style: t.bodySmall),
    ]);
  }

  Widget _reportSection(BuildContext context, Trip trip) {
    final t = Theme.of(context).textTheme;
    final km = trip.startOdometerKm != null && trip.endOdometerKm != null ? trip.endOdometerKm! - trip.startOdometerKm! : trip.gpsDistanceKm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (km != null) Text('${fmtKm1(km)} km', style: t.headlineSmall),
        if (trip.startOdometerKm != null) Text('Odometer ${fmtKm(trip.startOdometerKm!)} to ${trip.endOdometerKm == null ? '?' : fmtKm(trip.endOdometerKm!)} km'),
        const SizedBox(height: 8),
        Text(trip.status == 'report' ? 'Imported from the old app, so there is no GPS route.' : 'Not enough GPS points were recorded for stats.', style: t.bodySmall),
      ],
    );
  }
}

/// Horizontal bar showing distance by road type.
class RoadBar extends StatelessWidget {
  final Map<RoadClass, double> roadKm;
  const RoadBar({super.key, required this.roadKm});

  static Color colorFor(RoadClass c) => switch (c) {
        RoadClass.motorway => Colors.indigo.shade400,
        RoadClass.main => Colors.teal.shade500,
        RoadClass.suburban => Colors.amber.shade700,
        RoadClass.local => Colors.deepOrange.shade400,
        RoadClass.other => Colors.grey.shade500,
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final shares = roadShares(roadKm);
    if (shares.isEmpty) return const SizedBox.shrink();
    final shown = [for (final c in RoadClass.values) if ((shares[c] ?? 0) > 0) c];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 14,
          child: Row(children: [
            for (final c in shown)
              Expanded(flex: ((shares[c] ?? 0) * 1000).round().clamp(1, 1000), child: Container(color: colorFor(c))),
          ]),
        ),
      ),
      const SizedBox(height: 6),
      Wrap(spacing: 14, runSpacing: 4, children: [
        for (final c in shown)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: colorFor(c), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Text('${roadLabel(c)} ${((shares[c] ?? 0) * 100).round()}% · ${fmtKm1(roadKm[c] ?? 0)} km', style: t.bodySmall),
          ]),
      ]),
    ]);
  }
}
