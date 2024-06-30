import 'package:bloc/bloc.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/widgets/day_bar.dart';
import 'package:deep_work/widgets/day_selector.dart';
import 'package:deep_work/widgets/graphic_weekly_chart.dart';
import 'package:deep_work/widgets/notes_list.dart';
import 'package:deep_work/widgets/sidebar.dart';
import 'package:deep_work/widgets/timegoals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Row(children: [
          Sidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 30, 5, 5),
              child: ListView(children: [
                DaySelector(),
                BlocBuilder<LeaderboardBloc, LeaderboardState>(
                  builder: (context, state) {
                    if (state is LeaderboardLoaded) {
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Text(
                            state.dailySessions.totalMinutes.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w200),
                          ));
                    } else {
                      return SizedBox(
                        height: 1,
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
                  child: DayBar(
                    changeableDate: true,
                  ),
                ),
                Container(
                  child: GraphicWeeklyChart(
                    changeableDate: true,
                  ),
                  height: 300,
                ),
                SizedBox(
                  height: 100,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 100,
                        child: TimeGoalsWidget(
                          goalType: 'daily',
                          changeableDate: true,
                        ),
                      ),
                      Container(
                        width: 100,
                        child: TimeGoalsWidget(
                          goalType: 'weekly',
                        ),
                      ),
                      Container(
                        width: 100,
                        child: TimeGoalsWidget(
                          goalType: 'monthly',
                        ),
                      ),
                    ]),
                SizedBox(height: 50),
                // BlocBuilder<LeaderboardBloc, LeaderboardState>(
                //     builder: (context, state) {
                //   if (state is LeaderboardLoaded) {
                //     return Container(
                //       child: Center(
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: notesList(state.dailySessions.sessions),
                //         ),
                //       ),
                //     );
                //   } else {
                //     return Text('error loading leaderboard');
                //   }
                // }),
                Center(
                  child: Container(
                      width: double.infinity,
                      height: 600,
                      child: Center(child: WidgetForNotesList())),
                )
              ]),
            ),
          ),
        ]),
        // Add your chart widgets here
      ),
    );
  }
}

String concatNotes(List<String> notes) {
  String x = "";
  for (String i in notes) {
    x += i;
  }
  return x;
}

List<Widget> notesList(List<TimerResult> sessions) {
  List<Widget> notes = [];
  for (TimerResult session in sessions) {
    notes.add(ListTile(
      title: Text(session.startTime.toString()),
      subtitle: Text(concatNotes(session.notes)),
    ));
  }
  return notes;
}
