import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_state.dart';

abstract class QueensEvent extends Equatable {
  const QueensEvent();

  @override
  List<Object?> get props => [];
}

class LoadQueens extends QueensEvent {
  const LoadQueens();
}

class SortQueens extends QueensEvent {
  final QueenSortOption sortOption;
  final bool ascending;
  
  const SortQueens({required this.sortOption, this.ascending = true});
  
  @override
  List<Object?> get props => [sortOption, ascending];
}

class DeleteQueen extends QueensEvent {
  final String queenId;
  
  const DeleteQueen(this.queenId);
  
  @override
  List<Object?> get props => [queenId];
}

class FilterByBreed extends QueensEvent {
  final String? breedId;
  
  const FilterByBreed(this.breedId);
  
  @override
  List<Object?> get props => [breedId];
}

class FilterByStatus extends QueensEvent {
  final QueenStatus? status;
  
  const FilterByStatus(this.status);
  
  @override
  List<Object?> get props => [status];
}

class FilterByApiary extends QueensEvent {
  final String? apiaryId;
  
  const FilterByApiary(this.apiaryId);
  
  @override
  List<Object?> get props => [apiaryId];
}
class AddQueen extends QueensEvent {
  const AddQueen();
}

class FilterByDateRange extends QueensEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  
  const FilterByDateRange({this.fromDate, this.toDate});
  
  @override
  List<Object?> get props => [fromDate, toDate];
}

class ResetFilters extends QueensEvent {}
