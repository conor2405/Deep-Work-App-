import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/repo/firebase_auth_repo.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuthRepo extends Mock implements FirebaseAuthRepo {}
class MockUser extends Mock implements User {}

void main() {
  group('FirestoreRepo', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuthRepo authRepo;
    late FirestoreRepo repo;
    late MockUser user;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      authRepo = MockFirebaseAuthRepo();
      user = MockUser();
      when(() => user.uid).thenReturn('user-1');
      when(() => authRepo.currentUser).thenReturn(user);
      repo = FirestoreRepo(firestore: firestore, authRepo: authRepo);
    });

    test('postSession sets uid and closes open pauses', () async {
      final stats = TimerStats(targetTime: TimeModel(600));
      stats.pause();
      expect(stats.pauseEvents.first.endTime, isNull);

      repo.postSession(stats);

      expect(stats.uid, 'user-1');
      expect(stats.pauseEvents.first.endTime, isNotNull);

      final snapshot = await firestore.collection('sessions').get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.data()['uid'], 'user-1');
    });

    test('set/unset live user writes active payloads', () async {
      final stats = TimerStats(targetTime: TimeModel(600));

      repo.setLiveUser(stats, 10, 20);
      var doc =
          await firestore.collection('activeUsers').doc('user-1').get();
      expect(doc.data()?['isActive'], true);
      expect(doc.data()?['lat'], 10);
      expect(doc.data()?['lng'], 20);

      repo.unsetLiveUser();
      doc = await firestore.collection('activeUsers').doc('user-1').get();
      expect(doc.data()?['isActive'], false);

      repo.setLiveUserActive();
      doc = await firestore.collection('activeUsers').doc('user-1').get();
      expect(doc.data()?['isActive'], true);
    });
  });
}
