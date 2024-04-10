import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeeklyScoreboard extends StatefulWidget {
  @override
  _WeeklyScoreboardState createState() => _WeeklyScoreboardState();
}

class _WeeklyScoreboardState extends State<WeeklyScoreboard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LeaderboardLoaded) {
          return Container(
              child: Row(
            children: [
              Text('Total:' + state.weeklyScoreboard.total.toString()),
              Text('Monday:' + state.weeklyScoreboard.monday.toString()),
              Text('Tuesday:' + state.weeklyScoreboard.tuesday.toString()),
              Text('Wednesday:' + state.weeklyScoreboard.wednesday.toString()),
              Text('Thursday:' + state.weeklyScoreboard.thursday.toString()),
              Text('Friday:' + state.weeklyScoreboard.friday.toString()),
              Text('Saturday:' + state.weeklyScoreboard.saturday.toString()),
              Text('Sunday:' + state.weeklyScoreboard.sunday.toString()),
            ],
          ));
        } else {
          return Container(child: Text('Error loading leaderboard'));
        }
      },
    );
  }
}
