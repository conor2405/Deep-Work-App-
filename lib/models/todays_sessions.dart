import 'package:deep_work/models/timer_result.dart';

class TodaysSessions {
  final List<TimerResult> sessions;

  int get total => sessions.fold(
      0,
      (int previousValue, TimerResult element) =>
          previousValue + element.timeRun);

  int get totalMinutes => total ~/ 60;

  TodaysSessions({required this.sessions});

  factory TodaysSessions.fromTimerResultToday(List<TimerResult> timerResults) {
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

  factory TodaysSessions.fromTimerResult(
      List<TimerResult> timerResults, DateTime startDate, DateTime endDate) {
    List<TimerResult> today = [];

    today.addAll(timerResults
        .where((TimerResult timerResult) =>
            timerResult.timeFinished
                .copyWith(
                  hour: 0,
                  minute: 0,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0,
                )
                .isAfter(startDate) &&
            timerResult.timeFinished
                .copyWith(
                  hour: 0,
                  minute: 0,
                  second: 0,
                  millisecond: 0,
                  microsecond: 0,
                )
                .isBefore(endDate))
        .toList());
    return TodaysSessions(sessions: today);
  }
}
