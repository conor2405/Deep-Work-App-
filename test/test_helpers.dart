import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';

TimerResult buildTimerResult({
  required DateTime startTime,
  int timeRunSeconds = 600,
  int breakTimeSeconds = 0,
  bool completed = true,
  int? focusRating,
}) {
  return TimerResult(
    timeLeft: TimeModel(0),
    targetTime: TimeModel(timeRunSeconds),
    completed: completed,
    timeRun: timeRunSeconds,
    breakTime: breakTimeSeconds,
    timeElapsed: timeRunSeconds + breakTimeSeconds,
    startTime: startTime,
    timeFinished: startTime.add(Duration(seconds: timeRunSeconds)),
    breakEvents: const [],
    breaks: 0,
    sessionEfficiency: timeRunSeconds == 0
        ? 0
        : timeRunSeconds / (timeRunSeconds + breakTimeSeconds),
    focusRating: focusRating,
  );
}
