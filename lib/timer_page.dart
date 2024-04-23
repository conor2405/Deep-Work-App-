import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/widgets/central_timer.dart';
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
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CentralTimer(),
        ),
      ),
    );
  }
}
