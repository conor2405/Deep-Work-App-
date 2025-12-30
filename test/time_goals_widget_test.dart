import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/models/monthly_leaderboard.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/models/todays_sessions.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
import 'package:deep_work/widgets/timegoals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLeaderboardBloc extends MockBloc<LeaderboardEvent, LeaderboardState>
    implements LeaderboardBloc {}

TimerResult buildTimerResult(int minutes) {
  final startTime = DateTime(2024, 5, 1, 9);
  return TimerResult(
    targetTime: TimeModel(minutes * 60),
    completed: true,
    timeLeft: TimeModel.zero(),
    timeRun: minutes * 60,
    breakTime: 0,
    timeElapsed: minutes * 60,
    startTime: startTime,
    timeFinished: startTime.add(Duration(minutes: minutes)),
    breakEvents: const [],
    breaks: 0,
    sessionEfficiency: 1,
  );
}

LeaderboardLoaded buildLeaderboardLoaded({
  required TodaysSessions todaysSessions,
  required TodaysSessions dailySessions,
  required WeeklyScoreboard weeklyScoreboard,
  required WeeklyScoreboard weeklySessions,
  required MonthlyScoreboard monthlyScoreboard,
  required TimeGoalsAll timeGoals,
}) {
  final dates = List.generate(7, (index) => DateTime(2024, 5, index + 1));
  final selectedDate = DateTime(2024, 5, 1);

  return LeaderboardLoaded(
    weeklyScoreboard,
    monthlyScoreboard,
    todaysSessions,
    0,
    weeklyScoreboard,
    <Goal>[],
    timeGoals,
    dates,
    selectedDate,
    dailySessions,
    weeklySessions,
    weeklySessions,
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

  testWidgets('TimeGoalsWidget uses dailySessions for changeable dates',
      (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final timeGoals = TimeGoalsAll()
      ..setDaily = TimeGoal(type: 'daily', goal: 60)
      ..setWeekly = TimeGoal(type: 'weekly', goal: 300)
      ..setMonthly = TimeGoal(type: 'monthly', goal: 600);

    final state = buildLeaderboardLoaded(
      todaysSessions: TodaysSessions(sessions: [buildTimerResult(120)]),
      dailySessions: TodaysSessions(sessions: [buildTimerResult(30)]),
      weeklyScoreboard: WeeklyScoreboard(
        monday: 0,
        tuesday: 0,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0,
        total: 0,
      ),
      weeklySessions: WeeklyScoreboard(
        monday: 0,
        tuesday: 0,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0,
        total: 0,
      ),
      monthlyScoreboard: MonthlyScoreboard(month: 'May', time: List.filled(31, 0)),
      timeGoals: timeGoals,
    );

    when(() => leaderboardBloc.state).thenReturn(state);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LeaderboardBloc>.value(
          value: leaderboardBloc,
          child: const TimeGoalsWidget(
            goalType: 'daily',
            changeableDate: true,
          ),
        ),
      ),
    );

    expect(find.text('0:30/1:00'), findsOneWidget);
  });

  testWidgets('TimeGoalsWidget uses weekly totals for weekly goals',
      (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final timeGoals = TimeGoalsAll()
      ..setDaily = TimeGoal(type: 'daily', goal: 60)
      ..setWeekly = TimeGoal(type: 'weekly', goal: 600)
      ..setMonthly = TimeGoal(type: 'monthly', goal: 600);

    final state = buildLeaderboardLoaded(
      todaysSessions: TodaysSessions(sessions: [buildTimerResult(120)]),
      dailySessions: TodaysSessions(sessions: [buildTimerResult(30)]),
      weeklyScoreboard: WeeklyScoreboard(
        monday: 120,
        tuesday: 60,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0,
        total: 180,
      ),
      weeklySessions: WeeklyScoreboard(
        monday: 120,
        tuesday: 60,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0,
        total: 180,
      ),
      monthlyScoreboard: MonthlyScoreboard(month: 'May', time: List.filled(31, 0)),
      timeGoals: timeGoals,
    );

    when(() => leaderboardBloc.state).thenReturn(state);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LeaderboardBloc>.value(
          value: leaderboardBloc,
          child: const TimeGoalsWidget(goalType: 'weekly'),
        ),
      ),
    );

    expect(find.text('3:00/10:00'), findsOneWidget);
  });

  testWidgets('TimeGoalsWidget routes by goal type', (tester) async {
    final leaderboardBloc = MockLeaderboardBloc();
    final timeGoals = TimeGoalsAll()
      ..setDaily = TimeGoal(type: 'daily', goal: 60)
      ..setWeekly = TimeGoal(type: 'weekly', goal: 600)
      ..setMonthly = TimeGoal(type: 'monthly', goal: 600);

    final state = buildLeaderboardLoaded(
      todaysSessions: TodaysSessions(sessions: [buildTimerResult(120)]),
      dailySessions: TodaysSessions(sessions: [buildTimerResult(30)]),
      weeklyScoreboard: WeeklyScoreboard(
        monday: 120,
        tuesday: 60,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0,
        total: 180,
      ),
      weeklySessions: WeeklyScoreboard(
        monday: 120,
        tuesday: 60,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0,
        total: 180,
      ),
      monthlyScoreboard: MonthlyScoreboard(month: 'May', time: List.filled(31, 0)),
      timeGoals: timeGoals,
    );

    when(() => leaderboardBloc.state).thenReturn(state);

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/timeGoalsPageWeekly': (context) =>
              const Scaffold(body: Text('Weekly Goal')),
        },
        home: BlocProvider<LeaderboardBloc>.value(
          value: leaderboardBloc,
          child: const TimeGoalsWidget(goalType: 'weekly'),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.text('Weekly Goal'), findsOneWidget);
  });
}
