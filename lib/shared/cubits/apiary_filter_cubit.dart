import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

class ApiaryFilterState extends Equatable {
  final List<Apiary> availableApiaries;
  final String? selectedApiaryId;
  final bool isLoading;

  const ApiaryFilterState({
    this.availableApiaries = const [],
    this.selectedApiaryId,
    this.isLoading = false,
  });

  ApiaryFilterState copyWith({
    List<Apiary>? availableApiaries,
    String? Function()? selectedApiaryId,
    bool? isLoading,
  }) {
    return ApiaryFilterState(
      availableApiaries: availableApiaries ?? this.availableApiaries,
      selectedApiaryId: selectedApiaryId != null ? selectedApiaryId() : this.selectedApiaryId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [availableApiaries, selectedApiaryId, isLoading];
}

class ApiaryFilterCubit extends Cubit<ApiaryFilterState> {
  final ApiaryService _apiaryService;

  ApiaryFilterCubit(this._apiaryService) : super(const ApiaryFilterState());

  Future<void> loadApiaries() async {
    emit(state.copyWith(isLoading: true));
    try {
      final apiaries = await _apiaryService.getAllApiaries();
      emit(state.copyWith(
        availableApiaries: apiaries,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void selectApiary(String? apiaryId) {
    emit(state.copyWith(selectedApiaryId: () => apiaryId));
  }
}
