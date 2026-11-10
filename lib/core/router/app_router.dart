import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:focusmate/presentation/screens/splash/splash_screen.dart';
import 'package:focusmate/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:focusmate/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:focusmate/presentation/screens/task/add_task_screen.dart';
import 'package:focusmate/presentation/screens/task/edit_task_screen.dart';
import 'package:focusmate/presentation/screens/task/task_detail_screen.dart';
import 'package:focusmate/presentation/screens/reminder/reminder_config_screen.dart';
import 'package:focusmate/presentation/screens/task/task_breakdown_screen.dart';
import 'package:focusmate/presentation/screens/calendar/calendar_screen.dart';
import 'package:focusmate/presentation/screens/focus/focus_timer_screen.dart';
import 'package:focusmate/presentation/screens/routine/routine_screen.dart';
import 'package:focusmate/presentation/screens/braindump/brain_dump_screen.dart';
import 'package:focusmate/presentation/screens/settings/settings_screen.dart';
import 'package:focusmate/presentation/screens/settings/completed_tasks_screen.dart';

/// Named route constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String addTask = '/task/add';
  static const String editTask = '/task/edit/:id';
  static const String taskDetail = '/task/:id';
  static const String reminderConfig = '/task/:id/reminder';
  static const String taskBreakdown = '/task/:id/breakdown';
  static const String calendar = '/calendar';
  static const String focus = '/focus';
  static const String routines = '/routines';
  static const String brainDump = '/braindump';
  static const String settings = '/settings';
  static const String completedTasks = '/completed';
}

/// Application router built with GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Shell route wraps the main bottom-nav screens.
    ShellRoute(
      builder: (context, state, child) =>
          _MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          name: 'calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: AppRoutes.focus,
          name: 'focus',
          builder: (context, state) => const FocusTimerScreen(),
        ),
        GoRoute(
          path: AppRoutes.brainDump,
          name: 'brainDump',
          builder: (context, state) => const BrainDumpScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.addTask,
      name: 'addTask',
      builder: (context, state) => const AddTaskScreen(),
    ),
    GoRoute(
      path: AppRoutes.editTask,
      name: 'editTask',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return EditTaskScreen(taskId: taskId);
      },
    ),
    GoRoute(
      path: AppRoutes.taskDetail,
      name: 'taskDetail',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return TaskDetailScreen(taskId: taskId);
      },
    ),
    GoRoute(
      path: AppRoutes.reminderConfig,
      name: 'reminderConfig',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return ReminderConfigScreen(taskId: taskId);
      },
    ),
    GoRoute(
      path: AppRoutes.taskBreakdown,
      name: 'taskBreakdown',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return TaskBreakdownScreen(taskId: taskId);
      },
    ),
    GoRoute(
      path: AppRoutes.routines,
      name: 'routines',
      builder: (context, state) => const RoutineScreen(),
    ),
    GoRoute(
      path: AppRoutes.completedTasks,
      name: 'completedTasks',
      builder: (context, state) => const CompletedTasksScreen(),
    ),
  ],
);

/// Bottom navigation shell widget.
class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    final items = [
      (icon: Icons.home_rounded, label: 'Home', route: AppRoutes.home),
      (
        icon: Icons.calendar_month_rounded,
        label: 'Calendar',
        route: AppRoutes.calendar
      ),
      (
        icon: Icons.timer_rounded,
        label: 'Focus',
        route: AppRoutes.focus
      ),
      (
        icon: Icons.lightbulb_rounded,
        label: 'Brain Dump',
        route: AppRoutes.brainDump
      ),
      (
        icon: Icons.person_rounded,
        label: 'Profile',
        route: AppRoutes.settings
      ),
    ];

    int currentIndex = items.indexWhere((e) => location.startsWith(e.route));
    if (currentIndex < 0) currentIndex = 0;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => context.go(items[index].route),
      items: items
          .map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              label: e.label,
            ),
          )
          .toList(),
    );
  }
}
