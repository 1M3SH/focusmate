import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:focusmate/data/models/task_model.dart';
import 'package:focusmate/services/database/database_service.dart';

/// Repository for CRUD operations on [TaskModel].
class TaskRepository {
  TaskRepository(this._dbService);

  final DatabaseService _dbService;
  final _uuid = const Uuid();

  // ── Create ────────────────────────────────────────────────────────────────

  Future<TaskModel> createTask({
    required String userId,
    required String title,
    String? description,
    String? scheduledDate,
    String? scheduledTime,
    int priority = 1,
    String? category,
    int? estimatedDuration,
  }) async {
    final isar = await _dbService.database;
    final task = TaskModel()
      ..taskId = _uuid.v4()
      ..userId = userId
      ..title = title
      ..description = description
      ..scheduledDate = scheduledDate
      ..scheduledTime = scheduledTime
      ..priority = priority
      ..category = category
      ..estimatedDuration = estimatedDuration
      ..status = 0
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });
    return task;
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<TaskModel?> getTaskById(String taskId) async {
    final isar = await _dbService.database;
    return isar.taskModels.filter().taskIdEqualTo(taskId).findFirst();
  }

  Future<List<TaskModel>> getAllTasks(String userId) async {
    final isar = await _dbService.database;
    return isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<TaskModel>> getTasksByDate(
      String userId, String date) async {
    final isar = await _dbService.database;
    return isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .scheduledDateEqualTo(date)
        .findAll();
  }

  Future<List<TaskModel>> getPendingTasks(String userId) async {
    final isar = await _dbService.database;
    return isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .statusEqualTo(0)
        .sortByScheduledDate()
        .findAll();
  }

  Future<List<TaskModel>> getCompletedTasks(String userId) async {
    final isar = await _dbService.database;
    return isar.taskModels
        .filter()
        .userIdEqualTo(userId)
        .statusEqualTo(1)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<TaskModel> updateTask(TaskModel task) async {
    final isar = await _dbService.database;
    task.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });
    return task;
  }

  Future<void> markTaskCompleted(String taskId) async {
    final isar = await _dbService.database;
    final task = await getTaskById(taskId);
    if (task != null) {
      task.status = 1;
      task.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.taskModels.put(task);
      });
    }
  }

  Future<void> markTaskPending(String taskId) async {
    final isar = await _dbService.database;
    final task = await getTaskById(taskId);
    if (task != null) {
      task.status = 0;
      task.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.taskModels.put(task);
      });
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteTask(String taskId) async {
    final isar = await _dbService.database;
    await isar.writeTxn(() async {
      await isar.taskModels.filter().taskIdEqualTo(taskId).deleteAll();
    });
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  /// Returns [completed, total] counts for today.
  Future<(int, int)> getDailyProgress(
      String userId, String date) async {
    final all = await getTasksByDate(userId, date);
    final completed = all.where((t) => t.status == 1).length;
    return (completed, all.length);
  }
}
