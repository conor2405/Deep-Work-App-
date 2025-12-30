import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/models/monthly_leaderboard.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// FILEPATH: /Users/conorkelly/Deep Work /deep_work/test/leaderboard_bloc_test.dart

import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';

class MockFirestoreRepo extends Mock implements FirestoreRepo {
  // this class should return a list of TimerResult objects when getSessions is called
  @override
  Future<List<TimerResult>> getSessions() async {
    return [
      TimerResult(
        targetTime: TimeModel(90 * 60),
        completed: true,
        timeLeft: TimeModel(0),
        timePaused: 0,
        timeRun: 90 * 60,
        timeElapsed: 90 * 60,
        startTime: DateTime.now().subtract(Duration(
            days:
                8)), // picking a date that is this month but not this week most of the time
        timeFinished:
            DateTime.now().subtract(Duration(days: 7, hours: 22, minutes: 30)),
        pauseEvents: const [],
        pauses: 0,
        sessionEfficiency: 1,
      ),
    ];
  }

  @override
  Future<TimeGoalsAll> getTimeGoals() async {
    return TimeGoalsAll();
  }
}

void main() {
  group('LeaderboardBloc', () {
    MockFirestoreRepo firestoreRepo = MockFirestoreRepo();
    setUp(() {
      firestoreRepo = MockFirestoreRepo();
      TimerBloc timerBloc = TimerBloc(firestoreRepo);
    });
    blocTest('Emits [LeaderboardLoading] when built the loaded ',
        build: () => LeaderboardBloc(
            firestoreRepo: firestoreRepo, timerBloc: TimerBloc(firestoreRepo)),
        act: (bloc) => bloc.add(LeaderboardInit()),
        //wait: const Duration(seconds: 4),
        expect: () => [isA<LeaderboardLoading>(), isA<LeaderboardLoaded>()]);
  });

  blocTest('emits correct weekly and monthly values',
      build: () => LeaderboardBloc(
          firestoreRepo: MockFirestoreRepo(),
          timerBloc: TimerBloc(MockFirestoreRepo())),
      act: (bloc) {
        bloc.add(LeaderboardInit());
      },
      expect: () => [
            isA<LeaderboardLoading>(),
            isA<LeaderboardLoaded>()
                .having(
                    (p0) => p0.monthlyScoreboard,
                    'emits monthly scoreboard',
                    isA<MonthlyScoreboard>().having(
                        (p0) => p0.total,
                        'monthly scoreboard with correct total',
                        90)) // the total is 90 minutes for the month
                .having(
                    (p0) => p0.weeklyScoreboard,
                    'Weeklyscoreboard emits',
                    isA<WeeklyScoreboard>().having(
                        (p0) => p0.total,
                        'weekly scoreboard with correct total',
                        0)), // the total is 0 minutes for the week
          ]);
}
