part of 'goal_bloc.dart';

@immutable
sealed class GoalEvent {}

class GoalInit extends GoalEvent {}

class NewTimeGoal extends GoalEvent {
  final TimeGoal goal;

  NewTimeGoal(this.goal);
}
