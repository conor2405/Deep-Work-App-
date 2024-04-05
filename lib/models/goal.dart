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
