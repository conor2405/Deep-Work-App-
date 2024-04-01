import 'package:deep_work/bloc/ToDo/to_do_bloc.dart';
import 'package:flutter/material.dart';
import 'package:deep_work/models/goal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoList extends StatelessWidget {
  final List<Goal> goals;

  TodoList({required this.goals});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ToDoBloc(),
      child: ListView.builder(
        itemCount: goals.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(goals[index].name),
            children: [
              ListTile(
                title: Text(goals[index].tasks[0].name),
              ),
              // Add more widgets here if needed
            ],
          );
        },
      ),
    );
  }
}
