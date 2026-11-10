import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:focusmate/core/constants/app_constants.dart';
import 'package:focusmate/data/models/task_model.dart';
import 'package:focusmate/data/models/reminder_model.dart';
import 'package:focusmate/data/models/subtask_model.dart';
import 'package:focusmate/data/models/focus_session_model.dart';
import 'package:focusmate/data/models/routine_model.dart';
import 'package:focusmate/data/models/brain_dump_note_model.dart';

/// Singleton that opens and exposes the Isar database instance.
class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  Isar? _isar;

  /// Opens the Isar database. Safe to call multiple times.
  Future<Isar> get database async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    _isar = await _openDatabase();
    return _isar!;
  }

  Future<Isar> _openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [
        TaskModelSchema,
        ReminderModelSchema,
        SubtaskModelSchema,
        FocusSessionModelSchema,
        RoutineModelSchema,
        RoutineActivityModelSchema,
        BrainDumpNoteModelSchema,
      ],
      directory: dir.path,
      name: AppConstants.isarDbName,
    );
  }

  /// Closes the database. Only needed in tests.
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
