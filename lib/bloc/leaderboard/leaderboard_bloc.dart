import 'package:bloc/bloc.dart';
import 'package:deep_work/models/monthly_leaderboard.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

// ToDo: handle when there are no sessions or when Firestore gives an error.

/// Intermediates between the FirestoreRepo and the state.
/// most the logic is in the FirestoreRepo and the data models.
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  FirestoreRepo firestoreRepo;

  LeaderboardBloc({required this.firestoreRepo}) : super(LeaderboardLoading()) {
    on<LeaderboardInit>((event, emit) async {
      emit(LeaderboardLoading());
      List<TimerResult> sessions = await firestoreRepo.getSessions();

      WeeklyScoreboard weeklyScoreboard =
          WeeklyScoreboard.fromTimerResult(sessions);

      MonthlyScoreboard monthlyScoreboard =
          MonthlyScoreboard.fromTimerResult(sessions);

      emit(LeaderboardLoaded(weeklyScoreboard, monthlyScoreboard));
    });
  }
}
