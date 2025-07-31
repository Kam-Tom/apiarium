import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

abstract class HiveTypesEvent extends Equatable {
  const HiveTypesEvent();

  @override
  List<Object?> get props => [];
}

class LoadHiveTypes extends HiveTypesEvent {
  const LoadHiveTypes();
}

class DeleteHiveType extends HiveTypesEvent {
  final String hiveTypeId;
  
  const DeleteHiveType(this.hiveTypeId);
  
  @override
  List<Object?> get props => [hiveTypeId];
}

class ToggleHiveTypeStar extends HiveTypesEvent {
  final String hiveTypeId;
  
  const ToggleHiveTypeStar(this.hiveTypeId);
  
  @override
  List<Object?> get props => [hiveTypeId];
}

class FilterByStarred extends HiveTypesEvent {
  final bool? starredOnly;
  
  const FilterByStarred(this.starredOnly);
  
  @override
  List<Object?> get props => [starredOnly];
}

class FilterByLocal extends HiveTypesEvent {
  final bool? localOnly;
  
  const FilterByLocal(this.localOnly);
  
  @override
  List<Object?> get props => [localOnly];
}

class FilterByMaterial extends HiveTypesEvent {
  final HiveMaterial? material;
  
  const FilterByMaterial(this.material);
  
  @override
  List<Object?> get props => [material];
}