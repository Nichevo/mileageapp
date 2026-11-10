import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart' show newId;
import '../domain/places.dart';
import '../domain/trip_filter.dart';
import '../domain/trip_stats.dart';
import '../trips/recorder.dart';
import '../trips/road_lookup.dart';
import '../trips/trip_lookups.dart';
import 'format.dart';
import 'trip_detail_page.dart';
import 'trip_format.dart';
import 'route_compare_page.dart' show RoutesPage;
import 'trip_map.dart';
import 'vehicle_page.dart' show VehicleChip;
import 'places_page.dart' show askPlaceName;
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
  TripSort _sort = TripSort.newest;
  TripPeriod _period = TripPeriod.all;
  TripSize _size = TripSize.any;
  final _selected = <String>{};
  String? _placeId; // filter: trips starting or ending here
  /// Every vehicle's trips (chosen from the vehicle chip).
  bool get _allVehicles => _viewAll?.value ?? false;
  ValueNotifier<bool>? _viewAll;
  void _onViewAll() => setState(() {
        _selected.clear();
        _endsKey = '';
      });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final n = AppScope.of(context).settings.viewAll;
    if (!identical(n, _viewAll)) {
      _viewAll?.removeListener(_onViewAll);
      _viewAll = n..addListener(_onViewAll);
    }
  }

  /// Start and end of every recorded trip, for place names.
  Map<String, ({({double lat, double lon}) from, ({double lat, double lon}) to})> _allEnds = const {};
  String _endsKey = '';

  /// First and last points of trips that might be merged, loaded on demand.
  final _ends = <String, ({({double lat, double lon}) from, ({double lat, double lon}) to})?>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _viewAll?.removeListener(_onViewAll);
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
      await TripRecorder.ingest(scope.repo, scope.settings.activeVehicleId!, settings: scope.settings);
      lookUpRecentTrips(scope.repo, scope.settings);
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
    if (_selected.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(_selected.clear)),
          title: Text('${_selected.length} selected'),
          actions: [
            TextButton.icon(
              onPressed: _selected.length < 2 ? null : () => _merge(_selected.toList()),
              icon: const Icon(Icons.merge),
              label: const Text('Merge'),
            ),
          ],
        ),
        body: _list(scope),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          const VehicleChip(allowAll: true),
          IconButton(
            tooltip: 'Routes you drive often',
            icon: const Icon(Icons.route_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RoutesPage())),
          ),
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
      body: _list(scope),
    );
  }

  static TripStats? _statsOf(Trip t) => t.statsJson == null ? null : TripStats.fromJson(jsonDecode(t.statsJson!) as Map<String, Object?>);

  TripRow _row(Trip t) {
    final s = _statsOf(t);
    final odoKm = t.startOdometerKm != null && t.endOdometerKm != null ? t.endOdometerKm! - t.startOdometerKm! : null;
    final e = _ends[t.id];
    return TripRow(
      id: t.id,
      start: t.startAt,
      end: t.endAt,
      km: s?.distanceKm ?? t.gpsDistanceKm ?? odoKm,
      duration: s?.total ?? (t.endAt?.difference(t.startAt)),
      avgKmh: s?.movingAvgKmh,
      from: e?.from,
      to: e?.to,
    );
  }

  Widget _list(AppScope scope) {
    final vid = scope.settings.activeVehicleId!;
    return StreamBuilder<List<Vehicle>>(
      stream: scope.repo.watchVehicles(),
      builder: (context, vsnap) {
        final vehicles = {for (final v in vsnap.data ?? const <Vehicle>[]) v.id: v};
        return StreamBuilder<List<Trip>>(
          // Keyed so switching between one and all vehicles starts a new stream.
          key: ValueKey(_allVehicles),
          stream: scope.repo.watchTrips(_allVehicles ? null : vid),
          builder: (context, snap) {
            final trips = (snap.data ?? const <Trip>[]).where((t) => t.status != 'recording' || t.id == _currentId).toList();
            final done = trips.where((t) => t.status == 'done').toList();
            // Merging only makes sense within one vehicle: suggest it for this one.
            final ownDone = done.where((t) => t.vehicleId == vid).toList();
            final byId = {for (final t in trips) t.id: t};
            final rows = filterTrips(
              [
                for (final t in trips)
                  if (t.id != _currentId) _row(t),
              ],
              sort: _sort,
              period: _period,
              size: _size,
              now: DateTime.now(),
            );
            final suggestions = _suggestions(scope, ownDone);
            _loadEnds(scope, trips);
            final places = scope.settings.places;
            if (_placeId != null && places.every((p) => p.id != _placeId)) _placeId = null;
            if (_placeId != null) {
              rows.removeWhere((r) {
                final e = _allEnds[r.id];
                return e == null || (placeAt(e.from, places)?.id != _placeId && placeAt(e.to, places)?.id != _placeId);
              });
            }
            final newPlace = _placeSuggestion(scope, places);
            final filtered = _period != TripPeriod.all || _size != TripSize.any || _placeId != null;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (_selected.isEmpty) ...[
                  if (!TripRecorder.supported)
                    const Card(
                      child: Padding(padding: EdgeInsets.all(16), child: Text('Trip recording works on the Android app.')),
                    )
                  else if (_currentId != null)
                    _liveCard(context)
                  else
                    _startCard(context),
                  const SizedBox(height: 16),
                  if (done.isNotEmpty) _yearSummary(context, done, all: _allVehicles),
                  for (final (a, b) in suggestions)
                    if (byId[a] != null && byId[b] != null) _suggestionCard(context, scope, byId[a]!, byId[b]!),
                  if (newPlace != null) _placeCard(context, scope, newPlace),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Tap trips to select them. Merging joins them into one trip, with the time between them as a stop.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                if (trips.isNotEmpty) _filterBar(context, places),
                if (trips.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No trips yet. Start one above, or set up auto-start so trips record themselves when the phone connects to the car.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No trips match these filters.', textAlign: TextAlign.center),
                  )
                else if (filtered)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${rows.length} trip${rows.length == 1 ? '' : 's'} · ${fmtKm(rows.fold(0.0, (a, r) => a + (r.km ?? 0)))} km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                for (final r in rows) _tripTile(context, byId[r.id]!, vehicle: _allVehicles ? vehicles[byId[r.id]!.vehicleId] : null),
              ],
            );
          },
        );
      },
    );
  }

  /// Loads trip ends again when the set of trips changes.
  void _loadEnds(AppScope scope, List<Trip> trips) {
    final key = '$_allVehicles:${trips.length}:${trips.where((t) => t.status == 'done').map((t) => t.id).join(',').hashCode}';
    if (key == _endsKey) return;
    _endsKey = key;
    scope.repo.allTripEnds(_allVehicles ? null : scope.settings.activeVehicleId!).then((e) {
      if (mounted) setState(() => _allEnds = e);
    });
  }

  /// "Home → Work" for trips that still have their automatic name.
  String _title(Trip t, List<Place> places) {
    final e = _allEnds[t.id];
    if (e == null || t.name != TripRecorder.defaultName(t.startAt)) return t.name;
    return placeTitle(placeAt(e.from, places), placeAt(e.to, places)) ?? t.name;
  }

  ({LatLon at, int count})? _placeSuggestion(AppScope scope, List<Place> places) {
    if (_allEnds.isEmpty) return null;
    final dismissed = scope.settings.dismissedPlaces.toSet();
    return suggestPlaces([
      for (final e in _allEnds.values) ...[e.from, e.to],
    ], places).where((s) => !dismissed.contains(_placeKey(s.at))).firstOrNull;
  }

  static String _placeKey(LatLon p) => '${p.lat.toStringAsFixed(3)},${p.lon.toStringAsFixed(3)}';

  Widget _placeCard(BuildContext context, AppScope scope, ({LatLon at, int count}) s) {
    final t = Theme.of(context).textTheme;
    final taken = scope.settings.places.map((p) => p.name).toSet();
    Future<void> name(String? n) async {
      n ??= await askPlaceName(context);
      if (n == null || n.trim().isEmpty) return;
      await scope.settings.setPlaces([...scope.settings.places, Place(newId(), n.trim(), s.at.lat, s.at.lon)]);
      setState(() {});
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 140, child: TripMap(route: [LatLng(s.at.lat, s.at.lon)], follow: true)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name this place?', style: t.titleSmall),
                Text('${s.count} trips start or end here. Named places give trips titles like "Home → Work", and stay on this phone.', style: t.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final n in ['Home', 'Work'])
                      if (!taken.contains(n)) ActionChip(label: Text(n), onPressed: () => name(n)),
                    ActionChip(label: const Text('Other name…'), onPressed: () => name(null)),
                    TextButton(
                      onPressed: () async {
                        await scope.settings.dismissPlace(_placeKey(s.at));
                        setState(() {});
                      },
                      child: const Text('Not now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar(BuildContext context, List<Place> places) {
    Widget menu<T>(IconData icon, T value, List<T> values, String Function(T) label, void Function(T) set, {bool highlight = false}) => PopupMenuButton<T>(
      initialValue: value,
      onSelected: (v) => setState(() => set(v)),
      itemBuilder: (_) => [for (final v in values) PopupMenuItem(value: v, child: Text(label(v)))],
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label(value)),
        backgroundColor: highlight ? Theme.of(context).colorScheme.secondaryContainer : null,
      ),
    );
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        menu(Icons.sort, _sort, TripSort.values, tripSortLabel, (v) => _sort = v),
        menu(Icons.date_range, _period, TripPeriod.values, tripPeriodLabel, (v) => _period = v, highlight: _period != TripPeriod.all),
        menu(Icons.straighten, _size, TripSize.values, tripSizeLabel, (v) => _size = v, highlight: _size != TripSize.any),
        if (places.isNotEmpty)
          menu<String>(
            Icons.place_outlined,
            _placeId ?? '',
            ['', ...places.map((p) => p.id)],
            (id) => id.isEmpty ? 'Any place' : places.firstWhere((p) => p.id == id).name,
            (v) => _placeId = v.isEmpty ? null : v,
            highlight: _placeId != null,
          ),
      ],
    );
  }

  /// Recent trips that look like one journey split in two. Their end points
  /// are loaded the first time they're seen, then checked for distance.
  List<(String, String)> _suggestions(AppScope scope, List<Trip> done) {
    final since = DateTime.now().subtract(const Duration(days: 30));
    final recent = done.where((t) => t.startAt.isAfter(since) && t.statsJson != null).toList();
    final byTime = mergeSuggestions([for (final t in recent) _row(t)]);
    final dismissed = scope.settings.dismissedMerges.toSet();
    final missing = {
      for (final (a, b) in byTime) ...[a, b],
    }.where((id) => !_ends.containsKey(id)).toList();
    if (missing.isNotEmpty) {
      for (final id in missing) {
        _ends[id] = null;
      }
      Future.wait(missing.map((id) async => _ends[id] = await scope.repo.tripEnds(id))).then((_) {
        if (mounted) setState(() {});
      });
      return const [];
    }
    return mergeSuggestions([
      for (final t in recent) _row(t),
    ]).where((p) => _ends[p.$1] != null && _ends[p.$2] != null && !dismissed.contains('${p.$1}+${p.$2}')).take(3).toList();
  }

  Widget _suggestionCard(BuildContext context, AppScope scope, Trip a, Trip b) {
    final gap = a.endAt == null ? null : b.startAt.difference(a.endAt!);
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('One journey in two parts?', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('"${a.name}" and "${b.name}"${gap == null ? '' : ' are ${fmtDuration(gap)} apart'}, and the second starts where the first ended.'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    await scope.settings.dismissMerge('${a.id}+${b.id}');
                    setState(() {});
                  },
                  child: const Text('Keep separate'),
                ),
                FilledButton.tonal(onPressed: () => _merge([a.id, b.id]), child: const Text('Merge')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _merge(List<String> ids) async {
    final scope = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Merge ${ids.length} trips?'),
        content: const Text('They become one trip named after the first. The time between them shows as a stop. This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Merge')),
        ],
      ),
    );
    if (ok != true) return;
    final trips = [for (final id in ids) await scope.repo.trip(id)];
    if (trips.any((t) => t == null || t.status != 'done')) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only recorded trips can be merged')));
      return;
    }
    if (trips.map((t) => t!.vehicleId).toSet().length > 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('These trips are in different vehicles. Move them to one vehicle first.')));
      }
      return;
    }
    await scope.repo.mergeTrips(ids);
    lookUpRecentTrips(scope.repo, scope.settings);
    if (mounted) setState(_selected.clear);
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
          label: StreamBuilder<List<Vehicle>>(
            stream: AppScope.of(context).repo.watchVehicles(),
            builder: (context, snap) {
              final live = [
                for (final v in snap.data ?? const <Vehicle>[])
                  if (v.archivedAt == null) v,
              ];
              final v = live.where((x) => x.id == AppScope.of(context).settings.activeVehicleId).firstOrNull;
              return Text(
                v == null || live.length < 2 ? 'Start trip' : 'Start trip in ${v.name}',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
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
    final route = [
      for (final s in _live)
        if ((s.accuracyM ?? 0) <= maxAccuracyM) LatLng(s.lat, s.lon),
    ];
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
                Row(
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.red.shade600, size: 14),
                    const SizedBox(width: 6),
                    Text('Recording', style: t.labelLarge),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_figure(t, '${fmtKm1(km)} km', 'distance'), _figure(t, fmtDuration(elapsed), 'elapsed'), _figure(t, fmtKmh(speed), 'now')],
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(onPressed: _busy ? null : _stop, icon: const Icon(Icons.stop), label: const Text('Stop trip')),
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
    children: [
      Text(value, style: t.titleLarge),
      Text(label, style: t.bodySmall),
    ],
  );

  Widget _yearSummary(BuildContext context, List<Trip> done, {bool all = false}) {
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
            Text('Recorded in $year${all ? ', all vehicles' : ''}', style: t.labelLarge),
            const SizedBox(height: 4),
            Text('$n trips · ${fmtKm(km)} km · ${fmtDuration(moving)} moving', style: t.titleMedium),
            const SizedBox(height: 12),
            BandBar(bandKm: bands),
          ],
        ),
      ),
    );
  }

  Widget _tripTile(BuildContext context, Trip trip, {Vehicle? vehicle}) {
    final s = trip.statsJson == null ? null : TripStats.fromJson(jsonDecode(trip.statsJson!) as Map<String, Object?>);
    final odoKm = trip.startOdometerKm != null && trip.endOdometerKm != null ? trip.endOdometerKm! - trip.startOdometerKm! : null;
    final km = s?.distanceKm ?? trip.gpsDistanceKm ?? odoKm;
    final road = RoadLookup.stored(trip.statsJson);
    final parts = <String>[
      ?vehicle?.name,
      fmtDate(trip.startAt),
      if (km != null) '${fmtKm1(km)} km',
      if (s != null) fmtDuration(s.total),
      if (s?.movingAvgKmh != null) 'avg ${fmtKmh(s!.movingAvgKmh)}',
      if (road != null && road.lightsPassed > 0) '${road.stoppedAtLights} of ${road.lightsPassed} lights red',
      if (trip.status == 'report') 'odometer only',
    ];
    final selecting = _selected.isNotEmpty;
    final selected = _selected.contains(trip.id);
    void toggle() => setState(() => selected ? _selected.remove(trip.id) : _selected.add(trip.id));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      selected: selected,
      leading: CircleAvatar(
        child: Icon(
          selected
              ? Icons.check
              : trip.status == 'report'
              ? Icons.description_outlined
              : (trip.startedBy == 'bluetooth' ? Icons.bluetooth : Icons.route),
        ),
      ),
      title: Text(_title(trip, AppScope.of(context).settings.places)),
      subtitle: Text(parts.join(' · ')),
      trailing: selecting ? null : const Icon(Icons.chevron_right),
      onLongPress: trip.status == 'done' ? toggle : null,
      onTap: selecting
          ? (trip.status == 'done' ? toggle : null)
          : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripDetailPage(tripId: trip.id))),
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
            child: Row(
              children: [
                for (final b in SpeedBand.values)
                  if ((shares[b] ?? 0) > 0)
                    Expanded(
                      flex: ((shares[b] ?? 0) * 1000).round().clamp(1, 1000),
                      child: Container(color: colorFor(b, cs)),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            for (final b in SpeedBand.values)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: colorFor(b, cs), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 4),
                  Text('${bandLabel(b)} ${((shares[b] ?? 0) * 100).round()}% · ${fmtKm(bandKm[b] ?? 0)} km', style: t.bodySmall),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
