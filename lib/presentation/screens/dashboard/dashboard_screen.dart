import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:focusmate/core/constants/app_colors.dart';
import 'package:focusmate/core/router/app_router.dart';
import 'package:focusmate/data/models/task_model.dart';
import 'package:focusmate/presentation/providers/task_provider.dart';
import 'package:focusmate/presentation/widgets/dashboard/daily_progress_card.dart';
import 'package:focusmate/presentation/widgets/task/task_list_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = ref.watch(todayPendingTasksProvider);
    final progressAsync = ref.watch(dailyProgressProvider);

    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, d MMMM').format(now);
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting 👋',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.6),
                      ),
                ),
                Text(dateLabel,
                    style:
                        Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {},
                tooltip: 'Search',
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Progress card
                progressAsync.when(
                  data: (progress) => DailyProgressCard(
                    completed: progress.$1,
                    total: progress.$2,
                  ),
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(
                        child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Today's tasks section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style:
                          Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () =>
                          context.go(AppRoutes.calendar),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                todayTasks.when(
                  data: (tasks) => tasks.isEmpty
                      ? _EmptyTasksPlaceholder()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) =>
                              TaskListTile(task: tasks[i]),
                        ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Text('Error: $e'),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addTask),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _EmptyTasksPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 56,
            color: Theme.of(context)
                .colorScheme
                .onBackground
                .withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks for today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.4),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first task',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.3),
                ),
          ),
        ],
      ),
    );
  }
}
