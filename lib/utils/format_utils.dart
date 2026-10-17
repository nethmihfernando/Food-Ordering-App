import 'package:intl/intl.dart';

/// Small collection of formatting helpers used across the UI.
class AppFormat {
  AppFormat._();

  static final NumberFormat _currency = NumberFormat.currency(symbol: '\$');

  static String currency(double amount) => _currency.format(amount);

  /// e.g. "8 Jul, 3:45 PM"
  static String orderTimestamp(DateTime date) => DateFormat('d MMM, h:mm a').format(date);
}
