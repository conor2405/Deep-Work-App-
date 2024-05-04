import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DayBar extends StatefulWidget {
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
                    children: generateDaysBars(state, constraints, context),
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

List<Widget> generateDaysBars(
    LeaderboardLoaded state, BoxConstraints constraints, BuildContext context) {
  // get the parent data widget width and divide by 86400

  List<Widget> daysBars = [];

  for (TimerResult timerResult in state.todaysSessions.sessions) {
    // get the start time and end time
    // calculate the width of the bar
    // add the bar to the stack

    daysBars.add(Positioned(
      left: alignmentPosition(timerResult.startTime, constraints),
      child: Container(
        width: widthofBar(
            timerResult.startTime, timerResult.timeFinished, constraints),
        height: 12,
        decoration: BoxDecoration(
          color: BlocProvider.of<SettingsBloc>(context).isDarkMode
              ? Colors.green[800]
              : Colors.green,
        ),
      ),
    ));

    buildPauses(timerResult, constraints);
  }

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

  return daysBars;
}

double alignmentPosition(DateTime time, BoxConstraints constraints) {
  double percentOfDay =
      (time.hour * 3600 + time.minute * 60 + time.second) / 86400;

  return percentOfDay * constraints.maxWidth;
}

double widthofBar(
    DateTime startTime, DateTime endTime, BoxConstraints constraints) {
  double percentOfDay = endTime.difference(startTime).inSeconds / 86400;

  return (constraints.maxWidth * percentOfDay);
}

double centerOfCurrentTimeBar(BoxConstraints constraints) {
  DateTime now = DateTime.now();
  double percentOfDay =
      (now.hour * 3600 + now.minute * 60 + now.second) / 86400;

  return (constraints.maxWidth * percentOfDay);
}

double widthOfCurrentTimeBar(int timeSetOnTimer, BoxConstraints constraints) {
  double percentOfDay = timeSetOnTimer / 86400;

  return (constraints.maxWidth * percentOfDay);
}

Widget buildPauses(TimerResult timerResult, BoxConstraints constraints) {
  List<Widget> pauses = [];

  for (Pause pause in timerResult.pauseEvents) {
    pauses.add(Positioned(
      left: alignmentPosition(pause.startTime, constraints),
      child: Container(
        width: widthofBar(pause.startTime, pause.endTime!, constraints),
        height: 12,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ));
  }

  return Stack(
    children: pauses,
  );
}
