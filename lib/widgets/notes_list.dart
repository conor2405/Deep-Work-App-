import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WidgetForNotesList extends StatefulWidget {
  @override
  _WidgetForNotesListState createState() => _WidgetForNotesListState();
}

class _WidgetForNotesListState extends State<WidgetForNotesList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          return Center(
            child: ListView.builder(
              itemCount: state.dailySessions.sessions.length,
              itemBuilder: (context, index) {
                return Center(
                  child: ListTile(
                    title: Text(
                      state.dailySessions.sessions[index].startTime.toString(),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      concatNotes(state.dailySessions.sessions[index].notes),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Text('error loading leaderboard');
        }
      },
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
