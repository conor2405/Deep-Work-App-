import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/models/monthly_leaderboard.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/models/todays_sessions.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

// ToDo: handle when there are no sessions or when Firestore gives an error.

/// Intermediates between the FirestoreRepo and the state.
/// most the logic is in the FirestoreRepo and the data models.
/// handles all results from the FirestoreRepo and converts them to the
/// appropriate data models.
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  FirestoreRepo firestoreRepo;

  // Stream listener to the state of the timer bloc
  late StreamSubscription<TimerState> _timerBlocSubscription;
  TimerBloc timerBloc;
  int timerValue = 90 * 60; // default value

  late WeeklyScoreboard weeklyScoreboard;
  late WeeklyScoreboard LastWeekScoreboard;
  late MonthlyScoreboard monthlyScoreboard;
  late TodaysSessions todaysSessions;
  List<Goal> goals = [];
  late TimeGoalsAll timeGoals;

  void _listenToTimerBloc() {
    _timerBlocSubscription = timerBloc.stream.listen((state) {
      if (state is TimerInitial) {
        timerValue = state.time.seconds;
        emit(LeaderboardLoaded(weeklyScoreboard, monthlyScoreboard,
            todaysSessions, timerValue, LastWeekScoreboard, goals, timeGoals));
      }
    });
  }

  LeaderboardBloc({required this.firestoreRepo, required this.timerBloc})
      : super(LeaderboardLoading()) {
    _listenToTimerBloc();

    on<LeaderboardInit>((event, emit) async {
      emit(LeaderboardLoading());

      List<TimerResult> sessions = await firestoreRepo.getSessions();
      timeGoals = await firestoreRepo.getTimeGoals();

      weeklyScoreboard = WeeklyScoreboard.thisWeekFromTimerResult(sessions);

      monthlyScoreboard = MonthlyScoreboard.fromTimerResult(sessions);

      todaysSessions = TodaysSessions.fromTimerResult(sessions);

      LastWeekScoreboard = WeeklyScoreboard.lastWeekFromTimerResult(sessions);

      //goals = await firestoreRepo.getGoals();

      emit(LeaderboardLoaded(weeklyScoreboard, monthlyScoreboard,
          todaysSessions, timerValue, LastWeekScoreboard, goals, timeGoals));
    });

    on<LeaderboardRefresh>((event, emit) async {
      List<TimerResult> sessions = await firestoreRepo.getSessions();
      timeGoals = await firestoreRepo.getTimeGoals();

      weeklyScoreboard = WeeklyScoreboard.thisWeekFromTimerResult(sessions);

      monthlyScoreboard = MonthlyScoreboard.fromTimerResult(sessions);

      todaysSessions = TodaysSessions.fromTimerResult(sessions);

      LastWeekScoreboard = WeeklyScoreboard.lastWeekFromTimerResult(sessions);

      //goals = await firestoreRepo.getGoals();

      emit(LeaderboardLoaded(weeklyScoreboard, monthlyScoreboard,
          todaysSessions, timerValue, LastWeekScoreboard, goals, timeGoals));
    });
  }
}
