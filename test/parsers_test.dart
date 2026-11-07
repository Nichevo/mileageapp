import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/domain/stats.dart';
import 'package:mileagelog/import/roadtrip_csv.dart';
import 'package:mileagelog/import/sheet_csv.dart';

void main() {
  group('Road Trip CSV', () {
    final text = File('sample_data/roadtrip_export_sample.csv').readAsStringSync();

    test('detects the format', () {
      expect(looksLikeRoadTripCsv(text), isTrue);
      expect(looksLikeRoadTripCsv('Trip (km),Litres'), isFalse);
    });

    test('parses all sections', () {
      final e = parseRoadTripCsv(text);
      expect(e.warnings, isEmpty);
      expect(e.fuel.length, 5);
      expect(e.fuel.first.odometerKm, 48000);
      expect(e.fuel.first.tripKm, isNull);
      expect(e.fuel[1].tripKm, 510.4);
      expect(e.fuel[3].partial, isTrue);
      expect(e.fuel[2].octane, '95');
      expect(e.fuel[2].lat, -36.85);
      expect(e.fuel[4].location, 'Sample Town');
      expect(e.fuel.first.at, DateTime(2025, 6, 2, 15, 59));
      expect(e.maintenance.length, 4);
      expect(e.maintenance.first.description, 'Insurance Payment');
      expect(e.maintenance.first.reminderInterval, '1y');
      expect(e.trips.length, 1);
      expect(e.trips.first.distanceKm, 1890.2);
      expect(e.vehicle?.name, 'Sample Car');
      expect(e.vehicle?.tankCapacity, 45);
      expect(e.tyreSets.single.name, '4x Sample Tyres');
    });

    test('date parsing', () {
      expect(parseRoadTripDate('2015-2-12 15:59'), DateTime(2015, 2, 12, 15, 59));
      expect(parseRoadTripDate('2015-10-8'), DateTime(2015, 10, 8));
      expect(parseRoadTripDate('nope'), isNull);
    });

    test('octane and reminders', () {
      expect(normaliseOctane('Super-Premium'), '98');
      expect(normaliseOctane('Premium'), '95');
      expect(normaliseOctane(null), isNull);
      expect(reminderMonths('1y'), 12);
      expect(reminderMonths('12m'), 12);
      expect(reminderMonths('1w'), isNull);
    });
  });

  group('Sheet CSV', () {
    final text = File('sample_data/sheet_sample.csv').readAsStringSync();

    test('parses rows and mixed dates', () {
      final r = parseSheetCsv(text);
      expect(r.warnings, isEmpty);
      expect(r.fills.length, 6);
      expect(r.fills.first.at, DateTime(2026, 2, 3));
      expect(r.fills[4].at, DateTime(2026, 4, 25)); // 25/Apr/2026
      expect(r.fills.first.odometerKm, 52110);
      expect(r.fills.first.rowNumber, 2);
      expect(r.fills[2].comments, 'sharetank');
    });

    test('date formats', () {
      expect(parseSheetDate('11/09/2025'), DateTime(2025, 9, 11));
      expect(parseSheetDate('10/Dec/2025'), DateTime(2025, 12, 10));
      expect(parseSheetDate('8/2/26'), DateTime(2026, 2, 8));
      expect(parseSheetDate('2025-09-11'), DateTime(2025, 9, 11));
      expect(parseSheetDate('x'), isNull);
    });

    test('comment split', () {
      expect(splitSheetComment('sharetank').payment, 'Sharetank');
      expect(splitSheetComment('sharetank').note, isNull);
      expect(splitSheetComment('long trip').note, 'long trip');
      expect(stationNameFromSheet('Z'), 'Z');
    });
  });

  group('stats', () {
    final rows = [
      FuelRow(at: DateTime(2026, 1, 1), odometerKm: 1000, quantity: 40, cost: 100),
      FuelRow(at: DateTime(2026, 2, 1), odometerKm: 1500, quantity: 40, cost: 120),
      FuelRow(at: DateTime(2026, 3, 1), odometerKm: 1800, quantity: 20, cost: 60, isFull: false),
      FuelRow(at: DateTime(2026, 4, 1), odometerKm: 2000, quantity: 25, cost: 75),
    ];

    test('per-tank economy skips first fill and merges partials', () {
      final s = tankStats(rows);
      expect(s[0].litresPer100, isNull);
      expect(s[1].litresPer100, closeTo(8.0, 1e-9));
      expect(s[1].costPer100, closeTo(24.0, 1e-9));
      expect(s[2].litresPer100, isNull); // partial
      // tank from 1500 to 2000: 20 + 25 L over 500 km
      expect(s[3].litresPer100, closeTo(9.0, 1e-9));
      expect(s[3].distanceKm, 200);
    });

    test('lifetime totals', () {
      final t = lifetimeTotals(rows);
      expect(t.km, 1000);
      expect(t.quantity, 85);
      expect(t.cost, 255);
      expect(t.per100, closeTo(8.5, 1e-9));
    });

    test('yearly totals and rolling', () {
      final y = yearlyTotals(rows);
      expect(y[2026]!.km, 1000);
      final r = rollingPer100(tankStats(rows), n: 5);
      expect(r[3], closeTo(8.5, 1e-9));
    });

    test('range', () {
      expect(rangeLeftKm(tankSize: 50, recentPer100: 10, kmSinceFill: 100), 400);
      expect(rangeLeftKm(tankSize: null, recentPer100: 10, kmSinceFill: 100), isNull);
    });
  });
}

