import 'package:deep_work/models/monthly_leaderboard.dart';
import 'package:deep_work/models/todays_sessions.dart';
import 'package:deep_work/models/weekly_leaderboard.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  test('WeeklyScoreboard respects week boundaries with reference date', () {
    final referenceDate = DateTime(2024, 5, 8); // Wednesday
    final monday = DateTime(2024, 5, 6, 9);
    final sunday = DateTime(2024, 5, 12, 9);
    final outside = DateTime(2024, 5, 13, 9);

    final results = [
      buildTimerResult(startTime: monday, timeRunSeconds: 600),
      buildTimerResult(startTime: sunday, timeRunSeconds: 1200),
      buildTimerResult(startTime: outside, timeRunSeconds: 1800),
    ];

    final scoreboard = WeeklyScoreboard.thisWeekFromTimerResult(
      results,
      referenceDate: referenceDate,
    );

    expect(scoreboard.monday, 10);
    expect(scoreboard.sunday, 20);
    expect(scoreboard.total, 30);
  });

  test('MonthlyScoreboard uses provided reference month', () {
    final referenceDate = DateTime(2024, 5, 15);
    final inMonth = DateTime(2024, 5, 15, 12);
    final otherMonth = DateTime(2024, 4, 15, 12);

    final results = [
      buildTimerResult(startTime: inMonth, timeRunSeconds: 1200),
      buildTimerResult(startTime: otherMonth, timeRunSeconds: 600),
    ];

    final scoreboard = MonthlyScoreboard.fromTimerResult(
      results,
      referenceDate: referenceDate,
    );

    expect(scoreboard.time[14], 20);
    expect(scoreboard.total, 20);
  });

  test('TodaysSessions uses provided reference date', () {
    final referenceDate = DateTime(2024, 5, 15);
    final sameDay = DateTime(2024, 5, 15, 10);
    final nextDay = DateTime(2024, 5, 16, 10);

    final results = [
      buildTimerResult(startTime: sameDay, timeRunSeconds: 600),
      buildTimerResult(startTime: nextDay, timeRunSeconds: 600),
    ];

    final sessions = TodaysSessions.fromTimerResultToday(
      results,
      referenceDate: referenceDate,
    );

    expect(sessions.sessions.length, 1);
    expect(sessions.totalMinutes, 10);
  });
}
