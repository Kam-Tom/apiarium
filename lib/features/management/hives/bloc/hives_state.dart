part of 'hives_bloc.dart';

enum HivesStatus { initial, loading, loaded, error }

class HiveFilter {
  final String? apiaryId;
  final String? strength;
  final String? hiveTypeId;
  final String? queenStatus;
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
}

class HivesState extends Equatable {
  final HivesStatus status;
  final List<Hive> allHives;
  final List<Hive> filteredHives;
  final HiveFilter filter;
  final HiveSortOption sortOption;
  final bool ascending;
  final String? errorMessage;
  final List<Apiary> availableApiaries;
  final List<HiveType> availableHiveTypes;

  const HivesState({
    this.status = HivesStatus.initial,
    this.allHives = const [],
    this.filteredHives = const [],
    this.filter = const HiveFilter(),
    this.sortOption = HiveSortOption.name,
    this.ascending = true,
    this.errorMessage,
    this.availableApiaries = const [],
    this.availableHiveTypes = const [],
  });

  HivesState copyWith({
    HivesStatus? status,
    List<Hive>? allHives,
    List<Hive>? filteredHives,
    HiveFilter? filter,
    HiveSortOption? sortOption,
    bool? ascending,
    String? Function()? errorMessage,
    List<Apiary>? availableApiaries,
    List<HiveType>? availableHiveTypes,
  }) {
    return HivesState(
      status: status ?? this.status,
      allHives: allHives ?? this.allHives,
      filteredHives: filteredHives ?? this.filteredHives,
      filter: filter ?? this.filter,
      sortOption: sortOption ?? this.sortOption,
      ascending: ascending ?? this.ascending,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      availableApiaries: availableApiaries ?? this.availableApiaries,
      availableHiveTypes: availableHiveTypes ?? this.availableHiveTypes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allHives,
    filteredHives,
    filter,
    sortOption,
    ascending,
    errorMessage,
    availableApiaries,
    availableHiveTypes,
  ];
}