part of 'timer_bloc.dart';

sealed class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object> get props => [];
}

final class TimerInitial extends TimerState {
  const TimerInitial();

  @override
  List<Object> get props => [];
}

final class TimerRunning extends TimerState {
  final int duration;

  TimerRunning(this.duration);

  @override
  List<Object> get props => [duration];
}

final class TimerDone extends TimerState {
  TimerDone(this.completed);
  bool completed;

  @override
  List<Object> get props => [completed];
}
