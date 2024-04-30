part of 'live_users_bloc.dart';

@immutable
sealed class LiveUsersState {}

final class LiveUsersInitial extends LiveUsersState {}

final class LiveUsersLoading extends LiveUsersState {}

final class LiveUsersLoaded extends LiveUsersState {
  final LiveUsers liveUsers;

  LiveUsersLoaded(this.liveUsers);

  @override
  List get props => [liveUsers, liveUsers.total, liveUsers.users, hashCode];
}
