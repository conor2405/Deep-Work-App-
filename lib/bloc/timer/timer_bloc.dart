import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class Ticker {
  const Ticker();
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(Duration(milliseconds: 100), (x) => ticks * x)
        .take(ticks);
  }
}

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  late TimerResult timerResult;
  late Timer timer;

  TimerBloc(FirestoreRepo firestoreRepo) : super(TimerInitial()) {
    on<TimerStart>((event, emit) async {
      timerResult =
          TimerResult(targetTime: event.duration, startTime: DateTime.now());
      timerResult.duration = timerResult.targetTime - 15;

      emit(TimerRunning(timerResult.duration));
    });

    on<TimerEnd>((event, emit) async {
      firestoreRepo.postSession(timerResult);
      emit(TimerDone(true));
    });
  }
}
