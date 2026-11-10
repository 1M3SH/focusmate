import 'package:isar/isar.dart';

part 'reminder_model.g.dart';

/// Isar collection for task reminders.
@Collection()
class ReminderModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String reminderId;

  /// The [TaskModel.taskId] this reminder belongs to.
  @Index()
  late String taskId;

  /// The scheduled date and time for this notification.
  late DateTime reminderDatetime;

  /// Whether the reminder is active.
  bool isEnabled = true;

  /// The ID registered with flutter_local_notifications.
  int? notificationId;

  /// How many times this reminder has been snoozed.
  int snoozeCount = 0;

  late DateTime createdAt;
}
