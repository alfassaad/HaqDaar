import 'package:intl/intl.dart';
import 'package:myapp/src/core/constants/app_constants.dart';

class DateFormatter {
  static final DateFormat _fullFormat = DateFormat(AppConstants.dateFormatFull);
  static final DateFormat _shortFormat = DateFormat(AppConstants.dateFormatShort);
  static final DateFormat _timeFormat = DateFormat(AppConstants.dateFormatTime);
  static final DateFormat _dateTimeFormat = DateFormat(AppConstants.dateFormatDateTime);
  
  static String formatTransactionDate(DateTime date) {
    return _fullFormat.format(date);
  }
  
  static String formatShortDate(DateTime date) {
    return _shortFormat.format(date);
  }
  
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }
  
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
  
  static String formatCurrency(double amount, {String symbol = 'Rs. ', int decimalDigits = 0}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits);
    return formatter.format(amount);
  }
}