part of 'leaderboard_bloc.dart';

@immutable
sealed class LeaderboardEvent {}

class LeaderboardInit extends LeaderboardEvent {}

class LeaderboardRefresh extends LeaderboardInit {}

class RefreshTimeGoals extends LeaderboardEvent {}

class SelectDate extends LeaderboardEvent {
  final DateTime date;

  SelectDate(this.date);
}
