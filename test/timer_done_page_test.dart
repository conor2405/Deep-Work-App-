import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/timer_done_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTimerBloc extends MockBloc<TimerEvent, TimerState>
    implements TimerBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockLeaderboardBloc extends MockBloc<LeaderboardEvent, LeaderboardState>
    implements LeaderboardBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(TimerConfirm());
    registerFallbackValue(TimerSetNotes(''));
    registerFallbackValue(TimerSetFocusRating(1));
    registerFallbackValue(TimerSubmitNotes());
    registerFallbackValue(LeaderboardRefresh());
  });

  Widget buildSubject({
    required TimerBloc timerBloc,
    required SettingsBloc settingsBloc,
    required LeaderboardBloc leaderboardBloc,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TimerBloc>.value(value: timerBloc),
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
        ],
        child: TimerDonePage(),
      ),
    );
  }

  Widget buildNavSubject({
    required TimerBloc timerBloc,
    required SettingsBloc settingsBloc,
    required LeaderboardBloc leaderboardBloc,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const Scaffold(body: SizedBox.shrink()),
      routes: {
        '/timer/confirm': (_) => MultiBlocProvider(
              providers: [
                BlocProvider<TimerBloc>.value(value: timerBloc),
                BlocProvider<SettingsBloc>.value(value: settingsBloc),
                BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
              ],
              child: TimerDonePage(),
            ),
      },
    );
  }

  testWidgets('shows reflection field when notes are enabled', (tester) async {
    final timerBloc = MockTimerBloc();
    final settingsBloc = MockSettingsBloc();
    final leaderboardBloc = MockLeaderboardBloc();
    final stats = TimerStats(targetTime: TimeModel(600));

    when(() => timerBloc.state).thenReturn(TimerDone(stats));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: true));
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading());

    await tester.pumpWidget(buildSubject(
      timerBloc: timerBloc,
      settingsBloc: settingsBloc,
      leaderboardBloc: leaderboardBloc,
    ));

    expect(find.text('What did you get done?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('shows focus rating prompt', (tester) async {
    final timerBloc = MockTimerBloc();
    final settingsBloc = MockSettingsBloc();
    final leaderboardBloc = MockLeaderboardBloc();
    final stats = TimerStats(targetTime: TimeModel(600));

    when(() => timerBloc.state).thenReturn(TimerDone(stats));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: false));
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading());

    await tester.pumpWidget(buildSubject(
      timerBloc: timerBloc,
      settingsBloc: settingsBloc,
      leaderboardBloc: leaderboardBloc,
    ));

    expect(find.text('How focused did you feel?'), findsOneWidget);
    expect(find.text('5. Deep focus 🎯'), findsOneWidget);
  });

  testWidgets('hides reflection field when notes are disabled', (tester) async {
    final timerBloc = MockTimerBloc();
    final settingsBloc = MockSettingsBloc();
    final leaderboardBloc = MockLeaderboardBloc();
    final stats = TimerStats(targetTime: TimeModel(600));

    when(() => timerBloc.state).thenReturn(TimerDone(stats));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: false));
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading());

    await tester.pumpWidget(buildSubject(
      timerBloc: timerBloc,
      settingsBloc: settingsBloc,
      leaderboardBloc: leaderboardBloc,
    ));

    expect(find.text('What did you get done?'), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('shows session summary stats', (tester) async {
    final timerBloc = MockTimerBloc();
    final settingsBloc = MockSettingsBloc();
    final leaderboardBloc = MockLeaderboardBloc();
    final stats = TimerStats(targetTime: TimeModel(600))
      ..timeRun = 1200
      ..breakTime = 300;

    when(() => timerBloc.state).thenReturn(TimerDone(stats));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: false));
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading());

    await tester.pumpWidget(buildSubject(
      timerBloc: timerBloc,
      settingsBloc: settingsBloc,
      leaderboardBloc: leaderboardBloc,
    ));

    expect(find.text('Session timeline'), findsOneWidget);
    expect(find.text('Focus time'), findsOneWidget);
    expect(find.text('Break time'), findsOneWidget);
    expect(find.text('Started at'), findsOneWidget);
    final timelineSize = tester.getSize(
      find.byKey(const ValueKey('sessionTimelineBar')),
    );
    expect(timelineSize.width, greaterThan(200));
  });

  testWidgets('submits reflection before confirming', (tester) async {
    final timerBloc = MockTimerBloc();
    final settingsBloc = MockSettingsBloc();
    final leaderboardBloc = MockLeaderboardBloc();
    final stats = TimerStats(targetTime: TimeModel(600));

    when(() => timerBloc.state).thenReturn(TimerDone(stats));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: true));
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading());
    when(() => timerBloc.add(any())).thenReturn(null);
    when(() => leaderboardBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(buildSubject(
      timerBloc: timerBloc,
      settingsBloc: settingsBloc,
      leaderboardBloc: leaderboardBloc,
    ));

    await tester.enterText(find.byType(TextField), 'Shipped report');
    final focusOption = find.text('4. Mostly focused 🙂');
    await tester.ensureVisible(focusOption);
    await tester.tap(focusOption);
    final confirmButton = find.widgetWithText(ElevatedButton, 'Confirm');
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    verify(() => timerBloc.add(any(
          that: isA<TimerSetNotes>()
              .having((event) => event.notes, 'notes', 'Shipped report'),
        ))).called(1);
    verify(() => timerBloc.add(any(
          that: isA<TimerSetFocusRating>()
              .having((event) => event.rating, 'rating', 4),
        ))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerSubmitNotes>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerConfirm>()))).called(1);
    verify(() => leaderboardBloc.add(any(that: isA<LeaderboardRefresh>()))).
        called(1);
  });

  testWidgets('does not show a back button', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final timerBloc = MockTimerBloc();
    final settingsBloc = MockSettingsBloc();
    final leaderboardBloc = MockLeaderboardBloc();
    final stats = TimerStats(targetTime: TimeModel(600));

    when(() => timerBloc.state).thenReturn(TimerDone(stats));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: true));
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading());

    await tester.pumpWidget(buildNavSubject(
      timerBloc: timerBloc,
      settingsBloc: settingsBloc,
      leaderboardBloc: leaderboardBloc,
      navigatorKey: navigatorKey,
    ));

    navigatorKey.currentState!.pushNamed('/timer/confirm');
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsNothing);
  });
}
