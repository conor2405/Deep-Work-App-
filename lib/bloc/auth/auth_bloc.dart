import 'package:bloc/bloc.dart';
import 'package:deep_work/repo/firebase_auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
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
  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    if (json['AuthState'] == 'true') {
      return Authenticated(FirebaseAuth.instance.currentUser);
    }
    return Unauthenticated();
  }

  @override
  Map<String, dynamic> toJson(AuthState state) {
    if (state is Authenticated) {
      return {'user': state.user?.uid, 'AuthState': 'true'};
    }
    return {'AuthState': 'false', 'user': 'null'};
  }
}
