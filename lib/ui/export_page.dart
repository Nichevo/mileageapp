/// More > Export data: spreadsheets (CSV) and trip routes (GPX).
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../domain/ownership_cost.dart' show CostPeriod, mergeCostPeriods;
import '../domain/stats.dart' show Period;
import '../export/data_export.dart';
import 'costs_page.dart' show VehicleCosts;
import 'format.dart';
import 'notes_page.dart' show incidentFields, decodeFields;
import 'service_page.dart' show expenseKinds;

enum ExportSet { fills, expenses, trips, costs, notes, gpx }

String exportSetLabel(ExportSet s) => switch (s) {
      ExportSet.fills => 'Fill-ups and charges',
      ExportSet.expenses => 'Expenses',
      ExportSet.trips => 'Trips with their stats',
      ExportSet.costs => 'Running costs by year',
      ExportSet.notes => 'Notes and incidents',
      ExportSet.gpx => 'Trip routes (GPX map file)',
    };

String _setHint(ExportSet s) => switch (s) {
      ExportSet.fills => 'Litres, cost, price, economy per tank, station',
      ExportSet.expenses => 'Services, WOF, rego, insurance, tyres, tolls, parking',
      ExportSet.trips => 'Distance, times, speeds, stops, road types, lights, weather',
      ExportSet.costs => 'Each category, depreciation, km and cost per km',
      ExportSet.notes => 'Incident details, place and time',
      ExportSet.gpx => 'Opens in Google Earth, Strava and map apps',
    };

/// One file to hand over.
class ExportFile {
  final String name;
  final String text;
  const ExportFile(this.name, this.text);
}

/// Builds the chosen files. [vehicleId] null means every vehicle.
Future<List<ExportFile>> buildExport(Repository repo, Set<ExportSet> sets, {String? vehicleId, DateWindow window = DateWindow.all, DateTime? now}) async {
  final vehicles = await repo.vehicles();
  final names = {for (final v in vehicles) v.id: v.name};
  final scope = vehicleId == null ? 'all-vehicles' : fileSafe(names[vehicleId] ?? 'vehicle');
  final tag = '${scope}_${window.fileTag}';
  final out = <ExportFile>[];

  if (sets.contains(ExportSet.fills)) {
    final events = await repo.watchEvents(vehicleId, kind: null).first;
    out.add(ExportFile('mileagelog-fillups_$tag.csv', fillUpsCsv(events, names, window: window)));
  }
  if (sets.contains(ExportSet.expenses)) {
    final ex = await repo.watchExpenses(vehicleId).first;
    final docs = (await repo.watchAllAttachments().first).where((a) => a.ownerKind == 'expense').map((a) => a.ownerId).toSet();
    out.add(ExportFile('mileagelog-expenses_$tag.csv', expensesCsv(ex, names, window: window, withDocs: docs, kindLabels: expenseKinds)));
  }
  List<Trip>? trips;
  if (sets.contains(ExportSet.trips) || sets.contains(ExportSet.gpx)) {
    trips = (await repo.watchTrips(vehicleId).first).where((t) => t.status != 'recording' && window.has(t.startAt)).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }
  if (sets.contains(ExportSet.trips)) {
    out.add(ExportFile('mileagelog-trips_$tag.csv', tripsCsv(trips!, names, window: window)));
  }
  if (sets.contains(ExportSet.costs)) {
    final events = await repo.watchEvents(null, kind: null).first;
    final ex = await repo.watchExpenses(null).first;
    final values = await repo.watchValues(null).first;
    final policies = await repo.watchAllPolicies().first;
    final when = now ?? DateTime.now();
    final rows = <(String, List<CostPeriod>)>[];
    for (final v in vehicles) {
      if (vehicleId != null && v.id != vehicleId) continue;
      final c = VehicleCosts.of(v, events, ex, values, policies);
      if (!c.hasData) continue;
      rows.add((v.name, c.periods(Period.year, now: when)));
    }
    if (vehicleId == null && rows.length > 1) rows.add(('All vehicles', mergeCostPeriods([for (final r in rows) r.$2])));
    out.add(ExportFile('mileagelog-running-costs_$tag.csv', costsCsv(rows, window: window)));
  }
  if (sets.contains(ExportSet.notes)) {
    final notes = await repo.watchNotes(vehicleId).first;
    final photos = <String, int>{};
    for (final a in await repo.watchAllAttachments().first) {
      if (a.ownerKind == 'note') photos[a.ownerId] = (photos[a.ownerId] ?? 0) + 1;
    }
    out.add(ExportFile('mileagelog-notes_$tag.csv', notesCsv(notes, names, incidentFields, window: window, decode: decodeFields, photos: photos)));
  }
  if (sets.contains(ExportSet.gpx)) {
    final tracks = <(Trip, String, List<TripPoint>)>[];
    for (final t in trips!) {
      final pts = await repo.tripPoints(t.id);
      if (pts.isNotEmpty) tracks.add((t, names[t.vehicleId] ?? '', pts));
    }
    if (tracks.isNotEmpty) out.add(ExportFile('mileagelog-routes_$tag.gpx', tripsGpx(tracks)));
  }
  return out;
}

