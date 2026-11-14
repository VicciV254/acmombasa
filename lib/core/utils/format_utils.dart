import 'date_format.dart';

/// 1420 -> "1,420".
String groupThousands(int n) {
  final s = n.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return n < 0 ? '-$buffer' : '$buffer';
}

/// 78 minutes -> "1h 18m"; 45 -> "45m"; 120 -> "2h".
String formatDuration(Duration d) {
  final minutes = d.inMinutes;
  if (minutes < 1) return '<1m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

String formatMinutes(int minutes) => formatDuration(Duration(minutes: minutes));

const List<String> _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// DateTime.weekday (1 = Monday) -> "Monday".
String weekdayName(int weekday) => _weekdayNames[weekday - 1];

/// "Today", "Yesterday" or "Oct 21, 2024".
String dayLabel(DateTime date, DateTime now) {
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(date.year, date.month, date.day))
      .inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  return DateFormatter.shortDate(date);
}

/// "59 mos ago", "1 mo ago" or "this month".
String monthsAgoLabel(DateTime from, DateTime now) {
  final months = (now.year - from.year) * 12 + now.month - from.month;
  if (months <= 0) return 'this month';
  return '$months ${months == 1 ? 'mo' : 'mos'} ago';
}
