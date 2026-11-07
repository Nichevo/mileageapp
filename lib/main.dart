import 'package:flutter/material.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/repository.dart';
import 'settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final repo = Repository(db);
  final settings = await Settings.load();
  final vehicle = await repo.ensureVehicle();
  if (settings.activeVehicleId == null) {
    await settings.setActiveVehicleId(vehicle.id);
  }
  runApp(MileageApp(repo: repo, settings: settings));
}
