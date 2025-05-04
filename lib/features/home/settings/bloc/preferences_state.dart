part of 'preferences_bloc.dart';

class PreferencesState extends Equatable {
  final String language;
  final bool isLoading;
  
  const PreferencesState({
    this.language = '',
    this.isLoading = false,
  });
  
  PreferencesState copyWith({
    String? language,
    bool? isLoading,
  }) {
    return PreferencesState(
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object> get props => [language, isLoading];
}

final class PreferencesInitial extends PreferencesState {}

final class PreferencesLoaded extends PreferencesState {
  const PreferencesLoaded({required super.language});
}
