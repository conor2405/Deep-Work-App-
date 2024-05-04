import 'package:deep_work/bloc/settings/settings_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/widgets/central_timer.dart';
import 'package:deep_work/widgets/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is TimerDone) {
            Navigator.pushNamed(context, '/timer/confirm');
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsInitial) {
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(alignment: Alignment.center, children: [
                  Opacity(
                      opacity: 0.5, child: state.showMap ? WorldMap() : null),
                  Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: CentralTimer()),
                  Container(
                      padding: EdgeInsets.all(30),
                      alignment: Alignment.topRight,
                      child: IconButton(
                          icon: state.showMap
                              ? Icon(Icons.remove_red_eye)
                              : Icon(Icons.close),
                          onPressed: () =>
                              BlocProvider.of<SettingsBloc>(context).add(
                                ToggleShowMap(),
                              ))),
                ]),
              );
            } else {
              return Text('error loading timer page');
            }
          },
        ),
      ),
    );
  }
}
