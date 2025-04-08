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
  final int? currentFrameCount;
  final int? currentBroodFrameCount;
  final int? currentBroodBoxCount;
  final int? currentHoneySuperBoxCount;
  
  // UI state
  final EditHiveStatus formStatus;
  final List<HiveType> availableHiveTypes;
  final List<Apiary> availableApiaries;
  final List<Queen> availableQueens;
  final bool showValidationErrors;
  final String? errorMessage;

  //Helper state
  final bool canCreateDefaultQueen;
  final bool skipSaving;
  final Hive? createdHive;
  final bool hideLocation;
  
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
    this.currentFrameCount,
    this.currentBroodFrameCount,
    this.currentBroodBoxCount,
    this.currentHoneySuperBoxCount,
    this.formStatus = EditHiveStatus.initial,
    this.availableHiveTypes = const [],
    this.availableApiaries = const [],
    this.availableQueens = const [],
    this.showValidationErrors = false,
    this.errorMessage,
    this.canCreateDefaultQueen = false,
    this.skipSaving = false,
    this.createdHive,
    this.hideLocation = false,
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
    int? Function()? currentFrameCount,
    int? Function()? currentBroodFrameCount,
    int? Function()? currentBroodBoxCount,
    int? Function()? currentHoneySuperBoxCount,
    EditHiveStatus Function()? formStatus,
    List<HiveType> Function()? availableHiveTypes,
    List<Apiary> Function()? availableApiaries,
    List<Queen> Function()? availableQueens,
    bool Function()? showValidationErrors,
    String? Function()? errorMessage,
    bool Function()? canCreateDefaultQueen,
    bool Function()? skipSaving,
    Hive? Function()? createdHive,
    bool Function()? hideLocation,
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
      currentFrameCount: currentFrameCount != null ? currentFrameCount() : this.currentFrameCount,
      currentBroodFrameCount: currentBroodFrameCount != null ? currentBroodFrameCount() : this.currentBroodFrameCount,
      currentBroodBoxCount: currentBroodBoxCount != null ? currentBroodBoxCount() : this.currentBroodBoxCount,
      currentHoneySuperBoxCount: currentHoneySuperBoxCount != null ? currentHoneySuperBoxCount() : this.currentHoneySuperBoxCount,
      formStatus: formStatus != null ? formStatus() : this.formStatus,
      availableHiveTypes: availableHiveTypes != null ? availableHiveTypes() : this.availableHiveTypes,
      availableApiaries: availableApiaries != null ? availableApiaries() : this.availableApiaries,
      availableQueens: availableQueens != null ? availableQueens() : this.availableQueens,
      showValidationErrors: showValidationErrors != null ? showValidationErrors() : this.showValidationErrors,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      canCreateDefaultQueen: canCreateDefaultQueen != null ? canCreateDefaultQueen() : this.canCreateDefaultQueen,
      skipSaving: skipSaving != null ? skipSaving() : this.skipSaving,
      createdHive: createdHive != null ? createdHive() : this.createdHive,
      hideLocation: hideLocation != null ? hideLocation() : this.hideLocation,
    );
  }
  
  List<String> get validationErrors {
    final errors = <String>[];
    if (name.trim().isEmpty) {
      errors.add('Hive name is required');
    }
    if (hiveType == null) {
      errors.add('Hive type is required');
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
    currentFrameCount,
    currentBroodFrameCount,
    currentBroodBoxCount,
    currentHoneySuperBoxCount,
    formStatus,
    availableHiveTypes,
    availableApiaries,
    availableQueens,
    showValidationErrors,
    errorMessage,
    canCreateDefaultQueen,
    skipSaving,
    createdHive,
    hideLocation,
  ];
}
