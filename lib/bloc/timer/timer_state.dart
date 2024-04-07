part of 'timer_bloc.dart';

sealed class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object> get props => [];
}

final class TimerInitial extends TimerState {
  TimerInitial(this.time);

  final TimeModel time; // 90 minutes

  @override
  List<Object> get props => [time.seconds, time];
}

final class TimerRunning extends TimerState {
  final TimerStats timeModel;

  TimerRunning(this.timeModel);

  @override
  List<Object> get props => [timeModel, identityHashCode(this)];
}

final class TimerDone extends TimerState {
  TimerDone(this.completed);
  bool completed;

  @override
  List<Object> get props => [completed];
}
