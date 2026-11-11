import 'dart:convert';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/reminders.dart' show tollPayBy, tollPayDays;
import '../domain/road_match.dart';
import '../domain/places.dart';
import '../domain/trip_profile.dart';
import '../domain/trip_weather.dart';
import '../domain/stats.dart';
import '../domain/trip_stats.dart';
import '../trips/recorder.dart' show TripRecorder;
import '../trips/road_lookup.dart';
import '../domain/route_compare.dart' show NearMatch, NearReason;
import '../trips/route_compare_service.dart';
import '../trips/weather_lookup.dart';
import 'export_page.dart' show shareTripGpx;
import 'format.dart';
import 'places_page.dart' show pickPlaceName;
import 'toll_form.dart';
import 'trip_format.dart';
import 'route_compare_page.dart';
import 'trip_map.dart';
import 'vehicle_page.dart' show vehicleIcon;
import 'trips_page.dart' show BandBar;

class TripDetailPage extends StatefulWidget {
  final String tripId;
  const TripDetailPage({super.key, required this.tripId});
  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  List<TripPoint>? _points;
  List<ProfilePoint> _profile = const [];
  List<TripStop> _stops = const [];
  TripStats? _stats;
  ({double per100, double price})? _fuel;
  bool _roadBusy = false, _roadTried = false;
  String? _roadError;
  bool _wxBusy = false, _wxTried = false;
  String? _wxError;

