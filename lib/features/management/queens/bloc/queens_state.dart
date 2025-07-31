import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

enum QueensStatus { initial, loading, loaded, error }
enum QueenSortOption { name, birthDate, breedName, status }

class QueenFilter {
  final QueenStatus? status;
  final String? breedId;
  final String? apiaryId;
  final DateTime? fromDate;
  final DateTime? toDate;

  const QueenFilter({
    this.status,
    this.breedId,
    this.apiaryId,
    this.fromDate,
    this.toDate,
  });

  QueenFilter copyWith({
    String? Function()? searchTerm,
    QueenStatus? Function()? status,
    String? Function()? breedId,
    String? Function()? apiaryId,
    DateTime? Function()? fromDate,
    DateTime? Function()? toDate,
  }) {
    return QueenFilter(
      status: status != null ? status() : this.status,
      breedId: breedId != null ? breedId() : this.breedId,
      apiaryId: apiaryId != null ? apiaryId() : this.apiaryId,
      fromDate: fromDate != null ? fromDate() : this.fromDate,
      toDate: toDate != null ? toDate() : this.toDate,
    );
  }
}

class QueensState extends Equatable {
  final QueensStatus status;
  final List<Queen> allQueens;
  final List<Queen> filteredQueens;
  final QueenFilter filter;
  final QueenSortOption sortOption;
  final bool ascending;
  final String? errorMessage;
  final List<QueenBreed> availableBreeds;

  const QueensState({
    this.status = QueensStatus.initial,
    this.allQueens = const [],
    this.filteredQueens = const [],
    this.filter = const QueenFilter(),
    this.sortOption = QueenSortOption.name,
    this.ascending = true,
    this.errorMessage,
    this.availableBreeds = const [],
  });

  QueensState copyWith({
    QueensStatus? status,
    List<Queen>? allQueens,
    List<Queen>? filteredQueens,
    QueenFilter? filter,
    QueenSortOption? sortOption,
    bool? ascending,
    String? Function()? errorMessage,
    List<QueenBreed>? availableBreeds,
  }) {
    return QueensState(
      status: status ?? this.status,
      allQueens: allQueens ?? this.allQueens,
      filteredQueens: filteredQueens ?? this.filteredQueens,
      filter: filter ?? this.filter,
      sortOption: sortOption ?? this.sortOption,
      ascending: ascending ?? this.ascending,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      availableBreeds: availableBreeds ?? this.availableBreeds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allQueens,
    filteredQueens,
    filter,
    sortOption,
    ascending,
    errorMessage,
    availableBreeds,
  ];
}
