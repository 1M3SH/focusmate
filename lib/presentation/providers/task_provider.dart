import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusmate/data/models/task_model.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';
import 'package:focusmate/presentation/providers/user_provider.dart';

/// Provides the list of all tasks for the current user.
final allTasksProvider =
    FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(taskRepositoryProvider).getAllTasks(userId);
});

/// Provides tasks scheduled for a specific date (YYYY-MM-DD).
final tasksByDateProvider = FutureProvider.autoDispose
    .family<List<TaskModel>, String>((ref, date) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(taskRepositoryProvider).getTasksByDate(userId, date);
});

/// Provides today's pending tasks.
final todayPendingTasksProvider =
    FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final today = _todayString();
  return ref.watch(taskRepositoryProvider).getTasksByDate(userId, today);
});

/// Provides completed tasks.
final completedTasksProvider =
    FutureProvider.autoDispose<List<TaskModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(taskRepositoryProvider).getCompletedTasks(userId);
});

/// Daily progress: (completed, total).
final dailyProgressProvider =
    FutureProvider.autoDispose<(int, int)>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return (0, 0);
  return ref
      .watch(taskRepositoryProvider)
      .getDailyProgress(userId, _todayString());
});

String _todayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
