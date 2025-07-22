import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/hive_types/bloc/hive_types_event.dart';
import 'package:apiarium/features/managment/hive_types/bloc/hive_types_state.dart';
import 'package:apiarium/shared/shared.dart';

class HiveTypesBloc extends Bloc<HiveTypesEvent, HiveTypesState> {
  final HiveService _hiveService;
  
  HiveTypesBloc({
    required HiveService hiveService,
  }) : 
    _hiveService = hiveService,
    super(const HiveTypesState()) {
    on<LoadHiveTypes>(_onLoadHiveTypes);
    on<DeleteHiveType>(_onDeleteHiveType);
    on<ToggleHiveTypeStar>(_onToggleHiveTypeStar);
    on<FilterByStarred>(_onFilterByStarred);
    on<FilterByLocal>(_onFilterByLocal);
    on<FilterByMaterial>(_onFilterByMaterial);
  }

  Future<void> _onLoadHiveTypes(
    LoadHiveTypes event,
    Emitter<HiveTypesState> emit,
  ) async {
    emit(state.copyWith(status: HiveTypesStatus.loading));
    
    try {
      final hiveTypes = await _hiveService.getAllHiveTypes();
      final filteredHiveTypes = _applyFilters(hiveTypes);
      
      emit(state.copyWith(
        status: HiveTypesStatus.loaded,
        allHiveTypes: hiveTypes,
        filteredHiveTypes: filteredHiveTypes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiveTypesStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onDeleteHiveType(
    DeleteHiveType event,
    Emitter<HiveTypesState> emit,
  ) async {
    try {
      await _hiveService.deleteHiveType(event.hiveTypeId);
      add(const LoadHiveTypes());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to delete hive type: ${e.toString()}',
      ));
    }
  }

  Future<void> _onToggleHiveTypeStar(
    ToggleHiveTypeStar event,
    Emitter<HiveTypesState> emit,
  ) async {
    try {
      await _hiveService.toggleHiveTypeStar(event.hiveTypeId);
      add(const LoadHiveTypes());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to toggle star: ${e.toString()}',
      ));
    }
  }

  void _onFilterByStarred(
    FilterByStarred event,
    Emitter<HiveTypesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      starredOnly: () => event.starredOnly,
    );
    
    final filteredHiveTypes = _applyFilters(state.allHiveTypes, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredHiveTypes: filteredHiveTypes,
    ));
  }

  void _onFilterByLocal(
    FilterByLocal event,
    Emitter<HiveTypesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      localOnly: () => event.localOnly,
    );
    
    final filteredHiveTypes = _applyFilters(state.allHiveTypes, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredHiveTypes: filteredHiveTypes,
    ));
  }

  void _onFilterByMaterial(
    FilterByMaterial event,
    Emitter<HiveTypesState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      material: () => event.material,
    );
    
    final filteredHiveTypes = _applyFilters(state.allHiveTypes, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredHiveTypes: filteredHiveTypes,
    ));
  }

  List<HiveType> _applyFilters(List<HiveType> hiveTypes, [HiveTypesFilter? filter]) {
    filter ??= state.filter;
    
    return hiveTypes.where((hiveType) {
      if (filter!.starredOnly == true && !hiveType.isStarred) {
        return false;
      }
      
      if (filter.localOnly == true && !hiveType.isLocal) {
        return false;
      }
      
      if (filter.material != null && hiveType.material != filter.material) {
        return false;
      }
      
      return true;
    }).toList();
  }
}