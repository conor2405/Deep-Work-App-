import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/ToDo/to_do_bloc.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestoreRepo extends Mock implements FirestoreRepo {}

class MockUser extends Mock implements User {}

void main() {
  group('ToDoBloc', () {
    late MockFirestoreRepo firestoreRepo;
    late MockUser user;

    setUp(() {
      firestoreRepo = MockFirestoreRepo();
      user = MockUser();
    });

    blocTest<ToDoBloc, ToDoState>(
      'emits loaded goals on init',
      build: () => ToDoBloc(firestoreRepo, userOverride: user),
      act: (bloc) => bloc.add(ToDoInit()),
      expect: () => [
        isA<ToDoInitial>(),
        isA<ToDoLoaded>()
            .having((state) => state.goals.length, 'goals length', 1)
            .having((state) => state.goals.first.tasks.length, 'task count', 5),
      ],
    );
  });
}
