import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:focusmate/presentation/providers/task_provider.dart';
import 'package:focusmate/presentation/widgets/task/task_list_tile.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() =>
      _CalendarScreenState();
}

class _CalendarScreenState
    extends ConsumerState<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();

  String get _selectedDateStr {
    return DateFormat('yyyy-MM-dd').format(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync =
        ref.watch(tasksByDateProvider(_selectedDateStr));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          // Simple week strip
          _WeekStrip(
            selectedDay: _selectedDay,
            onDaySelected: (d) =>
                setState(() => _selectedDay = d),
          ),
          const Divider(height: 1),
          Expanded(
            child: tasksAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks on this day',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.4),
                          ),
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
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatefulWidget {
  const _WeekStrip({
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  late PageController _pageController;
  late int _currentWeekOffset;

  static DateTime _startOfWeek(DateTime d) {
    return d.subtract(Duration(days: d.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _currentWeekOffset = 0;
    _pageController = PageController(initialPage: 500);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() => _currentWeekOffset = page - 500);
        },
        itemBuilder: (context, page) {
          final weekOffset = page - 500;
          final weekStart = _startOfWeek(DateTime.now())
              .add(Duration(days: weekOffset * 7));
          return Row(
            children: List.generate(7, (i) {
              final day =
                  weekStart.add(Duration(days: i));
              final isSelected = DateFormat('yyyy-MM-dd')
                      .format(day) ==
                  DateFormat('yyyy-MM-dd')
                      .format(widget.selectedDay);
              final isToday = DateFormat('yyyy-MM-dd')
                      .format(day) ==
                  DateFormat('yyyy-MM-dd')
                      .format(DateTime.now());

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onDaySelected(day),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                          : isToday
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(day),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
