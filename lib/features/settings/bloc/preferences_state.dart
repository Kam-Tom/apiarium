part of 'preferences_bloc.dart';

class PreferencesState extends Equatable {
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final String voiceControlModel;
  final bool isFirstTime;
  final bool isLoading;

  const PreferencesState({
    this.language = 'en',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.voiceControlModel = '',
    this.isFirstTime = true,
    this.isLoading = false,
  });

  PreferencesState copyWith({
    String? language,
    String? theme,
    bool? notificationsEnabled,
    String? voiceControlModel,
    bool? isFirstTime,
    bool? isLoading,
  }) {
    return PreferencesState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      voiceControlModel: voiceControlModel ?? this.voiceControlModel,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [
    language,
    theme,
    notificationsEnabled,
    voiceControlModel,
    isFirstTime,
    isLoading,
  ];
}