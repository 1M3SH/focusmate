import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:focusmate/core/constants/app_colors.dart';
import 'package:focusmate/core/router/app_router.dart';
import 'package:focusmate/data/models/task_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';

/// A swipeable task tile that shows priority, title, time, and category.
class TaskListTile extends ConsumerWidget {
  const TaskListTile({super.key, required this.task});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == 1;

    return Dismissible(
      key: Key('task_${task.taskId}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.check_rounded,
            color: AppColors.success, size: 28),
      ),
      confirmDismiss: (direction) async {
        if (isCompleted) {
          await ref
              .read(taskRepositoryProvider)
              .markTaskPending(task.taskId);
        } else {
          await ref
              .read(taskRepositoryProvider)
              .markTaskCompleted(task.taskId);
        }
        return false; // We handle state ourselves; don't remove from list here.
      },
      child: GestureDetector(
        onTap: () => context.push(
            AppRoutes.taskDetail.replaceAll(':id', task.taskId)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? Theme.of(context).dividerColor
                  : _priorityColor().withOpacity(0.25),
            ),
          ),
          child: Row(
            children: [
              // Priority strip
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Theme.of(context).dividerColor
                      : _priorityColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Checkbox
              GestureDetector(
                onTap: () async {
                  if (isCompleted) {
                    await ref
                        .read(taskRepositoryProvider)
                        .markTaskPending(task.taskId);
                  } else {
                    await ref
                        .read(taskRepositoryProvider)
                        .markTaskCompleted(task.taskId);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success
                          : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.4)
                                : null,
                          ),
                    ),
                    if (task.scheduledTime != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.scheduledTime!,
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
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Category chip
              if (task.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.category!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
