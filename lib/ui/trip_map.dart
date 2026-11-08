import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// OpenStreetMap view of a route with optional stop markers. Map tiles are
/// fetched from openstreetmap.org; the route itself never leaves the phone.
class TripMap extends StatelessWidget {
  final List<LatLng> route;
  final List<LatLng> stops;
  final bool follow; // live view: centre on the latest point
  const TripMap({super.key, required this.route, this.stops = const [], this.follow = false});

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
        PolylineLayer(polylines: [
          Polyline(points: route, strokeWidth: 4.5, color: cs.primary),
        ]),
        MarkerLayer(markers: [
          Marker(point: route.first, width: 18, height: 18, child: _dot(Colors.green.shade700)),
          for (final s in stops) Marker(point: s, width: 24, height: 24, child: _stopPin(cs)),
          Marker(point: route.last, width: 18, height: 18, child: _dot(follow ? cs.primary : Colors.red.shade700)),
        ]),
        const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
      ],
    );
  }

  Widget _dot(Color c) => Container(
        decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
      );

  Widget _stopPin(ColorScheme cs) => Container(
        decoration: BoxDecoration(color: cs.tertiary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        child: Icon(Icons.local_parking, size: 14, color: cs.onTertiary),
      );
}
