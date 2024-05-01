import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/widgets/central_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimerDonePage extends StatefulWidget {
  @override
  _TimerDonePageState createState() => _TimerDonePageState();
}

class _TimerDonePageState extends State<TimerDonePage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<TimerBloc, TimerState>(
      listener: (context, state) {
        if (state is TimerInitial) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Timer Done Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Container(
                      height: 400, width: 400, child: CentralTimer())),
              ElevatedButton(
                onPressed: () async {
                  BlocProvider.of<TimerBloc>(context).add(TimerConfirm());
                  await Future.delayed(Duration(milliseconds: 300));
                  BlocProvider.of<LeaderboardBloc>(context)
                      .add(LeaderboardRefresh());
                },
                child: Text('Go back to Timer Page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
