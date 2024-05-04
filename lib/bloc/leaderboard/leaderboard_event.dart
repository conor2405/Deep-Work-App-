part of 'leaderboard_bloc.dart';

@immutable
sealed class LeaderboardEvent {}

class LeaderboardInit extends LeaderboardEvent {}

class LeaderboardRefresh extends LeaderboardEvent {}

class RefreshTimeGoals extends LeaderboardEvent {}
