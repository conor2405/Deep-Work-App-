import 'package:deep_work/repo/realtime_db_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockOnDisconnect extends Mock implements OnDisconnect {}

void main() {
  test('resolveDatabaseUrl uses provided url', () {
    expect(
      resolveDatabaseUrl(
        databaseUrl: 'https://example.firebaseio.com',
        projectId: 'demo',
      ),
      'https://example.firebaseio.com',
    );
  });

  test('resolveDatabaseUrl falls back to default url', () {
    expect(
      resolveDatabaseUrl(
        databaseUrl: null,
        projectId: 'demo-project',
      ),
      'https://demo-project-default-rtdb.firebaseio.com',
    );
  });

  test('resolveDatabaseUrl throws when projectId is missing', () {
    expect(
      () => resolveDatabaseUrl(
        databaseUrl: null,
        projectId: '',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('setDisconnect writes expected fields', () async {
    final auth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'user-1'),
      signedIn: true,
    );
    final activeUsersRef = MockDatabaseReference();
    final onDisconnect = MockOnDisconnect();

    when(() => activeUsersRef.child('user-1')).thenReturn(activeUsersRef);
    when(() => activeUsersRef.onDisconnect()).thenReturn(onDisconnect);
    when(() => onDisconnect.update(any())).thenAnswer((_) async {});

    final repo = RealtimeDBRepo.test(
      activeUsersRef: activeUsersRef,
      auth: auth,
    );

    repo.setDisconnect();

    verify(() => onDisconnect.update({
          'uid': 'user-1',
          'lastSeen': ServerValue.timestamp,
          'active': false,
        })).called(1);
  });
}
