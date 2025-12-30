import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/models/monthly_leaderboard.dart';
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
  final today = TodaysSessions(sessions: []);
  final goals = <Goal>[];
  final timeGoals = TimeGoalsAll();
  final dates = List.generate(7, (index) => DateTime(2024, 5, index + 1));
  final selectedDate = DateTime(2024, 5, 1);

  return LeaderboardLoaded(
    weekly,
    monthly,
    today,
    0,
    weekly,
    goals,
    timeGoals,
    dates,
    selectedDate,
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
          child: GraphicWeeklyChart(),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Mon'));
    expect(text.style?.color, Colors.white);
  });
}
