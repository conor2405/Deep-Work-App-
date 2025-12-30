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

final class TimerStop extends TimerEnd {
  TimerStop() : super();
}

final class TimerAddFive extends TimerEvent {
  TimerAddFive();
}

final class TimerTakeFive extends TimerEvent {
  TimerTakeFive();
}

final class TimerStartBreak extends TimerEvent {
  final TimeModel duration;

  TimerStartBreak(this.duration);
}

final class TimerEndBreak extends TimerEvent {
  TimerEndBreak();
}

final class TimerBreakAddFive extends TimerEvent {
  TimerBreakAddFive();
}

final class TimerBreakTakeFive extends TimerEvent {
  TimerBreakTakeFive();
}

final class TimerConfirm extends TimerEvent {
  TimerConfirm();
}

final class TimerSetNotes extends TimerEvent {
  final String notes;

  TimerSetNotes(this.notes);
}

final class TimerSubmitNotes extends TimerEvent {
  TimerSubmitNotes();
}
