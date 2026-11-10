import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:focusmate/core/constants/app_colors.dart';
import 'package:focusmate/core/router/app_router.dart';
import 'package:focusmate/data/models/brain_dump_note_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';
import 'package:focusmate/presentation/providers/user_provider.dart';

final _notesProvider =
    FutureProvider.autoDispose<List<BrainDumpNoteModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider) ?? 'local_user';
  return ref.watch(brainDumpRepositoryProvider).getAllNotes(userId);
});

class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  ConsumerState<BrainDumpScreen> createState() =>
      _BrainDumpScreenState();
}

class _BrainDumpScreenState
    extends ConsumerState<BrainDumpScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final userId =
          ref.read(currentUserIdProvider) ?? 'local_user';
      await ref
          .read(brainDumpRepositoryProvider)
          .createNote(userId: userId, content: text);
      _controller.clear();
      ref.invalidate(_notesProvider);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteNote(String noteId) async {
    await ref
        .read(brainDumpRepositoryProvider)
        .deleteNote(noteId);
    ref.invalidate(_notesProvider);
  }

  Future<void> _convertToTask(BrainDumpNoteModel note) async {
    // Navigate to add task with pre-filled title.
    context.push(
      AppRoutes.addTask,
      extra: {'title': note.content, 'noteId': note.noteId},
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(_notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Dump'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.lightbulb_rounded, size: 16),
              label: notesAsync.when(
                data: (n) => Text('${n.length}'),
                loading: () => const Text('…'),
                error: (_, __) => const Text('?'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick capture field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization:
                        TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText:
                          'What\'s on your mind? Just type it…',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSaving ? null : _saveNote,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(),

          // Notes list
          Expanded(
            child: notesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
              data: (notes) {
                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 56,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your thoughts will appear here',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.4),
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, i) => _NoteCard(
                    note: notes[i],
                    onDelete: () => _deleteNote(notes[i].noteId),
                    onConvert: () => _convertToTask(notes[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onDelete,
    required this.onConvert,
  });

  final BrainDumpNoteModel note;
  final VoidCallback onDelete;
  final VoidCallback onConvert;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM, HH:mm');
    final isConverted = note.convertedTaskId != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'convert') onConvert();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    if (!isConverted)
                      const PopupMenuItem(
                        value: 'convert',
                        child: ListTile(
                          leading:
                              Icon(Icons.add_task_rounded),
                          title: Text('Convert to task'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red),
                        title: Text('Delete',
                            style: TextStyle(
                                color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  fmt.format(note.createdAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                      ),
                ),
                if (isConverted) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Converted',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
