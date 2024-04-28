import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/widgets/timegoals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeGoalsPage extends StatefulWidget {
  String goalType;
  TimeGoalsPage({required this.goalType}) : super();

  @override
  _TimeGoalsPageState createState() => _TimeGoalsPageState();
}

class _TimeGoalsPageState extends State<TimeGoalsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Goals Page'),
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          return Container(
              alignment: Alignment.center,
              child: TimeGoalsWidget(
                buttonEnabled: false,
              ));
        },
      ),
    );
  }
}
