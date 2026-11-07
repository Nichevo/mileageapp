import 'package:intl/intl.dart';

final _km = NumberFormat('#,##0', 'en_NZ');
final _km1 = NumberFormat('#,##0.0', 'en_NZ');
final _money = NumberFormat.currency(locale: 'en_NZ', symbol: r'$', decimalDigits: 2);
final _money0 = NumberFormat.currency(locale: 'en_NZ', symbol: r'$', decimalDigits: 0);
final _d = DateFormat('d MMM yyyy');
final _dShort = DateFormat('d MMM');

String fmtKm(num v) => _km.format(v);
String fmtKm1(num v) => _km1.format(v);
String fmtMoney(num v) => _money.format(v);
String fmtMoney0(num v) => _money0.format(v);
String fmtL(num v) => '${v.toStringAsFixed(2)} L';
String fmtPer100(num? v) => v == null ? '—' : v.toStringAsFixed(1);
String fmtPrice(num? v) => v == null ? '—' : '\$${v.toStringAsFixed(3)}/L';
String fmtDate(DateTime d) => _d.format(d);
String fmtDateShort(DateTime d) => _dShort.format(d);
