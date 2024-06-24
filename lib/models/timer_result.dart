import 'package:deep_work/models/time.dart';

/// TimerStats is a class that holds the state of the timer. when the timer is running.
class TimerStats {
  // all times and durations are in seconds
  late TimeModel timeLeft;
  final TimeModel targetTime;
  bool completed = false;
  final DateTime startTime = DateTime.now();
  int pauses = 0;
  List<Pause> pauseEvents = [];
  String? uid;
  int timeRun = 0;
  List<String> notes = [];

  TimerStats({
    required this.targetTime,
  }) {
    timeLeft = targetTime;
  }

  void pause() {
    pauses++;
    pauseEvents.add(Pause(startTime: DateTime.now()));
  }

  void resume() {
    pauseEvents.last.endTime = DateTime.now();
  }

  Duration get timeElapsed => DateTime.now().difference(startTime);

  int get timePaused => timeElapsed.inSeconds - timeRun;
  double get sessionEfficiency =>
      timeRun / timeElapsed.inSeconds > 1 ? 1 : timeRun / timeElapsed.inSeconds;

  set setUID(String uid) => this.uid = uid;

  void tick() {
    timeLeft = TimeModel(timeLeft.seconds - 1);
    timeRun++;
  }

  Map<String, dynamic> toJson() {
    final DateTime timeFinished = DateTime.now();
    return {
      'uid': uid,
      'timeLeft': timeLeft.seconds,
      'targetTime': targetTime.seconds,
      'completed': completed,
      'timeRun': timeRun,
      'timePaused': timePaused,
      'timeElapsed': timeElapsed.inSeconds,
      'startTime': startTime,
      'timeFinished': timeFinished,
      'pauses': pauses,
      'pauseEvents': pauseEvents.map((Pause pause) => pause.toJson()),
      'sessionEfficiency': sessionEfficiency,
      'notes': notes,
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

///  holds the result of the timer when retrieved from the database.
class TimerResult {
  final TimeModel timeLeft;
  final TimeModel targetTime;
  final bool completed;
  final int timeRun;
  final int timePaused;
  final int timeElapsed;
  final DateTime startTime;
  final DateTime timeFinished;
  final List<Pause> pauseEvents;
  final int pauses;
  final double sessionEfficiency;
  List<String> notes = [];

  TimerResult({
    required this.timeLeft,
    required this.targetTime,
    required this.completed,
    required this.timeRun,
    required this.timePaused,
    required this.timeElapsed,
    required this.startTime,
    required this.timeFinished,
    required this.pauses,
    required this.pauseEvents,
    required this.sessionEfficiency,
    this.notes = const [],
  });

  factory TimerResult.fromJson(Map<String, dynamic> json) {
    List<Pause> pauseEvents = [];
    for (Map<String, dynamic> pause in json['pauseEvents']) {
      pauseEvents.add(Pause.fromJson(pause));
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
    return TimerResult(
      timeLeft: TimeModel(json['timeLeft']),
      targetTime: TimeModel(json['targetTime']),
      completed: json['completed'],
      timeRun: json['timeRun'],
      timePaused: json['timePaused'],
      timeElapsed: json['timeElapsed'],
      startTime: DateTime.parse(json['startTime'].toDate().toString()),
      timeFinished: DateTime.parse(json['timeFinished'].toDate().toString()),
      pauses: json['pauses'],
      pauseEvents: pauseEvents,
      sessionEfficiency: sessionEfficiency,
      notes: notes,
    );
  }
}

/// holds the start and end time of a pause event.
/// strored in timerstats and timerresult as a list of [Pause] events.
class Pause {
  final DateTime startTime;
  DateTime? endTime;

  Pause({
    required this.startTime,
    this.endTime,
  });

  get timePaused => endTime!.difference(startTime).inSeconds;

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory Pause.fromJson(Map<String, dynamic> json) {
    if (json['endTime'] == null) {
      return Pause(
        startTime: DateTime.parse(json['startTime'].toDate().toString()),
      );
    }
    return Pause(
      startTime: DateTime.parse(json['startTime'].toDate().toString()),
      endTime: DateTime.parse(json['endTime'].toDate().toString()),
    );
  }
}
