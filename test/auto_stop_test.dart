import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/domain/trip_stats.dart';
import 'package:mileagelog/trips/recorder.dart';

void main() {
  test('a trip that ended by itself drops the points recorded while parked', () {
    final t0 = DateTime(2026, 11, 13, 8);
    final s = [for (var i = 0; i < 10; i++) GpsSample(t0.add(Duration(minutes: i)), -41.2, 174.7 + i * 0.001)];
    expect(trimToEnd(s, null), hasLength(10));
    expect(trimToEnd(s, t0.add(const Duration(minutes: 4, seconds: 30))).map((x) => x.at.minute), [0, 1, 2, 3, 4]);
    expect(trimToEnd(s, t0.add(const Duration(minutes: 4))).last.at, t0.add(const Duration(minutes: 4)));
  });
}
