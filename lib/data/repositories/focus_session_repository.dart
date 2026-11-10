import 'package:uuid/uuid.dart';
import 'package:focusmate/data/models/focus_session_model.dart';
import 'package:focusmate/services/database/database_service.dart';

/// Repository for recording and querying focus sessions.
class FocusSessionRepository {
  FocusSessionRepository(this._dbService);

  final DatabaseService _dbService;
  final _uuid = const Uuid();

  Future<FocusSessionModel> startSession({String? taskId}) async {
    final isar = await _dbService.database;
    final session = FocusSessionModel()
      ..sessionId = _uuid.v4()
      ..taskId = taskId
      ..startTime = DateTime.now()
      ..status = 1 // in-progress
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.focusSessionModels.put(session);
    });
    return session;
  }

  Future<FocusSessionModel> completeSession(
      String sessionId, bool interrupted) async {
    final isar = await _dbService.database;
    final session = await isar.focusSessionModels
        .filter()
        .sessionIdEqualTo(sessionId)
        .findFirst();
    if (session == null) throw Exception('Session not found: $sessionId');

    final end = DateTime.now();
    session
      ..endTime = end
      ..duration = end
          .difference(session.startTime)
          .inMinutes
      ..status = interrupted ? 1 : 0;

    await isar.writeTxn(() async {
      await isar.focusSessionModels.put(session);
    });
    return session;
  }

  Future<List<FocusSessionModel>> getSessionsForTask(
      String taskId) async {
    final isar = await _dbService.database;
    return isar.focusSessionModels
        .filter()
        .taskIdEqualTo(taskId)
        .sortByStartTimeDesc()
        .findAll();
  }

  Future<List<FocusSessionModel>> getRecentSessions(
      {int limit = 20}) async {
    final isar = await _dbService.database;
    return isar.focusSessionModels
        .filter()
        .statusEqualTo(0) // completed
        .sortByStartTimeDesc()
        .limit(limit)
        .findAll();
  }

  /// Total focus minutes for a given day (YYYY-MM-DD).
  Future<int> getTotalFocusMinutesForDay(String date) async {
    final isar = await _dbService.database;
    final startOfDay = DateTime.parse('${date}T00:00:00');
    final endOfDay = DateTime.parse('${date}T23:59:59');
    final sessions = await isar.focusSessionModels
        .filter()
        .startTimeGreaterThan(startOfDay)
        .startTimeLessThan(endOfDay)
        .statusEqualTo(0)
        .findAll();
    return sessions.fold<int>(
        0, (sum, s) => sum + (s.duration ?? 0));
  }
}
