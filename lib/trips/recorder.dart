import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../domain/trip_stats.dart';
import '../settings.dart';

/// Talks to the native Android recorder (TripRecorderService) and turns its
/// finished recordings into database rows.
class TripRecorder {
  static const _ch = MethodChannel('mileagelog/trips');

  static bool get supported => Platform.isAndroid;

  static Future<String?> currentTripId() async => supported ? await _ch.invokeMethod<String>('currentTrip') : null;
  static Future<String> tripsDir() async => (await _ch.invokeMethod<String>('tripsDir'))!;
  static Future<void> start(String tripId) => _ch.invokeMethod('startTrip', {'tripId': tripId});
  static Future<void> stop() => _ch.invokeMethod('stopTrip');
  static Future<bool> consumeStartRequest() async =>
      supported && (await _ch.invokeMethod<bool>('consumeStartRequest') ?? false);

  static Future<bool> hasPermission(String name) async =>
      !supported || (await _ch.invokeMethod<bool>('hasPermission', {'name': name}) ?? false);
  static Future<bool> requestPermission(String name) async =>
      !supported || (await _ch.invokeMethod<bool>('requestPermission', {'name': name}) ?? false);
  static Future<bool> batteryUnrestricted() async =>
      !supported || (await _ch.invokeMethod<bool>('batteryUnrestricted') ?? false);
  static Future<void> requestBatteryUnrestricted() => _ch.invokeMethod('requestBatteryUnrestricted');
  static Future<void> openAppSettings() => _ch.invokeMethod('openAppSettings');

