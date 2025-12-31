import 'dart:async';

import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DayBar extends StatefulWidget {
  bool changeableDate;
  DayBar({this.changeableDate = false});

  @override
  _DayBarState createState() => _DayBarState();
}

class _DayBarState extends State<DayBar> {
  static const double _barHeight = 12;
  static const double _labelHeight = 12;
  static const double _labelSpacing = 6;
  static const double _markerTickHeight = 6;
  static const Duration _nowTickRate = Duration(seconds: 30);

  Timer? _nowTicker;
  bool _isNowTickerActive = false;

  void _syncNowTicker(bool shouldRun) {
    if (shouldRun) {
      if (_isNowTickerActive) {
        return;
      }
      _isNowTickerActive = true;
      _nowTicker = Timer.periodic(_nowTickRate, (_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
      return;
    }
    _stopNowTicker();
  }

  void _stopNowTicker() {
    _nowTicker?.cancel();
    _nowTicker = null;
    _isNowTickerActive = false;
  }

  @override
  void dispose() {
    _stopNowTicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(builder: (context, constraints) {
              final barTop = _labelHeight + _labelSpacing;
              final totalHeight = barTop + _barHeight;
              final isDarkMode =
                  BlocProvider.of<SettingsBloc>(context).isDarkMode;
              final baseColor = isDarkMode ? Colors.grey : Colors.grey[200];
              final tickColor = Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.35);
              final nowColor =
                  Theme.of(context).colorScheme.primary.withOpacity(0.9);
              final showNowIndicator = !widget.changeableDate ||
                  isSameDay(state.selectedDate, DateTime.now());
              _syncNowTicker(showNowIndicator);

              return SizedBox(
                height: totalHeight,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: barTop,
                      child: Container(
                        height: _barHeight,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ...generateDaysBars(
                      state,
                      constraints,
                      context,
                      widget.changeableDate,
                      barTop: barTop,
                      barHeight: _barHeight,
                    ),
                    ...buildTimeMarkers(
                      constraints: constraints,
                      barTop: barTop,
                      barHeight: _barHeight,
                      labelHeight: _labelHeight,
                      tickHeight: _markerTickHeight,
                      color: tickColor,
                    ),
                    if (showNowIndicator)
                      buildCurrentTimeIndicator(
                        constraints: constraints,
                        barTop: barTop,
                        barHeight: _barHeight,
                        color: nowColor,
                      ),
                  ],
                ),
              );
            }),
          );
        } else if (state is LeaderboardLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 12,
              ),
            ),
          );
        } else {
          return Container(child: Text('Error loading leaderboard'));
        }
      },
    );
  }
}

List<Widget> generateDaysBars(
  LeaderboardLoaded state,
  BoxConstraints constraints,
  BuildContext context,
  bool changeableDate, {
  required double barTop,
  required double barHeight,
}) {
  // get the parent data widget width and divide by 86400

  List<Widget> daysBars = [];

  List<TimerResult> sessions = changeableDate
      ? state.dailySessions.sessions
      : state.todaysSessions.sessions;

  for (TimerResult timerResult in sessions) {
    // get the start time and end time
    // calculate the width of the bar
    // add the bar to the stack

    final efficiency = timerResult.sessionEfficiency.clamp(0.0, 1.0);
    final redValue = ((1 - efficiency) * 255).round().clamp(0, 255);
    final barWidth = widthofBar(
        timerResult.startTime, timerResult.timeFinished, constraints);

    if (barWidth > 0) {
      daysBars.add(Positioned(
        left: alignmentPosition(timerResult.startTime, constraints),
        top: barTop,
        child: Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: BlocProvider.of<SettingsBloc>(context).isDarkMode
                ? Colors.green[800]?.withRed(redValue)
                : Colors.green.withRed(redValue),
          ),
        ),
      ));
    }

    daysBars.addAll(buildBreaks(timerResult, constraints, barTop, barHeight));
  }
  if (!changeableDate) {
    daysBars.add(Positioned(
      left: centerOfCurrentTimeBar(constraints),
      top: barTop,
      child: Container(
        width: widthOfCurrentTimeBar(state.timerValue, constraints),
        height: barHeight,
        decoration: BoxDecoration(
          color: BlocProvider.of<SettingsBloc>(context).isDarkMode
              ? Colors.red[800]
              : Colors.red[400],
        ),
      ),
    ));
  }

  return daysBars;
}

