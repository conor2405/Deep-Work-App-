import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/models/monthly_leaderboard.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/models/todays_sessions.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
import 'package:deep_work/widgets/day_bar.dart';
import 'package:deep_work/widgets/graphic_weekly_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLeaderboardBloc extends MockBloc<LeaderboardEvent, LeaderboardState>
    implements LeaderboardBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

LeaderboardLoaded buildLeaderboardLoaded() {
  return buildLeaderboardLoadedWithSessions();
}

LeaderboardLoaded buildLeaderboardLoadedWithSessions(
    {List<TimerResult> sessions = const [], DateTime? selectedDate}) {
  final weekly = WeeklyScoreboard(
    monday: 0,
    tuesday: 0,
    wednesday: 0,
    thursday: 0,
    friday: 0,
    saturday: 0,
    sunday: 0,
    total: 0,
  );
  final monthly = MonthlyScoreboard(month: 'May', time: List.filled(31, 0));
  final today = TodaysSessions(sessions: sessions);
  final goals = <Goal>[];
  final timeGoals = TimeGoalsAll();
  final dates = List.generate(7, (index) => DateTime(2024, 5, index + 1));
  final selected = selectedDate ?? DateTime(2024, 5, 1);

  return LeaderboardLoaded(
    weekly,
    monthly,
    today,
    0,
    weekly,
    goals,
    timeGoals,
    dates,
    selected,
    today,
    weekly,
    weekly,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final storageDirectory = await Directory.systemTemp.createTemp();
    HydratedBloc.storage =
        await HydratedStorage.build(storageDirectory: storageDirectory);
  });

  tearDownAll(() async {
    await HydratedBloc.storage.close();
  });

  testWidgets('DayBar background color respects dark mode', (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final settingsBloc = MockSettingsBloc();
    final state = buildLeaderboardLoaded();

    when(() => leaderboardBloc.state).thenReturn(state);
    when(() => settingsBloc.isDarkMode).thenReturn(true);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
          ],
          child: DayBar(),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.grey));
    expect(container, isNotNull);

    when(() => settingsBloc.isDarkMode).thenReturn(false);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
          ],
          child: DayBar(),
        ),
      ),
    );

    final lightContainer = tester.widget<Container>(find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.grey[200]));
    expect(lightContainer, isNotNull);
  });

  testWidgets('GraphicWeeklyChart label color respects dark mode',
      (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final state = buildLeaderboardLoaded();
    final theme =
        ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue));

    when(() => leaderboardBloc.state).thenReturn(state);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
          ],
          child: GraphicWeeklyChart(),
        ),
        theme: theme,
      ),
    );

    final text = tester.widget<Text>(find.text('Mon'));
    expect(text.style?.color, theme.colorScheme.onSurface.withOpacity(0.7));
  });

  testWidgets('DayBar shows break segments for sessions', (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final settingsBloc = MockSettingsBloc();
    final startTime = DateTime(2024, 5, 1, 9);
    final breakStart = DateTime(2024, 5, 1, 9, 30);
    final breakEnd = DateTime(2024, 5, 1, 9, 45);
    final timerResult = TimerResult(
      targetTime: TimeModel(3600),
      completed: true,
      timeLeft: TimeModel.zero(),
      timeRun: 3600,
      breakTime: 0,
      timeElapsed: 3600,
      startTime: startTime,
      timeFinished: DateTime(2024, 5, 1, 10),
      breakEvents: [
        BreakPeriod(startTime: breakStart, endTime: breakEnd),
      ],
      breaks: 1,
      sessionEfficiency: 0.8,
    );
    final state =
        buildLeaderboardLoadedWithSessions(sessions: [timerResult]);

    when(() => leaderboardBloc.state).thenReturn(state);
    when(() => settingsBloc.isDarkMode).thenReturn(false);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
          ],
          child: DayBar(),
        ),
      ),
    );

    final breakSegmentFinder = find.byWidgetPredicate((widget) {
      return widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.blueGrey;
    });
    expect(breakSegmentFinder, findsWidgets);
  });

  testWidgets('DayBar renders milestone labels and current time indicator',
      (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final settingsBloc = MockSettingsBloc();
    final state = buildLeaderboardLoaded();

    when(() => leaderboardBloc.state).thenReturn(state);
    when(() => settingsBloc.isDarkMode).thenReturn(false);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
          ],
          child: DayBar(),
        ),
      ),
    );

    expect(find.text('Noon'), findsOneWidget);
    expect(find.text('6a'), findsOneWidget);
    expect(find.text('9a'), findsOneWidget);
    expect(find.text('3p'), findsOneWidget);
    expect(find.text('6p'), findsOneWidget);
    expect(find.text('9p'), findsOneWidget);
    expect(find.byKey(const Key('day_bar_now_indicator')), findsOneWidget);
  });

  testWidgets('DayBar shows current time indicator for today selection',
      (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final settingsBloc = MockSettingsBloc();
    final state =
        buildLeaderboardLoadedWithSessions(selectedDate: DateTime.now());

    when(() => leaderboardBloc.state).thenReturn(state);
    when(() => settingsBloc.isDarkMode).thenReturn(false);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
          ],
          child: DayBar(changeableDate: true),
        ),
      ),
    );

    expect(find.byKey(const Key('day_bar_now_indicator')), findsOneWidget);
  });

  testWidgets('DayBar hides current time indicator for historical views',
      (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final settingsBloc = MockSettingsBloc();
    final state = buildLeaderboardLoadedWithSessions(
      selectedDate: DateTime(2024, 5, 1),
    );

    when(() => leaderboardBloc.state).thenReturn(state);
    when(() => settingsBloc.isDarkMode).thenReturn(false);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
          ],
          child: DayBar(changeableDate: true),
        ),
      ),
    );

    expect(find.byKey(const Key('day_bar_now_indicator')), findsNothing);
  });
}
