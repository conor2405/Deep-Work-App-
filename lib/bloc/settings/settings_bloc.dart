import 'package:deep_work/repo/firestore_repo.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  FirestoreRepo firestoreRepo = FirestoreRepo();

  bool isDarkMode = true;

  SettingsBloc() : super(SettingsInitial(true)) {
    on<SettingsEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<ToggleDarkMode>((event, emit) {
      isDarkMode = !isDarkMode;
      emit(SettingsInitial(isDarkMode));
    });
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return SettingsInitial(true);
    }
    if (json['isDarkMode'] != null) {
      isDarkMode = json['isDarkMode'];
    } else {
      isDarkMode = true;
    }

    return SettingsInitial(isDarkMode);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'isDarkMode': isDarkMode,
    };
  }
}
