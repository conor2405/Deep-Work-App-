import 'package:bloc/bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:meta/meta.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  FirestoreRepo firestoreRepo;
  TimeGoalsAll timeGoals = TimeGoalsAll();

  GoalBloc(this.firestoreRepo) : super(GoalInitial()) {
    on<GoalInit>((event, emit) async {
      TimeGoalsAll timeGoals = await firestoreRepo.getTimeGoals();

      // firestoreRepo.setTimeGoal(timeGoals);
      emit(GoalsLoaded(timeGoals));
    });

    on<NewTimeGoal>((event, emit) async {
      TimeGoalsAll timeGoals = await firestoreRepo.getTimeGoals();

      emit(GoalsLoaded(timeGoals));
    });
  }
}
