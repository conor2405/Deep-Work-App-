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
  WeeklyScoreboard LastWeekScoreboard;
  MonthlyScoreboard monthlyScoreboard;
  TodaysSessions todaysSessions;
  int timerValue;
  List<Goal> goals;
  TimeGoalsAll timeGoals;

  LeaderboardLoaded(
      this.weeklyScoreboard,
      this.monthlyScoreboard,
      this.todaysSessions,
      this.timerValue,
      this.LastWeekScoreboard,
      this.goals,
      this.timeGoals);

  @override
  List<Object> get props => [
        weeklyScoreboard,
        monthlyScoreboard,
        todaysSessions,
        timerValue,
        LastWeekScoreboard,
        goals,
      ];
}
