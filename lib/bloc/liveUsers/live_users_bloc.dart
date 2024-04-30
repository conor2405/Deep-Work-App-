import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/repo/firestore_repo.dart';

import 'package:meta/meta.dart';

part 'live_users_event.dart';
part 'live_users_state.dart';

class LiveUsersBloc extends Bloc<LiveUsersEvent, LiveUsersState> {
  late StreamSubscription liveUsersStreamSubscription;
  List<LiveUser> liveUsers = [];

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late CollectionReference<Map<String, dynamic>> collectionRef =
      _firestore.collection('activeUsers');

  void _listenToLiveUsers() async {
    liveUsersStreamSubscription = collectionRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((event) {
      // clear list to avoid adding duplicates
      liveUsers = [];
      event.docs.forEach((element) {
        liveUsers.add(LiveUser.fromJson(element.data()));
      });

      emit(LiveUsersLoaded(LiveUsers(users: liveUsers)));
    });
  }

  LiveUsersBloc() : super(LiveUsersInitial()) {
    on<LiveUsersInit>((event, emit) async {
      emit(LiveUsersLoading());
      _listenToLiveUsers();
    });
  }

  @override
  Future<void> close() {
    // TODO: implement close

    liveUsersStreamSubscription.cancel();

    return super.close();
  }
}
