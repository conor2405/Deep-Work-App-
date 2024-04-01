part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class Authenticated extends AuthState {
  Authenticated(this.user);

  final User? user;
}

final class Unauthenticated extends AuthState {
  Unauthenticated();
}
