import 'package:equatable/equatable.dart';

enum EditQueenBreedStatus { initial, loading, loaded, saving, saved, error }

class EditQueenBreedState extends Equatable {
  final EditQueenBreedStatus status;
  final String? breedId;
  final String name;
  final String scientificName;
  final String origin;
  final String country;
  final bool isStarred;
  final bool isLocal;
  final int temperamentRating; // 0-5 stars (0=not rated, 1=very aggressive, 5=very gentle)
  final int honeyProductionRating; // 0-5 stars (0=not rated, 1=low, 5=high)
  final int winterHardinessRating; // 0-5 stars (0=not rated, 1=poor, 5=excellent)
  final int diseaseResistanceRating; // 0-5 stars (0=not rated, 1=poor, 5=excellent)
  final int popularityRating; // 0-5 stars (0=not rated, 1=very rare, 5=very popular)
  final String characteristics;
  final String? imageName;
  final double? cost;
  final String? errorMessage;
  final bool hasTriedSubmit; // Track if user has tried to submit

  const EditQueenBreedState({
    this.status = EditQueenBreedStatus.initial,
    this.breedId,
    this.name = '',
    this.scientificName = '',
    this.origin = '',
    this.country = '',
    this.isStarred = true,
    this.isLocal = true,
    this.temperamentRating = 0, // Default to not rated
    this.honeyProductionRating = 0,
    this.winterHardinessRating = 0,
    this.diseaseResistanceRating = 0,
    this.popularityRating = 0,
    this.characteristics = '',
    this.imageName,
    this.cost,
    this.errorMessage,
    this.hasTriedSubmit = false,
  });

  bool get isEditing => breedId != null;
  bool get isCreating => breedId == null;
  
  bool get isValid => name.trim().isNotEmpty;

  EditQueenBreedState copyWith({
    EditQueenBreedStatus? status,
    String? breedId,
    String? name,
    String? scientificName,
    String? origin,
    String? country,
    bool? isStarred,
    bool? isLocal,
    int? temperamentRating,
    int? honeyProductionRating,
    int? winterHardinessRating,
    int? diseaseResistanceRating,
    int? popularityRating,
    String? characteristics,
    String? Function()? imageName,
    double? Function()? cost,
    String? Function()? errorMessage,
    bool? hasTriedSubmit,
  }) {
    return EditQueenBreedState(
      status: status ?? this.status,
      breedId: breedId ?? this.breedId,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      origin: origin ?? this.origin,
      country: country ?? this.country,
      isStarred: isStarred ?? this.isStarred,
      isLocal: isLocal ?? this.isLocal,
      temperamentRating: temperamentRating ?? this.temperamentRating,
      honeyProductionRating: honeyProductionRating ?? this.honeyProductionRating,
      winterHardinessRating: winterHardinessRating ?? this.winterHardinessRating,
      diseaseResistanceRating: diseaseResistanceRating ?? this.diseaseResistanceRating,
      popularityRating: popularityRating ?? this.popularityRating,
      characteristics: characteristics ?? this.characteristics,
      imageName: imageName != null ? imageName() : this.imageName,
      cost: cost != null ? cost() : this.cost,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      hasTriedSubmit: hasTriedSubmit ?? this.hasTriedSubmit,
    );
  }

  @override
  List<Object?> get props => [
    status, breedId, name, scientificName, origin, country, isStarred, isLocal,
    temperamentRating, honeyProductionRating, winterHardinessRating,
    diseaseResistanceRating, popularityRating, characteristics, imageName, cost, 
    errorMessage, hasTriedSubmit,
  ];
}