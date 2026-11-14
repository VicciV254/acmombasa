/// Minimal date formatting so the app doesn't need the `intl` package yet.
abstract final class DateFormatter {
  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String weekdayShort(DateTime d) => _weekdays[d.weekday - 1].substring(0, 3);

  static String monthShort(DateTime d) => _months[d.month - 1].substring(0, 3);

  /// e.g. "October 2024"
  static String monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  /// e.g. "Thursday, October 24, 2024"
  static String fullDate(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}, ${d.year}';

  /// e.g. "March 14, 2023"
  static String longDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day}, ${d.year}';

  /// e.g. "Oct 21, 2024"
  static String shortDate(DateTime d) =>
      '${_months[d.month - 1].substring(0, 3)} ${d.day}, ${d.year}';

  /// e.g. "2024-10-24"
  static String isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// e.g. "10:42 AM"
  static String time12(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Minutes since midnight -> "02:00 PM".
  static String minutesToTime12(int minutes) {
    final d = DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60);
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minute '
        '${d.hour >= 12 ? 'PM' : 'AM'}';
  }

  /// "today", "yesterday", "3 days ago", "2 weeks ago", ...
  static String relativeDay(DateTime date, DateTime now) {
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    if (days <= 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 14) return '$days days ago';
    if (days < 60) return '${days ~/ 7} weeks ago';
    if (days < 730) return '${days ~/ 30} months ago';
    return '${days ~/ 365} years ago';
  }
}
