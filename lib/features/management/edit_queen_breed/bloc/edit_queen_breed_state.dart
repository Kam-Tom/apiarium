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
  final int honeyProductionRating;      // 0-5
  final int springDevelopmentRating;    // 0-5
  final int gentlenessRating;           // 0-5
  final int swarmingTendencyRating;     // 0-5
  final int winterHardinessRating;      // 0-5
  final int diseaseResistanceRating;    // 0-5
  final int heatToleranceRating;        // 0-5
  final String characteristics;
  final String? imageName;
  final double? cost;
  final String? errorMessage;
  final bool hasTriedSubmit;

  const EditQueenBreedState({
    this.status = EditQueenBreedStatus.initial,
    this.breedId,
    this.name = '',
    this.scientificName = '',
    this.origin = '',
    this.country = '',
    this.isStarred = true,
    this.isLocal = true,
    this.honeyProductionRating = 0,
    this.springDevelopmentRating = 0,
    this.gentlenessRating = 0,
    this.swarmingTendencyRating = 0,
    this.winterHardinessRating = 0,
    this.diseaseResistanceRating = 0,
    this.heatToleranceRating = 0,
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
    int? honeyProductionRating,
    int? springDevelopmentRating,
    int? gentlenessRating,
    int? swarmingTendencyRating,
    int? winterHardinessRating,
    int? diseaseResistanceRating,
    int? heatToleranceRating,
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
      honeyProductionRating: honeyProductionRating ?? this.honeyProductionRating,
      springDevelopmentRating: springDevelopmentRating ?? this.springDevelopmentRating,
      gentlenessRating: gentlenessRating ?? this.gentlenessRating,
      swarmingTendencyRating: swarmingTendencyRating ?? this.swarmingTendencyRating,
      winterHardinessRating: winterHardinessRating ?? this.winterHardinessRating,
      diseaseResistanceRating: diseaseResistanceRating ?? this.diseaseResistanceRating,
      heatToleranceRating: heatToleranceRating ?? this.heatToleranceRating,
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
    honeyProductionRating, springDevelopmentRating, gentlenessRating,
    swarmingTendencyRating, winterHardinessRating, diseaseResistanceRating,
    heatToleranceRating, characteristics, imageName, cost,
    errorMessage, hasTriedSubmit,
  ];
}