part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthInit extends AuthEvent {
  AuthInit();
}

final class SignedOut extends AuthEvent {
  SignedOut();
}
