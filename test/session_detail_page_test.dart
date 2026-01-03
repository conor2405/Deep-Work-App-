import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/widgets/session_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SessionDetailPage shows focus rating and notes', (tester) async {
    final session = TimerResult(
      timeLeft: TimeModel.zero(),
      targetTime: TimeModel(1500),
      completed: true,
      timeRun: 1200,
      breakTime: 300,
      timeElapsed: 1500,
      startTime: DateTime(2024, 1, 1, 9, 0),
      timeFinished: DateTime(2024, 1, 1, 9, 25),
      sessionEfficiency: 0.8,
      notes: const ['Finished the draft', 'Sent the update'],
      focusRating: 4,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDetailPage(session: session),
      ),
    );

    expect(find.text('Session details'), findsOneWidget);
    expect(find.text('Focus rating'), findsOneWidget);
    expect(find.textContaining('Mostly focused'), findsOneWidget);
    expect(find.textContaining('Finished the draft'), findsOneWidget);
    expect(find.textContaining('Sent the update'), findsOneWidget);
  });
}
