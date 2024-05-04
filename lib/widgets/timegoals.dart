import 'package:deep_work/bloc/goal/goal_bloc.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeGoalsWidget extends StatefulWidget {
  bool buttonEnabled;
  TimeGoalsWidget({super.key, this.buttonEnabled = true});
  @override
  _TimeGoalsWidgetState createState() => _TimeGoalsWidgetState();
}

class _TimeGoalsWidgetState extends State<TimeGoalsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoaded) {
            return GestureDetector(
                onTap: () {
                  widget.buttonEnabled
                      ? Navigator.pushNamed(context, '/timeGoalsPageDaily')
                      : null;
                },
                child: state.todaysSessions.totalMinutes <
                        state.timeGoals.daily.goal
                    ? TimeGoalCircle(goalType: 'daily')
                    : TimeGoalDone());
          } else if (state is LeaderboardLoading) {
            return Container(
              child: CircularProgressIndicator(),
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

class TimeGoalCircle extends StatelessWidget {
  String goalType;

  TimeGoalCircle({
    required this.goalType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          TimeGoal goal;

          switch (goalType) {
            case 'daily':
              goal = state.timeGoals.daily;
              break;
            case 'weekly':
              goal = state.timeGoals.weekly;
              break;
            case 'monthly':
              goal = state.timeGoals.monthly;
              break;
            default:
              goal = state.timeGoals.daily;
          }

          return Container(
            height: 100,
            child: Stack(
              children: [
                PieChart(PieChartData(
                  centerSpaceRadius: 80,
                  sectionsSpace: 10,
                  sections: [
                    PieChartSectionData(
                      showTitle: false,
                      radius: 10,
                      color: Theme.of(context).colorScheme.primary,
                      value: state.todaysSessions.totalMinutes /
                                  goal.goal.toDouble() >
                              1
                          ? 1
                          : state.todaysSessions.totalMinutes /
                              goal.goal.toDouble(),
                      title: state.todaysSessions.totalMinutes.toString(),
                      //title: null,
                    ),
                    PieChartSectionData(
                      showTitle: false,
                      radius: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      value: 1 -
                                  state.todaysSessions.totalMinutes /
                                      goal.goal.toDouble() >
                              0
                          ? 1 -
                              state.todaysSessions.totalMinutes /
                                  goal.goal.toDouble()
                          : 0,
                      // title: goalType
                    ),
                  ],
                )),
                Center(
                  child: Text(
                    '${state.todaysSessions.totalMinutes ~/ 60}:${state.todaysSessions.totalMinutes % 60}/${goal.goal ~/ 60}:${goal.goal % 60 == 0 ? '00' : goal.goal % 60}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200),
                  ),
                ),
              ],
            ),
          );
        }
        return Container(
          child: Text('Error loading goals'),
        );
      },
    );
  }
}

class TimeGoalDone extends StatelessWidget {
  const TimeGoalDone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          PieChart(PieChartData(
            centerSpaceRadius: 60,
            sectionsSpace: 10,
            sections: [
              PieChartSectionData(
                radius: 10,
                color: Colors.green,
                value: 1,
                showTitle: false,
              ),
            ],
          )),
          Text('Done!')
        ],
      ),
    );
  }
}
