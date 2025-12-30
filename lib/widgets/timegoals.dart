import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeGoalsWidget extends StatefulWidget {
  final String goalType;
  final bool changeableDate;
  final bool buttonEnabled;
  const TimeGoalsWidget(
      {super.key,
      this.buttonEnabled = true,
      this.goalType = 'daily',
      this.changeableDate = false});
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
            final goal = goalForType(state, widget.goalType);
            final totalMinutes = totalMinutesForType(
                state, widget.goalType, widget.changeableDate);
            final isComplete = totalMinutes >= goal.goal;

            return GestureDetector(
              onTap: widget.buttonEnabled
                  ? () {
                      Navigator.pushNamed(
                          context, goalRouteForType(widget.goalType));
                    }
                  : null,
              child: isComplete
                  ? const TimeGoalDone()
                  : TimeGoalCircle(
                      goalType: widget.goalType,
                      changeableDate: widget.changeableDate),
            );
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
  final String goalType;
  final bool changeableDate;

  const TimeGoalCircle({
    required this.goalType,
    this.changeableDate = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          final goal = goalForType(state, goalType);
          final totalMinutes =
              totalMinutesForType(state, goalType, changeableDate);
          final ratio = goal.goal == 0
              ? 0.0
              : (totalMinutes / goal.goal.toDouble()).clamp(0.0, 1.0);

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
                      value: ratio,
                      title: totalMinutes.toString(),
                      //title: null,
                    ),
                    PieChartSectionData(
                      showTitle: false,
                      radius: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                      value: (1 - ratio).clamp(0.0, 1.0),
                      // title: goalType
                    ),
                  ],
                )),
                Center(
                  child: Text(
                    '${totalMinutes ~/ 60}:${totalMinutes % 60 == 0 ? '00' : totalMinutes % 60}/${goal.goal ~/ 60}:${goal.goal % 60 == 0 ? '00' : goal.goal % 60}',
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

String goalRouteForType(String goalType) {
  switch (goalType) {
    case 'weekly':
      return '/timeGoalsPageWeekly';
    case 'monthly':
      return '/timeGoalsPageMonthly';
    case 'daily':
    default:
      return '/timeGoalsPageDaily';
  }
}

TimeGoal goalForType(LeaderboardLoaded state, String goalType) {
  switch (goalType) {
    case 'weekly':
      return state.timeGoals.weekly;
    case 'monthly':
      return state.timeGoals.monthly;
    case 'daily':
    default:
      return state.timeGoals.daily;
  }
}

int totalMinutesForType(
    LeaderboardLoaded state, String goalType, bool changeableDate) {
  switch (goalType) {
    case 'weekly':
      final weeklyTotal = changeableDate
          ? state.weeklySessions.total
          : state.weeklyScoreboard.total;
      return weeklyTotal.round();
    case 'monthly':
      return state.monthlyScoreboard.total.round();
    case 'daily':
    default:
      return changeableDate
          ? state.dailySessions.totalMinutes
          : state.todaysSessions.totalMinutes;
  }
}
