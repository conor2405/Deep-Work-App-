import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/timer_page.dart';
import 'package:deep_work/widgets/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockTimerBloc extends MockBloc<TimerEvent, TimerState>
    implements TimerBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

void main() {
  testWidgets('map toggles with settings showMap', (tester) async {
    final timerBloc = MockTimerBloc();
    final settingsBlocOn = MockSettingsBloc();
    final settingsBlocOff = MockSettingsBloc();

    when(() => timerBloc.state).thenReturn(TimerInitial(TimeModel(90 * 60)));
    when(() => settingsBlocOn.state)
        .thenReturn(SettingsInitial(showMap: true));
    when(() => settingsBlocOff.state)
        .thenReturn(SettingsInitial(showMap: false));

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TimerBloc>.value(value: timerBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBlocOn),
          ],
          child: TimerPage(),
        ),
      ),
    );

    expect(find.byType(WorldMap), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TimerBloc>.value(value: timerBloc),
            BlocProvider<SettingsBloc>.value(value: settingsBlocOff),
          ],
          child: TimerPage(),
        ),
      ),
    );

    expect(find.byType(WorldMap), findsNothing);
  });
}
