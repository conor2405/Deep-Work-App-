import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';

TimerResult buildTimerResult({
  required DateTime startTime,
  int timeRunSeconds = 600,
  int timePausedSeconds = 0,
  List<Pause> pauseEvents = const [],
  bool completed = true,
}) {
  return TimerResult(
    timeLeft: TimeModel(0),
    targetTime: TimeModel(timeRunSeconds),
    completed: completed,
    timeRun: timeRunSeconds,
    timePaused: timePausedSeconds,
    timeElapsed: timeRunSeconds + timePausedSeconds,
    startTime: startTime,
    timeFinished: startTime.add(Duration(seconds: timeRunSeconds)),
    pauses: pauseEvents.length,
    pauseEvents: pauseEvents,
    sessionEfficiency: timeRunSeconds == 0
        ? 0
        : timeRunSeconds / (timeRunSeconds + timePausedSeconds),
  );
}
