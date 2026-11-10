import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:focusmate/data/models/task_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';
import 'package:focusmate/presentation/widgets/common/priority_selector.dart';
import 'package:focusmate/presentation/widgets/common/category_selector.dart';

final _editTaskProvider =
    FutureProvider.autoDispose.family<TaskModel?, String>(
  (ref, id) =>
      ref.watch(taskRepositoryProvider).getTaskById(id),
);

class EditTaskScreen extends ConsumerStatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<EditTaskScreen> createState() =>
      _EditTaskScreenState();
}

class _EditTaskScreenState
    extends ConsumerState<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _priority = 1;
  String? _category;
  bool _loaded = false;
  bool _isSaving = false;

  void _loadTask(TaskModel task) {
    if (_loaded) return;
    _loaded = true;
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _priority = task.priority;
    _category = task.category;
    if (task.scheduledDate != null) {
      _selectedDate = DateTime.parse(task.scheduledDate!);
    }
    if (task.scheduledTime != null) {
      final parts = task.scheduledTime!.split(':');
      _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save(TaskModel original) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final dateStr = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;
      final timeStr = _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : null;

      original
        ..title = _titleController.text.trim()
        ..description =
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim()
        ..scheduledDate = dateStr
        ..scheduledTime = timeStr
        ..priority = _priority
        ..category = _category;

      await ref
          .read(taskRepositoryProvider)
          .updateTask(original);
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(_editTaskProvider(widget.taskId));

    return taskAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
      data: (task) {
        if (task == null) {
          return const Scaffold(
              body: Center(child: Text('Task not found')));
        }
        _loadTask(task);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Task'),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton(
                  onPressed: _isSaving ? null : () => _save(task),
                  child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        )
                      : const Text('Update'),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: 'Task title',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                  maxLines: null,
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Description (optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                            Icons.calendar_today_rounded,
                            size: 18),
                        label: Text(_selectedDate != null
                            ? DateFormat('d MMM')
                                .format(_selectedDate!)
                            : 'Date'),
                        onPressed: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                            Icons.access_time_rounded,
                            size: 18),
                        label: Text(_selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Time'),
                        onPressed: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrioritySelector(
                  value: _priority,
                  onChanged: (v) =>
                      setState(() => _priority = v),
                ),
                const SizedBox(height: 16),
                CategorySelector(
                  value: _category,
                  onChanged: (v) =>
                      setState(() => _category = v),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
