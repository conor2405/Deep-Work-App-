part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {}

final class SettingsInitial extends SettingsState {
  bool isDarkMode;
  bool showMap;

  SettingsInitial({this.isDarkMode = true, this.showMap = true});

  @override
  List get props => [isDarkMode, showMap];
}
