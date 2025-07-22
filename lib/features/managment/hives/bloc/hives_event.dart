part of 'hives_bloc.dart';

abstract class HivesEvent extends Equatable {
  const HivesEvent();

  @override
  List<Object?> get props => [];
}

class LoadHives extends HivesEvent {
  const LoadHives();
}

class DeleteHive extends HivesEvent {
  final String hiveId;

  const DeleteHive(this.hiveId);

  @override
  List<Object> get props => [hiveId];
}

class FilterByApiaryId extends HivesEvent {
  final String? apiaryId;

  const FilterByApiaryId(this.apiaryId);

  @override
  List<Object?> get props => [apiaryId];
}

class ResetFilters extends HivesEvent {
  const ResetFilters();
}

class ReorderHives extends HivesEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderHives({required this.oldIndex, required this.newIndex});

  @override
  List<Object> get props => [oldIndex, newIndex];
}

class SortHives extends HivesEvent {
  final HiveSortOption sortOption;
  final bool ascending;

  const SortHives({
    required this.sortOption,
    required this.ascending,
  });

  @override
  List<Object> get props => [sortOption, ascending];
}

class FilterByHiveTypeId extends HivesEvent {
  final String? hiveTypeId;

  const FilterByHiveTypeId(this.hiveTypeId);

  @override
  List<Object?> get props => [hiveTypeId];
}

class FilterByQueenStatus extends HivesEvent {
  final String? queenStatus;

  const FilterByQueenStatus(this.queenStatus);

  @override
  List<Object?> get props => [queenStatus];
}

class AddHive extends HivesEvent {
  const AddHive();
}

class FilterByHiveStatus extends HivesEvent {
  final HiveStatus? hiveStatus;

  const FilterByHiveStatus(this.hiveStatus);

  @override
  List<Object?> get props => [hiveStatus];
}
