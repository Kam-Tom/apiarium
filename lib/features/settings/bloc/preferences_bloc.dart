import 'package:apiarium/core/core.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;

  PreferencesBloc({
    required UserRepository userRepository,
    required SettingsRepository settingsRepository,
  }) : _userRepository = userRepository,
       _settingsRepository = settingsRepository,
       super(const PreferencesState()) {
    
    on<LoadPreferences>(_onLoadPreferences);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateTheme>(_onUpdateTheme);
    on<UpdateNotifications>(_onUpdateNotifications);
    on<MarkFirstTimeComplete>(_onMarkFirstTimeComplete);
  }

  Future<void> _onLoadPreferences(
    LoadPreferences event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final settings = _settingsRepository.settings;
      
      emit(PreferencesState(
        language: settings.language,
        theme: settings.theme,
        notificationsEnabled: settings.notificationsEnabled,
        voiceControlModel: settings.voiceControlModel,
        isFirstTime: settings.isFirstTime,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<PreferencesState> emit,
  ) async {
    final currentSettings = _settingsRepository.settings;
    final newSettings = currentSettings.copyWith(language: event.language);
    
    await _settingsRepository.updateSettings(newSettings);
    emit(state.copyWith(language: event.language));
  
  }

  Future<void> _onUpdateTheme(
    UpdateTheme event,
    Emitter<PreferencesState> emit,
  ) async {
    final currentSettings = _settingsRepository.settings;
    final newSettings = currentSettings.copyWith(theme: event.theme);
    
    await _settingsRepository.updateSettings(newSettings);
    emit(state.copyWith(theme: event.theme));
  }

  Future<void> _onUpdateNotifications(
    UpdateNotifications event,
    Emitter<PreferencesState> emit,
  ) async {
    final currentSettings = _settingsRepository.settings;
    final newSettings = currentSettings.copyWith(notificationsEnabled: event.enabled);
    
    await _settingsRepository.updateSettings(newSettings);
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  Future<void> _onMarkFirstTimeComplete(
    MarkFirstTimeComplete event,
    Emitter<PreferencesState> emit,
  ) async {
    final currentSettings = _settingsRepository.settings;
    final newSettings = currentSettings.copyWith(isFirstTime: false);
    
    await _settingsRepository.updateSettings(newSettings);
    emit(state.copyWith(isFirstTime: false));

    // Load initial data if this is first time - use current state language
    try {
      await getIt<QueenBreedRepository>().loadInitialData(state.language);
      await getIt<HiveTypeRepository>().loadInitialData(state.language);
      Logger.i('Initial data loaded for language: ${state.language}', tag: 'MyApp');
    } catch (e) {
      Logger.e('Failed to load initial data', tag: 'MyApp', error: e);
    }
  }
}