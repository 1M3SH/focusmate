import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusmate/core/constants/app_constants.dart';

enum FocusTimerPhase { focus, shortBreak, longBreak }

enum FocusTimerState { idle, running, paused, finished }

/// State object for the focus timer.
class FocusTimerNotifierState {
  const FocusTimerNotifierState({
    this.phase = FocusTimerPhase.focus,
    this.timerState = FocusTimerState.idle,
    this.focusDuration = AppConstants.defaultFocusDuration,
    this.breakDuration = AppConstants.defaultBreakDuration,
    this.longBreakDuration = AppConstants.defaultLongBreakDuration,
    this.secondsRemaining = AppConstants.defaultFocusDuration * 60,
    this.completedSessions = 0,
    this.taskId,
  });

  final FocusTimerPhase phase;
  final FocusTimerState timerState;
  final int focusDuration;
  final int breakDuration;
  final int longBreakDuration;
  final int secondsRemaining;
  final int completedSessions;
  final String? taskId;

  FocusTimerNotifierState copyWith({
    FocusTimerPhase? phase,
    FocusTimerState? timerState,
    int? focusDuration,
    int? breakDuration,
    int? longBreakDuration,
    int? secondsRemaining,
    int? completedSessions,
    String? taskId,
  }) {
    return FocusTimerNotifierState(
      phase: phase ?? this.phase,
      timerState: timerState ?? this.timerState,
      focusDuration: focusDuration ?? this.focusDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      completedSessions: completedSessions ?? this.completedSessions,
      taskId: taskId ?? this.taskId,
    );
  }

  String get formattedTime {
    final m = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get progress {
    final total = _totalSeconds;
    if (total == 0) return 0;
    return 1.0 - (secondsRemaining / total);
  }

  int get _totalSeconds {
    switch (phase) {
      case FocusTimerPhase.focus:
        return focusDuration * 60;
      case FocusTimerPhase.shortBreak:
        return breakDuration * 60;
      case FocusTimerPhase.longBreak:
        return longBreakDuration * 60;
    }
  }
}

/// Riverpod [StateNotifier] for the focus timer.
class FocusTimerNotifier
    extends StateNotifier<FocusTimerNotifierState> {
  FocusTimerNotifier() : super(const FocusTimerNotifierState());

  Timer? _timer;

  void configure({
    int? focusDuration,
    int? breakDuration,
    int? longBreakDuration,
    String? taskId,
  }) {
    state = state.copyWith(
      focusDuration: focusDuration,
      breakDuration: breakDuration,
      longBreakDuration: longBreakDuration,
      taskId: taskId,
      secondsRemaining:
          (focusDuration ?? state.focusDuration) * 60,
    );
  }

  void start() {
    if (state.timerState == FocusTimerState.running) return;
    state = state.copyWith(timerState: FocusTimerState.running);
    _startTick();
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(timerState: FocusTimerState.paused);
  }

  void resume() {
    if (state.timerState != FocusTimerState.paused) return;
    state = state.copyWith(timerState: FocusTimerState.running);
    _startTick();
  }

  void stop() {
    _timer?.cancel();
    state = FocusTimerNotifierState(
      focusDuration: state.focusDuration,
      breakDuration: state.breakDuration,
      longBreakDuration: state.longBreakDuration,
    );
  }

  void _startTick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining <= 0) {
        _onPhaseComplete();
      } else {
        state = state.copyWith(
            secondsRemaining: state.secondsRemaining - 1);
      }
    });
  }

  void _onPhaseComplete() {
    _timer?.cancel();
    if (state.phase == FocusTimerPhase.focus) {
      final sessions = state.completedSessions + 1;
      final nextPhase = sessions % AppConstants.sessionsBeforeLongBreak ==
              0
          ? FocusTimerPhase.longBreak
          : FocusTimerPhase.shortBreak;
      final nextSeconds = nextPhase == FocusTimerPhase.longBreak
          ? state.longBreakDuration * 60
          : state.breakDuration * 60;
      state = state.copyWith(
        phase: nextPhase,
        timerState: FocusTimerState.finished,
        completedSessions: sessions,
        secondsRemaining: nextSeconds,
      );
    } else {
      // Break over – back to focus.
      state = state.copyWith(
        phase: FocusTimerPhase.focus,
        timerState: FocusTimerState.finished,
        secondsRemaining: state.focusDuration * 60,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerNotifierState>(
  (ref) => FocusTimerNotifier(),
);
