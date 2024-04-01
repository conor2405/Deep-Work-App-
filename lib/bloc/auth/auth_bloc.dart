import 'package:bloc/bloc.dart';
import 'package:deep_work/repo/firebase_auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(FirebaseAuthRepo firebaseAuthRepo) : super(Unauthenticated()) {
    firebaseAuthRepo.authStateChanges.listen((user) {
      user != null ? add(AuthInit()) : add(SignedOut());
    });

    on<AuthInit>((event, emit) async {
      firebaseAuthRepo.isSignedIn
          ? emit(Authenticated(firebaseAuthRepo.currentUser))
          : emit(Unauthenticated());
    });

    on<AuthEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<SignedOut>((event, emit) async {
      emit(Unauthenticated());
    });
  }
}
