import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app.dart';
import '../backup/backup.dart';
import '../data/attachment_store.dart';
import '../sync/sheets_sync.dart';
import 'format.dart';
import 'attachments.dart' show DocumentsPage;
import 'care_page.dart';
import 'import_page.dart';
import 'reminder_settings_page.dart';
import 'ev_compare_page.dart';
import 'prices_page.dart';
import 'sharetank_page.dart';
import 'vehicle_page.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});
  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((i) {
      if (mounted) setState(() => _version = '${i.version} (${i.buildNumber})');
    });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _backup() async {
    final scope = AppScope.of(context);
    try {
      final json = await exportBackupJson(scope.repo.db, attachmentsDir: (await AttachmentStore.get()).dir);
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      final file = File(p.join(dir.path, 'mileagelog-backup-$stamp.json'));
      await file.writeAsString(json);
      await scope.settings.setLastBackupAt(DateTime.now());
      if (!mounted) return;
      setState(() {});
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/json')], subject: 'MileageLog backup'));
    } catch (e) {
      _snack('Backup failed: $e');
    }
  }

  Future<void> _restore() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final bytes = picked.files.first.bytes ?? await File(picked.files.first.path!).readAsBytes();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text('Rows in the backup are merged into the app by their ID. Nothing is deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Restore')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      final db = AppScope.of(context).repo.db;
      final summary = await restoreBackupJson(db, utf8.decode(bytes), attachmentsDir: (await AttachmentStore.get()).dir);
      _snack('Restored: $summary');
    } catch (e) {
      _snack('Restore failed: $e');
    }
  }

  Future<void> _sheetsSettings() async {
    final scope = AppScope.of(context);
    final ctl = TextEditingController(text: scope.settings.spreadsheetId ?? '');
    var enabled = scope.settings.sheetsSyncEnabled;
    final saved = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text('Google Sheets sync'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctl,
                decoration: const InputDecoration(labelText: 'Spreadsheet link or ID', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sync new fill-ups'),
                value: enabled,
                onChanged: (v) => setD(() => enabled = v),
              ),
              const Text('New fill-ups are appended to Sheet1 in the original layout and to a FillUps tab with full detail. Needs Google sign-in.', style: TextStyle(fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved != true) return;
    final id = ctl.text.trim().isEmpty ? null : settingsSpreadsheetId(ctl.text);
    if (ctl.text.trim().isNotEmpty && id == null) {
      _snack('That does not look like a Google Sheets link or ID');
      return;
    }
    await scope.settings.setSpreadsheetId(id);
    await scope.settings.setSheetsSyncEnabled(enabled && id != null);
    if (mounted) setState(() {});
  }

  Future<void> _syncNow() async {
    final scope = AppScope.of(context);
    final id = scope.settings.spreadsheetId;
    if (id == null) {
      _snack('Set the spreadsheet first');
      return;
    }
    try {
      final n = await SheetsSync(scope.repo, id).flush();
      _snack(n == 0 ? 'Nothing to sync' : 'Synced $n rows');
    } catch (e) {
      _snack('Sync failed: $e');
    }
  }

  Future<void> _queueAll() async {
    final scope = AppScope.of(context);
    await scope.repo.enqueueAll(scope.settings.activeVehicleId!);
    _snack('All fill-ups queued for the FillUps tab');
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final s = scope.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('Vehicles'),
            subtitle: const Text('Switch, add another, or edit details'),
            onTap: () => showVehicleSwitcher(context),
          ),
          ListTile(
            leading: const Icon(Icons.handyman_outlined),
            title: const Text('Car care'),
            subtitle: const Text('Service schedule, insurance, tyres'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CarCarePage())),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open_outlined),
            title: const Text('Documents'),
            subtitle: const Text('WOF, service invoices, insurance, rego papers'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentsPage())),
          ),
          ListTile(
            leading: const Icon(Icons.price_check),
            title: const Text('Fuel prices'),
            subtitle: const Text('National average, your stations, Gaspy'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PricesPage())),
          ),
          ListTile(
            leading: const Icon(Icons.electric_car_outlined),
            title: const Text('Would an EV pay off?'),
            subtitle: const Text('Your last year of driving, costed as an EV'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EvComparePage())),
          ),
          ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: const Text('Z Sharetank'),
            subtitle: const Text('Fuel bought ahead: balance and savings'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SharetankPage())),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Reminders'),
            subtitle: Text(scope.settings.remindersEnabled ? 'On at ${TimeOfDay(hour: scope.settings.reminderHour, minute: scope.settings.reminderMinute).format(context)}' : 'Off'),
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReminderSettingsPage()));
              if (mounted) setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Import history'),
            subtitle: const Text('Google Sheet CSV or the old app\'s export'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportPage())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.table_chart_outlined),
            title: const Text('Google Sheets sync'),
            subtitle: Text(s.spreadsheetId == null ? 'Not set up' : (s.sheetsSyncEnabled ? 'On' : 'Off')),
            onTap: _sheetsSettings,
          ),
          StreamBuilder<int>(
            stream: scope.repo.watchPendingSyncCount(),
            builder: (context, snap) => ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync now'),
              subtitle: Text('${snap.data ?? 0} rows waiting'),
              enabled: s.spreadsheetId != null,
              onTap: _syncNow,
              trailing: TextButton(onPressed: s.spreadsheetId == null ? null : _queueAll, child: const Text('Queue all')),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Back up now'),
            subtitle: Text(s.lastBackupAt == null ? 'Share a JSON file with everything in the app' : 'Last backup ${fmtDate(s.lastBackupAt!)}'),
            onTap: _backup,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore from backup'),
            subtitle: const Text('Merge a MileageLog JSON backup into the app'),
            onTap: _restore,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.gps_fixed),
            title: const Text('Use GPS on fill-ups'),
            subtitle: const Text('One fix when the form opens, to pick the station'),
            value: s.useGps,
            onChanged: (v) async {
              await s.setUseGps(v);
              setState(() {});
            },
          ),
          const Divider(),
          AboutListTile(
            icon: const Icon(Icons.info_outline),
            applicationName: 'MileageLog',
            applicationVersion: _version,
            aboutBoxChildren: const [Text('Personal mileage, fuel and trip log. Data stays on this phone and in the exports you choose.')],
          ),
        ],
      ),
    );
  }
}

String? settingsSpreadsheetId(String text) {
  final t = text.trim();
  final m = RegExp(r'/spreadsheets/d/([A-Za-z0-9_-]{20,})').firstMatch(t);
  if (m != null) return m[1];
  if (RegExp(r'^[A-Za-z0-9_-]{20,}$').hasMatch(t)) return t;
  return null;
}