/// Zip of several files, for saving in one go.
Uint8List zipFiles(List<ExportFile> files) {
  final a = Archive();
  for (final f in files) {
    final bytes = utf8.encode(f.text);
    a.addFile(ArchiveFile(f.name, bytes.length, bytes));
  }
  return Uint8List.fromList(ZipEncoder().encode(a));
}

/// Hands files to the share sheet. Swapped out in tests.
Future<void> Function(List<File> files, String subject) shareExport = (files, subject) async {
  await SharePlus.instance.share(ShareParams(files: [for (final f in files) XFile(f.path)], subject: subject));
};

/// Asks Android where to save. Swapped out in tests. Returns null if cancelled.
Future<String?> Function(String name, Uint8List bytes) saveExport = (name, bytes) =>
    FilePicker.platform.saveFile(dialogTitle: 'Save export', fileName: name, bytes: bytes);

/// Where files wait before sharing. Swapped out in tests.
Future<Directory> Function() exportTempDir = getTemporaryDirectory;

Future<List<File>> _writeTemp(List<ExportFile> files) async {
  final dir = Directory(p.join((await exportTempDir()).path, 'export'));
  if (await dir.exists()) await dir.delete(recursive: true);
  await dir.create(recursive: true);
  return [
    for (final f in files) await File(p.join(dir.path, f.name)).writeAsString(f.text),
  ];
}

/// Share one trip's route as a GPX file (from the trip page).
Future<void> shareTripGpx(BuildContext context, Trip trip) async {
  final repo = AppScope.of(context).repo;
  final messenger = ScaffoldMessenger.of(context);
  final pts = await repo.tripPoints(trip.id);
  if (pts.isEmpty) {
    messenger.showSnackBar(const SnackBar(content: Text('This trip has no GPS route to export')));
    return;
  }
  final v = await repo.vehicle(trip.vehicleId);
  final name = 'mileagelog-trip_${DateFormat('yyyy-MM-dd_HHmm').format(trip.startAt)}_${fileSafe(trip.name)}.gpx';
  try {
    final files = await _writeTemp([ExportFile(name, tripsGpx([(trip, v?.name ?? '', pts)]))]);
    await shareExport(files, trip.name);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
  }
}