double alignmentPosition(DateTime time, BoxConstraints constraints) {
  double percentOfDay =
      (time.hour * 3600 + time.minute * 60 + time.second) / 86400;

  return (percentOfDay * constraints.maxWidth).clamp(0.0, constraints.maxWidth);
}

double widthofBar(
    DateTime startTime, DateTime endTime, BoxConstraints constraints) {
  final safeEnd = isSameDay(startTime, endTime) && endTime.isAfter(startTime)
      ? endTime
      : startTime.copyWith(hour: 23, minute: 59, second: 59);
  double percentOfDay = safeEnd.difference(startTime).inSeconds / 86400;

  return (constraints.maxWidth * percentOfDay).clamp(0.0, constraints.maxWidth);
}

double centerOfCurrentTimeBar(BoxConstraints constraints) {
  DateTime now = DateTime.now();
  double percentOfDay =
      (now.hour * 3600 + now.minute * 60 + now.second) / 86400;

  return (constraints.maxWidth * percentOfDay);
}

double widthOfCurrentTimeBar(int timeSetOnTimer, BoxConstraints constraints) {
  double percentOfDay = timeSetOnTimer / 86400;

  return (constraints.maxWidth * percentOfDay).clamp(0.0, constraints.maxWidth);
}

List<Widget> buildBreaks(
  TimerResult timerResult,
  BoxConstraints constraints,
  double barTop,
  double barHeight,
) {
  final List<Widget> breaks = [];

  for (BreakPeriod breakPeriod in timerResult.breakEvents) {
    if (breakPeriod.endTime == null) {
      continue;
    }
    final breakWidth =
        widthofBar(breakPeriod.startTime, breakPeriod.endTime!, constraints);
    if (breakWidth <= 0) {
      continue;
    }
    breaks.add(Positioned(
      left: alignmentPosition(breakPeriod.startTime, constraints),
      top: barTop,
      child: Container(
        width: breakWidth,
        height: barHeight,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ));
  }

  return breaks;
}

bool isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

List<Widget> buildTimeMarkers({
  required BoxConstraints constraints,
  required double barTop,
  required double barHeight,
  required double labelHeight,
  required double tickHeight,
  required Color color,
}) {
  const markers = [
    _TimeMarker(hour: 6, label: '6a'),
    _TimeMarker(hour: 9, label: '9a'),
    _TimeMarker(hour: 12, label: 'Noon'),
    _TimeMarker(hour: 15, label: '3p'),
    _TimeMarker(hour: 18, label: '6p'),
    _TimeMarker(hour: 21, label: '9p'),
  ];
  const labelWidth = 36.0;
  final maxLeft = constraints.maxWidth > labelWidth
      ? constraints.maxWidth - labelWidth
      : 0.0;
  final List<Widget> widgets = [];

  for (final marker in markers) {
    final left = positionForHour(marker.hour, constraints);
    final labelLeft = (left - (labelWidth / 2)).clamp(0.0, maxLeft);

    widgets.add(Positioned(
      left: left - 0.5,
      top: barTop - tickHeight,
      child: Container(
        width: 1,
        height: barHeight + tickHeight,
        color: color,
      ),
    ));
    widgets.add(Positioned(
      left: labelLeft,
      top: 0,
      child: SizedBox(
        width: labelWidth,
        height: labelHeight,
        child: Text(
          marker.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 11,
            letterSpacing: 0.4,
          ),
        ),
      ),
    ));
  }

  return widgets;
}

Widget buildCurrentTimeIndicator({
  required BoxConstraints constraints,
  required double barTop,
  required double barHeight,
  required Color color,
}) {
  final left = centerOfCurrentTimeBar(constraints)
      .clamp(0.0, constraints.maxWidth);
  return Positioned(
    left: left - 1,
    top: barTop - 4,
    child: Container(
      key: const Key('day_bar_now_indicator'),
      width: 2,
      height: barHeight + 8,
      color: color,
    ),
  );
}

double positionForHour(int hour, BoxConstraints constraints) {
  final clampedHour = hour.clamp(0, 23).toDouble();
  final percentOfDay = (clampedHour * 3600) / 86400;
  return (constraints.maxWidth * percentOfDay)
      .clamp(0.0, constraints.maxWidth);
}

class _TimeMarker {
  final int hour;
  final String label;

  const _TimeMarker({required this.hour, required this.label});
}
