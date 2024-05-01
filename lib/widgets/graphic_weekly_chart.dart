import 'dart:math';

import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
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
          return Stack(children: [
            BarChart(BarChartData(
                minY: 0,
                maxY: (max<double>(state.weeklyScoreboard.total,
                            state.LastWeekScoreboard.total)
                        .toDouble() *
                    1.1),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
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
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      axisNameWidget: Text('Minutes',
                          style: TextStyle(color: Colors.white, fontSize: 10)),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style =
                              TextStyle(color: Colors.white, fontSize: 10);

                          return Text((value.toInt()).toString());
                        },
                        interval: (max<double>(state.weeklyScoreboard.total,
                                        state.LastWeekScoreboard.total)
                                    .toDouble() *
                                1.1) /
                            4,
                      )),
                ),
                barGroups: <BarChartGroupData>[
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                      toY: state.weeklyScoreboard.monday,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    BarChartRodData(
                        toY: state.LastWeekScoreboard.monday,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.5),
                        borderDashArray: [5, 5],
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                            width: 1,
                            style: BorderStyle.values[1])),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: state.weeklyScoreboard.tuesday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: state.LastWeekScoreboard.tuesday,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.5),
                        borderDashArray: [5, 5],
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                            width: 1,
                            style: BorderStyle.values[1])),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: state.weeklyScoreboard.wednesday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: state.LastWeekScoreboard.wednesday,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.5),
                        borderDashArray: [5, 5],
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                            width: 1,
                            style: BorderStyle.values[1])),
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(
                        toY: state.weeklyScoreboard.thursday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: state.LastWeekScoreboard.thursday,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.5),
                        borderDashArray: [5, 5],
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                            width: 1,
                            style: BorderStyle.values[1])),
                  ]),
                  BarChartGroupData(x: 4, barRods: [
                    BarChartRodData(
                        toY: state.weeklyScoreboard.friday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: state.LastWeekScoreboard.friday,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.5),
                        borderDashArray: [5, 5],
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                            width: 1,
                            style: BorderStyle.values[1])),
                  ]),
                  BarChartGroupData(x: 5, barRods: [
                    BarChartRodData(
                        toY: state.weeklyScoreboard.saturday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: state.LastWeekScoreboard.saturday,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.5),
                        borderDashArray: [5, 5],
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                            width: 1,
                            style: BorderStyle.values[1]))
                  ]),
                  BarChartGroupData(x: 6, barRods: [
                    BarChartRodData(
                        toY: state.weeklyScoreboard.sunday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: state.LastWeekScoreboard.sunday,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.5),
                        borderDashArray: [5, 5],
                        borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.5),
                            width: 1,
                            style: BorderStyle.values[1]))
                  ]),
                ])),
            Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 0, 30),
              child: LineChart(LineChartData(
                minY: 0,
                maxY: (max<double>(state.weeklyScoreboard.total,
                            state.LastWeekScoreboard.total)
                        .toDouble() *
                    1.1),
                minX: 0,
                maxX: 8,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.5),
                      dashArray: [
                        10,
                        5
                      ],
                      spots: [
                        FlSpot(1, state.LastWeekScoreboard.mondayCumulative),
                        FlSpot(2, state.LastWeekScoreboard.tuesdayCumulative),
                        FlSpot(3, state.LastWeekScoreboard.wednesdayCumulative),
                        FlSpot(4, state.LastWeekScoreboard.thursdayCumulative),
                        FlSpot(5, state.LastWeekScoreboard.fridayCumulative),
                        FlSpot(6, state.LastWeekScoreboard.saturdayCumulative),
                        FlSpot(7, state.LastWeekScoreboard.sundayCumulative),
                      ]),
                  thisWeekLineData(state.weeklyScoreboard, context),
                ],
              )),
            ),
          ]);
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

LineChartBarData thisWeekLineData(
    WeeklyScoreboard weeklyScoreboard, BuildContext context) {
  int weekDay = DateTime.now().weekday;

  List<FlSpot> spots = [
    FlSpot(1, weeklyScoreboard.mondayCumulative),
    FlSpot(2, weeklyScoreboard.tuesdayCumulative),
    FlSpot(3, weeklyScoreboard.wednesdayCumulative),
    FlSpot(4, weeklyScoreboard.thursdayCumulative),
    FlSpot(5, weeklyScoreboard.fridayCumulative),
    FlSpot(6, weeklyScoreboard.saturdayCumulative),
    FlSpot(7, weeklyScoreboard.sundayCumulative),
  ];

  return LineChartBarData(color: Theme.of(context).colorScheme.primary, spots: [
    ...spots.sublist(0, weekDay),
  ]);
}
