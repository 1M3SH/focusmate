import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:focusmate/core/constants/app_constants.dart';
import 'package:focusmate/data/models/reminder_model.dart';
import 'package:focusmate/data/models/task_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';

final _remindersProvider = FutureProvider.autoDispose
    .family<List<ReminderModel>, String>((ref, taskId) {
  return ref
      .watch(reminderRepositoryProvider)
      .getRemindersForTask(taskId);
});

final _taskForReminderProvider =
    FutureProvider.autoDispose.family<TaskModel?, String>(
  (ref, taskId) =>
      ref.watch(taskRepositoryProvider).getTaskById(taskId),
);

class ReminderConfigScreen extends ConsumerWidget {
  const ReminderConfigScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(_remindersProvider(taskId));
    final taskAsync = ref.watch(_taskForReminderProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add reminder',
            onPressed: () => _addReminder(context, ref,
                taskAsync.valueOrNull?.title ?? 'Task'),
          ),
        ],
      ),
      body: remindersAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.alarm_off_rounded, size: 56),
                  const SizedBox(height: 12),
                  Text('No reminders set',
                      style:
                          Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Reminder'),
                    onPressed: () => _addReminder(
                        context,
                        ref,
                        taskAsync.valueOrNull?.title ?? 'Task'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _ReminderTile(
              reminder: reminders[i],
              taskTitle:
                  taskAsync.valueOrNull?.title ?? 'Task',
              onDelete: () async {
                await ref
                    .read(reminderRepositoryProvider)
                    .deleteReminder(reminders[i].reminderId);
                ref.invalidate(_remindersProvider(taskId));
              },
              onSnooze: (minutes) async {
                await ref
                    .read(reminderRepositoryProvider)
                    .snoozeReminder(
                      reminders[i].reminderId,
                      taskAsync.valueOrNull?.title ?? 'Task',
                      minutes,
                    );
                ref.invalidate(_remindersProvider(taskId));
              },
              onToggle: (enabled) async {
                await ref
                    .read(reminderRepositoryProvider)
                    .toggleReminder(
                      reminders[i].reminderId,
                      taskAsync.valueOrNull?.title ?? 'Task',
                      enabled,
                    );
                ref.invalidate(_remindersProvider(taskId));
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _addReminder(
      BuildContext context, WidgetRef ref, String taskTitle) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final scheduled = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);

    await ref.read(reminderRepositoryProvider).createReminder(
          taskId: taskId,
          taskTitle: taskTitle,
          reminderDatetime: scheduled,
        );
    ref.invalidate(_remindersProvider(taskId));
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.taskTitle,
    required this.onDelete,
    required this.onSnooze,
    required this.onToggle,
  });

  final ReminderModel reminder;
  final String taskTitle;
  final VoidCallback onDelete;
  final ValueChanged<int> onSnooze;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM y  HH:mm');
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.alarm_rounded,
          color: reminder.isEnabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.4),
        ),
        title: Text(fmt.format(reminder.reminderDatetime)),
        subtitle: reminder.snoozeCount > 0
            ? Text('Snoozed ${reminder.snoozeCount}×')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: reminder.isEnabled,
              onChanged: onToggle,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'snooze5':
                    onSnooze(AppConstants.snooze5Min);
                  case 'snooze10':
                    onSnooze(AppConstants.snooze10Min);
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: 'snooze5', child: Text('Snooze 5 min')),
                PopupMenuItem(
                    value: 'snooze10',
                    child: Text('Snooze 10 min')),
                PopupMenuDivider(),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(
                            color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
