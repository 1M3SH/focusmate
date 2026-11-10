import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:focusmate/core/constants/app_colors.dart';
import 'package:focusmate/presentation/providers/focus_timer_provider.dart';
import 'package:focusmate/presentation/providers/repository_providers.dart';

class FocusTimerScreen extends ConsumerWidget {
  const FocusTimerScreen({super.key, this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);

    // Record session when a focus phase completes.
    ref.listen<FocusTimerNotifierState>(focusTimerProvider, (prev, next) async {
      if (prev?.timerState != FocusTimerState.finished &&
          next.timerState == FocusTimerState.finished &&
          prev?.phase == FocusTimerPhase.focus) {
        await ref.read(focusSessionRepositoryProvider).startSession(
              taskId: taskId,
            );
      }
    });

    final phaseLabel = switch (timer.phase) {
      FocusTimerPhase.focus => 'Focus',
      FocusTimerPhase.shortBreak => 'Short Break',
      FocusTimerPhase.longBreak => 'Long Break',
    };

    final phaseColor = switch (timer.phase) {
      FocusTimerPhase.focus => AppColors.primary,
      FocusTimerPhase.shortBreak => AppColors.secondary,
      FocusTimerPhase.longBreak => AppColors.warning,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showSettings(context, ref, timer, notifier),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Phase label
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  phaseLabel,
                  key: ValueKey(timer.phase),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: phaseColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Session ${timer.completedSessions + 1}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.5),
                    ),
              ),
              const SizedBox(height: 48),

              // Circular progress timer
              CircularPercentIndicator(
                radius: 130,
                lineWidth: 12,
                percent: timer.progress.clamp(0.0, 1.0),
                animation: false,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: phaseColor,
                backgroundColor: phaseColor.withOpacity(0.1),
                center: Text(
                  timer.formattedTime,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                ),
              ),

              const SizedBox(height: 48),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stop button (shown when running or paused)
                  if (timer.timerState != FocusTimerState.idle) ...[
                    IconButton.outlined(
                      onPressed: notifier.stop,
                      icon: const Icon(Icons.stop_rounded),
                      tooltip: 'Stop',
                    ),
                    const SizedBox(width: 24),
                  ],

                  // Main action button
                  FilledButton.icon(
                    onPressed: switch (timer.timerState) {
                      FocusTimerState.idle => notifier.start,
                      FocusTimerState.running => notifier.pause,
                      FocusTimerState.paused => notifier.resume,
                      FocusTimerState.finished => notifier.start,
                    },
                    icon: Icon(switch (timer.timerState) {
                      FocusTimerState.idle =>
                        Icons.play_arrow_rounded,
                      FocusTimerState.running =>
                        Icons.pause_rounded,
                      FocusTimerState.paused =>
                        Icons.play_arrow_rounded,
                      FocusTimerState.finished =>
                        Icons.play_arrow_rounded,
                    }),
                    label: Text(switch (timer.timerState) {
                      FocusTimerState.idle => 'Start',
                      FocusTimerState.running => 'Pause',
                      FocusTimerState.paused => 'Resume',
                      FocusTimerState.finished => 'Next',
                    }),
                    style: FilledButton.styleFrom(
                      backgroundColor: phaseColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Session dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < timer.completedSessions % 4
                          ? phaseColor
                          : phaseColor.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings(
    BuildContext context,
    WidgetRef ref,
    FocusTimerNotifierState state,
    FocusTimerNotifier notifier,
  ) {
    int focus = state.focusDuration;
    int shortBreak = state.breakDuration;
    int longBreak = state.longBreakDuration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Timer Settings',
                    style:
                        Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                _DurationSlider(
                  label: 'Focus duration',
                  value: focus,
                  min: 5,
                  max: 60,
                  onChanged: (v) => setModalState(() => focus = v),
                ),
                _DurationSlider(
                  label: 'Short break',
                  value: shortBreak,
                  min: 1,
                  max: 15,
                  onChanged: (v) =>
                      setModalState(() => shortBreak = v),
                ),
                _DurationSlider(
                  label: 'Long break',
                  value: longBreak,
                  min: 5,
                  max: 30,
                  onChanged: (v) =>
                      setModalState(() => longBreak = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      notifier.configure(
                        focusDuration: focus,
                        breakDuration: shortBreak,
                        longBreakDuration: longBreak,
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.titleMedium),
            Text('$value min',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (v) => onChanged(v.round()),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
