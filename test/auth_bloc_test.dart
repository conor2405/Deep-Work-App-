import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/auth/auth_bloc.dart';
import 'package:deep_work/repo/firebase_auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuthRepo extends Mock implements FirebaseAuthRepo {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storageDir;

  setUpAll(() async {
    storageDir = await Directory.systemTemp.createTemp();
    HydratedBloc.storage =
        await HydratedStorage.build(storageDirectory: storageDir);
  });

  tearDownAll(() async {
    await HydratedBloc.storage.close();
    await storageDir.delete(recursive: true);
  });

  group('AuthBloc', () {
    late MockFirebaseAuthRepo authRepo;
    late StreamController<User?> authController;
    late MockUser mockUser;

    setUp(() {
      authRepo = MockFirebaseAuthRepo();
      mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('user-1');
      authController = StreamController<User?>.broadcast();
      when(() => authRepo.authStateChanges)
          .thenAnswer((_) => authController.stream);
    });

    tearDown(() async {
      await authController.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits Authenticated when authStateChanges emits a user',
      build: () {
        when(() => authRepo.isSignedIn).thenReturn(true);
        when(() => authRepo.currentUser).thenReturn(mockUser);
        return AuthBloc(authRepo);
      },
      act: (bloc) => authController.add(mockUser),
      expect: () => [
        isA<Authenticated>().having((state) => state.user, 'user', mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits Unauthenticated when authStateChanges emits null',
      build: () {
        when(() => authRepo.isSignedIn).thenReturn(false);
        when(() => authRepo.currentUser).thenReturn(null);
        return AuthBloc(authRepo);
      },
      act: (bloc) => authController.add(null),
      expect: () => [isA<Unauthenticated>()],
    );
  });
}
