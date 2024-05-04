part of 'settings_bloc.dart';

@immutable
sealed class SettingsState {}

final class SettingsInitial extends SettingsState {
  bool isDarkMode;

  SettingsInitial(this.isDarkMode);

  @override
  List get props => [isDarkMode];
}
