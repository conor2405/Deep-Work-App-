import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
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

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(TimerStart());
    registerFallbackValue(TimerPause());
    registerFallbackValue(TimerResume());
    registerFallbackValue(TimerAddFive());
    registerFallbackValue(TimerTakeFive());
    registerFallbackValue(TimerSetNotes(''));
    registerFallbackValue(TimerSubmitNotes());
    registerFallbackValue(ToggleNotes());
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
    final settingsBloc = MockSettingsBloc();
    when(() => timerBloc.state).thenReturn(TimerInitial(TimeModel(90 * 60)));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: true));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<TimerBloc>.value(value: timerBloc),
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
            ],
            child: CentralTimer(),
          ),
        ),
      ),
    );

    expect(find.text('01:30:00'), findsOneWidget);
  });

  testWidgets('dispatches timer events on button taps', (tester) async {
    final timerBloc = MockTimerBloc();
    final settingsBloc = MockSettingsBloc();
    final stats = TimerStats(targetTime: TimeModel(600));
    stats.timeLeft = TimeModel(600);

    when(() => timerBloc.state).thenReturn(TimerRunning(stats));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: true));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<TimerBloc>.value(value: timerBloc),
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
            ],
            child: CentralTimer(),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.pause));
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.tap(find.byIcon(Icons.remove));
    await tester.tap(find.byIcon(Icons.add));

    verify(() => timerBloc.add(any(that: isA<TimerPause>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerResume>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerTakeFive>()))).called(1);
    verify(() => timerBloc.add(any(that: isA<TimerAddFive>()))).called(1);
  });

  testWidgets('notes panel respects settings', (tester) async {
    final timerBloc = MockTimerBloc();
    final settingsBloc = MockSettingsBloc();
    final stats = TimerStats(targetTime: TimeModel(600));
    stats.timeLeft = TimeModel(600);

    when(() => timerBloc.state).thenReturn(TimerRunning(stats));
    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: true));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<TimerBloc>.value(value: timerBloc),
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
            ],
            child: CentralTimer(),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notes_rounded), findsOneWidget);

    when(() => settingsBloc.state).thenReturn(SettingsInitial(showNotes: false));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<TimerBloc>.value(value: timerBloc),
              BlocProvider<SettingsBloc>.value(value: settingsBloc),
            ],
            child: CentralTimer(),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
