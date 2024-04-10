import 'package:deep_work/models/time.dart';

/// TimerStats is a class that holds the state of the timer.
class TimerStats {
  // all times and durations are in seconds
  late TimeModel timeLeft;
  final TimeModel targetTime;
  bool completed = false;
  final DateTime startTime = DateTime.now();
  int pauses = 0;

  TimerStats({
    required this.targetTime,
  }) {
    timeLeft = targetTime;
  }

  void pause() {
    pauses++;
  }

  Duration get timeElapsed => DateTime.now().difference(startTime);

  int get timeRun => targetTime.seconds - timeLeft.seconds;

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
      'pauses': pauses,
    };
  }

  factory TimerStats.fromJson(Map<String, dynamic> json) {
    final TimerStats timerStats = TimerStats(
      targetTime: TimeModel(json['targetTime']),
    );
    timerStats.timeLeft = TimeModel(json['timeLeft']);
    timerStats.completed = json['completed'];
    return timerStats;
  }
}

/// TimerResult is a class that holds the result of the timer when retrieved from the database.
class TimerResult {
  final TimeModel timeLeft;
  final TimeModel targetTime;
  final bool completed;
  final int timeRun;
  final int timePaused;
  final int timeElapsed;
  final DateTime startTime;
  final DateTime timeFinished;

  TimerResult({
    required this.timeLeft,
    required this.targetTime,
    required this.completed,
    required this.timeRun,
    required this.timePaused,
    required this.timeElapsed,
    required this.startTime,
    required this.timeFinished,
  });

  factory TimerResult.fromJson(Map<String, dynamic> json) {
    return TimerResult(
      timeLeft: TimeModel(json['timeLeft']),
      targetTime: TimeModel(json['targetTime']),
      completed: json['completed'],
      timeRun: json['timeRun'],
      timePaused: json['timePaused'],
      timeElapsed: json['timeElapsed'],
      startTime: DateTime.parse(json['startTime'].toDate().toString()),
      timeFinished: DateTime.parse(json['timeFinished'].toDate().toString()),
    );
  }
}
