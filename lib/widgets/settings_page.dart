import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsInitial) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Sidebar(),
                  Expanded(
                      child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Settings Page'),
                        SizedBox(
                          height: 100,
                        ),
                        Text('Dark Mode'),
                        Switch(
                            value: state.isDarkMode,
                            onChanged: (value) {
                              BlocProvider.of<SettingsBloc>(context)
                                  .add(ToggleDarkMode());
                            }),
                        Text('Show Map'),
                        Switch(
                            value: state.showMap,
                            onChanged: (value) {
                              BlocProvider.of<SettingsBloc>(context)
                                  .add(ToggleShowMap());
                            }),
                        Text('enable notes'),
                        Switch(
                            value: state.showNotes,
                            onChanged: (value) {
                              BlocProvider.of<SettingsBloc>(context)
                                  .add(ToggleNotes());
                            })
                      ],
                    ),
                  ))
                ],
              ),
              // Add your settings UI components here
            );
          } else {
            return Text('error loading settings page');
          }
        },
      ),
    );
  }
}
