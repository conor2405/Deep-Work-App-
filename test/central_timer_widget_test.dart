import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/widgets/central_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockTimerBloc extends MockBloc<TimerEvent, TimerState>
    implements TimerBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(TimerStart());
    registerFallbackValue(TimerEnd());
    registerFallbackValue(TimerAddFive());
    registerFallbackValue(TimerTakeFive());
    registerFallbackValue(TimerStartBreak(TimeModel(300)));
    registerFallbackValue(TimerEndBreak());
    registerFallbackValue(TimerBreakAddFive());
    registerFallbackValue(TimerBreakTakeFive());
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 1200);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });
  });

  testWidgets('renders time from TimerBloc state', (tester) async {
    final timerBloc = MockTimerBloc();
    when(() => timerBloc.state).thenReturn(TimerInitial(TimeModel(90 * 60)));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TimerBloc>.value(
            value: timerBloc,
            child: CentralTimer(),
          ),
        ),
      ),
    );

    expect(find.text('01:30:00'), findsOneWidget);
  });

  testWidgets('shows date and time before timer starts', (tester) async {
    final timerBloc = MockTimerBloc();
    when(() => timerBloc.state).thenReturn(TimerInitial(TimeModel(90 * 60)));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TimerBloc>.value(
            value: timerBloc,
            child: CentralTimer(),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('home-date')), findsOneWidget);
    expect(find.byKey(const Key('home-time')), findsOneWidget);
  });

  testWidgets('dispatches timer events on button taps', (tester) async {
    final timerBloc = MockTimerBloc();
    final stats = TimerStats(targetTime: TimeModel(600));
    stats.timeLeft = TimeModel(600);

    when(() => timerBloc.state).thenReturn(TimerRunning(stats));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TimerBloc>.value(
            value: timerBloc,
            child: CentralTimer(),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove));
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.stop_circle_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'End Session'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.free_breakfast));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Start Break'));
    await tester.pumpAndSettle();

    verify(() => timerBloc.add(any(that: isA<TimerTakeFive>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerAddFive>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerEnd>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerStartBreak>()))).called(1);
  });

  testWidgets('break controls dispatch events', (tester) async {
    final timerBloc = MockTimerBloc();
    final stats = TimerStats(targetTime: TimeModel(600));
    stats.breakTargetTime = TimeModel(300);
    stats.breakTimeLeft = TimeModel(300);

    when(() => timerBloc.state).thenReturn(TimerBreakRunning(stats));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TimerBloc>.value(
            value: timerBloc,
            child: CentralTimer(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('End Break'));
    await tester.tap(find.byIcon(Icons.remove));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    verify(() => timerBloc.add(any(that: isA<TimerEndBreak>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerBreakTakeFive>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerBreakAddFive>()))).called(1);
  });
}
