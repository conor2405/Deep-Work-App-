import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeeklyScoreboard extends StatefulWidget {
  @override
  _WeeklyScoreboardState createState() => _WeeklyScoreboardState();
}

class _WeeklyScoreboardState extends State<WeeklyScoreboard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LeaderboardLoaded) {
          return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                  child: BarChart(BarChartData(
                minY: 0,
                maxY: state.weeklyScoreboard.maxDay.toDouble() * 1.1,
                titlesData: FlTitlesData(),
                barGroups: List.generate(7, (index) {
                  final dayOfWeek = index + 1;
                  final dailyScore =
                      state.weeklyScoreboard.getDayofWeek(dayOfWeek);

                  return BarChartGroupData(x: dayOfWeek, barRods: [
                    BarChartRodData(
                      toY: dailyScore.toDouble(),
                      width: 22,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ]);
                }),
              )))); // ToDo: implement toBarChartData
        } else {
          return Container(child: Text('Error loading leaderboard'));
        }
      },
    );
  }
}
