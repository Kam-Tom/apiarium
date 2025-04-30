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

  HivesBloc({
    required HiveService hiveService,
    required ApiaryService apiaryService,
  }) : 
    _hiveService = hiveService,
    _apiaryService = apiaryService,
    super(const HivesState()) {
    on<LoadHives>(_onLoadHives);
    on<DeleteHive>(_onDeleteHive);
    on<FilterByApiaryId>(_onFilterByApiaryId);
    on<FilterByStrength>(_onFilterByStrength);
    on<FilterByHiveTypeId>(_onFilterByHiveTypeId);
    on<FilterByQueenStatus>(_onFilterByQueenStatus);
    on<FilterByHiveStatus>(_onFilterByHiveStatus);
    on<ResetFilters>(_onResetFilters);
    on<ReorderHives>(_onReorderHives);
    on<AddHive>(_onAddHive);
    on<SortHives>(_onSortHives);
  }

  Future<void> _onLoadHives(
    LoadHives event,
    Emitter<HivesState> emit,
  ) async {
    emit(state.copyWith(status: HivesStatus.loading));
    
    try {
      final hives = await _hiveService.getAllHives(includeApiary: true, includeQueen: true);
      final apiaries = await _apiaryService.getAllApiaries();
      
      final filteredHives = _applyFilters(hives);
      
      emit(state.copyWith(
        status: HivesStatus.loaded,
        allHives: hives,
        filteredHives: filteredHives,
        availableApiaries: apiaries,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HivesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteHive(
    DeleteHive event,
    Emitter<HivesState> emit,
  ) async {
    try {
      await _hiveService.deleteHive(hiveId: event.hiveId);
      
      // Refresh the list
      add(const LoadHives());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to delete hive: ${e.toString()}',
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

  void _onFilterByStrength(
    FilterByStrength event,
    Emitter<HivesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      strength: () => event.strength,
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
    
    // Handle the case where newIndex > oldIndex due to how ReorderableListView works
    final adjustedNewIndex = 
        event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex;
    
    // Create a mutable copy of the filteredHives list
    final updatedHives = [...state.filteredHives];
    
    // Remove item from old position and insert at new position
    final item = updatedHives.removeAt(event.oldIndex);
    updatedHives.insert(adjustedNewIndex, item);
    
    // Now assign consecutive position values to all hives
    final hivesWithNewPositions = List<Hive>.generate(
      updatedHives.length,
      (index) => updatedHives[index].copyWith(
        position: () => index,
      ),
    );
    
    // Create a map of hive IDs to their updated versions for easy lookup
    final updatedHiveMap = {
      for (var hive in hivesWithNewPositions) hive.id: hive
    };
    
    // Update the allHives list with the new positions
    final updatedAllHives = state.allHives.map((hive) {
      // If this hive was reordered, use the updated version
      return updatedHiveMap.containsKey(hive.id) 
          ? updatedHiveMap[hive.id]! 
          : hive;
    }).toList();

    // Use the batch update method to efficiently save all changes
    try {
      emit(
        state.copyWith(
          filteredHives: hivesWithNewPositions,
          allHives: updatedAllHives,
        ),
      );
      
      
      await _hiveService.updateHivesBatch(
        hivesWithNewPositions,
        skipHistoryLog: true  
      );

    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to save the new order: ${e.toString()}',
      ));
      
      // Reload the original order on error
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
        // Get apiary names for sorting
        final apiaries = Map.fromEntries(
          state.availableApiaries.map((a) => MapEntry(a.id, a.name)),
        );
        
        sortedHives.sort((a, b) {
          final apiaryNameA = a.apiary != null ? a.apiary!.name : '';
          final apiaryNameB = b.apiary != null ? a.apiary!.name : '';
          return event.ascending
              ? apiaryNameA.compareTo(apiaryNameB)
              : apiaryNameB.compareTo(apiaryNameA);
        });
        break;
      case HiveSortOption.type:
        sortedHives.sort((a, b) {
          final typeNameA = a.hiveType.name;
          final typeNameB = b.hiveType.name;
          return event.ascending
              ? typeNameA.compareTo(typeNameB)
              : typeNameB.compareTo(typeNameA);
        });
        break;
      case HiveSortOption.queenStatus:
        sortedHives.sort((a, b) {
          // Hives with queens come first (if ascending)
          final hasQueenA = a.queen != null;
          final hasQueenB = b.queen != null;
          
          if (hasQueenA != hasQueenB) {
            return event.ascending
                ? (hasQueenA ? -1 : 1)
                : (hasQueenA ? 1 : -1);
          }
          
          // If both have queens, sort by queen status
          if (hasQueenA && hasQueenB) {
            return event.ascending
                ? a.queen!.status.name.compareTo(b.queen!.status.name)
                : b.queen!.status.name.compareTo(a.queen!.status.name);
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
      // Filter by apiary
      if (filter!.apiaryId != null && hive.apiary?.id != filter.apiaryId) {
        return false;
      }
      
      // Filter by strength
      if (filter.strength != null) {
        // Assuming we derive strength from the current frame count
        final strength = _determineStrength(hive);
        if (strength != filter.strength) {
          return false;
        }
      }
      
      // Filter by hive type
      if (filter.hiveTypeId != null && hive.hiveType.id != filter.hiveTypeId) {
        return false;
      }
      
      // Filter by queen status
      if (filter.queenStatus != null) {
        if (filter.queenStatus == 'withQueen' && hive.queen == null) {
          return false;
        } else if (filter.queenStatus == 'noQueen' && hive.queen != null) {
          return false;
        } else if (filter.queenStatus == 'mated' && 
                  (hive.queen == null || hive.queen!.status != QueenStatus.lost)) {
          return false;
        } else if (filter.queenStatus == 'unmated' && 
                  (hive.queen == null || hive.queen!.status != QueenStatus.active)) {
          return false;
        } else if (filter.queenStatus == 'marked' && 
                  (hive.queen == null || !hive.queen!.marked)) {
          return false;
        }
      }
      
      // Filter by hive status
      if (filter.hiveStatus != null && hive.status != filter.hiveStatus) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Helper method to determine hive strength based on frame count
  String _determineStrength(Hive hive) {
    if (hive.currentFrameCount == null) return 'Unknown';
    
    final frameCount = hive.currentFrameCount!;
    if (frameCount >= 8) return 'Strong';
    if (frameCount >= 5) return 'Medium';
    return 'Weak';
  }

  FutureOr<void> _onAddHive(AddHive event, Emitter<HivesState> emit) async {
    try {
      final newHive = await _hiveService.createDefaultHive(
        name: 'New Hive',
      );
      
      // Add the new hive to both allHives and filteredHives
      final updatedAllHives = List<Hive>.from(state.allHives)..add(newHive);
      final updatedFilteredHives = List<Hive>.from(state.filteredHives)..add(newHive);
      
      emit(state.copyWith(
        allHives: updatedAllHives,
        filteredHives: updatedFilteredHives,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to add new hive: ${e.toString()}',
      ));
    }
  }
}
