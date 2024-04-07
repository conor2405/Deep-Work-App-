import 'package:deep_work/models/time.dart';

class TimerStats {
  // all times and durations are in seconds
  late TimeModel timeLeft;
  final TimeModel targetTime;
  bool completed = false;
  final DateTime startTime = DateTime.now();

  TimerStats({
    required this.targetTime,
  }) {
    timeLeft = targetTime;
  }

  Duration get timeElapsed => DateTime.now().difference(startTime);

  int get timeRun => timeElapsed.inSeconds;

  int get timePaused => timeElapsed.inSeconds - timeRun;

  void tick() {
    timeLeft = TimeModel(timeLeft.seconds - 1);
  }

  Map<String, dynamic> toJson() {
    final DateTime timeFinished = DateTime.now();
    return {
      'timeLeft': timeLeft.seconds,
      'targetTime': targetTime.seconds,
      'completed': completed,
      'timeRun': timeRun,
      'timePaused': timePaused,
      'timeElapsed': timeElapsed.inSeconds,
      'startTime': startTime,
      'timeFinished': timeFinished,
    };
  }
}
