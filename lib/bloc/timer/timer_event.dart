part of 'timer_bloc.dart';

sealed class TimerEvent {}

final class TimerStart extends TimerEvent {
  final int duration;

  TimerStart(this.duration);
}

final class TimerEnd extends TimerEvent {
  TimerEnd();
}
