import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final DateFormat _shortDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTime = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');
  static final NumberFormat _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  static String formatDate(DateTime date) => _shortDate.format(date);
  static String formatDateTime(DateTime date) => _dateTime.format(date);
  static String formatTime(DateTime date) => _timeOnly.format(date);
  static String formatCurrency(num amount) => _currency.format(amount);

  static String formatPoints(int points) => '$points pts';
}
