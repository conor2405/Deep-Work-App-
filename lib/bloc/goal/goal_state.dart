part of 'goal_bloc.dart';

@immutable
sealed class GoalState {}

final class GoalInitial extends GoalState {}

final class GoalsLoaded extends GoalState {
  final TimeGoalsAll timeGoals;

  GoalsLoaded(this.timeGoals);

  @override
  List<Object> get props => [timeGoals];
}
