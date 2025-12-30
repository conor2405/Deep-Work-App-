import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
      : _activeUsersRef = _buildActiveUsersRef(),
        _auth = FirebaseAuth.instance;

  @visibleForTesting
  RealtimeDBRepo.test({
    DatabaseReference? activeUsersRef,
    FirebaseAuth? auth,
  })  : _activeUsersRef =
            activeUsersRef ?? FirebaseDatabase.instance.ref('activeUsers'),
        _auth = auth ?? FirebaseAuth.instance;

  void setDisconnect() {
    final userId = uid;
    if (userId == null) {
      return;
    }
    _activeUsersRef.child(userId).onDisconnect().update({
      'uid': userId,
      'lastSeen': ServerValue.timestamp,
      'active': false,
    });
  }
}

DatabaseReference _buildActiveUsersRef() {
  final app = Firebase.app();
  final options = app.options;
  final databaseUrl = resolveDatabaseUrl(
    databaseUrl: options.databaseURL,
    projectId: options.projectId,
  );
  return FirebaseDatabase.instanceFor(
    app: app,
    databaseURL: databaseUrl,
  ).ref('activeUsers');
}

@visibleForTesting
String resolveDatabaseUrl({
  required String? databaseUrl,
  required String? projectId,
}) {
  if (databaseUrl != null && databaseUrl.isNotEmpty) {
    return databaseUrl;
  }
  if (projectId == null || projectId.isEmpty) {
    throw StateError('Missing Firebase projectId for Realtime Database URL.');
  }
  return 'https://$projectId-default-rtdb.firebaseio.com';
}
