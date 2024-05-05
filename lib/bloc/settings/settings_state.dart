part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {}

final class SettingsInitial extends SettingsState {
  bool isDarkMode;
  bool showMap;
  bool showNotes;

  SettingsInitial(
      {this.isDarkMode = true, this.showMap = true, this.showNotes = true});

  @override
  List get props => [isDarkMode, showMap, showNotes];
}
