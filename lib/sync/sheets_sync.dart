/// One-way export of fill-ups to the user's Google Sheet.
///
/// `Sheet1` keeps the original seven-column layout so the existing sheet keeps
/// working; a `FillUps` tab gets the full detail with the row UUID in column A
/// so edits made in the app update the right row.
///
/// Needs a Google OAuth client ID for Android, configured outside the repo
/// (see .env.example). Without one, sign-in fails and the queue just waits.
library;

import 'package:drift/drift.dart' hide Column;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../data/repository.dart';

class SheetsSync {
  final Repository repo;
  final String spreadsheetId;
  SheetsSync(this.repo, this.spreadsheetId);

  static final GoogleSignIn _signIn = GoogleSignIn(scopes: const [sheets.SheetsApi.spreadsheetsScope]);

  static const legacyHeader = ['Trip (km)', 'Litres', 'Cost', 'Odemeter', 'Date', 'Location', 'Comments'];
  static const fillUpsHeader = [
    'ID', 'Date', 'Odometer km', 'Trip km', 'Litres', 'Cost', 'Price/L', 'Full tank',
    'Station', 'Fuel', 'Payment', 'Notes', 'Lat', 'Lon', 'Source'
  ];

  static Future<GoogleSignInAccount?> signIn() async =>
      await _signIn.signInSilently() ?? await _signIn.signIn();

  static Future<void> signOut() => _signIn.signOut();

  static Future<GoogleSignInAccount?> currentUser() => _signIn.signInSilently();

  Future<sheets.SheetsApi> _api() async {
    final account = await signIn();
    if (account == null) throw StateError('Google sign-in cancelled');
    final client = await _signIn.authenticatedClient();
    if (client == null) throw StateError('No authenticated Google client');
    return sheets.SheetsApi(client);
  }

  static String _d(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  List<Object> legacyRow(EnergyEvent e, {double? tripKm}) => [
        (e.tripKm ?? tripKm ?? '').toString(),
        e.quantity,
        e.cost,
        e.odometerKm,
        _d(e.at),
        e.stationName ?? '',
        [if (e.paymentNote != null) e.paymentNote!.toLowerCase(), if (e.notes != null) e.notes!].join(' '),
      ];

  List<Object> fullRow(EnergyEvent e, {double? tripKm}) => [
        e.id,
        e.at.toIso8601String(),
        e.odometerKm,
        e.tripKm ?? tripKm ?? '',
        e.quantity,
        e.cost,
        e.quantity > 0 ? (e.cost / e.quantity) : '',
        e.isFull ? 'yes' : 'no',
        e.stationName ?? '',
        e.fuelType ?? '',
        e.paymentNote ?? '',
        e.notes ?? '',
        e.lat ?? '',
        e.lon ?? '',
        e.source,
      ];

  /// Makes sure the `FillUps` tab exists with its header.
  Future<void> ensureTabs(sheets.SheetsApi api) async {
    final ss = await api.spreadsheets.get(spreadsheetId);
    final titles = ss.sheets?.map((s) => s.properties?.title).whereType<String>().toSet() ?? {};
    if (!titles.contains('FillUps')) {
      await api.spreadsheets.batchUpdate(
        sheets.BatchUpdateSpreadsheetRequest(requests: [
          sheets.Request(addSheet: sheets.AddSheetRequest(properties: sheets.SheetProperties(title: 'FillUps'))),
        ]),
        spreadsheetId,
      );
      await api.spreadsheets.values.update(
        sheets.ValueRange(values: [fillUpsHeader]),
        spreadsheetId,
        'FillUps!A1',
        valueInputOption: 'USER_ENTERED',
      );
    }
  }

  /// Pushes everything in the sync queue. Returns the number of rows synced.
  Future<int> flush() async {
    final pending = await repo.pendingSync();
    if (pending.isEmpty) return 0;
    final api = await _api();
    await ensureTabs(api);

    // Read the FillUps tab once to know which IDs are already there.
    final existing = await api.spreadsheets.values.get(spreadsheetId, 'FillUps!A2:A');
    final idToRow = <String, int>{};
    final rows = existing.values ?? const [];
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].isNotEmpty) idToRow[rows[i].first.toString()] = i + 2;
    }

    var synced = 0;
    for (final item in pending) {
      try {
        if (item.targetTable != 'energy_events') {
          await repo.markSynced(item.seq);
          continue;
        }
        if (item.action == 'delete') {
          final row = idToRow[item.rowId];
          if (row != null) {
            await api.spreadsheets.values.clear(sheets.ClearValuesRequest(), spreadsheetId, 'FillUps!A$row:O$row');
          }
          await repo.markSynced(item.seq);
          synced++;
          continue;
        }
        final e = await (repo.db.select(repo.db.energyEvents)..where((x) => x.id.equals(item.rowId))).getSingleOrNull();
        if (e == null) {
          await repo.markSynced(item.seq);
          continue;
        }
        final tripKm = await _tripKmFor(e);
        final row = idToRow[e.id];
        if (row != null) {
          await api.spreadsheets.values.update(
            sheets.ValueRange(values: [fullRow(e, tripKm: tripKm)]),
            spreadsheetId,
            'FillUps!A$row',
            valueInputOption: 'USER_ENTERED',
          );
        } else {
          await api.spreadsheets.values.append(
            sheets.ValueRange(values: [fullRow(e, tripKm: tripKm)]),
            spreadsheetId,
            'FillUps!A1',
            valueInputOption: 'USER_ENTERED',
            insertDataOption: 'INSERT_ROWS',
          );
          idToRow[e.id] = rows.length + idToRow.length + 2;
          // Rows the app created (not imported from this sheet) also go on
          // Sheet1 in the original layout so the old sheet stays complete.
          if (e.source != 'sheet_import') {
            await api.spreadsheets.values.append(
              sheets.ValueRange(values: [legacyRow(e, tripKm: tripKm)]),
              spreadsheetId,
              'Sheet1!A1',
              valueInputOption: 'USER_ENTERED',
              insertDataOption: 'INSERT_ROWS',
            );
          }
        }
        await repo.markSynced(item.seq);
        synced++;
      } catch (err) {
        await repo.markSyncFailed(item.seq, err.toString());
        rethrow;
      }
    }
    return synced;
  }

  Future<double?> _tripKmFor(EnergyEvent e) async {
    final prev = await (repo.db.select(repo.db.energyEvents)
          ..where((x) => x.vehicleId.equals(e.vehicleId) & x.kind.equals(e.kind) & x.odometerKm.isSmallerThanValue(e.odometerKm))
          ..orderBy([(x) => OrderingTerm.desc(x.odometerKm)])
          ..limit(1))
        .getSingleOrNull();
    if (prev == null) return e.tripKm;
    return e.odometerKm - prev.odometerKm;
  }
}
