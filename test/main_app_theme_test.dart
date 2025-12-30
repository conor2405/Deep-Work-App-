import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/auth/auth_bloc.dart';
import 'package:deep_work/bloc/goal/goal_bloc.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/main.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/repo/firebase_auth_repo.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class MockTimerBloc extends MockBloc<TimerEvent, TimerState>
    implements TimerBloc {}

class MockLeaderboardBloc extends MockBloc<LeaderboardEvent, LeaderboardState>
    implements LeaderboardBloc {}

class MockGoalBloc extends MockBloc<GoalEvent, GoalState> implements GoalBloc {}

class MockFirebaseAuthRepo extends Mock implements FirebaseAuthRepo {}

class MockFirestoreRepo extends Mock implements FirestoreRepo {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final storageDirectory = await Directory.systemTemp.createTemp();
    HydratedBloc.storage =
        await HydratedStorage.build(storageDirectory: storageDirectory);
  });

  testWidgets('hydrated settings drive theme brightness', (tester) async {
    await HydratedBloc.storage.write('SettingsBloc', {
      'isDarkMode': false,
      'showMap': true,
      'showNotes': true,
    });

    final settingsBloc = SettingsBloc();
    final authBloc = MockAuthBloc();
    final timerBloc = MockTimerBloc();
    final leaderboardBloc = MockLeaderboardBloc();
    final goalBloc = MockGoalBloc();
    final authRepo = MockFirebaseAuthRepo();
    final firestoreRepo = MockFirestoreRepo();

    when(() => authBloc.state).thenReturn(Authenticated(null));
    when(() => timerBloc.state).thenReturn(TimerInitial(TimeModel(90 * 60)));

    await tester.pumpWidget(
      MyApp(
        authRepo: authRepo,
        firestoreRepo: firestoreRepo,
        authBloc: authBloc,
        timerBloc: timerBloc,
        leaderboardBloc: leaderboardBloc,
        goalBloc: goalBloc,
        settingsBloc: settingsBloc,
      ),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.colorScheme.brightness, Brightness.light);
  });
}
