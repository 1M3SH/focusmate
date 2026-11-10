import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:focusmate/core/constants/app_constants.dart';

/// Service responsible for scheduling and managing local notifications.
///
/// Call [initialise] once during app startup before using any other methods.
class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialised = false;

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> initialise() async {
    if (_initialised) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android.
    await _createChannels();

    _initialised = true;
  }

  Future<void> _createChannels() async {
    const taskChannel = AndroidNotificationChannel(
      AppConstants.taskReminderChannelId,
      AppConstants.taskReminderChannelName,
      description: 'Notifications for task reminders',
      importance: Importance.high,
    );
    const focusChannel = AndroidNotificationChannel(
      AppConstants.focusTimerChannelId,
      AppConstants.focusTimerChannelName,
      description: 'Notifications for focus timer sessions',
      importance: Importance.high,
    );
    const routineChannel = AndroidNotificationChannel(
      AppConstants.routineChannelId,
      AppConstants.routineChannelName,
      description: 'Notifications for daily routines',
      importance: Importance.defaultImportance,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(taskChannel);
    await androidPlugin?.createNotificationChannel(focusChannel);
    await androidPlugin?.createNotificationChannel(routineChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigation on tap is handled by the app via deep links in production.
    debugPrint(
        'Notification tapped: id=${response.id}, payload=${response.payload}');
  }

  // ── Task Reminders ────────────────────────────────────────────────────────

  /// Schedule an exact one-time reminder notification.
  Future<void> scheduleTaskReminder({
    required int notificationId,
    required String taskTitle,
    required DateTime scheduledAt,
    String? body,
    String? payload,
  }) async {
    final tzScheduled =
        tz.TZDateTime.from(scheduledAt, tz.local);

    await _plugin.zonedSchedule(
      notificationId,
      taskTitle,
      body ?? 'Your task reminder is here.',
      tzScheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.taskReminderChannelId,
          AppConstants.taskReminderChannelName,
          importance: Importance.high,
          priority: Priority.high,
          actions: [
            const AndroidNotificationAction('snooze', 'Snooze 10 min'),
            const AndroidNotificationAction('done', 'Mark Done'),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'task_reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Cancel a previously scheduled notification by its ID.
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ── Focus Timer ───────────────────────────────────────────────────────────

  /// Show an immediate notification when a focus session ends.
  Future<void> showFocusSessionComplete({
    required int notificationId,
    required String message,
  }) async {
    await _plugin.show(
      notificationId,
      'Focus session complete 🎉',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.focusTimerChannelId,
          AppConstants.focusTimerChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final iosResult = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    final androidResult =
        await android?.requestNotificationsPermission();

    return (iosResult ?? true) && (androidResult ?? true);
  }

  // ── Pending Notifications ─────────────────────────────────────────────────

  Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }
}
