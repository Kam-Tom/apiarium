part of 'edit_hive_bloc.dart';

enum EditHiveStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure
}

class EditHiveState extends Equatable {
  final String? hiveId;
  final String name;
  final Apiary? selectedApiary;
  final HiveType? hiveType;
  final Queen? queen;
  final HiveStatus status;
  final DateTime acquisitionDate;
  final Color? color;
  final String? imageUrl;
  final double hiveCost;
  final int broodFrameCount;
  final int honeyFrameCount;
  final int boxCount;
  final int superBoxCount;
  final EditHiveStatus formStatus;
  final List<Apiary> availableApiaries;
  final List<Queen> availableQueens;
  final List<HiveType> availableHiveTypes;
  final bool? hasFrames;
  final int? framesPerBox;
  final String? frameStandard;
  final List<HiveAccessory>? accessories;
  final bool showValidationErrors;
  final String? errorMessage;
  final Hive? savedHive;

  const EditHiveState({
    this.hiveId,
    this.name = '',
    this.selectedApiary,
    this.hiveType,
    this.queen,
    this.status = HiveStatus.active,
    required this.acquisitionDate,
    this.color,
    this.imageUrl,
    this.hiveCost = 0.0,
    this.broodFrameCount = 0,
    this.honeyFrameCount = 0,
    this.boxCount = 0,
    this.superBoxCount = 0,
    this.formStatus = EditHiveStatus.initial,
    this.availableApiaries = const [],
    this.availableQueens = const [],
    this.availableHiveTypes = const [],
    this.hasFrames,
    this.framesPerBox,
    this.frameStandard,
    this.accessories,
    this.showValidationErrors = false,
    this.errorMessage,
    this.savedHive,
  });

  EditHiveState copyWith({
    String? Function()? hiveId,
    String? Function()? name,
    Apiary? Function()? selectedApiary,
    HiveType? Function()? hiveType,
    Queen? Function()? queen,
    HiveStatus? Function()? status,
    DateTime? Function()? acquisitionDate,
    Color? Function()? color,
    String? Function()? imageUrl,
    double? Function()? hiveCost,
    int? Function()? broodFrameCount,
    int? Function()? honeyFrameCount,
    int? Function()? boxCount,
    int? Function()? superBoxCount,
    EditHiveStatus? Function()? formStatus,
    List<Apiary>? Function()? availableApiaries,
    List<Queen>? Function()? availableQueens,
    List<HiveType>? Function()? availableHiveTypes,
    bool? Function()? hasFrames,
    int? Function()? framesPerBox,
    String? Function()? frameStandard,
    List<HiveAccessory>? Function()? accessories,
    bool? Function()? showValidationErrors,
    String? Function()? errorMessage,
    Hive? Function()? savedHive,
  }) {
    return EditHiveState(
      hiveId: hiveId?.call() ?? this.hiveId,
      name: name?.call() ?? this.name,
      selectedApiary: selectedApiary?.call() ?? this.selectedApiary,
      hiveType: hiveType?.call() ?? this.hiveType,
      queen: queen?.call() ?? this.queen,
      status: status?.call() ?? this.status,
      acquisitionDate: acquisitionDate?.call() ?? this.acquisitionDate,
      color: color?.call() ?? this.color,
      imageUrl: imageUrl?.call() ?? this.imageUrl,
      hiveCost: hiveCost?.call() ?? this.hiveCost,
      broodFrameCount: broodFrameCount?.call() ?? this.broodFrameCount,
      honeyFrameCount: honeyFrameCount?.call() ?? this.honeyFrameCount,
      boxCount: boxCount?.call() ?? this.boxCount,
      superBoxCount: superBoxCount?.call() ?? this.superBoxCount,
      formStatus: formStatus?.call() ?? this.formStatus,
      availableApiaries: availableApiaries?.call() ?? this.availableApiaries,
      availableQueens: availableQueens?.call() ?? this.availableQueens,
      availableHiveTypes: availableHiveTypes?.call() ?? this.availableHiveTypes,
      hasFrames: hasFrames?.call() ?? this.hasFrames,
      framesPerBox: framesPerBox?.call() ?? this.framesPerBox,
      frameStandard: frameStandard?.call() ?? this.frameStandard,
      accessories: accessories?.call() ?? this.accessories,
      showValidationErrors: showValidationErrors?.call() ?? this.showValidationErrors,
      errorMessage: errorMessage?.call() ?? this.errorMessage,
      savedHive: savedHive?.call() ?? this.savedHive,
    );
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().isEmpty) {
      errors.add('Hive name is required');
    }
    return errors;
  }
  
  bool get isValid => validationErrors.isEmpty;
  
  @override
  List<Object?> get props => [
    hiveId, name, selectedApiary, hiveType, queen, status, acquisitionDate, color, imageUrl,
    hiveCost,
    broodFrameCount, honeyFrameCount, boxCount, superBoxCount, formStatus,
    availableApiaries, availableQueens, availableHiveTypes, hasFrames, framesPerBox, frameStandard,
    accessories,
    showValidationErrors, errorMessage, savedHive,
  ];
}