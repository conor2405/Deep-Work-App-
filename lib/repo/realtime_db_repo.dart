import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// handles communitcation with Firebase Realtime Database
/// currently only used for the active users.
/// Realtime DB has on disconnect listeners that can be used to
/// remove users from the active users list when they disconnect or close the app.
class RealtimeDBRepo {
  static final RealtimeDBRepo _instance = RealtimeDBRepo._internal();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DatabaseReference _activeUsersRef =
      FirebaseDatabase.instance.ref('activeUsers');
  FirebaseAuth _auth = FirebaseAuth.instance;
  String? get uid => _auth.currentUser?.uid;

  factory RealtimeDBRepo() {
    return _instance;
  }

  RealtimeDBRepo._internal();

  void setDisconnect() {
    _activeUsersRef.child(uid!).onDisconnect().update({
      'uid': uid,
      'lastSeen': ServerValue.timestamp,
      'active': false,
    });
  }
}
