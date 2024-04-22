import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphicWeeklyChart extends StatefulWidget {
  @override
  _GraphicWeeklyChartState createState() => _GraphicWeeklyChartState();
}

class _GraphicWeeklyChartState extends State<GraphicWeeklyChart> {
  @override
  Widget build(BuildContext context) {
    return Container(child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          return BarChart(BarChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style =
                              TextStyle(color: Colors.white, fontSize: 10);
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Mon';
                              break;
                            case 1:
                              text = 'Tue';
                              break;
                            case 2:
                              text = 'Wed';
                              break;
                            case 3:
                              text = 'Thu';
                              break;
                            case 4:
                              text = 'Fri';
                              break;
                            case 5:
                              text = 'Sat';
                              break;
                            case 6:
                              text = 'Sun';
                              break;
                            default:
                              text = '';
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(text, style: style),
                          );
                        })),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style =
                              TextStyle(color: Colors.white, fontSize: 10);

                          return Text((value.toInt()).toString());
                        },
                        interval: 30)),
              ),
              barGroups: <BarChartGroupData>[
                BarChartGroupData(x: 0, barRods: [
                  BarChartRodData(
                    toY: state.weeklyScoreboard.monday,
                    color: Theme.of(context).colorScheme.primary,
                  )
                ]),
                BarChartGroupData(x: 1, barRods: [
                  BarChartRodData(
                      toY: state.weeklyScoreboard.tuesday,
                      color: Theme.of(context).colorScheme.primary),
                ]),
                BarChartGroupData(x: 2, barRods: [
                  BarChartRodData(
                      toY: state.weeklyScoreboard.wednesday,
                      color: Theme.of(context).colorScheme.primary),
                ]),
                BarChartGroupData(x: 3, barRods: [
                  BarChartRodData(
                      toY: state.weeklyScoreboard.thursday,
                      color: Theme.of(context).colorScheme.primary),
                ]),
                BarChartGroupData(x: 4, barRods: [
                  BarChartRodData(
                      toY: state.weeklyScoreboard.friday,
                      color: Theme.of(context).colorScheme.primary),
                ]),
                BarChartGroupData(x: 5, barRods: [
                  BarChartRodData(
                      toY: state.weeklyScoreboard.saturday,
                      color: Theme.of(context).colorScheme.primary),
                ]),
                BarChartGroupData(x: 6, barRods: [
                  BarChartRodData(
                      toY: state.weeklyScoreboard.sunday,
                      color: Theme.of(context).colorScheme.primary),
                ]),
              ]));
        } else if (state is LeaderboardLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Container(child: Text('Error loading leaderboard'));
        }
      },
    ));
  }
}
