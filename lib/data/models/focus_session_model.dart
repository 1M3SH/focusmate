import 'package:isar/isar.dart';

part 'focus_session_model.g.dart';

/// Isar collection for recorded focus sessions.
@Collection()
class FocusSessionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String sessionId;

  /// Optional link to a task.
  @Index()
  String? taskId;

  late DateTime startTime;

  DateTime? endTime;

  /// Duration in minutes.
  int? duration;

  /// 0 = completed, 1 = interrupted.
  int status = 0;

  late DateTime createdAt;
}

enum FocusSessionStatus {
  completed,
  interrupted,
}
