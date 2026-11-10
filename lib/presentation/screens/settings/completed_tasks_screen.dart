import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusmate/presentation/providers/task_provider.dart';
import 'package:focusmate/presentation/widgets/task/task_list_tile.dart';

class CompletedTasksScreen extends ConsumerWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(completedTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Completed Tasks')),
      body: tasksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 56,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text(
                    'No completed tasks yet',
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
            itemCount: tasks.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                TaskListTile(task: tasks[i]),
          );
        },
      ),
    );
  }
}
