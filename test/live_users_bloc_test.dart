import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/liveUsers/live_users_bloc.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/repo/realtime_db_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRealtimeDBRepo extends Mock implements RealtimeDBRepo {}

void main() {
  group('LiveUsersBloc', () {
    late StreamController<LiveUsers> liveUsersController;
    late MockRealtimeDBRepo realtimeDBRepo;

    setUp(() {
      liveUsersController = StreamController<LiveUsers>();
      realtimeDBRepo = MockRealtimeDBRepo();
      when(() => realtimeDBRepo.setDisconnect()).thenAnswer((_) {});
    });

    tearDown(() async {
      await liveUsersController.close();
    });

    blocTest<LiveUsersBloc, LiveUsersState>(
      'emits loading then loaded when live users update',
      build: () => LiveUsersBloc(
        liveUsersStream: liveUsersController.stream,
        realtimeDBRepo: realtimeDBRepo,
      ),
      act: (bloc) {
        bloc.add(LiveUsersInit());
        liveUsersController.add(
          LiveUsers(
            users: [
              LiveUser(uid: 'user-1', isActive: true, geohash: 'ezs4'),
            ],
          ),
        );
      },
      expect: () => [
        isA<LiveUsersLoading>(),
        isA<LiveUsersLoaded>()
            .having((state) => state.liveUsers.total, 'total', 1),
      ],
      verify: (_) {
        verify(() => realtimeDBRepo.setDisconnect()).called(1);
      },
    );
  });
}
