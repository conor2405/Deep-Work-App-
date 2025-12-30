import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_helpers.dart';

class MockFirestoreRepo extends Mock implements FirestoreRepo {}

class MockTimerBloc extends MockBloc<TimerEvent, TimerState>
    implements TimerBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(LeaderboardInit());
    registerFallbackValue(SelectDate(DateTime(2024, 5, 8)));
  });

  blocTest<LeaderboardBloc, LeaderboardState>(
    'date navigation updates weekly and daily aggregates',
    build: () {
      final firestoreRepo = MockFirestoreRepo();
      final timerBloc = MockTimerBloc();

      when(() => firestoreRepo.getSessions()).thenAnswer((_) async {
        return [
          buildTimerResult(
              startTime: DateTime(2024, 5, 1, 10), timeRunSeconds: 600),
          buildTimerResult(
              startTime: DateTime(2024, 5, 8, 10), timeRunSeconds: 1200),
        ];
      });
      when(() => firestoreRepo.getTimeGoals())
          .thenAnswer((_) async => TimeGoalsAll());

      when(() => timerBloc.state).thenReturn(TimerInitial(TimeModel(90 * 60)));
      whenListen(
        timerBloc,
        Stream<TimerState>.fromIterable([TimerInitial(TimeModel(90 * 60))]),
        initialState: TimerInitial(TimeModel(90 * 60)),
      );

      return LeaderboardBloc(firestoreRepo: firestoreRepo, timerBloc: timerBloc);
    },
    act: (bloc) async {
      bloc.add(LeaderboardInit());
      await bloc.stream.firstWhere((state) => state is LeaderboardLoaded);
      bloc.add(SelectDate(DateTime(2024, 5, 8)));
    },
    expect: () => [
      isA<LeaderboardLoading>(),
      isA<LeaderboardLoaded>(),
      isA<LeaderboardLoaded>()
          .having((state) => state.dailySessions.totalMinutes,
              'daily minutes', 20)
          .having((state) => state.weeklySessions.total, 'weekly total', 20),
    ],
  );
}
