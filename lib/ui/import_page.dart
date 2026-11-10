import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../data/repository.dart';
import '../import/roadtrip_csv.dart';
import '../import/sheet_csv.dart';
import 'format.dart';

/// Pick a CSV, preview what was understood, confirm, import.
class ImportPage extends StatefulWidget {
  const ImportPage({super.key});
  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  String? _fileName;
  RoadTripExport? _roadTrip;
  SheetImportResult? _sheet;
  ImportSummary? _done;

  /// Anything worth importing: fill-ups, maintenance/expenses, trips or tyres.
  bool get _hasRows {
    final r = _roadTrip;
    if (r != null && (r.fuel.isNotEmpty || r.maintenance.isNotEmpty || r.trips.isNotEmpty || r.tyreSets.isNotEmpty)) return true;
    return _sheet?.fills.isNotEmpty ?? false;
  }
  bool _busy = false;

  Future<void> _pick() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final f = picked.files.first;
    final bytes = f.bytes ?? await File(f.path!).readAsBytes();
    final text = String.fromCharCodes(bytes);
    setState(() {
      _fileName = f.name;
      _done = null;
      _roadTrip = null;
      _sheet = null;
      if (looksLikeRoadTripCsv(text)) {
        _roadTrip = parseRoadTripCsv(text);
      } else {
        _sheet = parseSheetCsv(text);
      }
    });
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId!;
    try {
      ImportSummary s;
      if (_roadTrip != null) {
        s = await scope.repo.importRoadTrip(_roadTrip!, vehicleId: vid);
      } else {
        s = await scope.repo.importSheet(_sheet!, vehicleId: vid);
      }
      setState(() => _done = s);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Import history')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Two formats are understood: the Google Sheet exported as CSV (File > Download > CSV), and the Road Trip app\'s export. Re-importing the same file updates rows rather than duplicating them.'),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: _busy ? null : _pick, icon: const Icon(Icons.folder_open), label: Text(_fileName == null ? 'Choose a CSV file' : 'Choose a different file')),
          if (_fileName != null) ...[
            const SizedBox(height: 16),
            Text(_fileName!, style: t.titleMedium),
            const SizedBox(height: 8),
            if (_roadTrip != null) _roadTripPreview(_roadTrip!, t),
            if (_sheet != null) _sheetPreview(_sheet!, t),
            const SizedBox(height: 16),
            if (_done == null)
              FilledButton(
                onPressed: _busy || !_hasRows ? null : _import,
                child: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Import'),
              )
            else
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Done: $_done'),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _roadTripPreview(RoadTripExport e, TextTheme t) {
    final fuel = e.fuel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Road Trip export', style: t.labelLarge),
        Text('${fuel.length} fill-ups'
            '${fuel.isEmpty ? '' : ' from ${fmtDate(fuel.first.at)} at ${fmtKm(fuel.first.odometerKm)} km to ${fmtDate(fuel.last.at)} at ${fmtKm(fuel.last.odometerKm)} km'}'),
        Text('${e.maintenance.length} maintenance records, ${e.trips.length} trip reports, ${e.tyreSets.length} tyre sets'
            '${e.vehicle == null ? '' : ', vehicle "${e.vehicle!.name}"${e.vehicle!.tankCapacity == null ? '' : ' (${e.vehicle!.tankCapacity} L tank)'}'}'),
        if (fuel.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('First rows', style: t.labelMedium),
          for (final f in fuel.take(3))
            Text('${fmtDate(f.at)} · ${fmtKm(f.odometerKm)} km · ${fmtL(f.quantity)} · ${fmtMoney(f.cost)}${f.partial ? ' · partial' : ''}', style: t.bodySmall),
        ],
        for (final w in e.warnings) Text(w, style: t.bodySmall?.copyWith(color: Colors.orange)),
      ],
    );
  }

  Widget _sheetPreview(SheetImportResult r, TextTheme t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Google Sheet layout', style: t.labelLarge),
        Text('${r.fills.length} fill-ups'
            '${r.fills.isEmpty ? '' : ' from ${fmtDate(r.fills.first.at)} at ${fmtKm(r.fills.first.odometerKm)} km to ${fmtDate(r.fills.last.at)} at ${fmtKm(r.fills.last.odometerKm)} km'}'),
        if (r.fills.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('First rows', style: t.labelMedium),
          for (final f in r.fills.take(3))
            Text('${fmtDate(f.at)} · ${fmtKm(f.odometerKm)} km · ${fmtL(f.litres)} · ${fmtMoney(f.cost)}${f.location == null ? '' : ' · ${f.location}'}${f.comments == null ? '' : ' · ${f.comments}'}', style: t.bodySmall),
        ],
        for (final w in r.warnings) Text(w, style: t.bodySmall?.copyWith(color: Colors.orange)),
      ],
    );
  }
}
