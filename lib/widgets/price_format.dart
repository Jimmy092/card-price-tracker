import 'package:intl/intl.dart';

final _eur = NumberFormat.currency(locale: 'de_DE', symbol: '€');

String formatEurCents(int? cents) {
  if (cents == null) return '—';
  return _eur.format(cents / 100.0);
}

String formatPct(double? pct) {
  if (pct == null) return '—';
  final sign = pct > 0 ? '+' : '';
  return '$sign${pct.toStringAsFixed(1)}%';
}
