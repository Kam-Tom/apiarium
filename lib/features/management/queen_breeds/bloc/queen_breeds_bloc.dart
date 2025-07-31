import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/management/queen_breeds/bloc/queen_breeds_event.dart';
import 'package:apiarium/features/management/queen_breeds/bloc/queen_breeds_state.dart';
import 'package:apiarium/shared/shared.dart';

class QueenBreedsBloc extends Bloc<QueenBreedsEvent, QueenBreedsState> {
  final QueenService _queenService;
  
  QueenBreedsBloc({
    required QueenService queenService,
  }) : 
    _queenService = queenService,
    super(const QueenBreedsState()) {
    on<LoadQueenBreeds>(_onLoadQueenBreeds);
    on<CreateQueenBreed>(_onCreateQueenBreed);
    on<DeleteQueenBreed>(_onDeleteQueenBreed);
    on<ToggleBreedStar>(_onToggleBreedStar);
    on<FilterBreedsByStarred>(_onFilterBreedsByStarred);
    on<FilterBreedsByLocal>(_onFilterBreedsByLocal);
  }

  Future<void> _onLoadQueenBreeds(
    LoadQueenBreeds event,
    Emitter<QueenBreedsState> emit,
  ) async {
    emit(state.copyWith(status: QueenBreedsStatus.loading));
    
    try {
      final breeds = await _queenService.getAllQueenBreeds();
      final filteredBreeds = _applyFilters(breeds);
      
      emit(state.copyWith(
        status: QueenBreedsStatus.loaded,
        allBreeds: breeds,
        filteredBreeds: filteredBreeds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: QueenBreedsStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onCreateQueenBreed(
    CreateQueenBreed event,
    Emitter<QueenBreedsState> emit,
  ) async {
    try {
      await _queenService.createQueenBreed(
        name: event.name,
        scientificName: event.scientificName,
        origin: event.origin,
      );
      
      // Reload breeds
      add(const LoadQueenBreeds());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to create breed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteQueenBreed(
    DeleteQueenBreed event,
    Emitter<QueenBreedsState> emit,
  ) async {
    try {
      // TODO: Implement delete functionality in service
      // await _queenService.deleteQueenBreed(event.breedId);
      
      // For now, just reload breeds
      add(const LoadQueenBreeds());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to delete breed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onToggleBreedStar(
    ToggleBreedStar event,
    Emitter<QueenBreedsState> emit,
  ) async {
    try {
      await _queenService.toggleBreedStar(event.breedId);
      
      // Reload breeds to reflect changes
      add(const LoadQueenBreeds());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to toggle star: ${e.toString()}',
      ));
    }
  }

  void _onFilterByStarred(
    FilterBreedsByStarred event,
    Emitter<QueenBreedsState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      starredOnly: () => event.starredOnly,
    );
    
    final filteredBreeds = _applyFilters(state.allBreeds, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredBreeds: filteredBreeds,
    ));
  }

  void _onFilterByLocal(
    FilterBreedsByLocal event,
    Emitter<QueenBreedsState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      localOnly: () => event.localOnly,
    );
    
    final filteredBreeds = _applyFilters(state.allBreeds, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredBreeds: filteredBreeds,
    ));
  }

  void _onFilterBreedsByStarred(
    FilterBreedsByStarred event,
    Emitter<QueenBreedsState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      starredOnly: () => event.starredOnly,
    );
    
    final filteredBreeds = _applyFilters(state.allBreeds, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredBreeds: filteredBreeds,
    ));
  }

  void _onFilterBreedsByLocal(
    FilterBreedsByLocal event,
    Emitter<QueenBreedsState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      localOnly: () => event.localOnly,
    );
    
    final filteredBreeds = _applyFilters(state.allBreeds, newFilter);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredBreeds: filteredBreeds,
    ));
  }

  List<QueenBreed> _applyFilters(List<QueenBreed> breeds, [QueenBreedsFilter? filter]) {
    filter ??= state.filter;
    
    return breeds.where((breed) {
      // Filter by starred
      if (filter!.starredOnly == true && !breed.isStarred) {
        return false;
      }
      
      // Filter by local
      if (filter.localOnly == true && !breed.isLocal) {
        return false;
      }
      
      return true;
    }).toList();
  }
}