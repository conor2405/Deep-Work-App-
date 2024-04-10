import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyScoreboardWidget extends StatefulWidget {
  @override
  _MonthlyScoreboardWidgetState createState() =>
      _MonthlyScoreboardWidgetState();
}

class _MonthlyScoreboardWidgetState extends State<MonthlyScoreboardWidget> {
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
              Text('Total:' + state.monthlyScoreboard.total.toString()),
              Text('Month:' + state.monthlyScoreboard.month.toString()),
              Text(
                  '1st of month:' + state.monthlyScoreboard.time[0].toString()),
            ],
          ));
        } else {
          return Container(child: Text('Error loading leaderboard'));
        }
      },
    );
  }
}
