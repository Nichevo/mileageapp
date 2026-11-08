import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../data/database.dart';
import '../domain/trip_stats.dart';
import '../trips/recorder.dart';
import 'format.dart';
import 'trip_detail_page.dart';
import 'trip_format.dart';
import 'trip_map.dart';
import 'trip_settings_page.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});
  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  String? _currentId;
  List<GpsSample> _live = const [];
  Timer? _timer;
  bool _busy = false;
  ({String? address, String? name, bool autoStart})? _car;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted || !TripRecorder.supported) return;
    final scope = AppScope.of(context);
    final id = await TripRecorder.currentTripId();
    final live = id == null ? const <GpsSample>[] : await TripRecorder.liveSamples(id);
    // When a recording has just ended (here or from the notification),
    // save it into the database.
    if (id != _currentId || id == null) {
      await TripRecorder.ingest(scope.repo, scope.settings.activeVehicleId!);
    }
    final car = _car == null || id != _currentId ? await TripRecorder.car() : _car;
    if (!mounted) return;
    setState(() {
      _currentId = id;
      _live = live;
      _car = car;
    });
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    final err = await TripRecorder.startManual();
    if (err != null && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _refresh();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _stop() async {
    setState(() => _busy = true);
    await TripRecorder.stop();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _refresh();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          IconButton(
            tooltip: 'Auto-start with your car',
            icon: const Icon(Icons.bluetooth_drive),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TripSettingsPage()));
              _car = null;
              _refresh();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Trip>>(
        stream: scope.repo.watchTrips(scope.settings.activeVehicleId!),
        builder: (context, snap) {
          final trips = (snap.data ?? const <Trip>[]).where((t) => t.status != 'recording' || t.id == _currentId).toList();
          final done = trips.where((t) => t.status == 'done').toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (!TripRecorder.supported)
                const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Trip recording works on the Android app.')))
              else if (_currentId != null)
                _liveCard(context)
              else
                _startCard(context),
              const SizedBox(height: 16),
              if (done.isNotEmpty) _yearSummary(context, done),
              const SizedBox(height: 8),
              if (trips.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No trips yet. Start one above, or set up auto-start so trips record themselves when the phone connects to the car.', textAlign: TextAlign.center),
                ),
              for (final t in trips.where((t) => t.id != _currentId)) _tripTile(context, t),
            ],
          );
        },
      ),
    );
  }

  Widget _startCard(BuildContext context) {
    final car = _car;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
          onPressed: _busy ? null : _start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start trip', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 6),
        Text(
          car?.autoStart == true && car?.name != null
              ? 'Auto-start is on: trips start when the phone connects to ${car!.name}.'
              : 'Tip: tap the Bluetooth car icon above to start trips automatically in the car.',
          style: t.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _liveCard(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final route = [for (final s in _live) if ((s.accuracyM ?? 0) <= maxAccuracyM) LatLng(s.lat, s.lon)];
    final km = liveDistanceKm(_live);
    final start = _live.isNotEmpty ? _live.first.at : null;
    final elapsed = start == null ? Duration.zero : DateTime.now().difference(start);
    final speed = _live.isNotEmpty && _live.last.speedMps != null ? _live.last.speedMps! * 3.6 : null;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 240, child: TripMap(route: route, follow: true)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red.shade600, size: 14),
                  const SizedBox(width: 6),
                  Text('Recording', style: t.labelLarge),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _figure(t, '${fmtKm1(km)} km', 'distance'),
                    _figure(t, fmtDuration(elapsed), 'elapsed'),
                    _figure(t, fmtKmh(speed), 'now'),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _stop,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop trip'),
                ),
                const SizedBox(height: 4),
                Text('Recording carries on with the screen off. You can also stop it from the notification.', style: t.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _figure(TextTheme t, String value, String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(value, style: t.titleLarge), Text(label, style: t.bodySmall)],
      );

  Widget _yearSummary(BuildContext context, List<Trip> done) {
    final t = Theme.of(context).textTheme;
    final year = DateTime.now().year;
    var km = 0.0;
    var moving = Duration.zero;
    final bands = <SpeedBand, double>{};
    var n = 0;
    for (final trip in done.where((x) => x.startAt.year == year)) {
      n++;
      final s = trip.statsJson == null ? null : TripStats.fromJson(jsonDecode(trip.statsJson!) as Map<String, Object?>);
      km += s?.distanceKm ?? trip.gpsDistanceKm ?? 0;
      moving += s?.moving ?? Duration.zero;
      s?.bandKm.forEach((b, v) => bands[b] = (bands[b] ?? 0) + v);
    }
    if (n == 0) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recorded in $year', style: t.labelLarge),
            const SizedBox(height: 4),
            Text('$n trips · ${fmtKm(km)} km · ${fmtDuration(moving)} moving', style: t.titleMedium),
            const SizedBox(height: 12),
            BandBar(bandKm: bands),
          ],
        ),
      ),
    );
  }

  Widget _tripTile(BuildContext context, Trip trip) {
    final s = trip.statsJson == null ? null : TripStats.fromJson(jsonDecode(trip.statsJson!) as Map<String, Object?>);
    final odoKm = trip.startOdometerKm != null && trip.endOdometerKm != null ? trip.endOdometerKm! - trip.startOdometerKm! : null;
    final km = s?.distanceKm ?? trip.gpsDistanceKm ?? odoKm;
    final parts = <String>[
      fmtDate(trip.startAt),
      if (km != null) '${fmtKm1(km)} km',
      if (s != null) fmtDuration(s.total),
      if (s?.movingAvgKmh != null) 'avg ${fmtKmh(s!.movingAvgKmh)}',
      if (trip.status == 'report') 'odometer only',
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Icon(trip.status == 'report' ? Icons.description_outlined : (trip.startedBy == 'bluetooth' ? Icons.bluetooth : Icons.route)),
      ),
      title: Text(trip.name),
      subtitle: Text(parts.join(' · ')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripDetailPage(tripId: trip.id))),
    );
  }
}

/// Horizontal bar showing the urban / open road / motorway split by distance.
class BandBar extends StatelessWidget {
  final Map<SpeedBand, double> bandKm;
  const BandBar({super.key, required this.bandKm});

  static Color colorFor(SpeedBand b, ColorScheme cs) => switch (b) {
        SpeedBand.urban => cs.tertiary,
        SpeedBand.openRoad => cs.primary,
        SpeedBand.motorway => cs.secondary,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final shares = bandShares(bandKm);
    if (shares.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 14,
            child: Row(children: [
              for (final b in SpeedBand.values)
                if ((shares[b] ?? 0) > 0)
                  Expanded(flex: ((shares[b] ?? 0) * 1000).round().clamp(1, 1000), child: Container(color: colorFor(b, cs))),
            ]),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 14, runSpacing: 4, children: [
          for (final b in SpeedBand.values)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: colorFor(b, cs), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 4),
              Text('${bandLabel(b)} ${((shares[b] ?? 0) * 100).round()}% · ${fmtKm(bandKm[b] ?? 0)} km', style: t.bodySmall),
            ]),
        ]),
      ],
    );
  }
}
