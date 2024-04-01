import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_work/models/timer_result.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirestoreRepo();

  void postSession(TimerResult timerResult) {
    _firestore.collection('sessions').add(timerResult.toJson());
  }
  // Add your repository methods here
}
