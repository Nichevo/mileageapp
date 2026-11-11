/// One GPS fix on demand, for notes and photos. Quietly null when
/// location is off, refused, or not available (tests, desktop).
library;

import 'package:geolocator/geolocator.dart';

typedef Fix = ({double lat, double lon, double? accuracyM});

Future<Fix?> _defaultFix() async {
  try {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return null;
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
    );
    return (lat: p.latitude, lon: p.longitude, accuracyM: p.accuracy);
  } catch (_) {
    return null;
  }
}

/// Replaced in tests.
Future<Fix?> Function() currentFix = _defaultFix;
