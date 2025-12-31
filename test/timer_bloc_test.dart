import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestoreRepo extends Mock implements FirestoreRepo {}

void main() {
  group('TimerBloc', () {
    MockFirestoreRepo firestoreRepo = MockFirestoreRepo();

    test('initial state is 90 minutes', () {
      final bloc = TimerBloc(firestoreRepo);

      expect(bloc.state, isA<TimerInitial>());
      if (bloc.state is TimerInitial) {
        expect((bloc.state as TimerInitial).time.minutes, 90);
      } else {
        fail('Initial state is not TimerInitial');
      }
    });

    test('emits [TimerInitial] when TimerReset is added', () {
      final bloc = TimerBloc(firestoreRepo);

      bloc.add(TimerReset());
      expect(bloc.state, isA<TimerInitial>());
      if (bloc.state is TimerInitial) {
        expect((bloc.state as TimerInitial).time.minutes, 90);
        expect((bloc.state as TimerInitial).time.timeString, '01:30:00');
      } else {
        fail('Initial state is not TimerInitial');
      }
    });

    blocTest('emits [TimerInitial] when TimeUpdate is added',
        build: () => TimerBloc(firestoreRepo),
        act: (bloc) {
          bloc.add(TimeUpdate(TimeModel(60 * 654)));
        },
        expect: () => [
              isA<TimerInitial>()
                  .having((p0) => p0.time.minutes, '654 minutes correct', 654),
            ]);

    blocTest(
        'emits [TimerInitial] with correct trimmed time when TimeUpdate is added',
        build: () => TimerBloc(firestoreRepo),
        act: (bloc) {
          bloc.add(TimeUpdate(TimeModel(60 * 654)));
        },
        expect: () => [
              isA<TimerInitial>()
                  .having((p0) => p0.time.getTrimmedTimeMinutes,
                      '654 minutes correct', 180)
                  .having((p0) => p0.time.timeString, 'sting minutes correct',
                      '10:54:00'),
            ]);

    blocTest('trimmed time works as expected',
        build: () => TimerBloc(firestoreRepo),
        act: (bloc) => bloc.add(TimeUpdate(TimeModel(654 * 60))),
        expect: () => [
              isA<TimerInitial>().having((p0) => p0.time.getTrimmedTimeMinutes,
                  'Make sure trimmed time funtioning for values >180', 180),
            ]);
    blocTest('trimmed time works as expected',
        build: () => TimerBloc(firestoreRepo),
        act: (bloc) => bloc.add(TimeUpdate(TimeModel(23 * 60))),
        expect: () => [
              isA<TimerInitial>().having((p0) => p0.time.getTrimmedTimeMinutes,
                  'Make sure trimmed time funtioning for values <180', 23),
            ]);

    test('TimerEnd trims notes and clears current note', () async {
      final bloc = TimerBloc(firestoreRepo);
      when(() => firestoreRepo.unsetLiveUser()).thenReturn(null);

      bloc.timerResult = TimerStats(targetTime: TimeModel(60));
      bloc.currentNote = '  wrapped tasks  ';

      bloc.add(TimerEnd());
      await pumpEventQueue();

      expect(bloc.state, isA<TimerDone>());
      final doneState = bloc.state as TimerDone;
      expect(doneState.timeModel.notes, ['wrapped tasks']);
      expect(bloc.currentNote, isEmpty);
    });

    test('TimerSubmitNotes trims notes and clears current note', () async {
      final bloc = TimerBloc(firestoreRepo);
      bloc.timerResult = TimerStats(targetTime: TimeModel(60));

      bloc.currentNote = '  shipped report  ';
      bloc.add(TimerSubmitNotes());
      await pumpEventQueue();

      expect(bloc.timerResult.notes, ['shipped report']);
      expect(bloc.currentNote, isEmpty);

      bloc.currentNote = '   ';
      bloc.add(TimerSubmitNotes());
      await pumpEventQueue();

      expect(bloc.timerResult.notes, ['shipped report']);
      expect(bloc.currentNote, isEmpty);
    });

    test('TimerSetFocusRating stores valid ratings and ignores invalid', () async {
      final bloc = TimerBloc(firestoreRepo);
      bloc.timerResult = TimerStats(targetTime: TimeModel(60));

      bloc.add(TimerSetFocusRating(4));
      await pumpEventQueue();
      expect(bloc.timerResult.focusRating, 4);

      bloc.add(TimerSetFocusRating(9));
      await pumpEventQueue();
      expect(bloc.timerResult.focusRating, 4);
    });
  });
}
