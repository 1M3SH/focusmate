/// Application-wide constants for FocusMate.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'FocusMate';
  static const String appVersion = '1.0.0';

  // Snooze durations (minutes)
  static const int snooze5Min = 5;
  static const int snooze10Min = 10;
  static const int snooze15Min = 15;

  // Focus timer defaults (minutes)
  static const int defaultFocusDuration = 25;
  static const int defaultBreakDuration = 5;
  static const int defaultLongBreakDuration = 15;
  static const int sessionsBeforeLongBreak = 4;

  // Local notification channel IDs
  static const String taskReminderChannelId = 'task_reminders';
  static const String taskReminderChannelName = 'Task Reminders';
  static const String focusTimerChannelId = 'focus_timer';
  static const String focusTimerChannelName = 'Focus Timer';
  static const String routineChannelId = 'routines';
  static const String routineChannelName = 'Daily Routines';

  // SharedPreferences keys
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefThemeMode = 'theme_mode';
  static const String prefUserId = 'user_id';

  // Isar database name
  static const String isarDbName = 'focusmate_db';

  // Task priority labels
  static const Map<int, String> priorityLabels = {
    0: 'Low',
    1: 'Medium',
    2: 'High',
  };

  // Default task categories
  static const List<String> defaultCategories = [
    'Personal',
    'Work',
    'Study',
    'Health',
    'Home',
    'Finance',
    'Social',
    'Other',
  ];

  // Days of week labels
  static const List<String> daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> daysOfWeekFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}
