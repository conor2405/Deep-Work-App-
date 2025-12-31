import 'package:deep_work/models/time.dart';

/// TimerStats is a class that holds the state of the timer. when the timer is running.
class TimerStats {
  // all times and durations are in seconds
  late TimeModel timeLeft;
  final TimeModel targetTime;
  TimeModel breakTimeLeft = TimeModel.zero();
  TimeModel breakTargetTime = TimeModel.zero();
  bool completed = false;
  final DateTime startTime = DateTime.now();
  int breaks = 0;
  int breakTime = 0;
  List<BreakPeriod> breakEvents = [];
  String? uid;
  int timeRun = 0;
  List<String> notes = [];
  int? focusRating;

  TimerStats({
    required this.targetTime,
  }) {
    timeLeft = targetTime;
  }

  void startBreak(TimeModel duration) {
    breaks++;
    breakTargetTime = TimeModel(duration.seconds);
    breakTimeLeft = TimeModel(duration.seconds);
    breakEvents.add(BreakPeriod(startTime: DateTime.now()));
  }

  void endBreak() {
    if (breakEvents.isNotEmpty && breakEvents.last.endTime == null) {
      breakEvents.last.endTime = DateTime.now();
    }
  }

  Duration get timeElapsed => DateTime.now().difference(startTime);

  double get sessionEfficiency =>
      timeRun / timeElapsed.inSeconds > 1 ? 1 : timeRun / timeElapsed.inSeconds;

  set setUID(String uid) => this.uid = uid;

  void tick() {
    timeLeft = TimeModel(timeLeft.seconds - 1);
    timeRun++;
  }

  void tickBreak() {
    breakTimeLeft = TimeModel(breakTimeLeft.seconds - 1);
    breakTime++;
  }

  Map<String, dynamic> toJson() {
    final DateTime timeFinished = DateTime.now();
    return {
      'uid': uid,
      'timeLeft': timeLeft.seconds,
      'targetTime': targetTime.seconds,
      'completed': completed,
      'timeRun': timeRun,
      'breakTime': breakTime,
      'timeElapsed': timeElapsed.inSeconds,
      'startTime': startTime,
      'timeFinished': timeFinished,
      'breaks': breaks,
      'breakEvents':
          breakEvents.map((BreakPeriod breakEvent) => breakEvent.toJson()).toList(),
      'sessionEfficiency': sessionEfficiency,
      'notes': notes,
      if (focusRating != null) 'focusRating': focusRating,
    };
  }

  factory TimerStats.fromJson(Map<String, dynamic> json) {
    final TimerStats timerStats = TimerStats(
      targetTime: TimeModel(json['targetTime']),
    );
    timerStats.timeLeft = TimeModel(json['timeLeft']);
    timerStats.completed = json['completed'];
    if (json.containsKey('breakTime')) {
      timerStats.breakTime = json['breakTime'];
    }
    if (json.containsKey('breaks')) {
      timerStats.breaks = json['breaks'];
    }
    if (json.containsKey('breakEvents')) {
      final breakEvents = json['breakEvents'] as List<dynamic>;
      timerStats.breakEvents = breakEvents
          .map((event) => BreakPeriod.fromJson(event as Map<String, dynamic>))
          .toList();
    }
    if (json.containsKey('focusRating')) {
      timerStats.focusRating = json['focusRating'] as int?;
    }
    return timerStats;
  }
}

///  holds the result of the timer when retrieved from the database.
class TimerResult {
  final TimeModel timeLeft;
  final TimeModel targetTime;
  final bool completed;
  final int timeRun;
  final int breakTime;
  final int timeElapsed;
  final DateTime startTime;
  final DateTime timeFinished;
  final List<BreakPeriod> breakEvents;
  final int breaks;
  final double sessionEfficiency;
  List<String> notes = [];
  final int? focusRating;

  TimerResult({
    required this.timeLeft,
    required this.targetTime,
    required this.completed,
    required this.timeRun,
    this.breakTime = 0,
    required this.timeElapsed,
    required this.startTime,
    required this.timeFinished,
    this.breakEvents = const [],
    this.breaks = 0,
    required this.sessionEfficiency,
    this.notes = const [],
    this.focusRating,
  });

  factory TimerResult.fromJson(Map<String, dynamic> json) {
    List<BreakPeriod> breakEvents = [];
    if (json.containsKey('breakEvents')) {
      for (Map<String, dynamic> breakEvent in json['breakEvents']) {
        breakEvents.add(BreakPeriod.fromJson(breakEvent));
      }
    }
    double sessionEfficiency = 1;
    if (json.containsKey('sessionEfficiency')) {
      sessionEfficiency = json['sessionEfficiency'];
    }
    List<String> notes = [];
    if (json.containsKey('notes')) {
      json['notes'].forEach((note) {
        notes.add(note);
      });
    }
    final int? focusRating = json['focusRating'] as int?;
    return TimerResult(
      timeLeft: TimeModel(json['timeLeft']),
      targetTime: TimeModel(json['targetTime']),
      completed: json['completed'],
      timeRun: json['timeRun'],
      breakTime: json['breakTime'] ?? 0,
      timeElapsed: json['timeElapsed'],
      startTime: DateTime.parse(json['startTime'].toDate().toString()),
      timeFinished: DateTime.parse(json['timeFinished'].toDate().toString()),
      breaks: json['breaks'] ?? breakEvents.length,
      breakEvents: breakEvents,
      sessionEfficiency: sessionEfficiency,
      notes: notes,
      focusRating: focusRating,
    );
  }
}

/// holds the start and end time of a break event.
class BreakPeriod {
  final DateTime startTime;
  DateTime? endTime;

  BreakPeriod({
    required this.startTime,
    this.endTime,
  });

  int get timeOnBreak =>
      endTime == null ? 0 : endTime!.difference(startTime).inSeconds;

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory BreakPeriod.fromJson(Map<String, dynamic> json) {
    if (json['endTime'] == null) {
      return BreakPeriod(
        startTime: DateTime.parse(json['startTime'].toDate().toString()),
      );
    }
    return BreakPeriod(
      startTime: DateTime.parse(json['startTime'].toDate().toString()),
      endTime: DateTime.parse(json['endTime'].toDate().toString()),
    );
  }
}
