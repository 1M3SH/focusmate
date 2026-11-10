import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusmate/data/models/subtask_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';

final _subtasksProvider = FutureProvider.autoDispose
    .family<List<SubtaskModel>, String>((ref, taskId) {
  return ref.watch(subtaskRepositoryProvider).getSubtasksForTask(taskId);
});

class TaskBreakdownScreen extends ConsumerStatefulWidget {
  const TaskBreakdownScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskBreakdownScreen> createState() =>
      _TaskBreakdownScreenState();
}

class _TaskBreakdownScreenState
    extends ConsumerState<TaskBreakdownScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  Future<void> _addSubtask() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(subtaskRepositoryProvider).createSubtask(
            taskId: widget.taskId,
            title: text,
          );
      _controller.clear();
      ref.invalidate(_subtasksProvider(widget.taskId));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggle(String subtaskId) async {
    await ref.read(subtaskRepositoryProvider).toggleSubtask(subtaskId);
    ref.invalidate(_subtasksProvider(widget.taskId));
  }

  Future<void> _delete(String subtaskId) async {
    await ref
        .read(subtaskRepositoryProvider)
        .deleteSubtask(subtaskId);
    ref.invalidate(_subtasksProvider(widget.taskId));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtasksAsync =
        ref.watch(_subtasksProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Breakdown'),
      ),
      body: Column(
        children: [
          Expanded(
            child: subtasksAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (subtasks) {
                if (subtasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.format_list_bulleted_rounded,
                          size: 56,
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Break this task into steps',
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

                // Progress header
                final done =
                    subtasks.where((s) => s.isCompleted).length;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: subtasks.isEmpty
                                ? 0
                                : done / subtasks.length,
                            minHeight: 8,
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$done / ${subtasks.length}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...subtasks.map(
                      (s) => _SubtaskTile(
                        subtask: s,
                        onToggle: () => _toggle(s.subtaskId),
                        onDelete: () => _delete(s.subtaskId),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Add subtask input
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Add a step...',
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSaving ? null : _addSubtask,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtaskTile extends StatelessWidget {
  const _SubtaskTile({
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  final SubtaskModel subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: subtask.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          subtask.title,
          style: TextStyle(
            decoration: subtask.isCompleted
                ? TextDecoration.lineThrough
                : null,
            color: subtask.isCompleted
                ? Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4)
                : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onDelete,
          tooltip: 'Delete step',
        ),
      ),
    );
  }
}
