import 'package:equatable/equatable.dart';

abstract class QueenBreedsEvent extends Equatable {
  const QueenBreedsEvent();

  @override
  List<Object?> get props => [];
}

class LoadQueenBreeds extends QueenBreedsEvent {
  const LoadQueenBreeds();
}

class CreateQueenBreed extends QueenBreedsEvent {
  final String name;
  final String? scientificName;
  final String? origin;
  
  const CreateQueenBreed({
    required this.name,
    this.scientificName,
    this.origin,
  });
  
  @override
  List<Object?> get props => [name, scientificName, origin];
}

class ToggleBreedStar extends QueenBreedsEvent {
  final String breedId;
  
  const ToggleBreedStar(this.breedId);
  
  @override
  List<Object?> get props => [breedId];
}

class FilterBreedsByStarred extends QueenBreedsEvent {
  final bool? starredOnly;
  
  const FilterBreedsByStarred(this.starredOnly);
  
  @override
  List<Object?> get props => [starredOnly];
}

class FilterBreedsByLocal extends QueenBreedsEvent {
  final bool? localOnly;
  
  const FilterBreedsByLocal(this.localOnly);
  
  @override
  List<Object?> get props => [localOnly];
}

class DeleteQueenBreed extends QueenBreedsEvent {
  final String breedId;
  
  const DeleteQueenBreed(this.breedId);
  
  @override
  List<Object> get props => [breedId];
}