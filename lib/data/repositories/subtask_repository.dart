import 'package:uuid/uuid.dart';
import 'package:focusmate/data/models/subtask_model.dart';
import 'package:focusmate/services/database/database_service.dart';

/// Repository for subtask CRUD operations.
class SubtaskRepository {
  SubtaskRepository(this._dbService);

  final DatabaseService _dbService;
  final _uuid = const Uuid();

  Future<SubtaskModel> createSubtask({
    required String taskId,
    required String title,
    int? sequenceNumber,
  }) async {
    final isar = await _dbService.database;
    final existing = await getSubtasksForTask(taskId);
    final seq = sequenceNumber ?? existing.length;

    final subtask = SubtaskModel()
      ..subtaskId = _uuid.v4()
      ..taskId = taskId
      ..title = title
      ..isCompleted = false
      ..sequenceNumber = seq
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.subtaskModels.put(subtask);
    });
    return subtask;
  }

  Future<List<SubtaskModel>> getSubtasksForTask(String taskId) async {
    final isar = await _dbService.database;
    return isar.subtaskModels
        .filter()
        .taskIdEqualTo(taskId)
        .sortBySequenceNumber()
        .findAll();
  }

  Future<void> toggleSubtask(String subtaskId) async {
    final isar = await _dbService.database;
    final subtask = await isar.subtaskModels
        .filter()
        .subtaskIdEqualTo(subtaskId)
        .findFirst();
    if (subtask == null) return;

    subtask.isCompleted = !subtask.isCompleted;
    await isar.writeTxn(() async {
      await isar.subtaskModels.put(subtask);
    });
  }

  Future<SubtaskModel> updateSubtask(SubtaskModel subtask) async {
    final isar = await _dbService.database;
    await isar.writeTxn(() async {
      await isar.subtaskModels.put(subtask);
    });
    return subtask;
  }

  Future<void> deleteSubtask(String subtaskId) async {
    final isar = await _dbService.database;
    await isar.writeTxn(() async {
      await isar.subtaskModels
          .filter()
          .subtaskIdEqualTo(subtaskId)
          .deleteAll();
    });
  }

  /// Returns (completedCount, totalCount).
  Future<(int, int)> getSubtaskProgress(String taskId) async {
    final subtasks = await getSubtasksForTask(taskId);
    final completed = subtasks.where((s) => s.isCompleted).length;
    return (completed, subtasks.length);
  }
}
