part of 'to_do_bloc.dart';

sealed class ToDoState extends Equatable {
  const ToDoState();

  @override
  List<Object> get props => [];
}

final class ToDoInitial extends ToDoState {}

final class ToDoLoaded extends ToDoState {
  final List<Goal> goals;

  ToDoLoaded(this.goals);

  @override
  List<Object> get props => [goals];
}
