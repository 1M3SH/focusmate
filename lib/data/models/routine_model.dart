import 'package:isar/isar.dart';

part 'routine_model.g.dart';

/// Isar collection for recurring routines.
@Collection()
class RoutineModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String routineId;

  late String userId;
  late String routineName;

  /// Comma-separated day numbers (1=Mon … 7=Sun).
  late String repeatDays;

  bool isActive = true;

  late DateTime createdAt;
}

/// Isar collection for individual activities inside a routine.
@Collection()
class RoutineActivityModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String activityId;

  @Index()
  late String routineId;

  late String activityName;

  /// HH:mm string.
  String? scheduledTime;

  int sequenceNumber = 0;

  bool isCompleted = false;
}
