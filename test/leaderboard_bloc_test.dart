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
  MockFirestoreRepo({required this.sessionDate});

  final DateTime sessionDate;

  // this class should return a list of TimerResult objects when getSessions is called
  @override
  Future<List<TimerResult>> getSessions() async {
    return [
      TimerResult(
        targetTime: TimeModel(90 * 60),
        completed: true,
        timeLeft: TimeModel(0),
        timeRun: 90 * 60,
        timeElapsed: 90 * 60,
        startTime: sessionDate,
        timeFinished: sessionDate.add(const Duration(minutes: 90)),
        sessionEfficiency: 1,
      ),
    ];
  }

  @override
  Future<TimeGoalsAll> getTimeGoals() async {
    return TimeGoalsAll();
  }
}

const referenceDate = DateTime(2024, 6, 15);
final sessionDate = DateTime(2024, 6, 1, 9);

void main() {
  group('LeaderboardBloc', () {
    MockFirestoreRepo firestoreRepo =
        MockFirestoreRepo(sessionDate: sessionDate);
    setUp(() {
      firestoreRepo = MockFirestoreRepo(sessionDate: sessionDate);
    });
    blocTest('Emits [LeaderboardLoading] when built the loaded ',
        build: () => LeaderboardBloc(
            firestoreRepo: firestoreRepo,
            timerBloc: TimerBloc(firestoreRepo),
            referenceDate: referenceDate),
        act: (bloc) => bloc.add(LeaderboardInit()),
        //wait: const Duration(seconds: 4),
        expect: () => [isA<LeaderboardLoading>(), isA<LeaderboardLoaded>()]);
  });

  blocTest('emits correct weekly and monthly values',
      build: () => LeaderboardBloc(
          firestoreRepo: MockFirestoreRepo(sessionDate: sessionDate),
          timerBloc: TimerBloc(MockFirestoreRepo(sessionDate: sessionDate)),
          referenceDate: referenceDate),
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
