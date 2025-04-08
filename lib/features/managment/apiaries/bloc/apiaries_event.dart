part of 'apiaries_bloc.dart';

abstract class ApiariesEvent extends Equatable {
  const ApiariesEvent();

  @override
  List<Object?> get props => [];
}

class LoadApiaries extends ApiariesEvent {
  const LoadApiaries();
}

class DeleteApiary extends ApiariesEvent {
  final String apiaryId;
  
  const DeleteApiary(this.apiaryId);
  
  @override
  List<Object?> get props => [apiaryId];
}

class FilterByLocation extends ApiariesEvent {
  final String? location;
  
  const FilterByLocation(this.location);
  
  @override
  List<Object?> get props => [location];
}

class FilterByMigratory extends ApiariesEvent {
  final bool? isMigratory;
  
  const FilterByMigratory(this.isMigratory);
  
  @override
  List<Object?> get props => [isMigratory];
}

class FilterByApiaryStatus extends ApiariesEvent {
  final ApiaryStatus? status;
  
  const FilterByApiaryStatus(this.status);
  
  @override
  List<Object?> get props => [status];
}

class ResetFilters extends ApiariesEvent {
  const ResetFilters();
}

class ReorderApiaries extends ApiariesEvent {
  final int oldIndex;
  final int newIndex;
  
  const ReorderApiaries({
    required this.oldIndex,
    required this.newIndex,
  });
  
  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class SortApiaries extends ApiariesEvent {
  final ApiarySortOption sortOption;
  final bool ascending;
  
  const SortApiaries({
    required this.sortOption,
    required this.ascending,
  });
  
  @override
  List<Object?> get props => [sortOption, ascending];
}
