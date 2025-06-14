part of 'preferences_bloc.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class LoadPreferences extends PreferencesEvent {}

class UpdateLanguage extends PreferencesEvent {
  final String language;

  const UpdateLanguage(this.language);

  @override
  List<Object> get props => [language];
}

class UpdateTheme extends PreferencesEvent {
  final String theme;

  const UpdateTheme(this.theme);

  @override
  List<Object> get props => [theme];
}

class UpdateNotifications extends PreferencesEvent {
  final bool enabled;

  const UpdateNotifications(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class MarkFirstTimeComplete extends PreferencesEvent {}