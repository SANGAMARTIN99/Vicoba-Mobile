import 'package:intl/intl.dart';

/// Formatting helpers for currency, dates, and numbers in VicobaPlus
class Formatters {
  Formatters._();

  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');

  /// Formats amount into Tanzanian Shillings: "TZS 150,000"
  static String currency(num? amount, {String symbol = 'TZS'}) {
    if (amount == null) return '$symbol 0';
    return '$symbol ${_currencyFormat.format(amount)}';
  }

  /// Compact number format (e.g., 1.5M, 20K)
  static String compact(num? number) {
    if (number == null) return '0';
    return NumberFormat.compact().format(number);
  }

  /// Formats ISO 8601 string or DateTime to readable format: "02 Oct 2026"
  static String date(dynamic input) {
    if (input == null) return '-';
    DateTime? dt;
    if (input is DateTime) {
      dt = input;
    } else if (input is String) {
      dt = DateTime.tryParse(input);
    }
    if (dt == null) return input.toString();
    return DateFormat('dd MMM yyyy').format(dt);
  }

  /// Formats date with time: "02 Oct 2026, 14:30"
  static String dateTime(dynamic input) {
    if (input == null) return '-';
    DateTime? dt;
    if (input is DateTime) {
      dt = input;
    } else if (input is String) {
      dt = DateTime.tryParse(input);
    }
    if (dt == null) return input.toString();
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  /// Truncate long SHA-256 hash for UI: "e3b0c442...b974"
  static String truncateHash(String? hash, {int head = 8, int tail = 6}) {
    if (hash == null || hash.isEmpty) return '-';
    if (hash.length <= head + tail) return hash;
    return '${hash.substring(0, head)}...${hash.substring(hash.length - tail)}';
  }

  /// Formats percentage: "13.8%"
  static String percent(num? value, {int decimals = 1}) {
    if (value == null) return '0%';
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Standardizes phone number to East African format: +255 7XX XXX XXX
  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '-';
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('255') && cleaned.length == 12) {
      return '+255 ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    } else if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '+255 ${cleaned.substring(1, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
    }
    return phone;
  }
}
