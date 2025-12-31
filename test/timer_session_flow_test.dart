import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirestoreRepo extends Mock implements FirestoreRepo {}

void main() {
  setUpAll(() {
    registerFallbackValue(TimerStats(targetTime: TimeModel(0)));
  });

  test('timer session flow triggers presence calls in order', () async {
    final firestoreRepo = MockFirestoreRepo();
    final bloc = TimerBloc(firestoreRepo);

    when(() => firestoreRepo.setLiveUser(any(), any()))
        .thenReturn(null);
    when(() => firestoreRepo.unsetLiveUser()).thenReturn(null);
    when(() => firestoreRepo.setLiveUserActive()).thenReturn(null);
    when(() => firestoreRepo.postSession(any())).thenReturn(null);

    bloc.add(TimerStart());
    await pumpEventQueue();

    bloc.add(TimerStartBreak(TimeModel(5 * 60)));
    await pumpEventQueue();

    bloc.add(TimerEndBreak());
    await pumpEventQueue();

    bloc.add(TimerEnd());
    await pumpEventQueue();

    bloc.add(TimerConfirm());
    await pumpEventQueue();

    verifyInOrder([
      () => firestoreRepo.setLiveUser(any(), any()),
      () => firestoreRepo.unsetLiveUser(),
      () => firestoreRepo.setLiveUserActive(),
      () => firestoreRepo.unsetLiveUser(),
      () => firestoreRepo.postSession(any()),
    ]);

    await bloc.close();
  });
}
