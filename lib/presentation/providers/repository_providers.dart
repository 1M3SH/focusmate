import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusmate/services/database/database_service.dart';
import 'package:focusmate/services/notification/notification_service.dart';
import 'package:focusmate/data/repositories/task_repository.dart';
import 'package:focusmate/data/repositories/reminder_repository.dart';
import 'package:focusmate/data/repositories/subtask_repository.dart';
import 'package:focusmate/data/repositories/routine_repository.dart';
import 'package:focusmate/data/repositories/focus_session_repository.dart';
import 'package:focusmate/data/repositories/brain_dump_repository.dart';

// ── Services ──────────────────────────────────────────────────────────────────

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

// ── Repositories ──────────────────────────────────────────────────────────────

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(databaseServiceProvider)),
);

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(
    ref.watch(databaseServiceProvider),
    ref.watch(notificationServiceProvider),
  ),
);

final subtaskRepositoryProvider = Provider<SubtaskRepository>(
  (ref) => SubtaskRepository(ref.watch(databaseServiceProvider)),
);

final routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => RoutineRepository(ref.watch(databaseServiceProvider)),
);

final focusSessionRepositoryProvider =
    Provider<FocusSessionRepository>(
  (ref) => FocusSessionRepository(ref.watch(databaseServiceProvider)),
);

final brainDumpRepositoryProvider = Provider<BrainDumpRepository>(
  (ref) => BrainDumpRepository(ref.watch(databaseServiceProvider)),
);
