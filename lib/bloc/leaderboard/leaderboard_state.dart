part of 'leaderboard_bloc.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object> get props => [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();

  @override
  List<Object> get props => [];
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();

  @override
  List<Object> get props => [];
}

class LeaderboardLoaded extends LeaderboardState {
  WeeklyScoreboard weeklyScoreboard;
  MonthlyScoreboard monthlyScoreboard;

  LeaderboardLoaded(this.weeklyScoreboard, this.monthlyScoreboard);

  @override
  List<Object> get props => [weeklyScoreboard, monthlyScoreboard];
}
