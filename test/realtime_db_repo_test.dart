import 'package:deep_work/repo/realtime_db_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockOnDisconnect extends Mock implements OnDisconnect {}

void main() {
  test('setDisconnect writes expected fields', () async {
    final auth = MockFirebaseAuth(mockUser: MockUser(uid: 'user-1'));
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
