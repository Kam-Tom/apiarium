part of 'hives_bloc.dart';

enum HivesStatus { initial, loading, loaded, error }

class HiveFilter extends Equatable {
  final String? apiaryId;
  final String? strength;  // 'Strong', 'Medium', 'Weak'
  final String? hiveTypeId;
  final String? queenStatus; // 'withQueen', 'noQueen', etc.
  final HiveStatus? hiveStatus;

  const HiveFilter({
    this.apiaryId,
    this.strength,
    this.hiveTypeId,
    this.queenStatus,
    this.hiveStatus,
  });

  HiveFilter copyWith({
    String? Function()? apiaryId,
    String? Function()? strength,
    String? Function()? hiveTypeId,
    String? Function()? queenStatus,
    HiveStatus? Function()? hiveStatus,
  }) {
    return HiveFilter(
      apiaryId: apiaryId != null ? apiaryId() : this.apiaryId,
      strength: strength != null ? strength() : this.strength,
      hiveTypeId: hiveTypeId != null ? hiveTypeId() : this.hiveTypeId,
      queenStatus: queenStatus != null ? queenStatus() : this.queenStatus,
      hiveStatus: hiveStatus != null ? hiveStatus() : this.hiveStatus,
    );
  }

  @override
  List<Object?> get props => [apiaryId, strength, hiveTypeId, queenStatus, hiveStatus];
}

class HivesState extends Equatable {
  final HivesStatus status;
  final List<Hive> allHives;
  final List<Hive> filteredHives;
  final List<Apiary> availableApiaries;
  final HiveFilter filter;
  final String? errorMessage;
  final HiveSortOption sortOption;
  final bool ascending;

  const HivesState({
    this.status = HivesStatus.initial,
    this.allHives = const [],
    this.filteredHives = const [],
    this.availableApiaries = const [],
    this.filter = const HiveFilter(),
    this.errorMessage,
    this.sortOption = HiveSortOption.name,
    this.ascending = true,
  });

  HivesState copyWith({
    HivesStatus? status,
    List<Hive>? allHives,
    List<Hive>? filteredHives,
    List<Apiary>? availableApiaries,
    HiveFilter? filter,
    String? errorMessage,
    HiveSortOption? sortOption,
    bool? ascending,
  }) {
    return HivesState(
      status: status ?? this.status,
      allHives: allHives ?? this.allHives,
      filteredHives: filteredHives ?? this.filteredHives,
      availableApiaries: availableApiaries ?? this.availableApiaries,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
      sortOption: sortOption ?? this.sortOption,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    allHives, 
    filteredHives, 
    availableApiaries, 
    filter, 
    errorMessage,
    sortOption,
    ascending,
  ];
}
