import 'package:deep_work/models/timer_result.dart';

class TodaysSessions {
  final List<TimerResult> sessions;

  int get total => sessions.fold(
      0,
      (int previousValue, TimerResult element) =>
          previousValue + element.timeRun);

  TodaysSessions({required this.sessions});

  factory TodaysSessions.fromTimerResult(List<TimerResult> timerResults) {
    List<TimerResult> today = [];

    today.addAll(timerResults
        .where((TimerResult timerResult) =>
            timerResult.timeFinished.copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0,
            ) ==
            DateTime.now().copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0,
            ))
        .toList());
    return TodaysSessions(sessions: today);
  }
}
