import 'package:isar/isar.dart';

part 'brain_dump_note_model.g.dart';

/// Isar collection for quick-capture brain-dump notes.
@Collection()
class BrainDumpNoteModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String noteId;

  late String userId;

  late String content;

  late DateTime createdAt;

  DateTime? updatedAt;

  /// Set when the note has been converted to a full task.
  String? convertedTaskId;
}
