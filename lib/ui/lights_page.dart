/// Every traffic light you've driven through, across all trips: which ones
/// catch you red most often and cost you the most time.
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../domain/driving_stats.dart';
import '../domain/places.dart';
import '../domain/trip_stats.dart' show haversineKm;
import 'format.dart';
import 'route_compare_page.dart' show fmtMinSec;
import 'trip_format.dart';

enum LightSort { timeLost, oftenRed, phases, passes }

String lightSortLabel(LightSort s) => switch (s) {
      LightSort.timeLost => 'Most time lost',
      LightSort.oftenRed => 'Most often red',
      LightSort.phases => 'Most missed greens',
      LightSort.passes => 'Most driven',
    };

/// Lights in order for [s]. "Often red" needs three passes so one unlucky
/// stop doesn't top the list.
List<LightSpot> sortLights(List<LightSpot> spots, LightSort s) {
  final out = switch (s) {
    LightSort.oftenRed => spots.where((x) => x.passes >= 3 && x.stops > 0).toList(),
    LightSort.timeLost => spots.where((x) => x.totalWaitS > 0).toList(),
    LightSort.phases => spots.where((x) => x.multi > 0).toList(),
    LightSort.passes => [...spots],
  };
  int by(LightSpot a, LightSpot b) => switch (s) {
        LightSort.timeLost => b.totalWaitS.compareTo(a.totalWaitS),
        LightSort.oftenRed => b.stopRate.compareTo(a.stopRate) != 0 ? b.stopRate.compareTo(a.stopRate) : b.passes.compareTo(a.passes),
        LightSort.phases => b.multi.compareTo(a.multi) != 0 ? b.multi.compareTo(a.multi) : b.phases.compareTo(a.phases),
        LightSort.passes => b.passes.compareTo(a.passes),
      };
  return out..sort(by);
}

/// "Near Home" (or "1.2 km from Work") from your named places.
String? nearPlace(double lat, double lon, List<Place> places) {
  Place? best;
  var bestKm = double.infinity;
  for (final p in places) {
    final d = haversineKm(lat, lon, p.lat, p.lon);
    if (d < bestKm) {
      bestKm = d;
      best = p;
    }
  }
  if (best == null || bestKm > 5) return null;
  return bestKm < 0.4 ? 'Near ${best.name}' : '${bestKm.toStringAsFixed(1)} km from ${best.name}';
}

class LightsPage extends StatefulWidget {
  final String? vehicleId; // null = every vehicle
  const LightsPage({super.key, this.vehicleId});
  @override
  State<LightsPage> createState() => _LightsPageState();
}

class _LightsPageState extends State<LightsPage> {
  List<LightSpot>? _spots;
  LightSort _sort = LightSort.timeLost;
  LightSpot? _picked;
  final _map = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = AppScope.of(context).repo;
    final trips = widget.vehicleId == null ? (await repo.watchTrips(null).first).where((t) => t.status == 'done') : await repo.doneTrips(widget.vehicleId!);
    final facts = [for (final t in trips) ?TripFacts.fromJson(t.startAt, t.statsJson)];
    if (mounted) setState(() => _spots = lightHistory(facts));
  }

  @override
  Widget build(BuildContext context) {
    final spots = _spots;
    final t = Theme.of(context).textTheme;
    final places = AppScope.of(context).settings.places;
    return Scaffold(
      appBar: AppBar(title: const Text('Your traffic lights')),
      body: spots == null
          ? const Center(child: CircularProgressIndicator())
          : spots.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No traffic lights yet. They appear once trips have had their map lookup.', textAlign: TextAlign.center),
                  ),
                )
              : Builder(builder: (context) {
                  final list = sortLights(spots, _sort);
                  final passes = spots.fold(0, (a, s) => a + s.passes);
                  final stops = spots.fold(0, (a, s) => a + s.stops);
                  final waitS = spots.fold(0, (a, s) => a + s.totalWaitS);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Text(
                        '${spots.length} lights, passed $passes times. Caught red $stops times '
                        '(${(stops / passes * 100).round()}%), ${fmtDuration(Duration(seconds: waitS))} waiting in all.',
                        style: t.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(height: 260, child: _mapOf(spots)),
                      ),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 4, children: [
                        for (final s in LightSort.values)
                          ChoiceChip(label: Text(lightSortLabel(s)), selected: _sort == s, onSelected: (_) => setState(() => _sort = s)),
                      ]),
                      const SizedBox(height: 8),
                      if (list.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _sort == LightSort.phases
                                ? 'No light has kept you for more than one red phase yet.'
                                : 'Not enough passes yet: a light needs three before it ranks here.',
                            style: t.bodySmall,
                          ),
                        ),
                      for (final (i, s) in list.take(40).indexed) _tile(context, i + 1, s, places),
                      const SizedBox(height: 8),
                      Text(
                        'Red phases are estimated from how the car crept forward in the queue: a stop of 15 s or more after moving up counts as another red. '
                        'Lights within 45 m are treated as one intersection.',
                        style: t.bodySmall,
                      ),
                    ],
                  );
                }),
    );
  }

  Widget _tile(BuildContext context, int rank, LightSpot s, List<Place> places) {
    final name = nearPlace(s.lat, s.lon, places) ?? '${s.lat.toStringAsFixed(4)}, ${s.lon.toStringAsFixed(4)}';
    final parts = [
      'Red ${s.stops} of ${s.passes} times',
      if (s.medianWaitS != null) 'usual wait ${fmtMinSec(Duration(seconds: s.medianWaitS!))}',
      if (s.totalWaitS > 0) '${fmtDuration(Duration(seconds: s.totalWaitS))} in all',
      if (s.multi > 0) 'more than one red ${s.multi} time${s.multi == 1 ? '' : 's'}',
      'last ${fmtDate(s.last)}',
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      selected: identical(_picked, s),
      leading: CircleAvatar(
        backgroundColor: Color.lerp(Colors.green.shade600, Colors.red.shade600, s.stopRate),
        foregroundColor: Colors.white,
        child: Text('$rank'),
      ),
      title: Text(name),
      subtitle: Text(parts.join(' · ')),
      onTap: () {
        setState(() => _picked = s);
        _map.move(LatLng(s.lat, s.lon), 17);
      },
    );
  }

  Widget _mapOf(List<LightSpot> spots) {
    final pts = [for (final s in spots) LatLng(s.lat, s.lon)];
    final options = pts.toSet().length > 1
        ? MapOptions(initialCameraFit: CameraFit.bounds(bounds: LatLngBounds.fromPoints(pts), padding: const EdgeInsets.all(24)))
        : MapOptions(initialCenter: pts.first, initialZoom: 16);
    return FlutterMap(
      mapController: _map,
      options: options,
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'nz.mileagelog.app'),
        MarkerLayer(markers: [
          for (final s in spots)
            Marker(
              point: LatLng(s.lat, s.lon),
              width: identical(_picked, s) ? 24 : 16,
              height: identical(_picked, s) ? 24 : 16,
              child: GestureDetector(
                onTap: () => setState(() {
                  _picked = s;
                  _sort = LightSort.passes;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(Colors.green.shade600, Colors.red.shade600, s.stopRate),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 2),
                  ),
                ),
              ),
            ),
        ]),
        const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
      ],
    );
  }
}
