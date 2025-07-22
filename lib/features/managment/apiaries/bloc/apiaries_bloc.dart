import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

part 'apiaries_event.dart';
part 'apiaries_state.dart';

enum ApiarySortOption {
  name,
  location,
  hiveCount,
  createdAt,
  status,
}

class ApiariesBloc extends Bloc<ApiariesEvent, ApiariesState> {
  final ApiaryService _apiaryService;

  ApiariesBloc({
    required ApiaryService apiaryService,
  }) : 
    _apiaryService = apiaryService,
    super(const ApiariesState()) {
    on<LoadApiaries>(_onLoadApiaries);
    on<DeleteApiary>(_onDeleteApiary);
    on<FilterByLocation>(_onFilterByLocation);
    on<FilterByMigratory>(_onFilterByMigratory);
    on<FilterByApiaryStatus>(_onFilterByApiaryStatus);
    on<ResetFilters>(_onResetFilters);
    on<ReorderApiaries>(_onReorderApiaries);
    on<SortApiaries>(_onSortApiaries);
  }

  Future<void> _onLoadApiaries(
    LoadApiaries event,
    Emitter<ApiariesState> emit,
  ) async {
    emit(state.copyWith(status: ApiariesStatus.loading));
    
    try {
      final apiaries = await _apiaryService.getAllApiaries();
      
      final filteredApiaries = _applyFilters(apiaries);
      
      emit(state.copyWith(
        status: ApiariesStatus.loaded,
        allApiaries: apiaries,
        filteredApiaries: filteredApiaries,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ApiariesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteApiary(
    DeleteApiary event,
    Emitter<ApiariesState> emit,
  ) async {
    try {
      await _apiaryService.deleteApiary(event.apiaryId);
      
      // Refresh the list
      add(const LoadApiaries());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete apiary: ${e.toString()}',
      ));
    }
  }

  void _onFilterByLocation(
    FilterByLocation event,
    Emitter<ApiariesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      location: () => event.location,
    );
    
    final filteredApiaries = _applyFilters(state.allApiaries, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredApiaries: filteredApiaries,
    ));
  }

  void _onFilterByMigratory(
    FilterByMigratory event,
    Emitter<ApiariesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      isMigratory: () => event.isMigratory,
    );
    
    final filteredApiaries = _applyFilters(state.allApiaries, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredApiaries: filteredApiaries,
    ));
  }

  void _onFilterByApiaryStatus(
    FilterByApiaryStatus event,
    Emitter<ApiariesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      status: () => event.status,
    );
    
    final filteredApiaries = _applyFilters(state.allApiaries, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredApiaries: filteredApiaries,
    ));
  }

  void _onResetFilters(
    ResetFilters event,
    Emitter<ApiariesState> emit,
  ) {
    final newFilter = ApiaryFilter();
    final filteredApiaries = _applyFilters(state.allApiaries);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredApiaries: filteredApiaries,
    ));
  }

  void _onReorderApiaries(
    ReorderApiaries event,
    Emitter<ApiariesState> emit,
  ) async {    
    // Handle the case where newIndex > oldIndex due to how ReorderableListView works
    final adjustedNewIndex = 
        event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex;
    
    // Create a mutable copy of the filteredApiaries list
    final updatedApiaries = [...state.filteredApiaries];
    
    // Remove item from old position and insert at new position
    final item = updatedApiaries.removeAt(event.oldIndex);
    updatedApiaries.insert(adjustedNewIndex, item);
    
    try {
      emit(
        state.copyWith(
          filteredApiaries: updatedApiaries,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to save the new order: ${e.toString()}',
      ));
      
      // Reload the original order on error
      add(const LoadApiaries());
    }
  }

  void _onSortApiaries(
    SortApiaries event, 
    Emitter<ApiariesState> emit
  ) {
    final sortedApiaries = List<Apiary>.from(state.filteredApiaries);

    switch (event.sortOption) {
      case ApiarySortOption.name:
        sortedApiaries.sort((a, b) => event.ascending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case ApiarySortOption.location:
        sortedApiaries.sort((a, b) {
          if (a.location == null && b.location == null) return 0;
          if (a.location == null) return event.ascending ? -1 : 1;
          if (b.location == null) return event.ascending ? 1 : -1;
          return event.ascending
              ? a.location!.compareTo(b.location!)
              : b.location!.compareTo(a.location!);
        });
        break;
      case ApiarySortOption.hiveCount:
        sortedApiaries.sort((a, b) => event.ascending
            ? a.hiveCount.compareTo(b.hiveCount)
            : b.hiveCount.compareTo(a.hiveCount));
        break;
      case ApiarySortOption.createdAt:
        sortedApiaries.sort((a, b) => event.ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case ApiarySortOption.status:
        sortedApiaries.sort((a, b) => event.ascending
            ? a.status.name.compareTo(b.status.name)
            : b.status.name.compareTo(a.status.name));
        break;
    }

    emit(state.copyWith(
      filteredApiaries: sortedApiaries,
      sortOption: event.sortOption,
      ascending: event.ascending,
    ));
  }

  List<Apiary> _applyFilters(List<Apiary> apiaries, [ApiaryFilter? filter]) {
    filter ??= state.filter;
    
    return apiaries.where((apiary) {
      // Filter by location
      if (filter!.location != null && 
          (apiary.location == null || !apiary.location!.toLowerCase().contains(filter.location!.toLowerCase()))) {
        return false;
      }
      
      // Filter by migratory status
      if (filter.isMigratory != null && apiary.isMigratory != filter.isMigratory) {
        return false;
      }
      
      // Filter by apiary status
      if (filter.status != null && apiary.status != filter.status) {
        return false;
      }
      
      return true;
    }).toList();
  }
}