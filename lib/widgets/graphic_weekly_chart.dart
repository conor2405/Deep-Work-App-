import 'dart:math';

import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphicWeeklyChart extends StatefulWidget {
  final bool changeableDate;

  GraphicWeeklyChart({super.key, this.changeableDate = false});
  @override
  _GraphicWeeklyChartState createState() => _GraphicWeeklyChartState();
}

class _GraphicWeeklyChartState extends State<GraphicWeeklyChart> {
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const double _leftTitlesReservedSize = 44;
  static const double _bottomTitlesReservedSize = 24;
  static const EdgeInsets _lineChartPadding = EdgeInsets.fromLTRB(
    _leftTitlesReservedSize,
    8,
    12,
    _bottomTitlesReservedSize,
  );

  @override
  Widget build(BuildContext context) {
    WeeklyScoreboard weeklyScoreboard;
    WeeklyScoreboard lastWeekScoreboard;

    return Container(child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          widget.changeableDate
              ? weeklyScoreboard = state.weeklySessions
              : weeklyScoreboard = state.weeklyScoreboard;

          widget.changeableDate
              ? lastWeekScoreboard = state.weeklySessionsLastWeek
              : lastWeekScoreboard = state.LastWeekScoreboard;

          final scheme = Theme.of(context).colorScheme;
          final maxY = weeklyMaxY(weeklyScoreboard, lastWeekScoreboard);
          final style = Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.2,
              );
          final thisWeekValues = weeklyValues(weeklyScoreboard);
          final lastWeekValues = weeklyValues(lastWeekScoreboard);
          final gridInterval = maxY / 4;
          final primaryGlow =
              Color.lerp(scheme.primary, scheme.onSurface, 0.15) ??
                  scheme.primary;
          final thisWeekGradient = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryGlow.withOpacity(0.9),
              scheme.primary.withOpacity(0.7),
            ],
          );
          final lastWeekColor = scheme.tertiary.withOpacity(0.45);

          return Stack(children: [
            BarChart(BarChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: gridInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: scheme.onSurface.withOpacity(0.08),
                    strokeWidth: 1,
                    dashArray: [4, 6],
                  ),
                ),
                borderData: FlBorderData(show: false),
                groupsSpace: 14,
                alignment: BarChartAlignment.spaceBetween,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: _bottomTitlesReservedSize,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= _dayLabels.length) {
                              return const SizedBox.shrink();
                            }
                            final isToday = !widget.changeableDate &&
                                index == DateTime.now().weekday - 1;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 6,
                              child: Text(
                                _dayLabels[index],
                                style: style?.copyWith(
                                  color: isToday
                                      ? scheme.primary
                                      : style?.color,
                                ),
                              ),
                            );
                          })),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      axisNameWidget: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('Minutes', style: style),
                      ),
                      axisNameSize: 16,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: _leftTitlesReservedSize,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text('${value.toInt()}m', style: style),
                          );
                        },
                        interval: gridInterval,
                      )),
                ),
                barGroups: List.generate(_dayLabels.length, (index) {
                  return BarChartGroupData(x: index, barsSpace: 6, barRods: [
                    BarChartRodData(
                      toY: thisWeekValues[index],
                      gradient: thisWeekGradient,
                      width: 10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    BarChartRodData(
                      toY: lastWeekValues[index],
                      color: lastWeekColor,
                      width: 6,
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: lastWeekColor.withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                  ]);
                }))),
            Padding(
              padding: _lineChartPadding,
              child: LineChart(LineChartData(
                lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          scheme.surface.withOpacity(0.9),
                      tooltipBorder: BorderSide(
                        color: scheme.onSurface.withOpacity(0.08),
                        width: 1,
                      ),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      tooltipRoundedRadius: 8,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isThisWeek = spot.barIndex == 1;
                          final label = isThisWeek ? 'This week' : 'Last week';
                          final color = isThisWeek
                              ? scheme.primary
                              : scheme.tertiary.withOpacity(0.7);
                          return LineTooltipItem(
                            '$label: ${formatMinutes(spot.y)}',
                            TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    )),
                minY: 0,
                maxY: maxY,
                minX: 0,
                maxX: 6,
                clipData: FlClipData.all(),
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
                  lastWeekLineData(lastWeekScoreboard, context),
                  thisWeekLineData(weeklyScoreboard, context,
                      widget.changeableDate, state.selectedDate),
                ],
              )),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Wrap(
                spacing: 8,
                children: [
                  LegendItem(
                    label: 'This week',
                    color: scheme.primary,
                  ),
                  LegendItem(
                    label: 'Last week',
                    color: scheme.tertiary.withOpacity(0.7),
                    outlined: true,
                  ),
                ],
              ),
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