  Future<void> _lookupWeather() async {
    final repo = AppScope.of(context).repo;
    setState(() {
      _wxBusy = true;
      _wxTried = true;
      _wxError = null;
    });
    String? error;
    try {
      await WeatherLookup.analyse(repo, widget.tripId);
    } catch (_) {
      error = 'Couldn\'t reach the weather service. Check the connection and try again.';
    }
    if (!mounted) return;
    setState(() {
      _wxBusy = false;
      _wxError = error;
    });
  }

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
      _profile = tripProfile(samples);
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
        _statsJson = trip?.statsJson == null ? const {} : (jsonDecode(trip!.statsJson!) as Map<String, Object?>);
        if (trip != null && trip.status == 'done' && !_statsJson.containsKey('weather') && !_wxTried && _stats != null && scope.settings.weatherLookup) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_wxTried) _lookupWeather();
          });
        }
        if (trip != null && road == null && !_roadTried && _stats != null && scope.settings.roadLookup) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_roadTried) _lookupRoads();
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(trip == null ? 'Trip' : _title(trip)),
            actions: [
              if (trip != null) IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined), onPressed: () => _rename(trip)),
              if (trip != null) IconButton(tooltip: 'Export GPX route', icon: const Icon(Icons.ios_share), onPressed: () => shareTripGpx(context, trip)),
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
                          route: [for (final p in _accurate) LatLng(p.lat, p.lon)],
                          speedsKmh: pointSpeedsKmh([
                            for (final p in _accurate) GpsSample(p.at, p.lat, p.lon, speedMps: p.speedMps, accuracyM: p.accuracyM),
                          ]),
                          stops: [for (final s in _stops) if (s.lat != null && !_atLight(s, road)) LatLng(s.lat!, s.lon!)],
                          lights: [for (final l in road?.lights ?? const <LightPass>[]) (at: LatLng(l.lat, l.lon), stopped: l.stopped, phases: l.phases ?? (l.stopped ? 1 : 0))],
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
                          _vehicleRow(context, trip),
                          if (trip.status == 'done') _endsRow(context),
                          if (trip.notes != null) ...[const SizedBox(height: 6), Text(trip.notes!, style: t.bodyMedium)],
                          const SizedBox(height: 16),
                          if (_stats != null) ..._statsSection(context, _stats!, road, TripBattery.from(trip.statsJson)) else _reportSection(context, trip),
                          if (_stats != null && trip.status == 'done') _weatherSection(context, trip),
                          if (_stats != null) ..._chartsSection(context),
                          if (_stats != null && trip.status == 'done') _compareSection(context, trip),
                          if (_stats != null) ...[const SizedBox(height: 20), _roadSection(context, road)],
                          const SizedBox(height: 20),
                          _costsSection(context, trip, road),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Map<String, Object?> _statsJson = const {};

  /// Which vehicle the trip was in, with a way to move it to another.
  Widget _vehicleRow(BuildContext context, Trip trip) {
    final scope = AppScope.of(context);
    return StreamBuilder<List<Vehicle>>(
      stream: scope.repo.watchVehicles(),
      builder: (context, snap) {
        final vehicles = [for (final x in snap.data ?? const <Vehicle>[]) if (x.archivedAt == null || x.id == trip.vehicleId) x];
        final v = vehicles.where((x) => x.id == trip.vehicleId).firstOrNull;
        if (v == null) return const SizedBox.shrink();
        final car = scope.settings.vehicleCars[v.id];
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            ActionChip(
              avatar: Icon(vehicleIcon(v.kind), size: 18),
              label: Text(v.name),
              tooltip: vehicles.length > 1 ? 'Move to another vehicle' : null,
              onPressed: vehicles.length < 2 ? null : () => _moveTrip(trip, vehicles),
            ),
            if (trip.startedBy == 'bluetooth' && car != null) Text('via ${car.name}', style: Theme.of(context).textTheme.bodySmall),
          ]),
        );
      },
    );
  }

  Future<void> _moveTrip(Trip trip, List<Vehicle> vehicles) async {
    final scope = AppScope.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text('Which vehicle was this trip in?')),
          for (final v in vehicles)
            ListTile(
              leading: Icon(vehicleIcon(v.kind)),
              title: Text(v.name),
              trailing: v.id == trip.vehicleId ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(c, v.id),
            ),
        ]),
      ),
    );
    if (picked == null || picked == trip.vehicleId) return;
    await scope.repo.moveTrip(trip.id, picked);
    _compare = null;
    if (mounted) {
      final name = vehicles.firstWhere((v) => v.id == picked).name;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trip moved to $name')));
      setState(() {});
    }
  }

  /// Where the trip started and ended: the place name, or a chip to name it.
  Widget _endsRow(BuildContext context) {
    final pts = _accurate;
    if (pts.length < 2) return const SizedBox.shrink();
    final settings = AppScope.of(context).settings;
    Widget end(String label, TripPoint p) {
      final pl = placeAt((lat: p.lat, lon: p.lon), settings.places);
      if (pl != null) return Chip(avatar: const Icon(Icons.place_outlined, size: 18), label: Text('$label ${pl.name}'));
      return ActionChip(
        avatar: const Icon(Icons.add_location_alt_outlined, size: 18),
        label: Text(label == 'From' ? 'Name the start' : 'Name the destination'),
        onPressed: () async {
          final n = await pickPlaceName(
            context,
            taken: settings.places.map((x) => x.name).toSet(),
            title: label == 'From' ? 'Name where this trip started' : 'Name where this trip ended',
          );
          if (n == null || n.trim().isEmpty) return;
          await settings.setPlaces([...settings.places, Place(newId(), n.trim(), p.lat, p.lon)]);
          if (mounted) setState(() {});
        },
      );
    }

    final first = pts.first, last = pts.last;
    final roundTrip = haversineKm(first.lat, first.lon, last.lat, last.lon) * 1000 <= placeRadiusM;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(spacing: 8, runSpacing: 4, children: [end('From', first), if (!roundTrip) end('To', last)]),
    );
  }
  Future<TripComparison>? _compare;

  /// Stretches of this trip that other trips also drove, and trips that
  /// nearly did.
  Widget _compareSection(BuildContext context, Trip trip) {
    final scope = AppScope.of(context);
    _compare ??= RouteCompare.compareTrip(scope.repo, trip.vehicleId, trip.id, scope.settings.places);
    return FutureBuilder<TripComparison>(
      future: _compare,
      builder: (context, snap) {
        final list = snap.data?.stretches ?? const <StretchResult>[];
        final near = snap.data?.near ?? const [];
        if (list.isEmpty && near.isEmpty) return const SizedBox.shrink();
        final t = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Compared with other trips', style: t.titleMedium),
            if (list.isEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('No other trip shares 2 km of this route yet.', style: t.bodySmall)),
            for (final s in list)
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  leading: const Icon(Icons.compare_arrows),
                  title: Text('${s.name}, driven ${s.runs.length} times'),
                  subtitle: Text(stretchSummary(s, trip.id)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RouteComparePage(stretch: s, tripId: trip.id))),
                ),
              ),
            if (near.isNotEmpty) NearMatchCard(near: near),
          ]),
        );
      },
    );
  }

  /// Weather at the time and ground elevation, or a button to look them up.
  Widget _weatherSection(BuildContext context, Trip trip) {
    final t = Theme.of(context).textTheme;
    final looked = _statsJson.containsKey('weather');
    final w = TripWeather.fromJson(_statsJson['weather']);
    final e = TripElevation.fromJson(_statsJson['elev']);
    final samples = [for (final p in _accurate) GpsSample(p.at, p.lat, p.lon)];
    if (!looked) {
      if (_wxBusy) return const Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator());
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (_wxError != null) Text(_wxError!, style: t.bodySmall),
          OutlinedButton.icon(
            onPressed: _lookupWeather,
            icon: const Icon(Icons.cloud_outlined),
            label: Text(_wxError == null ? 'Look up weather and elevation' : 'Try again'),
          ),
        ]),
      );
    }
    if (w == null && e == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (w != null)
          Row(children: [
            Icon(_weatherIcon(w.code), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(w.describe(headingDeg: overallHeading(samples)), style: t.bodyLarge)),
          ]),
        if (e != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.terrain_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Climb ${e.gainM.round()} m, descent ${e.lossM.round()} m, between ${e.minM.round()} and ${e.maxM.round()} m above sea level',
                  style: t.bodyLarge),
            ),
          ]),
        ],
        const SizedBox(height: 4),
        Text('From Open-Meteo: weather for the hour of the trip near its middle, and ground height along the route.', style: t.bodySmall),
      ]),
    );
  }

  static IconData _weatherIcon(int code) => code >= 95
      ? Icons.thunderstorm_outlined
      : (code >= 51 ? Icons.water_drop_outlined : (code >= 45 ? Icons.foggy : (code >= 2 ? Icons.cloud_outlined : Icons.wb_sunny_outlined)));

  /// "Home → Work" for trips that still have their automatic name.
  String _title(Trip trip) {
    final pts = _accurate;
    if (pts.isEmpty || trip.name != TripRecorder.defaultName(trip.startAt)) return trip.name;
    final places = AppScope.of(context).settings.places;
    return placeTitle(placeAt((lat: pts.first.lat, lon: pts.first.lon), places), placeAt((lat: pts.last.lat, lon: pts.last.lon), places)) ?? trip.name;
  }

  List<TripPoint> get _accurate => [for (final p in _points ?? const <TripPoint>[]) if ((p.accuracyM ?? 0) <= maxAccuracyM) p];

  /// Speed, and elevation when the phone recorded it, through the trip.
  List<Widget> _chartsSection(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final speed = [for (final p in _profile) if (p.kmh != null) FlSpot(p.minutes, p.kmh!)];
    final alt = [for (final p in _profile) if (p.altitudeM != null) FlSpot(p.minutes, p.altitudeM!)];
    if (speed.length < 3) return const [];
    Widget chart(String title, List<FlSpot> spots, Color colour, String unit, {bool fromZero = true, String xUnit = 'min'}) {
      final ys = spots.map((s) => s.y);
      final lo = fromZero ? 0.0 : ys.reduce(math.min), hi = ys.reduce(math.max);
      final pad = math.max(5.0, (hi - lo) * 0.1);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Text(title, style: t.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: LineChart(LineChartData(
            minY: fromZero ? 0 : (lo - pad).floorToDouble(),
            maxY: (hi + pad).ceilToDouble(),
            minX: 0,
            maxX: spots.last.x,
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (v, m) => Text(v.round().toString(), style: t.labelSmall))),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: _niceMinutes(spots.last.x),
                  getTitlesWidget: (v, m) => Text('${v.round()} $xUnit', style: t.labelSmall),
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (items) => [
                  for (final i in items) LineTooltipItem('${i.y.round()} $unit\n${i.x.toStringAsFixed(xUnit == 'km' ? 1 : 0)} $xUnit', TextStyle(color: cs.onInverseSurface)),
                ],
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.15,
                color: colour,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: colour.withValues(alpha: 0.15)),
              ),
            ],
          )),
        ),
      ]);
    }

    final elev = TripElevation.fromJson(_statsJson['elev']);
    return [
      chart('Speed · km/h', speed, cs.primary, 'km/h'),
      if (elev != null && elev.profile.length >= 3)
        chart('Elevation · m, by distance', [for (final p in elev.profile) FlSpot(p.km, p.m)], cs.tertiary, 'm', fromZero: false, xUnit: 'km')
      else if (alt.length >= 3)
        chart('Elevation · m (phone GPS)', alt, cs.tertiary, 'm', fromZero: false),
    ];
  }

  static double _niceMinutes(double total) {
    for (final step in [1.0, 2, 5, 10, 15, 30, 60, 120, 240]) {
      if (total / step <= 6) return step.toDouble();
    }
    return 480;
  }

  /// A longer stop that was really a wait in the queue at a red light.
  static bool _atLight(TripStop s, RoadStats? road) =>
      road != null && s.lat != null && s.departAt != null && waitingAtLight(s.lat!, s.lon!, s.departAt!.difference(s.arriveAt), road.lights);

  List<Widget> _statsSection(BuildContext context, TripStats s, RoadStats? road, TripBattery? battery) {
    final t = Theme.of(context).textTheme;
    final lights = road?.lights ?? const <LightPass>[];
    final queued = s.stops.where((x) => waitingAtLight(x.lat, x.lon, x.duration, lights)).length;
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
      ('Longer stops', '${s.stops.length - queued}'),
      if (road != null && road.lightsPassed > 0) ...[
        ('Traffic lights', '${road.stoppedAtLights} red of ${road.lightsPassed}'),
        ('Waiting at lights', fmtMinSec(road.waitAtLights)),
        if (road.cyclesCounted) ('Red phases waited', '${road.redPhases}${road.multiPhaseLights > 0 ? ' (${road.multiPhaseLights} missed a green)' : ''}'),
      ],
      ('Climb', '${s.elevationGainM.round()} m'),
      ('Harsh braking', '${s.harshBrakes}'),
      ('Hard acceleration', '${s.harshAccels}'),
      if (battery != null) ('Phone battery used', battery.describe(s.total)),
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
      Text(
          'Short stops are 5 seconds to 2 minutes stationary, mostly traffic lights and give-ways. Longer stops are marked on the map. '
          '${queued == 0 ? '' : 'Long waits in the queue at a red light (up to 5 minutes) count as waiting at lights, not stops${queued == 1 ? '' : ' ($queued here)'}.'}',
          style: t.bodySmall),
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
                'waiting ${fmtMinSec(road.waitAtLights)} in total. They are marked on the map: red where you stopped, green where you didn\'t, '
                'with a number where you sat through more than one red.',
        style: t.bodySmall,
      ),
      if (road.cyclesCounted && road.stoppedAtLights > 0) ...[
        const SizedBox(height: 4),
        Text(
          'Longest waits: ${([...road.lights.where((l) => l.stopped)]..sort((a, b) => (b.waitS ?? 0).compareTo(a.waitS ?? 0))).take(3).map((l) => '${fmtMinSec(Duration(seconds: l.waitS ?? 0))}${(l.phases ?? 1) > 1 ? ' (${l.phases} reds)' : ''}').join(', ')}. '
          'Red phases are estimated from the GPS: a stop of 15 s or more after moving up in the queue counts as another red.',
          style: t.bodySmall,
        ),
      ],
      const SizedBox(height: 4),
      Text('From OpenStreetMap. The first and last 300 m aren\'t looked up, so lights right next to the start or end aren\'t counted.', style: t.bodySmall),
    ]);
  }

  /// Toll roads used, and tolls and parking logged against this trip.
  Widget _costsSection(BuildContext context, Trip trip, RoadStats? road) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final repo = AppScope.of(context).repo;
    final tolls = road?.tolls ?? const <TollUse>[];
    final tollNames = tolls.map((x) => x.name).join(', ');
    return StreamBuilder<List<Expense>>(
      stream: repo.watchTripExpenses(trip.id),
      builder: (context, snap) {
        final items = snap.data ?? const <Expense>[];
        final tollLogged = items.any((e) => e.kind == 'toll');
        final total = items.fold(0.0, (a, e) => a + e.cost);
        final by = tollPayBy(trip.startAt);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tolls and parking', style: t.titleSmall),
          if (tolls.isNotEmpty)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: tollLogged ? null : cs.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.toll_outlined),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Toll road: $tollNames', style: t.titleSmall)),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    tollLogged
                        ? 'Toll logged for this trip.'
                        : 'Pay by ${fmtDate(by)} (within $tollPayDays days of travel), unless a toll account pays it for you.',
                    style: t.bodySmall,
                  ),
                  if (!tollLogged)
                    Wrap(spacing: 8, children: [
                      TextButton.icon(onPressed: () => openTollPayment(context), icon: const Icon(Icons.open_in_new, size: 18), label: const Text('Pay on NZTA')),
                      TextButton.icon(
                        onPressed: () => editTollParking(context, kind: 'toll', tripId: trip.id, at: trip.startAt, place: tollNames),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Log toll paid'),
                      ),
                    ]),
                ]),
              ),
            ),
          for (final e in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(tollParkingIcon(e.kind)),
              title: Text(e.description),
              trailing: Text(fmtMoney(e.cost)),
              onTap: () => editTollParking(context, existing: e),
            ),
          if (items.length > 1) Text('Total ${fmtMoney(total)}', style: t.bodySmall),
          Wrap(spacing: 8, children: [
            TextButton.icon(
              onPressed: () => editTollParking(context, kind: 'parking', tripId: trip.id, at: trip.endAt ?? trip.startAt),
              icon: const Icon(Icons.local_parking, size: 18),
              label: const Text('Add parking'),
            ),
            if (tolls.isEmpty || tollLogged)
              TextButton.icon(
                onPressed: () => editTollParking(context, kind: 'toll', tripId: trip.id, at: trip.startAt, place: tollNames.isEmpty ? null : tollNames),
                icon: const Icon(Icons.toll_outlined, size: 18),
                label: const Text('Add toll'),
              ),
          ]),
        ]);
      },
    );
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

