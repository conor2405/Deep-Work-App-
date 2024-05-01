import 'package:deep_work/bloc/goal/goal_bloc.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/models/goal.dart';
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
  String selectedHour = '00';
  String selectedMinute = '00';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Goals Page'),
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  DropdownButton<String>(
                    value: selectedHour,
                    items: List.generate(10, (index) {
                      return DropdownMenuItem(
                        value: index < 10 ? '0$index' : index.toString(),
                        child: Text(index < 10 ? '0$index' : index.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedHour = value!;
                      });
                    },
                  ),
                  Text(':'),
                  DropdownButton<String>(
                    value: selectedMinute,
                    items: List.generate(60, (index) {
                      return DropdownMenuItem(
                        value: index < 10 ? '0$index' : index.toString(),
                        child: Text(index < 10 ? '0$index' : index.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        selectedMinute = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<GoalBloc>(context).add(SetTimeGoal(TimeGoal(
                      goal: int.parse(selectedHour) * 60 +
                          int.parse(selectedMinute),
                      type: widget.goalType,
                    )));
                  },
                  child: Text('Set Goal')),
              Container(
                  alignment: Alignment.center,
                  child: TimeGoalsWidget(
                    buttonEnabled: false,
                  )),
            ],
          );
        },
      ),
    );
  }
}
