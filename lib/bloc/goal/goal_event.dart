part of 'goal_bloc.dart';

@immutable
sealed class GoalEvent {}

class GoalInit extends GoalEvent {}

class SetTimeGoal extends GoalEvent {
  final TimeGoal goal;

  SetTimeGoal(this.goal);
}
