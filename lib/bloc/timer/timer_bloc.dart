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
  Timer? _timer;

  void _startTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timerResult.tick();

      // ignore: invalid_use_of_visible_for_testing_member
      emit(TimerRunning(timerResult));

      if (timerResult.timeLeft.seconds < 0) {
        timerResult.completed = true;
        timer.cancel();
        add(TimerEnd());
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  TimeModel time = TimeModel(90 * 60); // 90 minutes

  TimerBloc(FirestoreRepo firestoreRepo)
      : super(TimerInitial(TimeModel(90 * 60))) {
    on<TimerStart>((event, emit) async {
      timerResult = TimerStats(targetTime: time);
      emit(TimerRunning(timerResult));

      firestoreRepo.setLiveUser(
          timerResult, 53.280687520332016, 6.326202939104593);

      _startTimer();
    });

    on<TimerEnd>((event, emit) async {
      _stopTimer();
      emit(TimerDone(timerResult));
    });

    on<TimerConfirm>((event, emit) async {
      firestoreRepo.postSession(timerResult);
      time = TimeModel(90 * 60);
      emit(TimerInitial(time));
    });

    on<TimerReset>((event, emit) async {
      _stopTimer();
      time.setMinutes = 90;
      print(time.seconds); // increment index to trigger a rebuild
      emit(TimerInitial(TimeModel(90 * 60)));
    });
    // keeps track of time on widget, is called by the onend callback in the [SleekCircularSlider]
    on<TimeUpdate>((event, emit) async {
      time.seconds = event.time.seconds;
      emit(TimerInitial(time));
    });

    on<TimerPause>((event, emit) async {
      // check its not already paused
      if (_timer != null) {
        timerResult.pause();
        firestoreRepo.unsetLiveUser();
      }

      _stopTimer();

      emit(TimerRunning(timerResult));
    });
    on<TimerResume>((event, emit) async {
      if (_timer == null) {
        _startTimer();
        timerResult.resume();
        firestoreRepo.setLiveUserActive();
      }
    });

    @override
    close() {
      if (_timer != null) {
        _timer?.cancel();
      }
      super.close();
    }
  }
}
