import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/carjam.dart';

/// Looks up a plate with CarJam's ABCD API using the user's own API key.
/// Each lookup is charged to that key's CarJam account (repeat lookups of
/// the same plate within an hour are free).
class CarJamClient {
  static const base = 'https://www.carjam.co.nz/a/vehicle:abcd';

  static Uri pageFor(String plate) => Uri.parse('https://www.carjam.co.nz/car/?plate=${Uri.encodeQueryComponent(normalisePlate(plate))}');

  /// Throws a [CarJamException] with a message fit to show.
  static Future<CarDetails> lookup(String plate, String key, {http.Client? client, Duration Function(int s)? wait}) async {
    final c = client ?? http.Client();
    final p = normalisePlate(plate);
    if (p.isEmpty) throw const CarJamException('Enter the plate first');
    try {
      final uri = Uri.parse(base).replace(queryParameters: {'key': key.trim(), 'plate': p});
      for (var attempt = 0; attempt < 4; attempt++) {
        final r = await c.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 30));
        if (r.statusCode == 401 || r.statusCode == 403) throw const CarJamException('CarJam didn\'t accept the API key');
        if (r.statusCode != 200) throw CarJamException('CarJam lookup failed (${r.statusCode})');
        final body = r.body.trim();
        // CarJam answers null while it's still fetching, with a Refresh header in seconds.
        if (body == 'null' || body.isEmpty) {
          final secs = (int.tryParse(r.headers['refresh'] ?? '') ?? 3).clamp(1, 10);
          await Future<void>.delayed(wait?.call(secs) ?? Duration(seconds: secs));
          continue;
        }
        final Object? j;
        try {
          j = jsonDecode(body);
        } catch (_) {
          throw const CarJamException('CarJam sent something unexpected');
        }
        if (j is Map && (j['error'] != null || j['message'] != null) && j['make'] == null) {
          throw CarJamException('CarJam: ${j['error'] ?? j['message']}');
        }
        if (j is! Map) throw const CarJamException('CarJam sent something unexpected');
        final d = CarDetails.fromJson(j.cast<String, Object?>());
        if (d.isEmpty) throw CarJamException('CarJam has no details for $p');
        return d;
      }
      throw const CarJamException('CarJam is still fetching the details. Try again in a minute.');
    } on CarJamException {
      rethrow;
    } catch (_) {
      throw const CarJamException('Couldn\'t reach CarJam. Check the connection.');
    } finally {
      if (client == null) c.close();
    }
  }
}

class CarJamException implements Exception {
  final String message;
  const CarJamException(this.message);
  @override
  String toString() => message;
}
