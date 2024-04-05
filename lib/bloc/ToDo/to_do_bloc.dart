import 'package:bloc/bloc.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:deep_work/models/goal.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'to_do_event.dart';
part 'to_do_state.dart';

class ToDoBloc extends Bloc<ToDoEvent, ToDoState> {
  ToDoBloc(FirestoreRepo firestoreRepo) : super(ToDoInitial()) {
    on<ToDoInit>((event, emit) async {
      emit(ToDoInitial());
      // List<Goal> goals = await firestoreRepo.getGoals();
      List<Goal> goals = [
        Goal(
            id: 1,
            name: 'Goal 1',
            tasks: [
              Task(
                  id: 1,
                  name: 'Task 1',
                  uid: 'uid',
                  user: FirebaseAuth.instance.currentUser!),
              Task(
                  id: 1,
                  name: 'Task 2',
                  uid: 'uid',
                  user: FirebaseAuth.instance.currentUser!),
              Task(
                  id: 1,
                  name: 'Task 3',
                  uid: 'uid',
                  user: FirebaseAuth.instance.currentUser!),
              Task(
                  id: 1,
                  name: 'Task 4',
                  uid: 'uid',
                  user: FirebaseAuth.instance.currentUser!),
              Task(
                  id: 1,
                  name: 'Task 5',
                  uid: 'uid',
                  user: FirebaseAuth.instance.currentUser!),
            ],
            uid: 'uid',
            user: FirebaseAuth.instance.currentUser!)
      ];
      emit(ToDoLoaded(goals));
    });
    on<ToDoEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
