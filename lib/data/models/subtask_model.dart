import 'package:isar/isar.dart';

part 'subtask_model.g.dart';

/// Isar collection for subtasks (task breakdown items).
@Collection()
class SubtaskModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String subtaskId;

  @Index()
  late String taskId;

  late String title;

  bool isCompleted = false;

  int sequenceNumber = 0;

  late DateTime createdAt;
}
