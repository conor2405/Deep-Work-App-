part of 'timer_bloc.dart';

sealed class TimerEvent {}

final class TimerStart extends TimerEvent {
  TimerStart();
}

final class TimerEnd extends TimerEvent {
  TimerEnd();
}

final class TimerReset extends TimerEvent {
  TimerReset();
}

final class TimeUpdate extends TimerEvent {
  final TimeModel time;

  TimeUpdate(this.time);
}

final class Tick extends TimerEvent {
  int counter;
  Tick(this.counter);

  @override
  List<Object> get props => [counter];
}
