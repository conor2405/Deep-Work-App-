import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WidgetForNotesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          final sessionsWithNotes = state.dailySessions.sessions
              .where((session) =>
                  session.notes.any((note) => note.trim().isNotEmpty))
              .toList();

          if (sessionsWithNotes.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No notes for this day yet.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessionsWithNotes.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final session = sessionsWithNotes[index];
              return ListTile(
                title: Text(
                  session.startTime.toString(),
                  textAlign: TextAlign.center,
                ),
                subtitle: Text(
                  concatNotes(session.notes),
                  textAlign: TextAlign.center,
                ),
              );
            },
          );
        }
        return const Text('error loading leaderboard');
      },
    );
  }
}

String concatNotes(List<String> notes) {
  return notes
      .map((note) => note.trim())
      .where((note) => note.isNotEmpty)
      .join('\n');
}
