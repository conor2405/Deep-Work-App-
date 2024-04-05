part of 'to_do_bloc.dart';

sealed class ToDoEvent extends Equatable {
  const ToDoEvent();

  @override
  List<Object> get props => [];
}

final class ToDoInit extends ToDoEvent {
  ToDoInit();
}
