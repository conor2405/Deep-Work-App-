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

    on<SetTimeGoal>((event, emit) async {
      if (event.goal.type == 'daily') {
        timeGoals.daily = event.goal;
      } else if (event.goal.type == 'weekly') {
        timeGoals.weekly = event.goal;
      } else if (event.goal.type == 'monthly') {
        timeGoals.monthly = event.goal;
      } else if (event.goal.type == 'yearly') {
        timeGoals.yearly = event.goal;
      }
      firestoreRepo.setTimeGoal(timeGoals);

      emit(GoalsLoaded(timeGoals));
    });
  }
}
