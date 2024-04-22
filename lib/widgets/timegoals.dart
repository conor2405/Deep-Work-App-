import 'package:deep_work/bloc/goal/goal_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeGoalsWidget extends StatefulWidget {
  @override
  _TimeGoalsWidgetState createState() => _TimeGoalsWidgetState();
}

class _TimeGoalsWidgetState extends State<TimeGoalsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state is GoalsLoaded) {
            return Container(
              child: Text(
                  'Time Goals: ${state.timeGoals.daily.goal} uid: ${state.timeGoals.uid}'),
            );
          } else if (state is GoalInitial) {
            return Container(
              child: Text('Loading...'),
            );
          } else {
            return Container(
              child: Text('Error loading time goals'),
            );
          }
          // Widget content goes here
        },
      ),
    );
  }
}
