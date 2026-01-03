import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/widgets/session_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SessionSummaryCard shows timeline and stats for a session',
      (tester) async {
    final session = TimerResult(
      timeLeft: TimeModel.zero(),
      targetTime: TimeModel(1500),
      completed: true,
      timeRun: 1200,
      breakTime: 300,
      timeElapsed: 1500,
      startTime: DateTime(2024, 1, 1, 9, 0),
      timeFinished: DateTime(2024, 1, 1, 9, 25),
      breakEvents: [
        BreakPeriod(
          startTime: DateTime(2024, 1, 1, 9, 10),
          endTime: DateTime(2024, 1, 1, 9, 15),
        ),
      ],
      sessionEfficiency: 0.8,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionSummaryCard.fromTimerResult(timeResult: session),
        ),
      ),
    );

    expect(find.text('Session timeline'), findsOneWidget);
    expect(find.text('Focus time'), findsOneWidget);
    expect(find.text('Break time'), findsOneWidget);
    expect(find.text('Started at'), findsOneWidget);
    expect(find.byKey(const ValueKey('sessionTimelineBar')), findsOneWidget);
  });
}
