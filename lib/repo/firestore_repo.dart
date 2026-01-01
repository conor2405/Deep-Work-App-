import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_work/models/feedback.dart';
import 'package:deep_work/models/goal.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:deep_work/repo/firebase_auth_repo.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuthRepo _firebaseAuthRepo;
  FirestoreRepo({FirebaseFirestore? firestore, FirebaseAuthRepo? authRepo})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuthRepo = authRepo ?? FirebaseAuthRepo();

  String? get uid => _firebaseAuthRepo.currentUser?.uid;

  void postSession(TimerStats timerResult) {
    timerResult.setUID = uid!;
    for (BreakPeriod breakEvent in timerResult.breakEvents) {
      if (breakEvent.endTime == null) {
        breakEvent.endTime = DateTime.now();
      }
    }

    _firestore.collection('sessions').add(timerResult.toJson());
  }

// gets session details
  Future<List<TimerResult>> getSessions() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('sessions')
        .where('uid', isEqualTo: uid)
        .get();
    return querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            TimerResult.fromJson(doc.data()))
        .toList();
  }

  Future<List<Goal>> getGoals() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('goals').where('uid', isEqualTo: uid).get();

    return querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            Goal.fromMap(doc.data()))
        .toList();
  }

  void postGoal(Goal goal) {
    goal.uid = uid!;

    _firestore.collection('goals').add(goal.toJson());
  }

  void setTimeGoal(TimeGoalsAll timeGoals) {
    timeGoals.uid = uid!;
    _firestore
        .collection('timeGoals')
        .doc(timeGoals.uid.toString())
        .set(timeGoals.toJson(), SetOptions(merge: true));
  }

  Future<TimeGoalsAll> getTimeGoals() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('timeGoals')
        .where(FieldPath.documentId, isEqualTo: uid)
        .get();

    TimeGoalsAll timeGoal = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      return TimeGoalsAll.fromJson(doc.data());
    }).first;

    return timeGoal;
  }

  void updateGoal(Goal goal) {
    goal.uid = uid!;
    _firestore
        .collection('goals')
        .doc(goal.id.toString())
        .set(goal.toJson(), SetOptions(merge: true));
  }

  void postFeedback(FeedbackEntry feedback) {
    feedback = FeedbackEntry(
      uid: uid!,
      message: feedback.message,
      email: feedback.email,
      createdAt: feedback.createdAt,
    );

    _firestore.collection('feedback').add(feedback.toJson());
  }

  // Live user methods
  // set live user
  void setLiveUser(TimerStats timerStats, String geohash) {
    final sanitizedGeohash = geohash.trim().toLowerCase();
    LiveUser liveUser = LiveUser(
      uid: uid!,
      isActive: true,
      geohash: sanitizedGeohash,
    );
    _firestore.collection('activeUsers').doc(uid).set(liveUser.toJson());
  }

  // listen to stream of live users

  // update live user time

  // deactivate live user
  void unsetLiveUser() {
    _firestore.collection('activeUsers').doc(uid).set(
      {
        'isActive': false,
      },
      SetOptions(merge: true),
    );
  }

  // reactivate live user
  void setLiveUserActive() {
    _firestore.collection('activeUsers').doc(uid).set(
      {
        'isActive': true,
      },
      SetOptions(merge: true),
    );
  }
}
