import '../data/repository.dart';
import '../settings.dart';
import 'road_lookup.dart';
import 'weather_lookup.dart';

/// Background lookups for recent trips, one after the other so they don't
/// overwrite each other's results: roads and traffic lights, then weather
/// and elevation. Each has its own switch in the trip settings.
Future<void> lookUpRecentTrips(Repository repo, Settings settings) async {
  final vid = settings.activeVehicleId;
  if (vid == null) return;
  try {
    // Older trips, once each, offline. A newer way of counting recounts all.
    const version = 2;
    final all = settings.lightCountVersion < version;
    await RoadLookup.countLightCycles(repo, force: all);
    if (all) await settings.setLightCountVersion(version);
  } catch (_) {}
  if (settings.roadLookup) await RoadLookup.analyseRecent(repo, vid);
  if (settings.weatherLookup) await WeatherLookup.analyseRecent(repo, vid);
}