  static Future<List<({String name, String address})>> bondedDevices() async {
    final list = await _ch.invokeListMethod<Map>('bondedDevices') ?? const [];
    return [for (final m in list) (name: m['name'] as String, address: m['address'] as String)]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  static Future<({String? address, String? name, bool autoStart})> car() async {
    if (!supported) return (address: null, name: null, autoStart: false);
    final m = await _ch.invokeMapMethod<String, Object?>('getCar') ?? const {};
    return (address: m['address'] as String?, name: m['name'] as String?, autoStart: m['autoStart'] == true);
  }

  static Future<void> setCar(String? address, String? name) => _ch.invokeMethod('setCar', {'address': address, 'name': name});
  static Future<void> setAutoStart(bool enabled) => _ch.invokeMethod('setAutoStart', {'enabled': enabled});

  /// Tells the recorder which Bluetooth devices start trips: one per vehicle.
  /// The single car chosen in older versions is moved onto the current
  /// vehicle the first time.
  static Future<void> syncCars(Settings settings) async {
    if (!supported) return;
    final old = await car();
    if (old.address != null) {
      final vid = settings.activeVehicleId;
      if (settings.vehicleForCar(old.address) == null && vid != null && !settings.vehicleCars.containsKey(vid)) {
        await settings.setVehicleCar(vid, (address: old.address!, name: old.name ?? 'Car'));
      }
      await setCar(null, null);
    }
    await _ch.invokeMethod('setCars', {
      'addresses': [for (final c in settings.vehicleCars.values) c.address],
      'vehicles': {for (final e in settings.vehicleCars.entries) e.value.address: e.key},
    });
  }

  /// The recorder notes the selected vehicle on every trip as it starts, so
  /// a trip started from the widget or notification goes to the right car.
  static Future<void> setActiveVehicle(String? id, String? name) async {
    if (!supported) return;
    await _ch.invokeMethod('setActiveVehicle', {'id': id, 'name': name});
  }

  /// Starts a manual trip after making sure the essentials are granted.
  /// Returns an error message, or null when recording started.
  static Future<String?> startManual() async {
    if (!await requestPermission('location')) return 'Location permission is needed to record a trip';
    await requestPermission('notifications'); // optional, but the Stop button lives there
    try {
      await start(newId());
      return null;
    } on PlatformException catch (e) {
      return 'Could not start recording: ${e.message}';
    }
  }

  /// Samples recorded so far for a trip that is still in progress.
  static Future<List<GpsSample>> liveSamples(String tripId) async {
    final f = File('${await tripsDir()}/$tripId.csv');
    if (!await f.exists()) return const [];
    return GpsSample.parseAll(await f.readAsString());
  }

  static String defaultName(DateTime start) => 'Trip ${DateFormat('EEE d MMM, HH:mm').format(start)}';

  /// Brings recordings on disk into the database. Finished ones are saved
  /// with their points, stops and stats and their files removed; the one in
  /// progress gets (or keeps) a 'recording' row so it shows in the list.
  /// Returns the number of trips finished by this call.
  /// A trip started by a vehicle's Bluetooth goes to that vehicle; while one
  /// is recording, the app switches to that vehicle.
  static Future<int> ingest(Repository repo, String vehicleId, {Settings? settings}) async {
    if (!supported) return 0;
    final dir = Directory(await tripsDir());
    if (!await dir.exists()) return 0;
    final current = await currentTripId();
    var finished = 0;
    await for (final f in dir.list()) {
      if (f is! File || !f.path.endsWith('.meta.json')) continue;
      final meta = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      final id = meta['id'] as String;
      final csv = File(f.path.replaceFirst('.meta.json', '.csv'));
      final samples = await csv.exists() ? GpsSample.parseAll(await csv.readAsString()) : <GpsSample>[];
      final startAt = DateTime.fromMillisecondsSinceEpoch((meta['startAt'] as num).toInt());
      final startedBy = meta['startedBy'] as String? ?? 'manual';
      final existing = await repo.trip(id);
      final ended = meta['endAt'] != null || id != current;
      final carVehicle = settings?.vehicleForCar(meta['carAddress'] as String?);
      // Recorded at the start (since v0.18); only trusted if it still exists.
      final metaVehicle = meta['vehicleId'] is String && await repo.vehicle(meta['vehicleId'] as String) != null ? meta['vehicleId'] as String : null;
      final tripVehicle = chooseTripVehicle(saved: existing?.vehicleId, atStart: metaVehicle, byCar: carVehicle, selected: vehicleId);

      if (!ended) {
        if (carVehicle != null && carVehicle == tripVehicle && carVehicle != settings!.activeVehicleId) await settings.setActiveVehicleId(carVehicle);
        if (existing == null) {
          await repo.upsertTrip(TripsCompanion.insert(
            id: id,
            vehicleId: tripVehicle,
            name: defaultName(startAt),
            startAt: startAt,
            status: const Value('recording'),
            startedBy: Value(startedBy),
          ));
        }
        continue;
      }

      final endAt = meta['endAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((meta['endAt'] as num).toInt())
          : (samples.isNotEmpty ? samples.last.at : startAt);
      final stats = computeTripStats(samples);
      // A Bluetooth connection without real driving (e.g. sitting in the
      // car on the phone) shouldn't leave an empty trip behind.
      final tooSmall = samples.length < 2 || (startedBy == 'bluetooth' && stats.distanceKm < 0.2);
      if (tooSmall) {
        if (existing != null) await repo.deleteTrip(id);
      } else {
        await repo.saveRecordedTrip(
          TripsCompanion.insert(
            id: id,
            vehicleId: tripVehicle,
            name: existing?.name ?? defaultName(startAt),
            startAt: startAt,
            endAt: Value(endAt),
            gpsDistanceKm: Value(stats.distanceKm),
            status: const Value('done'),
            notes: Value(existing?.notes),
            startedBy: Value(startedBy),
            statsJson: Value(jsonEncode({...stats.toJson(), ...?batteryJson(meta)})),
          ),
          [
            for (final s in samples)
              TripPointsCompanion.insert(
                tripId: id,
                at: s.at,
                lat: s.lat,
                lon: s.lon,
                speedMps: Value(s.speedMps),
                accuracyM: Value(s.accuracyM),
                altitudeM: Value(s.altitudeM),
              ),
          ],
          [
            for (final st in stats.stops)
              TripStopsCompanion.insert(
                id: newId(),
                tripId: id,
                arriveAt: st.arrive,
                departAt: Value(st.depart),
                lat: Value(st.lat),
                lon: Value(st.lon),
              ),
          ],
        );
        finished++;
      }
      await f.delete();
      if (await csv.exists()) await csv.delete();
    }
    return finished;
  }
}

/// Which vehicle a recorded trip belongs to: as already saved (it may have
/// been moved), else the vehicle noted when recording started, else the one
/// whose Bluetooth started it, else the one selected now.
String chooseTripVehicle({String? saved, String? atStart, String? byCar, required String selected}) => saved ?? atStart ?? byCar ?? selected;

/// Battery readings the recorder saved in a trip's meta file, for the
/// trip's stats: {'battery': {'start': 82, 'end': 77, 'charging': false}}.
Map<String, Object?>? batteryJson(Map<String, dynamic> meta) {
  final start = (meta['batteryStart'] as num?)?.toInt();
  final end = (meta['batteryEnd'] as num?)?.toInt();
  if (start == null || end == null) return null;
  return {
    'battery': {'start': start, 'end': end, 'charging': meta['charging'] == true},
  };
}
