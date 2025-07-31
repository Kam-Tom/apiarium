import 'package:equatable/equatable.dart';

abstract class EditQueenBreedEvent extends Equatable {
  const EditQueenBreedEvent();

  @override
  List<Object?> get props => [];
}

class EditQueenBreedLoadData extends EditQueenBreedEvent {
  final String? breedId;
  
  const EditQueenBreedLoadData({this.breedId});
  
  @override
  List<Object?> get props => [breedId];
}

class EditQueenBreedNameChanged extends EditQueenBreedEvent {
  final String name;
  
  const EditQueenBreedNameChanged(this.name);
  
  @override
  List<Object> get props => [name];
}

class EditQueenBreedScientificNameChanged extends EditQueenBreedEvent {
  final String scientificName;
  
  const EditQueenBreedScientificNameChanged(this.scientificName);
  
  @override
  List<Object> get props => [scientificName];
}

class EditQueenBreedOriginChanged extends EditQueenBreedEvent {
  final String origin;
  
  const EditQueenBreedOriginChanged(this.origin);
  
  @override
  List<Object> get props => [origin];
}

class EditQueenBreedCountryChanged extends EditQueenBreedEvent {
  final String country;
  
  const EditQueenBreedCountryChanged(this.country);
  
  @override
  List<Object> get props => [country];
}

class EditQueenBreedHoneyProductionRatingChanged extends EditQueenBreedEvent {
  final int rating;
  
  const EditQueenBreedHoneyProductionRatingChanged(this.rating);
  
  @override
  List<Object> get props => [rating];
}

class EditQueenBreedWinterHardinessRatingChanged extends EditQueenBreedEvent {
  final int rating;
  
  const EditQueenBreedWinterHardinessRatingChanged(this.rating);
  
  @override
  List<Object> get props => [rating];
}

class EditQueenBreedDiseaseResistanceRatingChanged extends EditQueenBreedEvent {
  final int rating;
  
  const EditQueenBreedDiseaseResistanceRatingChanged(this.rating);
  
  @override
  List<Object> get props => [rating];
}

class EditQueenBreedSpringDevelopmentRatingChanged extends EditQueenBreedEvent {
  final int rating;
  const EditQueenBreedSpringDevelopmentRatingChanged(this.rating);
  @override
  List<Object> get props => [rating];
}

class EditQueenBreedGentlenessRatingChanged extends EditQueenBreedEvent {
  final int rating;
  const EditQueenBreedGentlenessRatingChanged(this.rating);
  @override
  List<Object> get props => [rating];
}

class EditQueenBreedSwarmingTendencyRatingChanged extends EditQueenBreedEvent {
  final int rating;
  const EditQueenBreedSwarmingTendencyRatingChanged(this.rating);
  @override
  List<Object> get props => [rating];
}

class EditQueenBreedHeatToleranceRatingChanged extends EditQueenBreedEvent {
  final int rating;
  const EditQueenBreedHeatToleranceRatingChanged(this.rating);
  @override
  List<Object> get props => [rating];
}

class EditQueenBreedCharacteristicsChanged extends EditQueenBreedEvent {
  final String characteristics;
  
  const EditQueenBreedCharacteristicsChanged(this.characteristics);
  
  @override
  List<Object> get props => [characteristics];
}

class EditQueenBreedToggleStarred extends EditQueenBreedEvent {
  const EditQueenBreedToggleStarred();
}

class EditQueenBreedImageChanged extends EditQueenBreedEvent {
  final String? imagePath;

  const EditQueenBreedImageChanged(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class EditQueenBreedImageDeleted extends EditQueenBreedEvent {
  const EditQueenBreedImageDeleted();
}

class EditQueenBreedCostChanged extends EditQueenBreedEvent {
  final double? cost;
  
  const EditQueenBreedCostChanged(this.cost);
  
  @override
  List<Object?> get props => [cost];
}

class EditQueenBreedSubmitted extends EditQueenBreedEvent {
  const EditQueenBreedSubmitted();
}

class EditQueenBreedResetValidation extends EditQueenBreedEvent {
  const EditQueenBreedResetValidation();
}