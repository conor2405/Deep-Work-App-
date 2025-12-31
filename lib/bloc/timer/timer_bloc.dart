import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:equatable/equatable.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final FirestoreRepo _firestoreRepo;
  late TimerStats timerResult;
  Timer? _timer;
  Timer? _breakTimer;

  String currentNote = '';

  void _startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerResult.tick();

      // ignore: invalid_use_of_visible_for_testing_member
      emit(TimerRunning(timerResult));

      if (timerResult.timeLeft.seconds <= 0) {
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

  void _startBreakTimer() {
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerResult.tickBreak();

      // ignore: invalid_use_of_visible_for_testing_member
      emit(TimerBreakRunning(timerResult));

      if (timerResult.breakTimeLeft.seconds <= 0) {
        timerResult.breakTimeLeft = TimeModel.zero();
        timerResult.endBreak();
        timer.cancel();
        _breakTimer = null;
        _firestoreRepo.setLiveUserActive();
        _startTimer();
        emit(TimerRunning(timerResult));
      }
    });
  }

  void _stopBreakTimer() {
    _breakTimer?.cancel();
    _breakTimer = null;
  }

  TimeModel time = TimeModel(90 * 60); // 90 minutes

  TimerBloc(this._firestoreRepo)
      : super(TimerInitial(TimeModel(90 * 60))) {
    on<TimerStart>((event, emit) async {
      timerResult = TimerStats(targetTime: time);
      emit(TimerRunning(timerResult));

      _firestoreRepo.setLiveUser(
          timerResult, 53.280687520332016, 6.326202939104593);

      _startTimer();
    });

    on<TimerEnd>((event, emit) async {
      _stopTimer();
      _stopBreakTimer();
      timerResult.endBreak();
      final trimmedNote = currentNote.trim();
      if (trimmedNote.isNotEmpty) {
        timerResult.notes.add(trimmedNote);
      }
      currentNote = '';
      _firestoreRepo.unsetLiveUser();
      emit(TimerDone(timerResult));
    });

    on<TimerStop>((event, emit) async {
      _stopTimer();
      _stopBreakTimer();
      emit(TimerRunning(timerResult));
    });

    on<TimerConfirm>((event, emit) async {
      _firestoreRepo.postSession(timerResult);
      time = TimeModel(90 * 60);
      emit(TimerInitial(time));
    });

    on<TimerReset>((event, emit) async {
      _stopTimer();
      _stopBreakTimer();
      time.setMinutes = 90;
      print(time.seconds); // increment index to trigger a rebuild
      emit(TimerInitial(TimeModel(90 * 60)));
    });
    // keeps track of time on widget, is called by the onend callback in the [SleekCircularSlider]
    on<TimeUpdate>((event, emit) async {
      time.seconds = event.time.seconds;
      emit(TimerInitial(time));
    });

    on<TimerAddFive>((event, emit) async {
      if (_breakTimer != null) {
        return;
      }
      timerResult.timeLeft.seconds = timerResult.timeLeft.seconds + 300;
      timerResult.targetTime.seconds = timerResult.targetTime.seconds + 300;
      emit(TimerRunning(timerResult));
    });

    on<TimerTakeFive>((event, emit) async {
      if (_breakTimer != null) {
        return;
      }
      timerResult.timeLeft.seconds = timerResult.timeLeft.seconds - 300;
      timerResult.targetTime.seconds = timerResult.targetTime.seconds - 300;
      if (timerResult.targetTime.seconds < 0 ||
          timerResult.timeLeft.seconds < 0) {
        timerResult.targetTime.seconds = 5;
        timerResult.timeLeft.seconds = 3;
      }
      emit(TimerRunning(timerResult));
    });

    on<TimerStartBreak>((event, emit) async {
      if (_timer == null || event.duration.seconds <= 0) {
        return;
      }
      _stopTimer();
      timerResult.startBreak(event.duration);
      _firestoreRepo.unsetLiveUser();
      _startBreakTimer();
      emit(TimerBreakRunning(timerResult));
    });

    on<TimerEndBreak>((event, emit) async {
      if (_breakTimer == null) {
        return;
      }
      _stopBreakTimer();
      timerResult.endBreak();
      timerResult.breakTimeLeft = TimeModel.zero();
      timerResult.breakTargetTime = TimeModel.zero();
      _firestoreRepo.setLiveUserActive();
      _startTimer();
      emit(TimerRunning(timerResult));
    });

    on<TimerBreakAddFive>((event, emit) async {
      if (_breakTimer == null) {
        return;
      }
      timerResult.breakTimeLeft.seconds += 300;
      timerResult.breakTargetTime.seconds += 300;
      emit(TimerBreakRunning(timerResult));
    });

    on<TimerBreakTakeFive>((event, emit) async {
      if (_breakTimer == null) {
        return;
      }
      timerResult.breakTimeLeft.seconds -= 300;
      timerResult.breakTargetTime.seconds -= 300;
      if (timerResult.breakTimeLeft.seconds < 60 ||
          timerResult.breakTargetTime.seconds < 60) {
        timerResult.breakTimeLeft.seconds = 60;
        timerResult.breakTargetTime.seconds = 60;
      }
      emit(TimerBreakRunning(timerResult));
    });
    on<TimerSetNotes>((event, emit) async {
      currentNote = event.notes;
    });

    on<TimerSetFocusRating>((event, emit) async {
      final rating = event.rating;
      if (rating == null) {
        timerResult.focusRating = null;
        return;
      }
      if (rating < 1 || rating > 5) {
        return;
      }
      timerResult.focusRating = rating;
    });

    on<TimerSubmitNotes>((event, emit) async {
      final trimmedNote = currentNote.trim();
      if (trimmedNote.isNotEmpty) {
        timerResult.notes.add(trimmedNote);
      }
      currentNote = '';
    });
  }

  @override
  Future<void> close() async {
    _stopTimer();
    _stopBreakTimer();
    return super.close();
  }
}
