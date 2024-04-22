import 'package:firebase_auth/firebase_auth.dart';

class Goal {
  int id;
  String name;
  DateTime? dueDate;
  String uid;
  List<Task> tasks;
  User user;

  Goal({
    required this.id,
    required this.name,
    this.dueDate,
    required this.uid,
    required this.tasks,
    required this.user,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      dueDate: map['dueDate'],
      uid: map['uid'],
      tasks: map['tasks'],
      user: map['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dueDate': dueDate,
      'uid': uid,
      'tasks': tasks,
      'user': user,
    };
  }
}

class Task {
  int id;
  String name;
  DateTime? dueDate;
  String uid;
  User user;

  Task({
    required this.id,
    required this.name,
    this.dueDate,
    required this.uid,
    required this.user,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      dueDate: map['dueDate'],
      uid: map['uid'],
      user: map['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dueDate': dueDate,
      'uid': uid,
      'user': user,
    };
  }
}

class TimeGoalsAll {
  TimeGoal daily = TimeGoal(type: 'daily', goal: 0, completed: 0);

  TimeGoal weekly = TimeGoal(type: 'weekly', goal: 0, completed: 0);
  TimeGoal monthly = TimeGoal(type: 'monthly', goal: 0, completed: 0);
  TimeGoal yearly = TimeGoal(type: 'yearly', goal: 0, completed: 0);
  String? uid;

  set setDaily(TimeGoal daily) => this.daily = daily;
  set setWeekly(TimeGoal weekly) => this.weekly = weekly;
  set setMonthly(TimeGoal monthly) => this.monthly = monthly;
  set setYearly(TimeGoal yearly) => this.yearly = yearly;

  set setUID(String uid) => this.uid = uid;

  TimeGoalsAll() {
    if (daily.type != 'daily') {
      throw ArgumentError('daily goal type must be daily');
    }
    if (weekly.type != 'weekly') {
      throw ArgumentError('weekly goal type must be weekly');
    }
    if (monthly.type != 'monthly') {
      throw ArgumentError('monthly goal type must be monthly');
    }
    if (yearly.type != 'yearly') {
      throw ArgumentError('yearly goal type must be yearly');
    }
  }

  factory TimeGoalsAll.fromJson(Map<String, dynamic> json) {
    TimeGoalsAll timeGoalsAll = TimeGoalsAll();

    timeGoalsAll.setDaily = TimeGoal.fromJson(json['daily']);
    timeGoalsAll.setWeekly = TimeGoal.fromJson(json['weekly']);
    timeGoalsAll.setMonthly = TimeGoal.fromJson(json['monthly']);
    timeGoalsAll.setYearly = TimeGoal.fromJson(json['yearly']);
    if (json['uid'] != null) {
      timeGoalsAll.setUID = json['uid'];
    }

    return timeGoalsAll;
  }

  Map<String, dynamic> toJson() {
    return {
      'daily': daily.toJson(),
      'weekly': weekly.toJson(),
      'monthly': monthly.toJson(),
      'yearly': yearly.toJson(),
      'uid': uid,
    };
  }
}

class TimeGoal {
  String type;
  int goal;
  int? completed;

  DateTime? timeSet;

  TimeGoal({
    required this.type,
    required this.goal,
    this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'goal': goal,
      'completed': completed,
    };
  }

  factory TimeGoal.fromJson(Map<String, dynamic> json) {
    return TimeGoal(
      type: json['type'],
      goal: json['goal'],
      completed: json['completed'],
    );
  }
}
