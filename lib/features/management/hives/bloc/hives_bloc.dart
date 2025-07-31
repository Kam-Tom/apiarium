import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

part 'hives_event.dart';
part 'hives_state.dart';

enum HiveSortOption {
  name,
  apiary,
  type,
  queenStatus,
  hiveStatus,
}

class HivesBloc extends Bloc<HivesEvent, HivesState> {
  final HiveService _hiveService;
  final ApiaryService _apiaryService;
  final StorageService _storageService;

  HivesBloc({
    required HiveService hiveService,
    required ApiaryService apiaryService,
    required StorageService storageService,
  }) : 
    _hiveService = hiveService,
    _apiaryService = apiaryService,
    _storageService = storageService,
    super(const HivesState()) {
    on<LoadHives>(_onLoadHives);
    on<DeleteHive>(_onDeleteHive);
    on<FilterByApiaryId>(_onFilterByApiaryId);
    on<FilterByHiveTypeId>(_onFilterByHiveTypeId);
    on<FilterByQueenStatus>(_onFilterByQueenStatus);
    on<FilterByHiveStatus>(_onFilterByHiveStatus);
    on<ResetFilters>(_onResetFilters);
    on<ReorderHives>(_onReorderHives);
    on<SortHives>(_onSortHives);
  }

  Future<void> _onLoadHives(
    LoadHives event,
    Emitter<HivesState> emit,
  ) async {
    emit(state.copyWith(status: HivesStatus.loading));
    
    try {
      final hives = await _hiveService.getAllHives();
      final apiaries = await _apiaryService.getAllApiaries();
      final hiveTypes = await _hiveService.getAllHiveTypes();
      
      final filteredHives = _applyFilters(hives);
      
      emit(state.copyWith(
        status: HivesStatus.loaded,
        allHives: hives,
        filteredHives: filteredHives,
        availableApiaries: apiaries,
        availableHiveTypes: hiveTypes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HivesStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onDeleteHive(
    DeleteHive event,
    Emitter<HivesState> emit,
  ) async {
    try {
      final hive = await _hiveService.getHiveById(event.hiveId);
      if (hive != null) {
        await _storageService.removeFromStorage(
          group: 'management',
          item: 'hive',
          variant: hive.hiveType,
          reason: 'Hive deleted: ${hive.name}',
          apiaryId: hive.apiaryId,
        );
      }
      
      await _hiveService.deleteHive(event.hiveId);
      add(const LoadHives());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to delete hive: ${e.toString()}',
      ));
    }
  }

  void _onFilterByApiaryId(
    FilterByApiaryId event,
    Emitter<HivesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      apiaryId: () => event.apiaryId,
    );
    
    final filteredHives = _applyFilters(state.allHives, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredHives: filteredHives,
    ));
  }

  void _onFilterByHiveTypeId(
    FilterByHiveTypeId event,
    Emitter<HivesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      hiveTypeId: () => event.hiveTypeId,
    );
    
    final filteredHives = _applyFilters(state.allHives, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredHives: filteredHives,
    ));
  }

  void _onFilterByQueenStatus(
    FilterByQueenStatus event,
    Emitter<HivesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      queenStatus: () => event.queenStatus,
    );
    
    final filteredHives = _applyFilters(state.allHives, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredHives: filteredHives,
    ));
  }

  void _onFilterByHiveStatus(
    FilterByHiveStatus event,
    Emitter<HivesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      hiveStatus: () => event.hiveStatus,
    );
    
    final filteredHives = _applyFilters(state.allHives, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredHives: filteredHives,
    ));
  }

  void _onResetFilters(
    ResetFilters event,
    Emitter<HivesState> emit,
  ) {
    final newFilter = HiveFilter();
    final filteredHives = _applyFilters(state.allHives);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredHives: filteredHives,
    ));
  }

  void _onReorderHives(
    ReorderHives event,
    Emitter<HivesState> emit,
  ) async {
    final adjustedNewIndex = 
        event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex;
    
    final updatedHives = [...state.filteredHives];
    final item = updatedHives.removeAt(event.oldIndex);
    updatedHives.insert(adjustedNewIndex, item);
    
    final hivesWithNewPositions = List<Hive>.generate(
      updatedHives.length,
      (index) => updatedHives[index].copyWith(
        order: () => index,
      ),
    );
    
    final updatedHiveMap = {
      for (var hive in hivesWithNewPositions) hive.id: hive
    };
    
    final updatedAllHives = state.allHives.map((hive) {
      return updatedHiveMap.containsKey(hive.id) 
          ? updatedHiveMap[hive.id]! 
          : hive;
    }).toList();

    try {
      emit(
        state.copyWith(
          filteredHives: hivesWithNewPositions,
          allHives: updatedAllHives,
        ),
      );
      
      for (final hive in hivesWithNewPositions) {
        await _hiveService.updateHive(hive);
      }

    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to save the new order: ${e.toString()}',
      ));
      
      add(const LoadHives());
    }
  }

  void _onSortHives(SortHives event, Emitter<HivesState> emit) {
    final sortedHives = List<Hive>.from(state.filteredHives);

    switch (event.sortOption) {
      case HiveSortOption.name:
        sortedHives.sort((a, b) => event.ascending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case HiveSortOption.apiary:
        sortedHives.sort((a, b) {
          final apiaryNameA = a.apiaryName ?? '';
          final apiaryNameB = b.apiaryName ?? '';
          return event.ascending
              ? apiaryNameA.compareTo(apiaryNameB)
              : apiaryNameB.compareTo(apiaryNameA);
        });
        break;
      case HiveSortOption.type:
        sortedHives.sort((a, b) {
          final typeNameA = a.hiveType;
          final typeNameB = b.hiveType;
          return event.ascending
              ? typeNameA.compareTo(typeNameB)
              : typeNameB.compareTo(typeNameA);
        });
        break;
      case HiveSortOption.queenStatus:
        sortedHives.sort((a, b) {
          final hasQueenA = a.queenId != null;
          final hasQueenB = b.queenId != null;
          
          if (hasQueenA != hasQueenB) {
            return event.ascending
                ? (hasQueenA ? -1 : 1)
                : (hasQueenA ? 1 : -1);
          }
          
          if (hasQueenA && hasQueenB) {
            final queenNameA = a.queenName ?? '';
            final queenNameB = b.queenName ?? '';
            return event.ascending
                ? queenNameA.compareTo(queenNameB)
                : queenNameB.compareTo(queenNameA);
          }
          
          return 0;
        });
        break;
      case HiveSortOption.hiveStatus:
        sortedHives.sort((a, b) => event.ascending
            ? a.status.name.compareTo(b.status.name)
            : b.status.name.compareTo(a.status.name));
        break;
    }

    emit(state.copyWith(
      filteredHives: sortedHives,
      sortOption: event.sortOption,
      ascending: event.ascending,
    ));
  }

  List<Hive> _applyFilters(List<Hive> hives, [HiveFilter? filter]) {
    filter ??= state.filter;
    
    return hives.where((hive) {
      if (filter!.apiaryId != null && hive.apiaryId != filter.apiaryId) {
        return false;
      }
      
      if (filter.hiveTypeId != null && hive.hiveTypeId != filter.hiveTypeId) {
        return false;
      }
      
      if (filter.queenStatus != null) {
        if (filter.queenStatus == 'withQueen' && hive.queenId == null) {
          return false;
        } else if (filter.queenStatus == 'noQueen' && hive.queenId != null) {
          return false;
        }
      }
      
      if (filter.hiveStatus != null && hive.status != filter.hiveStatus) {
        return false;
      }
      
      return true;
    }).toList();
  }
}