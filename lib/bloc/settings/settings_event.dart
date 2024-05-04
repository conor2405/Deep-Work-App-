part of 'settings_bloc.dart';

@immutable
sealed class SettingsEvent {}

class ToggleDarkMode extends SettingsEvent {}

class ToggleShowMap extends SettingsEvent {}