/// Phone battery at the start and end of a recorded trip.
class TripBattery {
  final int start, end;
  final bool charging;
  const TripBattery(this.start, this.end, this.charging);

  static TripBattery? from(String? statsJson) {
    if (statsJson == null) return null;
    final b = (jsonDecode(statsJson) as Map<String, Object?>)['battery'];
    if (b is! Map || b['start'] is! num || b['end'] is! num) return null;
    return TripBattery((b['start'] as num).toInt(), (b['end'] as num).toInt(), b['charging'] == true);
  }

  int get used => start - end;

  /// "3% · 2.6% per hour", or "Charging (60% to 72%)".
  String describe(Duration total) {
    if (charging) return 'Charging ($start% to $end%)';
    final perHour = total.inMinutes >= 10 ? ' · ${(used / (total.inMinutes / 60)).toStringAsFixed(1)}% per hour' : '';
    return '${used <= 0 ? 0 : used}%$perHour';
  }
}

/// Why a near match doesn't count yet, in words.
String nearReasonText(NearMatch m, String? stretch) {
  final km = m.sharedKm.toStringAsFixed(1);
  final pieces = m.pieces > 1 ? ' in ${m.pieces} pieces' : '';
  return switch (m.reason) {
    NearReason.partCover => 'Drove ${((m.cover ?? 0) * 100).round()}% of ${stretch ?? 'the stretch'}, needs 90%',
    NearReason.tooShort => 'Same road the same way for $km km$pieces, needs 2 km in one go',
    NearReason.drift => 'Close for $km km$pieces, but GPS was up to 90 m off (needs within 40 m)',
    NearReason.opposite => 'Same road the other way for $km km$pieces, which doesn\'t count',
  };
}

/// Trips that came close to matching this one, with a score.
class NearMatchCard extends StatelessWidget {
  final List<({NearMatch match, String name, String? stretch})> near;
  const NearMatchCard({super.key, required this.near});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.join_inner),
        title: Text('${near.length} trip${near.length == 1 ? '' : 's'} nearly matched'),
        subtitle: const Text('How close each came to counting, and why it didn\'t'),
        shape: const Border(),
        children: [
          for (final n in near)
            ListTile(
              leading: SizedBox(
                width: 44,
                height: 44,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(value: n.match.score, strokeWidth: 4, backgroundColor: cs.surfaceContainerHighest),
                  Text('${(n.match.score * 100).round()}', style: t.labelSmall),
                ]),
              ),
              title: Text('${n.name}, ${fmtDate(n.match.start)} ${TimeOfDay.fromDateTime(n.match.start.toLocal()).format(context)}'),
              subtitle: Text(nearReasonText(n.match, n.stretch)),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripDetailPage(tripId: n.match.tripId))),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('Score out of 100: how close the trip came to counting as the same route. 100 would count.', style: t.bodySmall),
          ),
        ],
      ),
    );
  }
}
