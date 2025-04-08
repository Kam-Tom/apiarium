import 'dart:async';

import 'package:apiarium/shared/repositories/queen_breed_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_event.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_state.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/extensions/date_compare.dart';

class QueensBloc extends Bloc<QueensEvent, QueensState> {
  final QueenRepository _queenRepository;
  final ApiaryRepository _apiaryRepository;
  final QueenBreedRepository _breedRepository;
  
  QueensBloc({
    required QueenRepository queenRepository,
    required ApiaryRepository apiaryRepository,
    required QueenBreedRepository breedRepository,
  }) : 
    _queenRepository = queenRepository,
    _apiaryRepository = apiaryRepository,
    _breedRepository = breedRepository,
    super(const QueensState()) {
    on<LoadQueens>(_onLoadQueens);
    on<SortQueens>(_onSortQueens);
    on<DeleteQueen>(_onDeleteQueen);
    on<FilterByBreed>(_onFilterByBreed);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByApiary>(_onFilterByApiary);
    on<FilterByDateRange>(_onFilterByDateRange);
    on<ResetFilters>(_onResetFilters);
    on<AddQueen>(_onAddQueen);
  }

  Future<void> _onLoadQueens(
    LoadQueens event,
    Emitter<QueensState> emit,
  ) async {
    emit(state.copyWith(status: QueensStatus.loading));
    
    try {
      // Load all necessary data
      final queens = await _queenRepository.getAllQueens(includeApiary: true, includeHive: true);
      final breeds = await _breedRepository.getAllBreeds();
      final apiaries = await _apiaryRepository.getAllApiaries();
      
      final filteredQueens = _applyFilters(queens);
      final sortedQueens = _applySorting(
        filteredQueens, 
        state.sortOption, 
        state.ascending
      );
      
      emit(state.copyWith(
        status: QueensStatus.loaded,
        allQueens: queens,
        filteredQueens: sortedQueens,
        availableBreeds: breeds,
        availableApiaries: apiaries,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: QueensStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onSortQueens(
    SortQueens event,
    Emitter<QueensState> emit,
  ) {
    final sortedQueens = _applySorting(
      state.filteredQueens,
      event.sortOption,
      event.ascending,
    );
    
    emit(state.copyWith(
      sortOption: event.sortOption,
      ascending: event.ascending,
      filteredQueens: sortedQueens,
    ));
  }

  Future<void> _onDeleteQueen(
    DeleteQueen event,
    Emitter<QueensState> emit,
  ) async {
    try {
      await _queenRepository.deleteQueen(event.queenId);
      
      // Refresh the list
      add(const LoadQueens());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to delete queen: ${e.toString()}',
      ));
    }
  }

  void _onFilterByBreed(
    FilterByBreed event,
    Emitter<QueensState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      breedId: () => event.breedId,
    );
    
    final filteredQueens = _applyFilters(state.allQueens, newFilter);
    final sortedQueens = _applySorting(
      filteredQueens, 
      state.sortOption, 
      state.ascending
    );
    
    emit(state.copyWith(
      filter: newFilter,
      filteredQueens: sortedQueens,
    ));
  }

  void _onFilterByStatus(
    FilterByStatus event,
    Emitter<QueensState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      status: () => event.status,
    );
    
    final filteredQueens = _applyFilters(state.allQueens, newFilter);
    final sortedQueens = _applySorting(
      filteredQueens, 
      state.sortOption, 
      state.ascending
    );
    
    emit(state.copyWith(
      filter: newFilter,
      filteredQueens: sortedQueens,
    ));
  }

  void _onFilterByApiary(
    FilterByApiary event,
    Emitter<QueensState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      apiaryId: () => event.apiaryId,
    );
    
    final filteredQueens = _applyFilters(state.allQueens, newFilter);
    final sortedQueens = _applySorting(
      filteredQueens, 
      state.sortOption, 
      state.ascending
    );
    
    emit(state.copyWith(
      filter: newFilter,
      filteredQueens: sortedQueens,
    ));
  }

  void _onFilterByDateRange(
    FilterByDateRange event,
    Emitter<QueensState> emit,
  ) {
    final newFilter = state.filter.copyWith(
      fromDate: () => event.fromDate,
      toDate: () => event.toDate,
    );
    
    final filteredQueens = _applyFilters(state.allQueens, newFilter);
    final sortedQueens = _applySorting(
      filteredQueens, 
      state.sortOption, 
      state.ascending
    );
    
    emit(state.copyWith(
      filter: newFilter,
      filteredQueens: sortedQueens,
    ));
  }

  void _onResetFilters(
    ResetFilters event,
    Emitter<QueensState> emit,
  ) {
    final newFilter = const QueenFilter();
    final filteredQueens = _applyFilters(state.allQueens);
    final sortedQueens = _applySorting(
      filteredQueens, 
      state.sortOption, 
      state.ascending
    );
    
    emit(state.copyWith(
      filter: newFilter,
      filteredQueens: sortedQueens,
    ));
  }

  FutureOr<void> _onAddQueen(
    AddQueen event, 
    Emitter<QueensState> emit
  ) async {
    try {
      final newQueen = await _queenRepository.createDefaultQueen();
      
      // Add the new queen to both allQueens and filteredQueens
      final updatedAllQueens = List<Queen>.from(state.allQueens)..add(newQueen);
      final updatedFilteredQueens = List<Queen>.from(state.filteredQueens)..add(newQueen);
      
      // Apply sorting to maintain consistency
      final sortedFilteredQueens = _applySorting(
        updatedFilteredQueens,
        state.sortOption,
        state.ascending
      );
      
      emit(state.copyWith(
        allQueens: updatedAllQueens,
        filteredQueens: sortedFilteredQueens,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to add queen: ${e.toString()}',
      ));
    }
  }

  List<Queen> _applyFilters(List<Queen> queens, [QueenFilter? filter]) {
    filter ??= state.filter;
    
    return queens.where((queen) {
      // Filter by status
      if (filter!.status != null && queen.status != filter.status) {
        return false;
      }
      
      // Filter by breed
      if (filter.breedId != null && queen.breed.id != filter.breedId) {
        return false;
      }
      
      // Filter by apiary
      if (filter.apiaryId != null && queen.apiary?.id != filter.apiaryId) {
        return false;
      }
      
      // Filter by date range
      if (filter.fromDate != null && queen.birthDate.isBeforeDay(filter.fromDate!)) {
        return false;
      }
      
      if (filter.toDate != null && queen.birthDate.isAfterDay(filter.toDate!)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  List<Queen> _applySorting(
    List<Queen> queens,
    QueenSortOption sortOption,
    bool ascending,
  ) {
    final sortedList = List<Queen>.from(queens);
    
    switch (sortOption) {
      case QueenSortOption.name:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case QueenSortOption.birthDate:
        sortedList.sort((a, b) => a.birthDate.compareTo(b.birthDate));
        break;
      case QueenSortOption.breedName:
        sortedList.sort((a, b) => a.breed.name.compareTo(b.breed.name));
        break;
      case QueenSortOption.status:
        sortedList.sort((a, b) => a.status.name.compareTo(b.status.name));
        break;
    }
    
    return ascending ? sortedList : sortedList.reversed.toList();
  }
}
