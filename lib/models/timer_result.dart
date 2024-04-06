class TimerStats {
  // all times and durations are in seconds
  int duration = 0;
  final int targetTime;
  bool completed = false;
  final DateTime startTime;

  TimerStats({
    required this.targetTime,
    required this.startTime,
    this.completed = false,
  });

  set setDuration(int duration) {
    this.duration = duration;
    if (duration >= targetTime) {
      completed = true;
    }
  }

  int get remainingTime => targetTime - duration;

  factory TimerStats.fromMap(Map<String, dynamic> map) {
    return TimerStats(
      targetTime: map['targetTime'],
      completed: map['completed'],
      startTime: map['startTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'targetTime': targetTime,
      'completed': completed,
      'startTime': startTime,
    };
  }
}
