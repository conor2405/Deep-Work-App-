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

  // sessions from firestore, first populated on init
  List<TimerResult> sessions = [];
  // will be populated with the current week based on todays date.
  late WeeklyScoreboard weeklyScoreboard;
  late WeeklyScoreboard LastWeekScoreboard;
  late MonthlyScoreboard monthlyScoreboard;
  late TodaysSessions todaysSessions;
  List<Goal> goals = [];
  late TimeGoalsAll timeGoals;
  // will be populated with the week the user selects.
  late TodaysSessions dailySessions;
  late WeeklyScoreboard weeklySessions;
  late WeeklyScoreboard weeklySessionsLastWeek;
  late MonthlyScoreboard monthlySessions;
  bool _hasLoaded = false;
  // todays date at 00:00:00
  DateTime today =
      DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  // the dates from mon - sun of the selected week
  List<DateTime> dates = [];

  DateTime selectedDate = DateTime.now();

  // listens to the timer bloc in order to get selected time for red section of the day bar.
  void _listenToTimerBloc() {
    _timerBlocSubscription = timerBloc.stream.listen((state) {
      if (state is TimerInitial) {
        timerValue = state.time.seconds;
        if (!_hasLoaded) {
          return;
        }
        emit(LeaderboardLoaded(
          weeklyScoreboard,
          monthlyScoreboard,
          todaysSessions,
          timerValue,
          LastWeekScoreboard,
          goals,
          timeGoals,
          dates,
          selectedDate,
          dailySessions,
          weeklySessions,
          weeklySessionsLastWeek,
        ));
      }
    });
  }

  LeaderboardBloc({required this.firestoreRepo, required this.timerBloc})
      : super(LeaderboardLoading()) {
    _listenToTimerBloc();

    on<LeaderboardInit>((event, emit) async {
      /// leaderboard refresh extends init.
      /// this event is called by both, if init we want to show loading
      /// if refresh we want to keep the current state and refresh in background then update.
      if (event is! LeaderboardRefresh) {
        emit(LeaderboardLoading());
      }

      sessions = await firestoreRepo.getSessions();
      timeGoals = await firestoreRepo.getTimeGoals();

      weeklyScoreboard = WeeklyScoreboard.thisWeekFromTimerResult(sessions);

      monthlyScoreboard = MonthlyScoreboard.fromTimerResult(sessions);

      todaysSessions = TodaysSessions.fromTimerResultToday(sessions);

      LastWeekScoreboard = WeeklyScoreboard.lastWeekFromTimerResult(sessions);

      dates = datesForWeek(today);

      dailySessions = TodaysSessions.fromTimerResult(
        sessions,
        date: selectedDate,
      );

      weeklySessions = WeeklyScoreboard.fromTimerResult(
        sessions,
        startDate: dates.first,
        endDate: dates.last,
      );

      weeklySessionsLastWeek = WeeklyScoreboard.fromTimerResult(
        sessions,
        startDate: dates.first.subtract(Duration(days: 7)),
        endDate: dates.last.subtract(Duration(days: 7)),
      );

      //goals = await firestoreRepo.getGoals();
      _hasLoaded = true;
      emit(LeaderboardLoaded(
        weeklyScoreboard,
        monthlyScoreboard,
        todaysSessions,
        timerValue,
        LastWeekScoreboard,
        goals,
        timeGoals,
        dates,
        selectedDate,
        dailySessions,
        weeklySessions,
        weeklySessionsLastWeek,
      ));
    });

    on<RefreshTimeGoals>((event, emit) async {
      timeGoals = await firestoreRepo.getTimeGoals();

      emit(LeaderboardLoaded(
        weeklyScoreboard,
        monthlyScoreboard,
        todaysSessions,
        timerValue,
        LastWeekScoreboard,
        goals,
        timeGoals,
        dates,
        selectedDate,
        dailySessions,
        weeklySessions,
        weeklySessionsLastWeek,
      ));
    });
    on<SelectDate>((event, emit) {
      selectedDate = event.date;
      if (!_hasLoaded) {
        return;
      }

      dailySessions = TodaysSessions.fromTimerResult(
        sessions,
        date: selectedDate,
      );
      dates = datesForWeek(selectedDate);

      weeklySessions = WeeklyScoreboard.fromTimerResult(
        sessions,
        startDate: dates.first,
        endDate: dates.last,
      );

      weeklySessionsLastWeek = WeeklyScoreboard.fromTimerResult(
        sessions,
        startDate: dates.first.subtract(Duration(days: 7)),
        endDate: dates.last.subtract(Duration(days: 7)),
      );

      emit(LeaderboardLoaded(
        weeklyScoreboard,
        monthlyScoreboard,
        todaysSessions,
        timerValue,
        LastWeekScoreboard,
        goals,
        timeGoals,
        dates,
        selectedDate,
        dailySessions,
        weeklySessions,
        weeklySessionsLastWeek,
      ));
    });

    on<BackArrowPressed>((event, emit) {
      selectedDate = selectedDate.subtract(Duration(days: 1));
      if (!_hasLoaded) {
        return;
      }

      dailySessions = TodaysSessions.fromTimerResult(
        sessions,
        date: selectedDate,
      );
      dates = datesForWeek(selectedDate);

      weeklySessions = WeeklyScoreboard.fromTimerResult(
        sessions,
        startDate: dates.first,
        endDate: dates.last,
      );

      weeklySessionsLastWeek = WeeklyScoreboard.fromTimerResult(
        sessions,
        startDate: dates.first.subtract(Duration(days: 7)),
        endDate: dates.last.subtract(Duration(days: 7)),
      );

      emit(LeaderboardLoaded(
        weeklyScoreboard,
        monthlyScoreboard,
        todaysSessions,
        timerValue,
        LastWeekScoreboard,
        goals,
        timeGoals,
        dates,
        selectedDate,
        dailySessions,
        weeklySessions,
        weeklySessionsLastWeek,
      ));
    });

    on<ForwardArrowPressed>((event, emit) {
      selectedDate = selectedDate.add(Duration(days: 1));
      if (!_hasLoaded) {
        return;
      }

      dailySessions = TodaysSessions.fromTimerResult(
        sessions,
        date: selectedDate,
      );

      dates = datesForWeek(selectedDate);

      weeklySessions = WeeklyScoreboard.fromTimerResult(
        sessions,
        startDate: dates.first,
        endDate: dates.last,
      );

      weeklySessionsLastWeek = WeeklyScoreboard.fromTimerResult(
        sessions,
        startDate: dates.first.subtract(Duration(days: 7)),
        endDate: dates.last.subtract(Duration(days: 7)),
      );
      emit(LeaderboardLoaded(
        weeklyScoreboard,
        monthlyScoreboard,
        todaysSessions,
        timerValue,
        LastWeekScoreboard,
        goals,
        timeGoals,
        dates,
        selectedDate,
        dailySessions,
        weeklySessions,
        weeklySessionsLastWeek,
      ));
    });
  }

  List<DateTime> datesForWeek(DateTime dateTime) {
    dateTime = dateTime.copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    List<DateTime> dates = [];
    int dayOfWeek = dateTime.weekday;
    for (int i = 0; i < 7; i++) {
      dates.add(dateTime.subtract(Duration(days: dateTime.weekday - 1 - i)));
    }
    return dates;
  }
}

