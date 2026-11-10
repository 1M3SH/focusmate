import 'package:isar/isar.dart';

part 'task_model.g.dart';

/// Isar collection for persisting tasks locally.
@Collection()
class TaskModel {
  /// Auto-incremented Isar ID.
  Id id = Isar.autoIncrement;

  /// UUID string used as a stable external identifier.
  @Index(unique: true)
  late String taskId;

  late String userId;

  /// Mandatory task title.
  late String title;

  String? description;

  /// ISO-8601 date string (YYYY-MM-DD).
  String? scheduledDate;

  /// HH:mm 24-hour string.
  String? scheduledTime;

  /// 0 = Low, 1 = Medium, 2 = High.
  int priority = 1;

  String? category;

  /// Estimated duration in minutes.
  int? estimatedDuration;

  /// 0 = Pending, 1 = Completed, 2 = Cancelled.
  int status = 0;

  late DateTime createdAt;

  DateTime? updatedAt;

  /// Back-links to associated reminders and subtasks are handled via their
  /// own collections to keep the model flat for Isar.
}

/// Task completion status enum.
enum TaskStatus {
  pending,
  completed,
  cancelled,
}

extension TaskStatusExtension on int {
  TaskStatus get asTaskStatus {
    switch (this) {
      case 1:
        return TaskStatus.completed;
      case 2:
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }
}

/// Task priority enum.
enum TaskPriority {
  low,
  medium,
  high,
}

extension TaskPriorityExtension on int {
  TaskPriority get asTaskPriority {
    switch (this) {
      case 2:
        return TaskPriority.high;
      case 1:
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }
}
