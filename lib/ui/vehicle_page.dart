import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../app.dart';
import '../data/database.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({super.key});
  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final _name = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _tank = TextEditingController();
  final _rated = TextEditingController();
  final _notes = TextEditingController();
  Vehicle? _v;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final scope = AppScope.of(context);
    final v = await scope.repo.vehicle(scope.settings.activeVehicleId!);
    if (v == null || !mounted) return;
    setState(() {
      _v = v;
      _name.text = v.name;
      _make.text = v.make ?? '';
      _model.text = v.model ?? '';
      _year.text = v.year?.toString() ?? '';
      _tank.text = v.tankSize?.toString() ?? '';
      _rated.text = v.ratedEconomy?.toString() ?? '';
      _notes.text = v.notes ?? '';
    });
  }

  Future<void> _save() async {
    final scope = AppScope.of(context);
    await scope.repo.saveVehicle(VehiclesCompanion(
      id: Value(_v!.id),
      name: Value(_name.text.trim().isEmpty ? 'My car' : _name.text.trim()),
      kind: Value(_v!.kind),
      make: Value(_make.text.trim().isEmpty ? null : _make.text.trim()),
      model: Value(_model.text.trim().isEmpty ? null : _model.text.trim()),
      year: Value(int.tryParse(_year.text)),
      tankSize: Value(double.tryParse(_tank.text)),
      ratedEconomy: Value(double.tryParse(_rated.text)),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
      createdAt: Value(_v!.createdAt),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle')),
      body: _v == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _make, decoration: const InputDecoration(labelText: 'Make', border: OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _model, decoration: const InputDecoration(labelText: 'Model', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _tank, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Tank size (L)', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 12),
                TextField(controller: _rated, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Rated economy (L/100 km)', helperText: 'The maker\'s figure, shown as a benchmark', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes (stay on this phone)', border: OutlineInputBorder())),
                const SizedBox(height: 20),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
    );
  }
}
