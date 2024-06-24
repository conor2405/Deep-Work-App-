import 'dart:math';

import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphicWeeklyChart extends StatefulWidget {
  bool changeableDate;

  GraphicWeeklyChart({this.changeableDate = false});
  @override
  _GraphicWeeklyChartState createState() => _GraphicWeeklyChartState();
}

class _GraphicWeeklyChartState extends State<GraphicWeeklyChart> {
  @override
  Widget build(BuildContext context) {
    WeeklyScoreboard weeklyScoreboard;
    WeeklyScoreboard LastWeekScoreboard;

    return Container(child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          widget.changeableDate
              ? weeklyScoreboard = state.weeklySessions
              : weeklyScoreboard = state.weeklyScoreboard;

          widget.changeableDate
              ? LastWeekScoreboard = state.weeklySessionsLastWeek
              : LastWeekScoreboard = state.LastWeekScoreboard;

          TextStyle style = TextStyle(
              color: BlocProvider.of<SettingsBloc>(context).isDarkMode
                  ? Colors.white
                  : Colors.black,
              fontSize: 10);

          return Stack(children: [
            BarChart(BarChartData(
                minY: 0,
                maxY: (max<double>(
                            weeklyScoreboard.total, LastWeekScoreboard.total)
                        .toDouble() *
                    1.1),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
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
                      axisNameWidget: Text('Minutes', style: style),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text((value.toInt()).toString());
                        },
                        interval: (max<double>(
                                        max<double>(weeklyScoreboard.total,
                                            LastWeekScoreboard.total),
                                        1)
                                    .toDouble() *
                                1.1) /
                            4,
                      )),
                ),
                barGroups: <BarChartGroupData>[
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                      toY: weeklyScoreboard.monday,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    BarChartRodData(
                        toY: LastWeekScoreboard.monday,
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
                        toY: weeklyScoreboard.tuesday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: LastWeekScoreboard.tuesday,
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
                        toY: weeklyScoreboard.wednesday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: LastWeekScoreboard.wednesday,
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
                        toY: weeklyScoreboard.thursday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: LastWeekScoreboard.thursday,
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
                        toY: weeklyScoreboard.friday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: LastWeekScoreboard.friday,
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
                        toY: weeklyScoreboard.saturday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: LastWeekScoreboard.saturday,
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
                        toY: weeklyScoreboard.sunday,
                        color: Theme.of(context).colorScheme.primary),
                    BarChartRodData(
                        toY: LastWeekScoreboard.sunday,
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
                lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        List<LineTooltipItem> items = [];

                        if (touchedSpots.length == 1) {
                          items.add(LineTooltipItem(
                              touchedSpots.first.y.toString(),
                              TextStyle(color: Colors.white.withOpacity(0.3))));
                          return items;
                        } else {
                          items.add(LineTooltipItem(
                              touchedSpots.first.y.toString(),
                              TextStyle(color: Colors.white)));

                          items.add(LineTooltipItem(
                              touchedSpots[1].y.toString(),
                              TextStyle(color: Colors.white.withOpacity(0.3))));

                          return items;
                        }
                      },
                    )),
                minY: 0,
                maxY: (max<double>(
                            weeklyScoreboard.total, LastWeekScoreboard.total)
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
                      dashArray: [10, 5],
                      dotData: FlDotData(show: false),
                      spots: [
                        FlSpot(1, LastWeekScoreboard.mondayCumulative),
                        FlSpot(2, LastWeekScoreboard.tuesdayCumulative),
                        FlSpot(3, LastWeekScoreboard.wednesdayCumulative),
                        FlSpot(4, LastWeekScoreboard.thursdayCumulative),
                        FlSpot(5, LastWeekScoreboard.fridayCumulative),
                        FlSpot(6, LastWeekScoreboard.saturdayCumulative),
                        FlSpot(7, LastWeekScoreboard.sundayCumulative),
                      ]),
                  thisWeekLineData(weeklyScoreboard, context,
                      widget.changeableDate, state.selectedDate),
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

LineChartBarData thisWeekLineData(WeeklyScoreboard weeklyScoreboard,
    BuildContext context, bool changeableDate, DateTime date) {
  int weekDay = DateTime.now().weekday;

  DateTime startOfWeek = DateTime.now()
      .subtract(Duration(days: weekDay - 1))
      .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0);

  List<FlSpot> spots = [
    FlSpot(1, weeklyScoreboard.mondayCumulative),
    FlSpot(2, weeklyScoreboard.tuesdayCumulative),
    FlSpot(3, weeklyScoreboard.wednesdayCumulative),
    FlSpot(4, weeklyScoreboard.thursdayCumulative),
    FlSpot(5, weeklyScoreboard.fridayCumulative),
    FlSpot(6, weeklyScoreboard.saturdayCumulative),
    FlSpot(7, weeklyScoreboard.sundayCumulative),
  ];
  if (changeableDate &&
      date
          .copyWith(hour: 1, minute: 0, second: 0, microsecond: 0)
          .isBefore(startOfWeek)) {
    return LineChartBarData(
        color: Theme.of(context).colorScheme.primary,
        dotData: FlDotData(show: false),
        spots: spots);
  } else {
    return LineChartBarData(
        color: Theme.of(context).colorScheme.primary,
        dotData: FlDotData(show: false),
        spots: [
          ...spots.sublist(0, weekDay),
        ]);
  }
}
