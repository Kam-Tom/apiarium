import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../shared/services/user_service.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final UserService _userService;

  PreferencesBloc({required UserService userService})
    : _userService = userService,
      super(PreferencesInitial()) {
    on<LoadPreferences>(_onLoadPreferences);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  void _onLoadPreferences(
    LoadPreferences event,
    Emitter<PreferencesState> emit,
  ) {
    String language = _userService.language;
    if (language.isEmpty) {
      // Get device locale
      final deviceLocale =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      if (['en', 'pl'].contains(deviceLocale)) {
        language = deviceLocale;
        // Save this preference for future app launches
        _userService.language = language;
      } else {
        // If device locale is not supported, fallback to English
        language = 'en';
        _userService.language = language;
      }
    }
    emit(PreferencesLoaded(language: language));
  }

  void _onChangeLanguage(ChangeLanguage event, Emitter<PreferencesState> emit) {
    _userService.language = event.language;
    emit(state.copyWith(language: event.language));
  }
}
