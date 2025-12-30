import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

/// handles communitcation with Firebase Realtime Database
/// currently only used for the active users.
/// Realtime DB has on disconnect listeners that can be used to
/// remove users from the active users list when they disconnect or close the app.
class RealtimeDBRepo {
  static final RealtimeDBRepo _instance = RealtimeDBRepo._internal();
  final DatabaseReference _activeUsersRef;
  final FirebaseAuth _auth;
  String? get uid => _auth.currentUser?.uid;

  factory RealtimeDBRepo() {
    return _instance;
  }

  RealtimeDBRepo._internal()
      : _activeUsersRef = FirebaseDatabase.instance.ref('activeUsers'),
        _auth = FirebaseAuth.instance;

  @visibleForTesting
  RealtimeDBRepo.test({
    DatabaseReference? activeUsersRef,
    FirebaseAuth? auth,
  })  : _activeUsersRef =
            activeUsersRef ?? FirebaseDatabase.instance.ref('activeUsers'),
        _auth = auth ?? FirebaseAuth.instance;

  void setDisconnect() {
    _activeUsersRef.child(uid!).onDisconnect().update({
      'uid': uid,
      'lastSeen': ServerValue.timestamp,
      'active': false,
    });
  }
}
