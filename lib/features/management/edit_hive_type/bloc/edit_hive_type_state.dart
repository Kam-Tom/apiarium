part of 'edit_hive_type_bloc.dart';

enum EditHiveTypeStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
}

class EditHiveTypeState extends Equatable {
  final EditHiveTypeStatus status;
  final String? id;
  final String name;
  final String? manufacturer;
  final HiveMaterial material;
  final bool hasFrames;
  final int? broodFrameCount;
  final int? honeyFrameCount;
  final String? frameStandard;
  final int? boxCount;
  final int? superBoxCount;
  final int? framesPerBox;
  final int? maxBroodFrameCount;
  final int? maxHoneyFrameCount;
  final int? maxBoxCount;
  final int? maxSuperBoxCount;
  final List<HiveAccessory>? accessories;
  final String? country;
  final bool isLocal;
  final bool isStarred;
  final double? cost;
  final String? imageName;
  final HiveIconType iconType;
  final String? errorMessage;
  final HiveType? hiveType;
  final bool showValidationErrors;

  const EditHiveTypeState({
    this.status = EditHiveTypeStatus.initial,
    this.id,
    this.name = '',
    this.manufacturer,
    this.material = HiveMaterial.wood,
    this.hasFrames = true,
    this.broodFrameCount,
    this.honeyFrameCount,
    this.frameStandard,
    this.boxCount,
    this.superBoxCount,
    this.framesPerBox,
    this.maxBroodFrameCount,
    this.maxHoneyFrameCount,
    this.maxBoxCount,
    this.maxSuperBoxCount,
    this.accessories,
    this.country,
    this.isLocal = true,
    this.isStarred = false, // default is false
    this.cost,
    this.imageName,
    this.iconType = HiveIconType.beehive1,
    this.errorMessage,
    this.hiveType,
    this.showValidationErrors = false,
  });

  bool get isValid {
    if (name.trim().isEmpty) return false;
    return true;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().isEmpty) {
      errors.add('Name is required');
    }
    return errors;
  }

  EditHiveTypeState copyWith({
    EditHiveTypeStatus? Function()? status,
    String? Function()? id,
    String? Function()? name,
    String? Function()? manufacturer,
    HiveMaterial? Function()? material,
    bool? Function()? hasFrames,
    int? Function()? broodFrameCount,
    int? Function()? honeyFrameCount,
    String? Function()? frameStandard,
    int? Function()? boxCount,
    int? Function()? superBoxCount,
    int? Function()? framesPerBox,
    int? Function()? maxBroodFrameCount,
    int? Function()? maxHoneyFrameCount,
    int? Function()? maxBoxCount,
    int? Function()? maxSuperBoxCount,
    List<HiveAccessory>? Function()? accessories,
    String? Function()? country,
    bool? Function()? isLocal,
    bool? Function()? isStarred,
    double? Function()? cost,
    String? Function()? imageName,
    HiveIconType? Function()? iconType,
    String? Function()? errorMessage,
    HiveType? Function()? hiveType,
    bool? Function()? showValidationErrors,
  }) {
    return EditHiveTypeState(
      status: status?.call() ?? this.status,
      id: id?.call() ?? this.id,
      name: name?.call() ?? this.name,
      manufacturer: manufacturer?.call() ?? this.manufacturer,
      material: material?.call() ?? this.material,
      hasFrames: hasFrames?.call() ?? this.hasFrames,
      broodFrameCount: broodFrameCount?.call() ?? this.broodFrameCount,
      honeyFrameCount: honeyFrameCount?.call() ?? this.honeyFrameCount,
      frameStandard: frameStandard?.call() ?? this.frameStandard,
      boxCount: boxCount?.call() ?? this.boxCount,
      superBoxCount: superBoxCount?.call() ?? this.superBoxCount,
      framesPerBox: framesPerBox?.call() ?? this.framesPerBox,
      maxBroodFrameCount: maxBroodFrameCount?.call() ?? this.maxBroodFrameCount,
      maxHoneyFrameCount: maxHoneyFrameCount?.call() ?? this.maxHoneyFrameCount,
      maxBoxCount: maxBoxCount?.call() ?? this.maxBoxCount,
      maxSuperBoxCount: maxSuperBoxCount?.call() ?? this.maxSuperBoxCount,
      accessories: accessories?.call() ?? this.accessories,
      country: country?.call() ?? this.country,
      isLocal: isLocal?.call() ?? this.isLocal,
      isStarred: isStarred?.call() ?? this.isStarred,
      cost: cost?.call() ?? this.cost,
      imageName: imageName?.call() ?? this.imageName,
      iconType: iconType?.call() ?? this.iconType,
      errorMessage: errorMessage?.call() ?? this.errorMessage,
      hiveType: hiveType?.call() ?? this.hiveType,
      showValidationErrors: showValidationErrors?.call() ?? this.showValidationErrors,
    );
  }

  @override
  List<Object?> get props => [
    status, id, name, manufacturer, material, hasFrames,
    broodFrameCount, honeyFrameCount, frameStandard, boxCount,
    superBoxCount, framesPerBox, maxBroodFrameCount, maxHoneyFrameCount,
    maxBoxCount, maxSuperBoxCount, accessories, country, isLocal, isStarred,
    cost, imageName, iconType, errorMessage, hiveType, showValidationErrors,
  ];
}