import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

enum HiveTypesStatus { initial, loading, loaded, error }

class HiveTypesFilter {
  final bool? starredOnly;
  final bool? localOnly;
  final HiveMaterial? material;

  const HiveTypesFilter({
    this.starredOnly,
    this.localOnly,
    this.material,
  });

  HiveTypesFilter copyWith({
    bool? Function()? starredOnly,
    bool? Function()? localOnly,
    HiveMaterial? Function()? material,
  }) {
    return HiveTypesFilter(
      starredOnly: starredOnly != null ? starredOnly() : this.starredOnly,
      localOnly: localOnly != null ? localOnly() : this.localOnly,
      material: material != null ? material() : this.material,
    );
  }
}

class HiveTypesState extends Equatable {
  final HiveTypesStatus status;
  final List<HiveType> allHiveTypes;
  final List<HiveType> filteredHiveTypes;
  final HiveTypesFilter filter;
  final String? errorMessage;

  const HiveTypesState({
    this.status = HiveTypesStatus.initial,
    this.allHiveTypes = const [],
    this.filteredHiveTypes = const [],
    this.filter = const HiveTypesFilter(),
    this.errorMessage,
  });

  HiveTypesState copyWith({
    HiveTypesStatus? status,
    List<HiveType>? allHiveTypes,
    List<HiveType>? filteredHiveTypes,
    HiveTypesFilter? filter,
    String? Function()? errorMessage,
  }) {
    return HiveTypesState(
      status: status ?? this.status,
      allHiveTypes: allHiveTypes ?? this.allHiveTypes,
      filteredHiveTypes: filteredHiveTypes ?? this.filteredHiveTypes,
      filter: filter ?? this.filter,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allHiveTypes,
    filteredHiveTypes,
    filter,
    errorMessage,
  ];
}