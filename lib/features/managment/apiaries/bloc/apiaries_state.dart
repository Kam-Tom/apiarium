part of 'apiaries_bloc.dart';

enum ApiariesStatus { initial, loading, loaded, error }

class ApiaryFilter extends Equatable {
  final String? location;
  final bool? isMigratory;
  final ApiaryStatus? status;

  const ApiaryFilter({
    this.location,
    this.isMigratory,
    this.status,
  });

  ApiaryFilter copyWith({
    String? Function()? location,
    bool? Function()? isMigratory,
    ApiaryStatus? Function()? status,
  }) {
    return ApiaryFilter(
      location: location != null ? location() : this.location,
      isMigratory: isMigratory != null ? isMigratory() : this.isMigratory,
      status: status != null ? status() : this.status,
    );
  }

  @override
  List<Object?> get props => [location, isMigratory, status];
}

class ApiariesState extends Equatable {
  final ApiariesStatus status;
  final List<Apiary> allApiaries;
  final List<Apiary> filteredApiaries;
  final ApiaryFilter filter;
  final String? errorMessage;
  final ApiarySortOption sortOption;
  final bool ascending;

  const ApiariesState({
    this.status = ApiariesStatus.initial,
    this.allApiaries = const [],
    this.filteredApiaries = const [],
    this.filter = const ApiaryFilter(),
    this.errorMessage,
    this.sortOption = ApiarySortOption.name,
    this.ascending = true,
  });

  ApiariesState copyWith({
    ApiariesStatus? status,
    List<Apiary>? allApiaries,
    List<Apiary>? filteredApiaries,
    ApiaryFilter? filter,
    String? errorMessage,
    ApiarySortOption? sortOption,
    bool? ascending,
  }) {
    return ApiariesState(
      status: status ?? this.status,
      allApiaries: allApiaries ?? this.allApiaries,
      filteredApiaries: filteredApiaries ?? this.filteredApiaries,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
      sortOption: sortOption ?? this.sortOption,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    allApiaries, 
    filteredApiaries, 
    filter, 
    errorMessage,
    sortOption,
    ascending,
  ];
}
