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
  final String? imageUrl;
  final int position;
  final Color? color;
  final int? broodFrameCount;
  final int? honeyFrameCount;
  final int? boxCount;
  final int? superBoxCount;
  final bool? hasFrames;
  final int? framesPerBox;
  final String? frameStandard;
  
  // UI state
  final EditHiveStatus formStatus;
  final List<HiveType> availableHiveTypes;
  final List<Apiary> availableApiaries;
  final List<Queen> availableQueens;
  final bool showValidationErrors;
  final String? errorMessage;

  //Helper state
  final bool canCreateDefaultQueen;
  final Hive? savedHive;
  
  const EditHiveState({
    this.hiveId,
    this.name = '',
    this.selectedApiary,
    this.hiveType,
    this.queen,
    this.status = HiveStatus.active,
    required this.acquisitionDate,
    this.imageUrl,
    this.position = 0,
    this.color,
    this.broodFrameCount,
    this.honeyFrameCount,
    this.boxCount,
    this.superBoxCount,
    this.hasFrames,
    this.framesPerBox,
    this.frameStandard,
    this.formStatus = EditHiveStatus.initial,
    this.availableHiveTypes = const [],
    this.availableApiaries = const [],
    this.availableQueens = const [],
    this.showValidationErrors = false,
    this.errorMessage,
    this.canCreateDefaultQueen = false,
    this.savedHive,
  });
  
  EditHiveState copyWith({
    String? Function()? hiveId,
    String Function()? name,
    Apiary? Function()? selectedApiary,
    HiveType? Function()? hiveType,
    Queen? Function()? queen,
    HiveStatus Function()? status,
    DateTime Function()? acquisitionDate,
    String? Function()? imageUrl,
    int Function()? position,
    Color? Function()? color,
    int? Function()? broodFrameCount,
    int? Function()? honeyFrameCount,
    int? Function()? boxCount,
    int? Function()? superBoxCount,
    bool? Function()? hasFrames,
    int? Function()? framesPerBox,
    String? Function()? frameStandard,
    EditHiveStatus Function()? formStatus,
    List<HiveType> Function()? availableHiveTypes,
    List<Apiary> Function()? availableApiaries,
    List<Queen> Function()? availableQueens,
    bool Function()? showValidationErrors,
    String? Function()? errorMessage,
    bool Function()? canCreateDefaultQueen,
    Hive? Function()? savedHive,
  }) {
    return EditHiveState(
      hiveId: hiveId != null ? hiveId() : this.hiveId,
      name: name != null ? name() : this.name,
      selectedApiary: selectedApiary != null ? selectedApiary() : this.selectedApiary,
      hiveType: hiveType != null ? hiveType() : this.hiveType,
      queen: queen != null ? queen() : this.queen,
      status: status != null ? status() : this.status,
      acquisitionDate: acquisitionDate != null ? acquisitionDate() : this.acquisitionDate,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      position: position != null ? position() : this.position,
      color: color != null ? color() : this.color,
      broodFrameCount: broodFrameCount != null ? broodFrameCount() : this.broodFrameCount,
      honeyFrameCount: honeyFrameCount != null ? honeyFrameCount() : this.honeyFrameCount,
      boxCount: boxCount != null ? boxCount() : this.boxCount,
      superBoxCount: superBoxCount != null ? superBoxCount() : this.superBoxCount,
      hasFrames: hasFrames != null ? hasFrames() : this.hasFrames,
      framesPerBox: framesPerBox != null ? framesPerBox() : this.framesPerBox,
      frameStandard: frameStandard != null ? frameStandard() : this.frameStandard,
      formStatus: formStatus != null ? formStatus() : this.formStatus,
      availableHiveTypes: availableHiveTypes != null ? availableHiveTypes() : this.availableHiveTypes,
      availableApiaries: availableApiaries != null ? availableApiaries() : this.availableApiaries,
      availableQueens: availableQueens != null ? availableQueens() : this.availableQueens,
      showValidationErrors: showValidationErrors != null ? showValidationErrors() : this.showValidationErrors,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      canCreateDefaultQueen: canCreateDefaultQueen != null ? canCreateDefaultQueen() : this.canCreateDefaultQueen,
      savedHive: savedHive != null ? savedHive() : this.savedHive,
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
    hiveId,
    name,
    selectedApiary,
    hiveType,
    queen,
    status,
    acquisitionDate,
    imageUrl,
    position,
    color,
    broodFrameCount,
    honeyFrameCount,
    boxCount,
    superBoxCount,
    hasFrames,
    framesPerBox,
    frameStandard,
    formStatus,
    availableHiveTypes,
    availableQueens,
    showValidationErrors,
    errorMessage,
    canCreateDefaultQueen,
    savedHive,
  ];
}