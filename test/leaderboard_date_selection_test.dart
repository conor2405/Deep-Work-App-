import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestoreRepo extends Mock implements FirestoreRepo {
  @override
  Future<List<TimerResult>> getSessions() async {
    return [];
  }

  @override
  Future<TimeGoalsAll> getTimeGoals() async {
    return TimeGoalsAll();
  }
}

DateTime startOfWeek(DateTime date) {
  final normalized =
      date.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

void main() {
  group('LeaderboardBloc date selection', () {
    blocTest<LeaderboardBloc, LeaderboardState>(
        'SelectDate updates selectedDate and week range',
        build: () => LeaderboardBloc(
            firestoreRepo: MockFirestoreRepo(),
            timerBloc: TimerBloc(MockFirestoreRepo())),
        act: (bloc) async {
          bloc.add(LeaderboardInit());
          await bloc.stream.firstWhere((state) => state is LeaderboardLoaded);
          bloc.add(SelectDate(DateTime(2024, 5, 3)));
        },
        expect: () => [
              isA<LeaderboardLoading>(),
              isA<LeaderboardLoaded>(),
              isA<LeaderboardLoaded>()
                  .having((state) => state.selectedDate, 'selectedDate',
                      DateTime(2024, 5, 3))
                  .having((state) => state.dates.first, 'weekStart',
                      startOfWeek(DateTime(2024, 5, 3))),
            ]);

    blocTest<LeaderboardBloc, LeaderboardState>(
        'BackArrowPressed moves selectedDate back one day',
        build: () => LeaderboardBloc(
            firestoreRepo: MockFirestoreRepo(),
            timerBloc: TimerBloc(MockFirestoreRepo())),
        act: (bloc) async {
          bloc.add(LeaderboardInit());
          await bloc.stream.firstWhere((state) => state is LeaderboardLoaded);
          bloc.add(SelectDate(DateTime(2024, 5, 3)));
          await bloc.stream.firstWhere((state) =>
              state is LeaderboardLoaded &&
              state.selectedDate == DateTime(2024, 5, 3));
          bloc.add(BackArrowPressed());
        },
        expect: () => [
              isA<LeaderboardLoading>(),
              isA<LeaderboardLoaded>(),
              isA<LeaderboardLoaded>(),
              isA<LeaderboardLoaded>().having((state) => state.selectedDate,
                  'selectedDate', DateTime(2024, 5, 2)),
            ]);

    blocTest<LeaderboardBloc, LeaderboardState>(
        'ForwardArrowPressed moves selectedDate forward one day',
        build: () => LeaderboardBloc(
            firestoreRepo: MockFirestoreRepo(),
            timerBloc: TimerBloc(MockFirestoreRepo())),
        act: (bloc) async {
          bloc.add(LeaderboardInit());
          await bloc.stream.firstWhere((state) => state is LeaderboardLoaded);
          bloc.add(SelectDate(DateTime(2024, 5, 3)));
          await bloc.stream.firstWhere((state) =>
              state is LeaderboardLoaded &&
              state.selectedDate == DateTime(2024, 5, 3));
          bloc.add(ForwardArrowPressed());
        },
        expect: () => [
              isA<LeaderboardLoading>(),
              isA<LeaderboardLoaded>(),
              isA<LeaderboardLoaded>(),
              isA<LeaderboardLoaded>().having((state) => state.selectedDate,
                  'selectedDate', DateTime(2024, 5, 4)),
            ]);
  });
}
