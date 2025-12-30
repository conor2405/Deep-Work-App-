import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_work/models/live_users.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:deep_work/repo/realtime_db_repo.dart';

import 'package:meta/meta.dart';

part 'live_users_event.dart';
part 'live_users_state.dart';

class LiveUsersBloc extends Bloc<LiveUsersEvent, LiveUsersState> {
  StreamSubscription<LiveUsers>? _liveUsersStreamSubscription;
  List<LiveUser> liveUsers = [];

  final FirebaseFirestore? _firestore;
  final RealtimeDBRepo _realtimeDBRepo;
  final Stream<LiveUsers>? _liveUsersStream;

  LiveUsersBloc({
    FirebaseFirestore? firestore,
    RealtimeDBRepo? realtimeDBRepo,
    Stream<LiveUsers>? liveUsersStream,
  })  : _firestore = firestore,
        _realtimeDBRepo = realtimeDBRepo ?? RealtimeDBRepo(),
        _liveUsersStream = liveUsersStream,
        super(LiveUsersInitial()) {
    on<LiveUsersInit>((event, emit) async {
      emit(LiveUsersLoading());
      _listenToLiveUsers();
      _realtimeDBRepo.setDisconnect();
    });
  }

  Stream<LiveUsers> _buildLiveUsersStream() {
    if (_liveUsersStream != null) {
      return _liveUsersStream!;
    }
    final firestore = _firestore ?? FirebaseFirestore.instance;
    return firestore
        .collection('activeUsers')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => LiveUser.fromJson(doc.data()))
          .toList();
      return LiveUsers(users: users);
    });
  }

  void _listenToLiveUsers() {
    _liveUsersStreamSubscription?.cancel();
    _liveUsersStreamSubscription = _buildLiveUsersStream().listen((users) {
      liveUsers = users.users;
      emit(LiveUsersLoaded(users));
    });
  }

  @override
  Future<void> close() async {
    await _liveUsersStreamSubscription?.cancel();
    return super.close();
  }
}
