import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/goal/goal_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestoreRepo extends Mock implements FirestoreRepo {}

void main() {
  setUpAll(() {
    registerFallbackValue(TimeGoalsAll());
  });

  group('GoalBloc', () {
    late MockFirestoreRepo firestoreRepo;

    setUp(() {
      firestoreRepo = MockFirestoreRepo();
    });

    blocTest<GoalBloc, GoalState>(
      'emits GoalsLoaded on init',
      build: () {
        final timeGoals = TimeGoalsAll();
        timeGoals.daily = TimeGoal(type: 'daily', goal: 30, completed: 0);
        when(() => firestoreRepo.getTimeGoals())
            .thenAnswer((_) async => timeGoals);
        return GoalBloc(firestoreRepo);
      },
      act: (bloc) => bloc.add(GoalInit()),
      expect: () => [
        isA<GoalsLoaded>().having(
            (state) => state.timeGoals.daily.goal, 'daily goal', 30),
      ],
      verify: (_) {
        verify(() => firestoreRepo.getTimeGoals()).called(1);
      },
    );

    blocTest<GoalBloc, GoalState>(
      'updates daily goal on SetTimeGoal',
      build: () {
        when(() => firestoreRepo.setTimeGoal(any())).thenAnswer((_) {});
        return GoalBloc(firestoreRepo);
      },
      act: (bloc) =>
          bloc.add(SetTimeGoal(TimeGoal(type: 'daily', goal: 45, completed: 0))),
      expect: () => [
        isA<GoalsLoaded>().having(
            (state) => state.timeGoals.daily.goal, 'daily goal', 45),
      ],
      verify: (_) {
        verify(() => firestoreRepo.setTimeGoal(any())).called(1);
      },
    );
  });
}
