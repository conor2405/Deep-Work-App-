import 'dart:io';

import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/widgets/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final storageDirectory = await Directory.systemTemp.createTemp();
    HydratedBloc.storage =
        await HydratedStorage.build(storageDirectory: storageDirectory);
  });

  testWidgets('switches dispatch events and mirror state', (tester) async {
    final settingsBloc = SettingsBloc();
    addTearDown(settingsBloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: settingsBloc,
          child: SettingsPage(),
        ),
      ),
    );

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));
    expect(find.text('Dark Mode'), findsNothing);

    expect(settingsBloc.state, isA<SettingsInitial>());
    expect((settingsBloc.state as SettingsInitial).isDarkMode, true);

    await tester.tap(switches.at(0));
    await tester.pump();

    expect((settingsBloc.state as SettingsInitial).showMap, false);

    await tester.tap(switches.at(1));
    await tester.pump();

    expect((settingsBloc.state as SettingsInitial).showNotes, false);
  });
}
