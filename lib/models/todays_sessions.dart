import 'package:deep_work/models/timer_result.dart';
import 'package:equatable/equatable.dart';

class TodaysSessions {
  final List<TimerResult> sessions;

  int get total => sessions.fold(
      0,
      (int previousValue, TimerResult element) =>
          previousValue + element.timeRun);

  int get totalMinutes => total ~/ 60;

  TodaysSessions({required this.sessions});

  factory TodaysSessions.fromTimerResultToday(List<TimerResult> timerResults,
      {DateTime? referenceDate}) {
    final DateTime now = referenceDate ?? DateTime.now();
    List<TimerResult> today = [];

    today.addAll(timerResults
        .where((TimerResult timerResult) =>
            timerResult.startTime.copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0,
            ) ==
            now.copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0,
            ))
        .toList());
    return TodaysSessions(sessions: today);
  }

  factory TodaysSessions.fromTimerResult(List<TimerResult> timerResults,
      {required DateTime date}) {
    List<TimerResult> today = [];

    today.addAll(timerResults
        .where((TimerResult timerResult) =>
            timerResult.startTime.isAfter(
                date.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0)) &&
            timerResult.startTime.isBefore(date.copyWith(
                hour: 23, minute: 59, second: 59, millisecond: 900)))
        .toList());
    return TodaysSessions(sessions: today);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TodaysSessions &&
        sessions == other.sessions &&
        total == other.total;
  }
}