// on<LeaderboardRefresh>((event, emit) async {
//   List<TimerResult> sessions = await firestoreRepo.getSessions();
//   timeGoals = await firestoreRepo.getTimeGoals();

//   weeklyScoreboard = WeeklyScoreboard.thisWeekFromTimerResult(sessions);

//   monthlyScoreboard = MonthlyScoreboard.fromTimerResult(sessions);

//   todaysSessions = TodaysSessions.fromTimerResultToday(sessions);

//   LastWeekScoreboard = WeeklyScoreboard.lastWeekFromTimerResult(sessions);

//   //goals = await firestoreRepo.getGoals();

//   /// init the objects that are needed for the chart page
//   /// get the weekly sessions
//   /// get the monthly sessions
//   /// get the daily sessions
//   ///

//   // daily sessions, based on today
//     dailySessions = TodaysSessions.fromTimerResult(
//     sessions,
//     date: today,
//   );

//   /// day of week needed to get the start of the week
//   int dayOfWeek = today.weekday;
//   // weekly sessions, based on the start of the week and end.
//    weeklySessions = WeeklyScoreboard.fromTimerResult(
//     sessions,
//     startDate: today.subtract(Duration(days: dayOfWeek - 1)),
//     endDate: today.add(Duration(days: 7 - dayOfWeek)),
//   );
//   // list of dates that contain int for date, and true or false for past or future
//   List<Map<String, dynamic>> dates = [];
//   //// get the dates for this week
//   ///
//   /// 1. get the date for the start of the week
//   /// increment the date by 1 until the end of the week
//   /// if date < today add true to past, else add false
//   for (int i = 0; i < 7; i++) {
//     DateTime date = today
//         .subtract(Duration(days: dayOfWeek - 1 - i))
//         .copyWith(
//             hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
//     dates.add({
//       'date': date,
//       'past': date.isBefore(today),
//     });
//   }

//   emit(LeaderboardLoaded(weeklyScoreboard, monthlyScoreboard,
//       todaysSessions, timerValue, LastWeekScoreboard, goals, timeGoals));
// });
