import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/management/queens/bloc/queens_event.dart';
import 'package:apiarium/features/management/queens/bloc/queens_state.dart';
import 'package:apiarium/shared/shared.dart';

class QueensBloc extends Bloc<QueensEvent, QueensState> {
  final QueenService _queenService;
  final StorageService _storageService;
  
  QueensBloc({
    required QueenService queenService,
    required StorageService storageService,
  }) : 
    _queenService = queenService,
    _storageService = storageService,
    super(const QueensState()) {
    on<LoadQueens>(_onLoadQueens);
    on<SortQueens>(_onSortQueens);
    on<DeleteQueen>(_onDeleteQueen);
    on<FilterByBreed>(_onFilterByBreed);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByApiary>(_onFilterByApiary);
    on<FilterByDateRange>(_onFilterByDateRange);
    on<ResetFilters>(_onResetFilters);
  }

  Future<void> _onLoadQueens(LoadQueens event, Emitter<QueensState> emit) async {
    emit(state.copyWith(status: QueensStatus.loading));
    
    try {
      final results = await Future.wait([
        _queenService.getAllQueens(),
        _queenService.getAllQueenBreeds(),
      ]);
      
      final queens = results[0] as List<Queen>;
      final breeds = results[1] as List<QueenBreed>;
      
      final filteredQueens = _applyFilters(queens);
      final sortedQueens = _applySorting(filteredQueens, state.sortOption, state.ascending);
      
      emit(state.copyWith(
        status: QueensStatus.loaded,
        allQueens: queens,
        filteredQueens: sortedQueens,
        availableBreeds: breeds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: QueensStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onSortQueens(SortQueens event, Emitter<QueensState> emit) {
    final sortedQueens = _applySorting(state.filteredQueens, event.sortOption, event.ascending);
    
    emit(state.copyWith(
      sortOption: event.sortOption,
      ascending: event.ascending,
      filteredQueens: sortedQueens,
    ));
  }

  Future<void> _onDeleteQueen(DeleteQueen event, Emitter<QueensState> emit) async {
    try {
      final queen = await _queenService.getQueenById(event.queenId);
      if (queen != null) {
        await _storageService.removeFromStorage(
          group: 'management',
          item: 'queen',
          variant: queen.breedName,
          reason: 'Queen deleted: ${queen.name}',
          apiaryId: queen.apiaryId,
        );
      }
      
      await _queenService.deleteQueen(event.queenId);
      add(const LoadQueens());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to delete queen: ${e.toString()}',
      ));
    }
  }

  void _onFilterByBreed(FilterByBreed event, Emitter<QueensState> emit) {
    _applyFilter(emit, state.filter.copyWith(breedId: () => event.breedId));
  }

  void _onFilterByStatus(FilterByStatus event, Emitter<QueensState> emit) {
    _applyFilter(emit, state.filter.copyWith(status: () => event.status));
  }

  void _onFilterByApiary(FilterByApiary event, Emitter<QueensState> emit) {
    _applyFilter(emit, state.filter.copyWith(apiaryId: () => event.apiaryId));
  }

  void _onFilterByDateRange(FilterByDateRange event, Emitter<QueensState> emit) {
    _applyFilter(emit, state.filter.copyWith(
      fromDate: () => event.fromDate,
      toDate: () => event.toDate,
    ));
  }

  void _onResetFilters(ResetFilters event, Emitter<QueensState> emit) {
    _applyFilter(emit, const QueenFilter());
  }

  void _applyFilter(Emitter<QueensState> emit, QueenFilter newFilter) {
    final filteredQueens = _applyFilters(state.allQueens, newFilter);
    final sortedQueens = _applySorting(filteredQueens, state.sortOption, state.ascending);
    
    emit(state.copyWith(
      filter: newFilter,
      filteredQueens: sortedQueens,
    ));
  }

  List<Queen> _applyFilters(List<Queen> queens, [QueenFilter? filter]) {
    filter ??= state.filter;
    
    return queens.where((queen) => 
      _matchesStatusFilter(queen, filter!.status) &&
      _matchesBreedFilter(queen, filter.breedId) &&
      _matchesApiaryFilter(queen, filter.apiaryId) &&
      _matchesDateRangeFilter(queen, filter.fromDate, filter.toDate)
    ).toList();
  }

  bool _matchesStatusFilter(Queen queen, QueenStatus? status) {
    return status == null || queen.status == status;
  }

  bool _matchesBreedFilter(Queen queen, String? breedId) {
    return breedId == null || queen.breedId == breedId;
  }

  bool _matchesApiaryFilter(Queen queen, String? apiaryId) {
    if (apiaryId == null) return true;
    if (apiaryId == 'none') return queen.apiaryId == null;
    return queen.apiaryId == apiaryId;
  }

  bool _matchesDateRangeFilter(Queen queen, DateTime? fromDate, DateTime? toDate) {
    if (fromDate != null && queen.birthDate.isBeforeDay(fromDate)) return false;
    if (toDate != null && queen.birthDate.isAfterDay(toDate)) return false;
    return true;
  }

  List<Queen> _applySorting(List<Queen> queens, QueenSortOption sortOption, bool ascending) {
    final sortedList = [...queens];
    
    switch (sortOption) {
      case QueenSortOption.name:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
      case QueenSortOption.birthDate:
        sortedList.sort((a, b) => a.birthDate.compareTo(b.birthDate));
      case QueenSortOption.breedName:
        sortedList.sort((a, b) => a.breedName.compareTo(b.breedName));
      case QueenSortOption.status:
        sortedList.sort((a, b) => a.status.name.compareTo(b.status.name));
    }
    
    return ascending ? sortedList : sortedList.reversed.toList();
  }
}