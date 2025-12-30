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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(builder: (context, constraints) {
              return Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: BlocProvider.of<SettingsBloc>(context).isDarkMode
                        ? Colors.grey
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: generateDaysBars(
                        state, constraints, context, widget.changeableDate),
                  )
                  // Widget content goes here
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

List<Widget> generateDaysBars(LeaderboardLoaded state,
    BoxConstraints constraints, BuildContext context, bool changeableDate) {
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
        child: Container(
          width: barWidth,
          height: 12,
          decoration: BoxDecoration(
            color: BlocProvider.of<SettingsBloc>(context).isDarkMode
                ? Colors.green[800]?.withRed(redValue)
                : Colors.green.withRed(redValue),
          ),
        ),
      ));
    }

    daysBars.addAll(buildBreaks(timerResult, constraints));
  }
  if (!changeableDate) {
    daysBars.add(Positioned(
      left: centerOfCurrentTimeBar(constraints),
      child: Container(
        width: widthOfCurrentTimeBar(state.timerValue, constraints),
        height: 12,
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

List<Widget> buildBreaks(TimerResult timerResult, BoxConstraints constraints) {
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
      child: Container(
        width: breakWidth,
        height: 12,
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
