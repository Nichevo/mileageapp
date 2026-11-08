import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../domain/prices.dart';

/// Downloads MBIE's weekly fuel price monitoring table (national average
/// pump prices, updated weekly) and keeps a copy on the phone. Nothing about
/// you is sent; it's a plain download of a public file.
class NationalPriceSource {
  static const url = 'https://www.mbie.govt.nz/assets/Data-Files/Energy/Weekly-fuel-price-monitoring/weekly-table.csv';
  static const sourceName = 'MBIE weekly fuel price monitoring';
  static const maxAge = Duration(days: 3);

  static NationalPrices? _memo;
  static DateTime? _memoAt;
  static Future<NationalPrices?>? _inFlight;

  /// When the copy on the phone was downloaded.
  static DateTime? get fetchedAt => _memoAt;

  /// National prices, from memory, the phone's copy or a fresh download.
  /// Returns whatever is available (possibly stale) when offline, or null
  /// when there's nothing yet.
  static Future<NationalPrices?> load({bool refresh = false, http.Client? client}) =>
      _inFlight ??= _load(refresh, client).whenComplete(() => _inFlight = null);

  static Future<NationalPrices?> _load(bool refresh, http.Client? client) async {
    final fresh = _memoAt != null && DateTime.now().difference(_memoAt!) < maxAge;
    if (_memo != null && fresh && !refresh) return _memo;
    File? file;
    try {
      file = File('${(await getApplicationSupportDirectory()).path}/mbie_weekly.csv');
      if (_memo == null && await file.exists()) {
        _memo = await compute(NationalPrices.parseMbie, await file.readAsString());
        _memoAt = await file.lastModified();
        if (!refresh && DateTime.now().difference(_memoAt!) < maxAge) return _memo;
      }
    } catch (_) {
      file = null;
    }
    final c = client ?? http.Client();
    try {
      final r = await c.get(Uri.parse(url), headers: {'User-Agent': 'MileageLog (nz.mileagelog.app)'}).timeout(const Duration(seconds: 30));
      if (r.statusCode == 200) {
        final parsed = await compute(NationalPrices.parseMbie, r.body);
        if (!parsed.isEmpty) {
          _memo = parsed;
          _memoAt = DateTime.now();
          await file?.writeAsString(r.body);
        }
      }
    } catch (_) {
      // Offline or the site is down: keep what we have.
    } finally {
      if (client == null) c.close();
    }
    return _memo;
  }

  @visibleForTesting
  static void setForTest(NationalPrices? p) {
    _memo = p;
    _memoAt = p == null ? null : DateTime.now();
  }
}
