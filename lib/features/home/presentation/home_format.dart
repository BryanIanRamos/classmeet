import '../application/home_providers.dart';

/// Copy helpers shared by the Home screens (8, 14–16), so the same data
/// reads the same everywhere.

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// "Monday" … "Sunday".
String weekdayName(DateTime date) => _weekdays[date.weekday - 1];

/// Whole calendar days from [now] to [due] (time of day ignored; UTC dates,
/// so a daylight-saving change cannot shift the count).
int daysUntil(DateTime now, DateTime due) {
  final today = DateTime.utc(now.year, now.month, now.day);
  final dueDay = DateTime.utc(due.year, due.month, due.day);
  return dueDay.difference(today).inDays;
}

/// "Today", "In 1 day" or "In 5 days". Past dates read "Today".
String dueLabel(int days) {
  if (days <= 0) return 'Today';
  return 'In $days ${countLabel(days, 'day')}';
}

/// "3 activities left", "1 activity left".
String activitiesLeftLabel(int remaining) =>
    '$remaining ${countLabel(remaining, 'activity', 'activities')} left';

/// "Available until Sunday" (8, 14): the weekday the quest closes.
String availableUntilLabel(DateTime until) =>
    'Available until ${weekdayName(until)}';
