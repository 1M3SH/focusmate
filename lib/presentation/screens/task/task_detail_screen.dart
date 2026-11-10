import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:focusmate/core/constants/app_colors.dart';
import 'package:focusmate/core/router/app_router.dart';
import 'package:focusmate/data/models/task_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';
import 'package:focusmate/presentation/widgets/task/subtask_list.dart';

final _taskDetailProvider =
    FutureProvider.autoDispose.family<TaskModel?, String>(
  (ref, taskId) =>
      ref.watch(taskRepositoryProvider).getTaskById(taskId),
);

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(_taskDetailProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context
                .push(AppRoutes.editTask.replaceAll(':id', taskId)),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.alarm_rounded),
            onPressed: () => context.push(
                AppRoutes.reminderConfig.replaceAll(':id', taskId)),
            tooltip: 'Reminders',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: taskAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (task) {
          if (task == null) {
            return const Center(child: Text('Task not found'));
          }
          return _TaskDetailBody(task: task);
        },
      ),
    );
  }
}

class _TaskDetailBody extends ConsumerWidget {
  const _TaskDetailBody({required this.task});

  final TaskModel task;

  Color _priorityColor() {
    switch (task.priority) {
      case 2:
        return AppColors.priorityHigh;
      case 1:
        return AppColors.priorityMedium;
      default:
        return AppColors.priorityLow;
    }
  }

  String _priorityLabel() {
    switch (task.priority) {
      case 2:
        return 'High';
      case 1:
        return 'Medium';
      default:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == 1;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _priorityColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _priorityColor().withOpacity(0.4)),
              ),
              child: Text(
                _priorityLabel(),
                style: TextStyle(
                  color: _priorityColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        if (task.description != null) ...[
          const SizedBox(height: 16),
          Text(
            task.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.7),
                ),
          ),
        ],

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Meta info
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (task.scheduledDate != null)
              _MetaChip(
                icon: Icons.calendar_today_rounded,
                label: DateFormat('EEE, d MMM y')
                    .format(DateTime.parse(task.scheduledDate!)),
              ),
            if (task.scheduledTime != null)
              _MetaChip(
                icon: Icons.access_time_rounded,
                label: task.scheduledTime!,
              ),
            if (task.category != null)
              _MetaChip(
                icon: Icons.label_rounded,
                label: task.category!,
              ),
            if (task.estimatedDuration != null)
              _MetaChip(
                icon: Icons.timer_rounded,
                label: '${task.estimatedDuration} min',
              ),
          ],
        ),

        const SizedBox(height: 24),

        // Subtasks
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtasks',
                style: Theme.of(context).textTheme.headlineSmall),
            TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Breakdown'),
              onPressed: () => context.push(
                  AppRoutes.taskBreakdown
                      .replaceAll(':id', task.taskId)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SubtaskList(taskId: task.taskId),

        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.timer_rounded),
                label: const Text('Start Focus'),
                onPressed: () => context.push(
                    '${AppRoutes.focus}?taskId=${task.taskId}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: Icon(isCompleted
                    ? Icons.undo_rounded
                    : Icons.check_rounded),
                label:
                    Text(isCompleted ? 'Undo' : 'Mark Done'),
                onPressed: () async {
                  if (isCompleted) {
                    await ref
                        .read(taskRepositoryProvider)
                        .markTaskPending(task.taskId);
                  } else {
                    await ref
                        .read(taskRepositoryProvider)
                        .markTaskCompleted(task.taskId);
                  }
                  if (context.mounted) context.pop();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.6)),
          const SizedBox(width: 6),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
