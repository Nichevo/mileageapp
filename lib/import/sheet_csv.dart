/// Parser for the Google Sheet layout (exported as CSV or read through the
/// Sheets API): Trip (km), Litres, Cost, Odemeter, Date, Location, Comments.
library;

import 'package:csv/csv.dart';

class SheetFill {
  final double? tripKm;
  final double litres;
  final double cost;
  final double odometerKm;
  final DateTime at;
  final String? location;
  final String? comments;
  final int rowNumber; // 1-based row in the sheet, for idempotent re-import
  const SheetFill({
    this.tripKm,
    required this.litres,
    required this.cost,
    required this.odometerKm,
    required this.at,
    this.location,
    this.comments,
    required this.rowNumber,
  });
}

class SheetImportResult {
  final List<SheetFill> fills;
  final List<String> warnings;
  const SheetImportResult(this.fills, this.warnings);
}

const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'sept': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

/// Day-first dates: `11/09/2025`, `10/Dec/2025`, `8/2/26`, also ISO `2025-09-11`.
DateTime? parseSheetDate(String s) {
  final t = s.trim();
  var m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(t);
  if (m != null) return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  m = RegExp(r'^(\d{1,2})[/\-. ]([A-Za-z]{3,4}|\d{1,2})[/\-. ](\d{2,4})$').firstMatch(t);
  if (m == null) return null;
  final day = int.parse(m[1]!);
  final monthPart = m[2]!;
  final month = int.tryParse(monthPart) ?? _months[monthPart.toLowerCase()];
  if (month == null) return null;
  var year = int.parse(m[3]!);
  if (year < 100) year += 2000;
  return DateTime(year, month, day);
}

/// Accepts a list of rows (first row = headers) in any column order, matching
/// headers loosely ("Odemeter" and "Odometer" both work).
SheetImportResult parseSheetRows(List<List<String>> rows) {
  final warnings = <String>[];
  if (rows.isEmpty) return SheetImportResult(const [], ['Sheet is empty']);
  final header = rows.first.map((h) => h.trim().toLowerCase()).toList();
  int? col(List<String> names) {
    for (var i = 0; i < header.length; i++) {
      for (final n in names) {
        if (header[i].startsWith(n)) return i;
      }
    }
    return null;
  }

  final cTrip = col(['trip']);
  final cLitres = col(['litre', 'liter', 'fuel']);
  final cCost = col(['cost', 'total', 'price']);
  final cOdo = col(['odemeter', 'odometer', 'odo']);
  final cDate = col(['date']);
  final cLoc = col(['location', 'station']);
  final cCom = col(['comment', 'note']);
  if (cLitres == null || cCost == null || cOdo == null || cDate == null) {
    return SheetImportResult(const [], ['Could not find the Litres, Cost, Odometer and Date columns in: ${rows.first.join(', ')}']);
  }

  String cell(List<String> r, int? i) => (i == null || i >= r.length) ? '' : r[i].trim();
  double? num_(String s) => double.tryParse(s.replaceAll(RegExp(r'[^0-9.\-]'), ''));

  final fills = <SheetFill>[];
  for (var i = 1; i < rows.length; i++) {
    final r = rows[i];
    if (r.every((c) => c.trim().isEmpty)) continue;
    final at = parseSheetDate(cell(r, cDate));
    final litres = num_(cell(r, cLitres));
    final cost = num_(cell(r, cCost));
    final odo = num_(cell(r, cOdo));
    if (at == null || litres == null || cost == null || odo == null) {
      warnings.add('Row ${i + 1} skipped (date/litres/cost/odometer unreadable): ${r.join(', ')}');
      continue;
    }
    fills.add(SheetFill(
      tripKm: num_(cell(r, cTrip)),
      litres: litres,
      cost: cost,
      odometerKm: odo,
      at: at,
      location: cell(r, cLoc).isEmpty ? null : cell(r, cLoc),
      comments: cell(r, cCom).isEmpty ? null : cell(r, cCom),
      rowNumber: i + 1,
    ));
  }
  return SheetImportResult(fills, warnings);
}

SheetImportResult parseSheetCsv(String text) {
  final rows = const CsvToListConverter(shouldParseNumbers: false, eol: '\n')
      .convert(text.replaceAll('\r\n', '\n'))
      .map((r) => r.map((c) => c.toString()).toList())
      .toList();
  return parseSheetRows(rows);
}

/// Normalises the sheet's short station codes.
String stationNameFromSheet(String? location) {
  if (location == null) return 'Unknown';
  final t = location.trim();
  if (t.toLowerCase() == 'z') return 'Z';
  return t;
}

/// "sharetank" -> "Sharetank" payment tag; anything else is a note.
({String? payment, String? note}) splitSheetComment(String? comments) {
  if (comments == null || comments.trim().isEmpty) return (payment: null, note: null);
  final t = comments.trim();
  if (t.toLowerCase().contains('sharetank')) {
    final rest = t.replaceAll(RegExp('sharetank', caseSensitive: false), '').trim();
    return (payment: 'Sharetank', note: rest.isEmpty ? null : rest);
  }
  return (payment: null, note: t);
}
