import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

enum QueenBreedsStatus { initial, loading, loaded, error }

class QueenBreedsFilter {
  final bool? starredOnly;
  final bool? localOnly;

  const QueenBreedsFilter({
    this.starredOnly,
    this.localOnly,
  });

  QueenBreedsFilter copyWith({
    bool? Function()? starredOnly,
    bool? Function()? localOnly,
  }) {
    return QueenBreedsFilter(
      starredOnly: starredOnly != null ? starredOnly() : this.starredOnly,
      localOnly: localOnly != null ? localOnly() : this.localOnly,
    );
  }
}

class QueenBreedsState extends Equatable {
  final QueenBreedsStatus status;
  final List<QueenBreed> allBreeds;
  final List<QueenBreed> filteredBreeds;
  final QueenBreedsFilter filter;
  final String? errorMessage;

  const QueenBreedsState({
    this.status = QueenBreedsStatus.initial,
    this.allBreeds = const [],
    this.filteredBreeds = const [],
    this.filter = const QueenBreedsFilter(),
    this.errorMessage,
  });

  QueenBreedsState copyWith({
    QueenBreedsStatus? status,
    List<QueenBreed>? allBreeds,
    List<QueenBreed>? filteredBreeds,
    QueenBreedsFilter? filter,
    String? Function()? errorMessage,
  }) {
    return QueenBreedsState(
      status: status ?? this.status,
      allBreeds: allBreeds ?? this.allBreeds,
      filteredBreeds: filteredBreeds ?? this.filteredBreeds,
      filter: filter ?? this.filter,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allBreeds,
    filteredBreeds,
    filter,
    errorMessage,
  ];
}