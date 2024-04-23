import 'package:deep_work/bloc/goal/goal_bloc.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
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
      child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoaded) {
            return GestureDetector(
                child: state.todaysSessions.total < state.timeGoals.daily.goal
                    ? TimeGoalCircle()
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
  const TimeGoalCircle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          return Container(
            height: 100,
            child: PieChart(PieChartData(
              centerSpaceRadius: 80,
              sectionsSpace: 10,
              sections: [
                PieChartSectionData(
                  radius: 10,
                  color: Theme.of(context).colorScheme.primary,
                  value: state.todaysSessions.total /
                              state.timeGoals.daily.goal.toDouble() >
                          1
                      ? 1
                      : state.todaysSessions.total /
                          state.timeGoals.daily.goal.toDouble(),
                  title: state.todaysSessions.total.toString(),
                ),
                PieChartSectionData(
                    showTitle: false,
                    radius: 10,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0),
                    value: 1 -
                                state.todaysSessions.total /
                                    state.timeGoals.daily.goal.toDouble() >
                            0
                        ? 1 -
                            state.todaysSessions.total /
                                state.timeGoals.daily.goal.toDouble()
                        : 0,
                    title: state.timeGoals.daily.type),
              ],
            )),
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
