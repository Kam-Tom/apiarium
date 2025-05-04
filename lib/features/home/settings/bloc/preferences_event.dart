part of 'preferences_bloc.dart';

sealed class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class LoadPreferences extends PreferencesEvent {}

class ChangeLanguage extends PreferencesEvent {
  final String language;
  
  const ChangeLanguage(this.language);
  
  @override
  List<Object> get props => [language];
}
