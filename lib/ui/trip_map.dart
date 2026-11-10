import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../domain/trip_profile.dart';

/// OpenStreetMap view of a route with optional stop markers. Map tiles are
/// fetched from openstreetmap.org; the route itself is only sent out for the
/// optional road lookup (see lib/trips/road_lookup.dart).
class TripMap extends StatelessWidget {
  final List<LatLng> route;
  final List<LatLng> stops;
  /// Traffic lights passed: green where the car went straight through,
  /// red where it stopped.
  final List<({LatLng at, bool stopped, int phases})> lights;
  final bool follow; // live view: centre on the latest point
  /// Speed at each route point (km/h). When given, the line is coloured by
  /// speed and a legend is shown.
  final List<double?>? speedsKmh;
  const TripMap({super.key, required this.route, this.stops = const [], this.lights = const [], this.follow = false, this.speedsKmh});

  /// Slow to fast: red, orange, amber, light green, green.
  static const speedColours = [Color(0xffd32f2f), Color(0xfff57c00), Color(0xfffbc02d), Color(0xff7cb342), Color(0xff2e7d32)];

  /// Splits the route into runs of the same speed colour.
  static List<Polyline> speedLines(List<LatLng> route, List<double?> kmh) {
    final out = <Polyline>[];
    if (route.length < 2 || kmh.length != route.length) return out;
    var band = speedBand(kmh[0]);
    var run = <LatLng>[route[0]];
    for (var i = 1; i < route.length; i++) {
      final b = speedBand(kmh[i]);
      run.add(route[i]);
      if (b != band || i == route.length - 1) {
        out.add(Polyline(points: run, strokeWidth: 5, color: speedColours[band]));
        run = [route[i]];
        band = b;
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (route.isEmpty) {
      return Container(
        color: cs.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Text('Waiting for GPS…'),
      );
    }
    final distinct = route.toSet().length > 1;
    final options = (!follow && distinct)
        ? MapOptions(
            initialCameraFit: CameraFit.bounds(bounds: LatLngBounds.fromPoints(route), padding: const EdgeInsets.all(28)),
          )
        : MapOptions(initialCenter: route.last, initialZoom: 15);
    return FlutterMap(
      key: follow ? ValueKey(route.length ~/ 15) : null, // re-centre every ~15 points while live
      options: options,
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'nz.mileagelog.app',
        ),
        PolylineLayer(
          polylines: speedsKmh != null && speedsKmh!.length == route.length
              ? speedLines(route, speedsKmh!)
              : [Polyline(points: route, strokeWidth: 4.5, color: cs.primary)],
        ),
        MarkerLayer(markers: [
          Marker(point: route.first, width: 18, height: 18, child: _dot(Colors.green.shade700)),
          for (final l in lights) Marker(point: l.at, width: l.phases >= 2 ? 20 : 14, height: l.phases >= 2 ? 20 : 14, child: _light(l.stopped, l.phases)),
          for (final s in stops) Marker(point: s, width: 24, height: 24, child: _stopPin(cs)),
          Marker(point: route.last, width: 18, height: 18, child: _dot(follow ? cs.primary : Colors.red.shade700)),
        ]),
        if (speedsKmh != null)
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.88), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('km/h ', style: TextStyle(fontSize: 11, color: Colors.black87)),
                for (var i = 0; i < speedColours.length; i++) ...[
                  Container(width: 10, height: 10, color: speedColours[i]),
                  Text(' ${speedBandLabel(i)}  ', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                ],
              ]),
            ),
          ),
        const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
      ],
    );
  }

  Widget _dot(Color c) => Container(
        decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
      );

  /// Green: straight through. Red: stopped; the number is red phases
  /// waited when more than one.
  Widget _light(bool stopped, int phases) => Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: stopped ? Colors.red.shade600 : Colors.green.shade600,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black87, width: 2),
        ),
        child: phases >= 2 ? Text('$phases', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold, height: 1)) : null,
      );

  Widget _stopPin(ColorScheme cs) => Container(
        decoration: BoxDecoration(color: cs.tertiary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        child: Icon(Icons.local_parking, size: 14, color: cs.onTertiary),
      );
}
