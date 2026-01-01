import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseAuthRepo _instance = FirebaseAuthRepo._internal();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  factory FirebaseAuthRepo() {
    return _instance;
  }
  FirebaseAuthRepo._internal();

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle sign up error
      print('Sign up error: $e');
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Handle sign in error
      print('Sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      // Handle sign out error
      print('Sign out error: $e');
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      // Handle anonymous sign in error
      print('Anonymous sign in error: $e');
      return null;
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isSignedIn => _firebaseAuth.currentUser != null;

  bool get isAnonymous => _firebaseAuth.currentUser?.isAnonymous ?? false;
}
