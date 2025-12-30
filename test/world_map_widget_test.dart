import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/liveUsers/live_users_bloc.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/widgets/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mocktail/mocktail.dart';

class MockLiveUsersBloc extends MockBloc<LiveUsersEvent, LiveUsersState>
    implements LiveUsersBloc {}

void main() {
  testWidgets('marker count matches live users', (tester) async {
    final liveUsersBloc = MockLiveUsersBloc();
    final users = LiveUsers(users: [
      LiveUser(uid: '1', isActive: true, lat: 10, lng: 20),
      LiveUser(uid: '2', isActive: true, lat: 30, lng: 40),
    ]);

    whenListen(
      liveUsersBloc,
      Stream<LiveUsersState>.fromIterable([LiveUsersLoaded(users)]),
      initialState: LiveUsersLoaded(users),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorldMap(liveUsersBloc: liveUsersBloc),
      ),
    );

    await tester.pumpAndSettle();

    final markerLayer =
        tester.widget<MarkerLayer>(find.byType(MarkerLayer).first);
    expect(markerLayer.markers.length, 3);
  });

  testWidgets('empty state renders background only', (tester) async {
    final liveUsersBloc = MockLiveUsersBloc();
    final users = LiveUsers(users: []);

    whenListen(
      liveUsersBloc,
      Stream<LiveUsersState>.fromIterable([LiveUsersLoaded(users)]),
      initialState: LiveUsersLoaded(users),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorldMap(liveUsersBloc: liveUsersBloc),
      ),
    );

    await tester.pumpAndSettle();

    final markerLayer =
        tester.widget<MarkerLayer>(find.byType(MarkerLayer).first);
    expect(markerLayer.markers.length, 1);
  });
}
