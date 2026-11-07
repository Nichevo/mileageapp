import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mileagelog/app.dart';
import 'package:mileagelog/data/database.dart';
import 'package:mileagelog/data/repository.dart';
import 'package:mileagelog/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app starts on an empty database', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = Repository(db);
    final settings = await Settings.load();
    final v = await repo.ensureVehicle();
    await settings.setActiveVehicleId(v.id);

    await tester.pumpWidget(MileageApp(repo: repo, settings: settings));
    await tester.pump();
    expect(find.text('Log a fill-up'), findsOneWidget);
    expect(find.text('No fill-ups yet'), findsOneWidget);
    await db.close();
  });
}