double weeklyMaxY(
    WeeklyScoreboard weeklyScoreboard, WeeklyScoreboard lastWeekScoreboard) {
  final maxTotal = max(weeklyScoreboard.total, lastWeekScoreboard.total);
  return max(maxTotal * 1.1, 10);
}

String formatMinutes(double minutes) {
  return '${minutes.toStringAsFixed(0)} min';
}

class LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;

  const LegendItem({
    required this.label,
    required this.color,
    this.outlined = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w300,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(4),
            border: outlined ? Border.all(color: color, width: 1) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: labelStyle),
      ],
    );
  }
}

List<double> weeklyValues(WeeklyScoreboard scoreboard) {
  return [
    scoreboard.monday,
    scoreboard.tuesday,
    scoreboard.wednesday,
    scoreboard.thursday,
    scoreboard.friday,
    scoreboard.saturday,
    scoreboard.sunday,
  ];
}

List<FlSpot> weeklyCumulativeSpots(WeeklyScoreboard scoreboard) {
  return [
    FlSpot(0, scoreboard.mondayCumulative),
    FlSpot(1, scoreboard.tuesdayCumulative),
    FlSpot(2, scoreboard.wednesdayCumulative),
    FlSpot(3, scoreboard.thursdayCumulative),
    FlSpot(4, scoreboard.fridayCumulative),
    FlSpot(5, scoreboard.saturdayCumulative),
    FlSpot(6, scoreboard.sundayCumulative),
  ];
}

LineChartBarData lastWeekLineData(
    WeeklyScoreboard lastWeekScoreboard, BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return LineChartBarData(
    color: scheme.tertiary.withOpacity(0.45),
    dashArray: [8, 6],
    isCurved: true,
    curveSmoothness: 0.25,
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    spots: weeklyCumulativeSpots(lastWeekScoreboard),
  );
}

LineChartBarData thisWeekLineData(WeeklyScoreboard weeklyScoreboard,
    BuildContext context, bool changeableDate, DateTime date) {
  final scheme = Theme.of(context).colorScheme;
  int weekDay = DateTime.now().weekday;

  DateTime startOfWeek = DateTime.now()
      .subtract(Duration(days: weekDay - 1))
      .copyWith(hour: 0, minute: 0, second: 0, microsecond: 0);

  List<FlSpot> spots = weeklyCumulativeSpots(weeklyScoreboard);
  final displaySpots = (changeableDate &&
          date
              .copyWith(hour: 1, minute: 0, second: 0, microsecond: 0)
              .isBefore(startOfWeek))
      ? spots
      : spots.sublist(0, weekDay);
  return LineChartBarData(
    gradient: LinearGradient(
      colors: [
        scheme.primary.withOpacity(0.7),
        scheme.primary,
      ],
    ),
    isCurved: true,
    curveSmoothness: 0.2,
    barWidth: 3,
    isStrokeCapRound: true,
    shadow: Shadow(
      color: scheme.primary.withOpacity(0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    dotData: FlDotData(
      show: true,
      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
        radius: 2.5,
        color: scheme.primary,
        strokeColor: scheme.onSurface.withOpacity(0.2),
        strokeWidth: 1,
      ),
    ),
    belowBarData: BarAreaData(
      show: true,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          scheme.primary.withOpacity(0.12),
          scheme.primary.withOpacity(0.0),
        ],
      ),
    ),
    spots: displaySpots,
  );
}
