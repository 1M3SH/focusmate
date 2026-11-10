import 'package:intl/intl.dart';

/// Utility helpers for date and time formatting.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _isoDateFmt = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayDateFmt = DateFormat('EEE, d MMM y');
  static final DateFormat _displayTimeFmt = DateFormat('HH:mm');
  static final DateFormat _displayDateTimeFmt =
      DateFormat('EEE, d MMM y  HH:mm');

  /// Returns today as a YYYY-MM-DD string.
  static String today() => _isoDateFmt.format(DateTime.now());

  /// Formats a [DateTime] to YYYY-MM-DD.
  static String toDateString(DateTime dt) =>
      _isoDateFmt.format(dt);

  /// Parses a YYYY-MM-DD string to [DateTime].
  static DateTime? fromDateString(String? s) {
    if (s == null) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  /// Human-readable date, e.g. "Mon, 3 Jan 2026".
  static String displayDate(DateTime dt) =>
      _displayDateFmt.format(dt);

  /// Human-readable time, e.g. "14:30".
  static String displayTime(DateTime dt) =>
      _displayTimeFmt.format(dt);

  /// Combined date + time display.
  static String displayDateTime(DateTime dt) =>
      _displayDateTimeFmt.format(dt);

  /// Returns true if [dt] falls on today's date.
  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
  }

  /// Returns true if [dt] is before today (time-agnostic).
  static bool isOverdue(DateTime dt) {
    final now = DateTime.now();
    return dt.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Formats duration in minutes as a human-readable string.
  static String formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
