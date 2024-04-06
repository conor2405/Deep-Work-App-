import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:equatable/equatable.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  late TimerStats timerResult;
  Timer? timer;

  void startTimer(int duration) async {
    int counter = duration;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time.seconds = counter;
      TimerRunning(time);
      counter--;
      this.add(Tick(counter));
      print(counter);
      if (counter < 0) {
        timer.cancel();
        this.add(TimerEnd());
      }
    });
  }

  TimeModel time = TimeModel(90 * 60); // 90 minutes

  TimerBloc(FirestoreRepo firestoreRepo)
      : super(TimerInitial(TimeModel(90 * 60))) {
    on<TimerStart>((event, emit) async {
      TimerRunning(time);
      timerResult =
          TimerStats(targetTime: time.minutes, startTime: DateTime.now());
      timerResult.duration = time.minutes;

      startTimer(time.minutes * 60);
    });

    on<TimerEnd>((event, emit) async {
      firestoreRepo.postSession(timerResult);
      emit(TimerDone(true));
    });

    on<TimerReset>((event, emit) async {
      time.setMinutes = 90;
      print(time.seconds); // increment index to trigger a rebuild
      emit(TimerInitial(TimeModel(90 * 60)));
    });
    // keeps track of time on widget, is called by the onend callback in the [SleekCircularSlider]
    on<TimeUpdate>((event, emit) async {
      print(event.time.seconds);
      time.seconds = event.time.seconds;
      emit(TimerInitial(time));
    });
    on<Tick>((event, emit) async {
      emit(TimerRunning(TimeModel(event.counter)));
    });

    @override
    Future<void> close() {
      if (timer != null) {
        timer?.cancel();
      }
      return super.close();
    }
  }
}
