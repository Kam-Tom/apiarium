import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
    Emitter<PreferencesState> emit
  ) {
    final language = _userService.language;
    emit(PreferencesLoaded(language: language));
  }
  
  void _onChangeLanguage(
    ChangeLanguage event, 
    Emitter<PreferencesState> emit
  ) {
    _userService.language = event.language;
    emit(state.copyWith(language: event.language));
  }
}
