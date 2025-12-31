import 'package:bloc_test/bloc_test.dart';
import 'package:deep_work/bloc/liveUsers/live_users_bloc.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/widgets/world_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockLiveUsersBloc extends MockBloc<LiveUsersEvent, LiveUsersState>
    implements LiveUsersBloc {}

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => '/tmp';
}

Future<void> _pumpWorldMap(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 10; i++) {
    if (tester.any(find.byType(FlutterMap))) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  late PathProviderPlatform originalPathProvider;

  setUpAll(() {
    originalPathProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  tearDownAll(() {
    PathProviderPlatform.instance = originalPathProvider;
  });

  test('shouldUseCachedTiles disables cache on web', () {
    expect(
      shouldUseCachedTiles(enableTiles: true, isWeb: true),
      isFalse,
    );
    expect(
      shouldUseCachedTiles(enableTiles: true, isWeb: false),
      isTrue,
    );
    expect(
      shouldUseCachedTiles(enableTiles: false, isWeb: false),
      isFalse,
    );
  });

  test('wrapLongitude keeps values in range', () {
    expect(wrapLongitude(45), 45);
    expect(wrapLongitude(190), closeTo(-170, 0.0001));
    expect(wrapLongitude(-190), closeTo(170, 0.0001));
  });

  testWidgets('marker count matches live users', (tester) async {
    final liveUsersBloc = MockLiveUsersBloc();
    final users = LiveUsers(users: [
      LiveUser(uid: '1', isActive: true, geohash: 'ezs4'),
      LiveUser(uid: '2', isActive: true, geohash: 'u4pr'),
    ]);

    whenListen(
      liveUsersBloc,
      Stream<LiveUsersState>.fromIterable([LiveUsersLoaded(users)]),
      initialState: LiveUsersLoaded(users),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorldMap(liveUsersBloc: liveUsersBloc, enableTiles: false),
      ),
    );

    await _pumpWorldMap(tester);
    expect(find.byType(FlutterMap), findsOneWidget);

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
        home: WorldMap(liveUsersBloc: liveUsersBloc, enableTiles: false),
      ),
    );

    await _pumpWorldMap(tester);
    expect(find.byType(FlutterMap), findsOneWidget);

    final markerLayer =
        tester.widget<MarkerLayer>(find.byType(MarkerLayer).first);
    expect(markerLayer.markers.length, 1);
  });

  testWidgets('community pulse badge renders count', (tester) async {
    final liveUsersBloc = MockLiveUsersBloc();
    final users = LiveUsers(users: [
      LiveUser(uid: '1', isActive: true, geohash: 'ezs4'),
      LiveUser(uid: '2', isActive: true, geohash: 'u4pr'),
      LiveUser(uid: '3', isActive: true, geohash: 'gcpv'),
    ]);

    whenListen(
      liveUsersBloc,
      Stream<LiveUsersState>.fromIterable([LiveUsersLoaded(users)]),
      initialState: LiveUsersLoaded(users),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WorldMap(liveUsersBloc: liveUsersBloc, enableTiles: false),
      ),
    );

    await _pumpWorldMap(tester);
    expect(find.byKey(const Key('focus_pulse_badge')), findsOneWidget);
    expect(find.text('Focus Pulse'), findsOneWidget);
    expect(find.textContaining('minds in session'), findsOneWidget);
  });
}
