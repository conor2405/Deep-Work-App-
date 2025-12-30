import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storageDir;

  setUpAll(() async {
    storageDir = await Directory.systemTemp.createTemp();
    HydratedBloc.storage =
        await HydratedStorage.build(storageDirectory: storageDir);
  });

  setUp(() async {
    await HydratedBloc.storage.clear();
  });

  tearDownAll(() async {
    await HydratedBloc.storage.close();
    await storageDir.delete(recursive: true);
  });

  group('SettingsBloc', () {
    test('initial state uses default values', () {
      final bloc = SettingsBloc();
      expect(bloc.state, isA<SettingsInitial>());
      final state = bloc.state as SettingsInitial;
      expect(state.isDarkMode, true);
      expect(state.showMap, true);
      expect(state.showNotes, true);
    });

    blocTest<SettingsBloc, SettingsState>(
      'toggles dark mode',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(ToggleDarkMode()),
      expect: () => [
        isA<SettingsInitial>()
            .having((state) => state.isDarkMode, 'isDarkMode', false)
            .having((state) => state.showMap, 'showMap', true)
            .having((state) => state.showNotes, 'showNotes', true),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'toggles map visibility',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(ToggleShowMap()),
      expect: () => [
        isA<SettingsInitial>()
            .having((state) => state.showMap, 'showMap', false)
            .having((state) => state.isDarkMode, 'isDarkMode', true)
            .having((state) => state.showNotes, 'showNotes', true),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'toggles notes visibility',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(ToggleNotes()),
      expect: () => [
        isA<SettingsInitial>()
            .having((state) => state.showNotes, 'showNotes', false)
            .having((state) => state.isDarkMode, 'isDarkMode', true)
            .having((state) => state.showMap, 'showMap', true),
      ],
    );

    test('rehydrates persisted settings across instances', () async {
      final bloc = SettingsBloc();
      bloc.add(ToggleDarkMode());
      bloc.add(ToggleShowMap());
      bloc.add(ToggleNotes());
      await bloc.stream.firstWhere((state) {
        return state is SettingsInitial &&
            state.isDarkMode == false &&
            state.showMap == false &&
            state.showNotes == false;
      });
      await Future<void>.delayed(Duration(milliseconds: 1));
      await bloc.close();

      final rehydrated = SettingsBloc();
      final state = rehydrated.state as SettingsInitial;
      expect(state.isDarkMode, false);
      expect(state.showMap, false);
      expect(state.showNotes, false);
      await rehydrated.close();
    });

    test('defaults showNotes when missing from persisted state', () async {
      await HydratedBloc.storage.write('SettingsBloc', {
        'isDarkMode': false,
        'showMap': false,
      });

      final bloc = SettingsBloc();
      final state = bloc.state as SettingsInitial;
      expect(state.isDarkMode, false);
      expect(state.showMap, false);
      expect(state.showNotes, true);
      await bloc.close();
    });
  });
}
