import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusmate/data/models/subtask_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';

final _subtaskListProvider = FutureProvider.autoDispose
    .family<List<SubtaskModel>, String>((ref, taskId) {
  return ref
      .watch(subtaskRepositoryProvider)
      .getSubtasksForTask(taskId);
});

/// Renders a compact subtask list inside the task detail screen.
class SubtaskList extends ConsumerWidget {
  const SubtaskList({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(_subtaskListProvider(taskId));

    return subtasksAsync.when(
      loading: () => const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e'),
      data: (subtasks) {
        if (subtasks.isEmpty) {
          return Text(
            'No steps added yet',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                ),
          );
        }

        return Column(
          children: subtasks
              .map(
                (s) => CheckboxListTile(
                  value: s.isCompleted,
                  onChanged: (_) async {
                    await ref
                        .read(subtaskRepositoryProvider)
                        .toggleSubtask(s.subtaskId);
                    ref.invalidate(_subtaskListProvider(taskId));
                  },
                  title: Text(
                    s.title,
                    style: TextStyle(
                      decoration: s.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: s.isCompleted
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4)
                          : null,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
