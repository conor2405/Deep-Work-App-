import 'package:deep_work/models/time.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/models/feedback.dart';
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

    test('postSession sets uid and closes open breaks', () async {
      final stats = TimerStats(targetTime: TimeModel(600));
      stats.startBreak(TimeModel(300));
      expect(stats.breakEvents.first.endTime, isNull);

      repo.postSession(stats);

      expect(stats.uid, 'user-1');
      expect(stats.breakEvents.first.endTime, isNotNull);

      final snapshot = await firestore.collection('sessions').get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.data()['uid'], 'user-1');
    });

    test('set/unset live user writes active payloads', () async {
      final stats = TimerStats(targetTime: TimeModel(600));

      repo.setLiveUser(stats, 'ezs4');
      var doc =
          await firestore.collection('activeUsers').doc('user-1').get();
      expect(doc.data()?['isActive'], true);
      expect(doc.data()?['geohash'], 'ezs4');
      expect(doc.data()?.containsKey('lat'), isFalse);
      expect(doc.data()?.containsKey('lng'), isFalse);

      repo.unsetLiveUser();
      doc = await firestore.collection('activeUsers').doc('user-1').get();
      expect(doc.data()?['isActive'], false);

      repo.setLiveUserActive();
      doc = await firestore.collection('activeUsers').doc('user-1').get();
      expect(doc.data()?['isActive'], true);
    });

    test('postFeedback stores message with uid', () async {
      final entry = FeedbackEntry(
        uid: 'ignored',
        message: 'Keep the map glow subtle.',
        email: 'feedback@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      repo.postFeedback(entry);

      final snapshot = await firestore.collection('feedback').get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.data()['uid'], 'user-1');
      expect(
        snapshot.docs.first.data()['message'],
        'Keep the map glow subtle.',
      );
      expect(
        snapshot.docs.first.data()['email'],
        'feedback@example.com',
      );
    });
  });
}