enum _Range { all, thisYear, last12, lastYear, custom }

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});
  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _sets = {ExportSet.fills, ExportSet.expenses, ExportSet.trips, ExportSet.costs};
  bool _allVehicles = false;
  _Range _range = _Range.all;
  DateTimeRange? _custom;
  bool _busy = false;

  DateWindow get _window {
    final now = DateTime.now();
    return switch (_range) {
      _Range.all => DateWindow.all,
      _Range.thisYear => DateWindow(from: DateTime(now.year)),
      _Range.last12 => DateWindow(from: DateTime(now.year - 1, now.month, now.day + 1)),
      _Range.lastYear => DateWindow(from: DateTime(now.year - 1), to: DateTime(now.year - 1, 12, 31)),
      _Range.custom => _custom == null ? DateWindow.all : DateWindow(from: _custom!.start, to: _custom!.end),
    };
  }

  String _rangeLabel(_Range r) => switch (r) {
        _Range.all => 'All time',
        _Range.thisYear => 'This year',
        _Range.last12 => 'Last 12 months',
        _Range.lastYear => 'Last year (${DateTime.now().year - 1})',
        _Range.custom => _custom == null ? 'Choose dates…' : '${fmtDate(_custom!.start)} to ${fmtDate(_custom!.end)}',
      };

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _custom,
    );
    if (r != null) setState(() => _custom = r);
    if (_custom == null) setState(() => _range = _Range.all);
  }

  Future<List<ExportFile>?> _build() async {
    final scope = AppScope.of(context);
    setState(() => _busy = true);
    try {
      final files = await buildExport(scope.repo, _sets, vehicleId: _allVehicles ? null : scope.settings.activeVehicleId, window: _window);
      if (files.isEmpty && mounted) _snack('Nothing to export for that choice');
      return files.isEmpty ? null : files;
    } catch (e) {
      _snack('Export failed: $e');
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _share() async {
    final files = await _build();
    if (files == null) return;
    try {
      await shareExport(await _writeTemp(files), 'MileageLog export');
    } catch (e) {
      _snack('Share failed: $e');
    }
  }

  Future<void> _save() async {
    final files = await _build();
    if (files == null) return;
    final stamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final single = files.length == 1;
    final name = single ? files.first.name : 'mileagelog-export_$stamp.zip';
    final bytes = single ? Uint8List.fromList(utf8.encode(files.first.text)) : zipFiles(files);
    try {
      final path = await saveExport(name, bytes);
      if (path != null) _snack(single ? 'Saved $name' : 'Saved ${files.length} files in $name');
    } catch (e) {
      _snack('Save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final vid = scope.settings.activeVehicleId;
    return Scaffold(
      appBar: AppBar(title: const Text('Export data')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('Spreadsheet files (CSV) open in Excel, Google Sheets and Numbers. '
                  'For a full copy to restore later, use Back up now instead.'),
            ),
            const _Heading('What'),
            for (final s in ExportSet.values)
              CheckboxListTile(
                value: _sets.contains(s),
                title: Text(exportSetLabel(s)),
                subtitle: Text(_setHint(s)),
                onChanged: (v) => setState(() => v == true ? _sets.add(s) : _sets.remove(s)),
              ),
            const _Heading('Which vehicles'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<Vehicle?>(
                future: vid == null ? Future.value(null) : scope.repo.vehicle(vid),
                builder: (c, snap) => SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(snap.data?.name ?? 'This vehicle', overflow: TextOverflow.ellipsis)),
                    const ButtonSegment(value: true, label: Text('All vehicles')),
                  ],
                  selected: {_allVehicles},
                  onSelectionChanged: (s) => setState(() => _allVehicles = s.first),
                ),
              ),
            ),
            const _Heading('Dates'),
            RadioGroup<_Range>(
              groupValue: _range,
              onChanged: (v) {
                setState(() => _range = v!);
                if (v == _Range.custom) _pickRange();
              },
              child: Column(
                children: [
                  for (final r in _Range.values)
                    RadioListTile<_Range>(
                      value: r,
                      title: Text(_rangeLabel(r)),
                      dense: true,
                      secondary: r == _Range.custom && _range == _Range.custom
                          ? IconButton(tooltip: 'Change dates', icon: const Icon(Icons.edit_calendar_outlined), onPressed: _pickRange)
                          : null,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy || _sets.isEmpty ? null : _share,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy || _sets.isEmpty ? null : _save,
                      icon: const Icon(Icons.download),
                      label: const Text('Save to phone'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                _busy
                    ? 'Preparing files…'
                    : 'Share sends the files to Drive, email or another app. Save to phone puts them in a folder you choose'
                        '${_sets.length > 1 ? ', as one zip file' : ''}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
