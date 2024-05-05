import 'package:deep_work/repo/firestore_repo.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  FirestoreRepo firestoreRepo = FirestoreRepo();

  bool isDarkMode = true;
  bool showMap = true;
  bool notes = true;

  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<ToggleDarkMode>((event, emit) {
      isDarkMode = !isDarkMode;
      emit(SettingsInitial(
          isDarkMode: isDarkMode, showMap: showMap, showNotes: notes));
    });

    on<ToggleShowMap>((event, emit) {
      showMap = !showMap;
      emit(SettingsInitial(
          isDarkMode: isDarkMode, showMap: showMap, showNotes: notes));
    });

    on<ToggleNotes>((event, emit) {
      notes = !notes;
      emit(SettingsInitial(
          isDarkMode: isDarkMode, showMap: showMap, showNotes: notes));
    });
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return SettingsInitial();
    }
    if (json['isDarkMode'] != null) {
      isDarkMode = json['isDarkMode'];
    } else {
      isDarkMode = true;
    }
    if (json['showMap'] != null) {
      showMap = json['showMap'];
    } else {
      showMap = true;
    }

    return SettingsInitial(isDarkMode: isDarkMode, showMap: showMap);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'isDarkMode': isDarkMode,
      'showMap': showMap,
    };
  }
}
