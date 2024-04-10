import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreRepo();

  void postSession(TimerStats timerResult) {
    _firestore.collection('sessions').add(timerResult.toJson());
  }

// gets session details
  Future<List<TimerResult>> getSessions() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('sessions').get();
    return querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            TimerResult.fromJson(doc.data()))
        .toList();
  }
}
