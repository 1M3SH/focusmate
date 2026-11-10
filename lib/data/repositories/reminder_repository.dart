import 'package:uuid/uuid.dart';
import 'package:focusmate/data/models/reminder_model.dart';
import 'package:focusmate/services/database/database_service.dart';
import 'package:focusmate/services/notification/notification_service.dart';

/// Repository for managing task reminders and scheduling notifications.
class ReminderRepository {
  ReminderRepository(this._dbService, this._notificationService);

  final DatabaseService _dbService;
  final NotificationService _notificationService;
  final _uuid = const Uuid();

  // ── Create ────────────────────────────────────────────────────────────────

  Future<ReminderModel> createReminder({
    required String taskId,
    required String taskTitle,
    required DateTime reminderDatetime,
    bool isEnabled = true,
  }) async {
    final isar = await _dbService.database;
    final notificationId =
        reminderDatetime.millisecondsSinceEpoch ~/ 1000 & 0x7FFFFFFF;

    final reminder = ReminderModel()
      ..reminderId = _uuid.v4()
      ..taskId = taskId
      ..reminderDatetime = reminderDatetime
      ..isEnabled = isEnabled
      ..notificationId = notificationId
      ..snoozeCount = 0
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.reminderModels.put(reminder);
    });

    if (isEnabled && reminderDatetime.isAfter(DateTime.now())) {
      await _notificationService.scheduleTaskReminder(
        notificationId: notificationId,
        taskTitle: taskTitle,
        scheduledAt: reminderDatetime,
        payload: taskId,
      );
    }

    return reminder;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<List<ReminderModel>> getRemindersForTask(String taskId) async {
    final isar = await _dbService.database;
    return isar.reminderModels
        .filter()
        .taskIdEqualTo(taskId)
        .sortByReminderDatetime()
        .findAll();
  }

  // ── Snooze ────────────────────────────────────────────────────────────────

  Future<void> snoozeReminder(
    String reminderId,
    String taskTitle,
    int snoozeMinutes,
  ) async {
    final isar = await _dbService.database;
    final reminder = await isar.reminderModels
        .filter()
        .reminderIdEqualTo(reminderId)
        .findFirst();
    if (reminder == null) return;

    // Cancel the old notification.
    if (reminder.notificationId != null) {
      await _notificationService
          .cancelNotification(reminder.notificationId!);
    }

    final newTime = DateTime.now().add(Duration(minutes: snoozeMinutes));
    final newNotificationId =
        newTime.millisecondsSinceEpoch ~/ 1000 & 0x7FFFFFFF;

    reminder
      ..reminderDatetime = newTime
      ..snoozeCount = reminder.snoozeCount + 1
      ..notificationId = newNotificationId;

    await isar.writeTxn(() async {
      await isar.reminderModels.put(reminder);
    });

    await _notificationService.scheduleTaskReminder(
      notificationId: newNotificationId,
      taskTitle: taskTitle,
      scheduledAt: newTime,
      payload: reminder.taskId,
    );
  }

  // ── Reschedule ────────────────────────────────────────────────────────────

  Future<void> rescheduleReminder(
    String reminderId,
    String taskTitle,
    DateTime newDatetime,
  ) async {
    final isar = await _dbService.database;
    final reminder = await isar.reminderModels
        .filter()
        .reminderIdEqualTo(reminderId)
        .findFirst();
    if (reminder == null) return;

    if (reminder.notificationId != null) {
      await _notificationService
          .cancelNotification(reminder.notificationId!);
    }

    final newNotificationId =
        newDatetime.millisecondsSinceEpoch ~/ 1000 & 0x7FFFFFFF;

    reminder
      ..reminderDatetime = newDatetime
      ..notificationId = newNotificationId;

    await isar.writeTxn(() async {
      await isar.reminderModels.put(reminder);
    });

    await _notificationService.scheduleTaskReminder(
      notificationId: newNotificationId,
      taskTitle: taskTitle,
      scheduledAt: newDatetime,
      payload: reminder.taskId,
    );
  }

  // ── Toggle ────────────────────────────────────────────────────────────────

  Future<void> toggleReminder(
    String reminderId,
    String taskTitle,
    bool enabled,
  ) async {
    final isar = await _dbService.database;
    final reminder = await isar.reminderModels
        .filter()
        .reminderIdEqualTo(reminderId)
        .findFirst();
    if (reminder == null) return;

    reminder.isEnabled = enabled;
    await isar.writeTxn(() async {
      await isar.reminderModels.put(reminder);
    });

    if (!enabled && reminder.notificationId != null) {
      await _notificationService
          .cancelNotification(reminder.notificationId!);
    } else if (enabled &&
        reminder.notificationId != null &&
        reminder.reminderDatetime.isAfter(DateTime.now())) {
      await _notificationService.scheduleTaskReminder(
        notificationId: reminder.notificationId!,
        taskTitle: taskTitle,
        scheduledAt: reminder.reminderDatetime,
        payload: reminder.taskId,
      );
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteReminder(String reminderId) async {
    final isar = await _dbService.database;
    final reminder = await isar.reminderModels
        .filter()
        .reminderIdEqualTo(reminderId)
        .findFirst();

    if (reminder?.notificationId != null) {
      await _notificationService
          .cancelNotification(reminder!.notificationId!);
    }

    await isar.writeTxn(() async {
      await isar.reminderModels
          .filter()
          .reminderIdEqualTo(reminderId)
          .deleteAll();
    });
  }

  Future<void> deleteAllRemindersForTask(String taskId) async {
    final reminders = await getRemindersForTask(taskId);
    for (final r in reminders) {
      await deleteReminder(r.reminderId);
    }
  }
}
