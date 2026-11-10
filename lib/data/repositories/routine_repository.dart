import 'package:uuid/uuid.dart';
import 'package:focusmate/data/models/routine_model.dart';
import 'package:focusmate/services/database/database_service.dart';

/// Repository for routine and routine-activity CRUD operations.
class RoutineRepository {
  RoutineRepository(this._dbService);

  final DatabaseService _dbService;
  final _uuid = const Uuid();

  // ── Routines ──────────────────────────────────────────────────────────────

  Future<RoutineModel> createRoutine({
    required String userId,
    required String name,
    required List<int> repeatDays,
    bool isActive = true,
  }) async {
    final isar = await _dbService.database;
    final routine = RoutineModel()
      ..routineId = _uuid.v4()
      ..userId = userId
      ..routineName = name
      ..repeatDays = repeatDays.join(',')
      ..isActive = isActive
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.routineModels.put(routine);
    });
    return routine;
  }

  Future<List<RoutineModel>> getRoutinesForUser(String userId) async {
    final isar = await _dbService.database;
    return isar.routineModels
        .filter()
        .userIdEqualTo(userId)
        .sortByCreatedAt()
        .findAll();
  }

  Future<RoutineModel?> getRoutineById(String routineId) async {
    final isar = await _dbService.database;
    return isar.routineModels
        .filter()
        .routineIdEqualTo(routineId)
        .findFirst();
  }

  Future<RoutineModel> updateRoutine(RoutineModel routine) async {
    final isar = await _dbService.database;
    await isar.writeTxn(() async {
      await isar.routineModels.put(routine);
    });
    return routine;
  }

  Future<void> toggleRoutine(String routineId, bool isActive) async {
    final isar = await _dbService.database;
    final routine = await getRoutineById(routineId);
    if (routine == null) return;
    routine.isActive = isActive;
    await isar.writeTxn(() async {
      await isar.routineModels.put(routine);
    });
  }

  Future<void> deleteRoutine(String routineId) async {
    final isar = await _dbService.database;
    await isar.writeTxn(() async {
      await isar.routineModels
          .filter()
          .routineIdEqualTo(routineId)
          .deleteAll();
      await isar.routineActivityModels
          .filter()
          .routineIdEqualTo(routineId)
          .deleteAll();
    });
  }

  // ── Activities ────────────────────────────────────────────────────────────

  Future<RoutineActivityModel> addActivity({
    required String routineId,
    required String name,
    String? scheduledTime,
  }) async {
    final isar = await _dbService.database;
    final existing = await getActivitiesForRoutine(routineId);

    final activity = RoutineActivityModel()
      ..activityId = _uuid.v4()
      ..routineId = routineId
      ..activityName = name
      ..scheduledTime = scheduledTime
      ..sequenceNumber = existing.length
      ..isCompleted = false;

    await isar.writeTxn(() async {
      await isar.routineActivityModels.put(activity);
    });
    return activity;
  }

  Future<List<RoutineActivityModel>> getActivitiesForRoutine(
      String routineId) async {
    final isar = await _dbService.database;
    return isar.routineActivityModels
        .filter()
        .routineIdEqualTo(routineId)
        .sortBySequenceNumber()
        .findAll();
  }

  Future<void> toggleActivity(String activityId) async {
    final isar = await _dbService.database;
    final activity = await isar.routineActivityModels
        .filter()
        .activityIdEqualTo(activityId)
        .findFirst();
    if (activity == null) return;
    activity.isCompleted = !activity.isCompleted;
    await isar.writeTxn(() async {
      await isar.routineActivityModels.put(activity);
    });
  }

  Future<void> deleteActivity(String activityId) async {
    final isar = await _dbService.database;
    await isar.writeTxn(() async {
      await isar.routineActivityModels
          .filter()
          .activityIdEqualTo(activityId)
          .deleteAll();
    });
  }
}
