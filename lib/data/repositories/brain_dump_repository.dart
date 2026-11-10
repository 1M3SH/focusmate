import 'package:uuid/uuid.dart';
import 'package:focusmate/data/models/brain_dump_note_model.dart';
import 'package:focusmate/services/database/database_service.dart';

/// Repository for Brain Dump note CRUD operations.
class BrainDumpRepository {
  BrainDumpRepository(this._dbService);

  final DatabaseService _dbService;
  final _uuid = const Uuid();

  Future<BrainDumpNoteModel> createNote({
    required String userId,
    required String content,
  }) async {
    final isar = await _dbService.database;
    final note = BrainDumpNoteModel()
      ..noteId = _uuid.v4()
      ..userId = userId
      ..content = content
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.brainDumpNoteModels.put(note);
    });
    return note;
  }

  Future<List<BrainDumpNoteModel>> getAllNotes(String userId) async {
    final isar = await _dbService.database;
    return isar.brainDumpNoteModels
        .filter()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<BrainDumpNoteModel?> getNoteById(String noteId) async {
    final isar = await _dbService.database;
    return isar.brainDumpNoteModels
        .filter()
        .noteIdEqualTo(noteId)
        .findFirst();
  }

  Future<BrainDumpNoteModel> updateNote(
      String noteId, String content) async {
    final isar = await _dbService.database;
    final note = await getNoteById(noteId);
    if (note == null) throw Exception('Note not found: $noteId');

    note
      ..content = content
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.brainDumpNoteModels.put(note);
    });
    return note;
  }

  Future<void> deleteNote(String noteId) async {
    final isar = await _dbService.database;
    await isar.writeTxn(() async {
      await isar.brainDumpNoteModels
          .filter()
          .noteIdEqualTo(noteId)
          .deleteAll();
    });
  }

  /// Mark a note as converted to a task.
  Future<void> markAsConverted(
      String noteId, String taskId) async {
    final isar = await _dbService.database;
    final note = await getNoteById(noteId);
    if (note == null) return;

    note.convertedTaskId = taskId;
    await isar.writeTxn(() async {
      await isar.brainDumpNoteModels.put(note);
    });
  }
}
