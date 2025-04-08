part of 'edit_queen_bloc.dart';

enum EditQueenStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure
}

class EditQueenState extends Equatable {
  final EditQueenStatus status;
  final String? errorMessage;
  
  // Form validation errors
  final Map<String, String?> validationErrors;
  final bool showValidationErrors;
  
  // Queen properties
  final String? id;
  final String name;
  final QueenBreed? queenBreed;
  final DateTime birthDate;
  final QueenSource source;
  final String? hiveName;
  final bool marked;
  final Color? markColor;
  final QueenStatus queenStatus;
  final String? origin;
  
  // Available selections
  final List<QueenBreed> availableBreeds;
  final List<Apiary> availableApiaries;
  final List<Hive> availableHives;
  final Hive? selectedHive;
  final Apiary? selectedApiary;
  
  // New flag
  final bool hideLocation;
  final bool skipSaving;
  final Queen? createdQueen;
  
  // Original state of the queen for comparison
  final Queen? originalQueen;
  
  // Helper method to get color based on year
  static Color getColorForYear(int year) {
    // Get last digit of year
    int lastDigit = year % 10;
    
    // Return color based on international standard
    switch (lastDigit) {
      case 1:
      case 6:
        return Colors.white;
      case 2:
      case 7:
        return Colors.yellow;
      case 3:
      case 8:
        return Colors.red;
      case 4:
      case 9:
        return Colors.green;
      case 0:
      case 5:
        return Colors.blue;
      default:
        return Colors.white; // Fallback
    }
  }
  
  const EditQueenState({
    this.status = EditQueenStatus.initial,
    this.errorMessage,
    this.validationErrors = const {},
    this.showValidationErrors = false,
    this.id,
    this.name = '',
    this.availableBreeds = const [],
    this.queenBreed,
    required this.birthDate,
    this.source = QueenSource.bought,
    this.hiveName,
    this.marked = true,
    this.markColor,
    this.queenStatus = QueenStatus.active,
    this.origin,
    this.availableApiaries = const [],
    this.availableHives = const [],
    this.selectedHive,
    this.selectedApiary,
    this.hideLocation = false,
    this.skipSaving = false,
    this.createdQueen,
    this.originalQueen,
  });

  EditQueenState copyWith({
    EditQueenStatus Function()? status,
    String? Function()? errorMessage,
    Map<String, String?> Function()? validationErrors,
    bool Function()? showValidationErrors,
    String? Function()? id,
    String? Function()? name,
    List<QueenBreed> Function()? availableBreeds,
    QueenBreed? Function()? queenBreed,
    DateTime? Function()? birthDate,
    QueenSource? Function()? source,
    String? Function()? hiveName,
    bool? Function()? marked,
    Color? Function()? markColor,
    QueenStatus? Function()? queenStatus,
    String? Function()? origin,
    List<Apiary> Function()? availableApiaries,
    List<Hive> Function()? availableHives,
    Hive? Function()? selectedHive,
    Apiary? Function()? selectedApiary,
    bool Function()? hideLocation,
    bool Function()? skipSaving,
    Queen? Function()? createdQueen,
    Queen? Function()? originalQueen,
  }) {
    return EditQueenState(
      status: status != null ? status() : this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      validationErrors: validationErrors != null ? validationErrors() : this.validationErrors,
      showValidationErrors: showValidationErrors != null ? showValidationErrors() : this.showValidationErrors,
      id: id != null ? id() : this.id,
      name: name != null ? name()! : this.name,
      availableBreeds: availableBreeds != null ? availableBreeds() : this.availableBreeds,
      queenBreed: queenBreed != null ? queenBreed() : this.queenBreed,
      birthDate: birthDate != null ? birthDate()! : this.birthDate,
      source: source != null ? source()! : this.source,
      hiveName: hiveName != null ? hiveName() : this.hiveName,
      marked: marked != null ? marked()! : this.marked,
      markColor: markColor != null ? markColor() : this.markColor,
      queenStatus: queenStatus != null ? queenStatus()! : this.queenStatus,
      origin: origin != null ? origin() : this.origin,
      availableApiaries: availableApiaries != null ? availableApiaries() : this.availableApiaries,
      availableHives: availableHives != null ? availableHives() : this.availableHives,
      selectedHive: selectedHive != null ? selectedHive() : this.selectedHive,
      selectedApiary: selectedApiary != null ? selectedApiary() : this.selectedApiary,
      hideLocation: hideLocation != null ? hideLocation() : this.hideLocation,
      skipSaving: skipSaving != null ? skipSaving() : this.skipSaving,
      createdQueen: createdQueen != null ? createdQueen() : this.createdQueen,
      originalQueen: originalQueen != null ? originalQueen() : this.originalQueen,
    );
  }
  
  @override
  List<Object?> get props => [
    status, errorMessage, validationErrors, showValidationErrors,
    id, name, availableBreeds, queenBreed, birthDate,
    source, hiveName, marked, markColor, queenStatus, origin,
    availableApiaries, availableHives, selectedHive, selectedApiary, hideLocation,
    skipSaving, createdQueen, originalQueen
  ];
  
  /// Helper method to check if the form is valid
  bool get isFormValid {
    // Check required fields
    if (name.trim().isEmpty) return false;
    if (queenBreed == null) return false;
    
    // Check if there are any validation errors
    if (validationErrors.isNotEmpty) return false;
    
    return true;
  }
  
  /// Helper method to get validation errors for specific fields
  String? validationErrorFor(String field) {
    return showValidationErrors ? validationErrors[field] : null;
  }
  
  /// Helper method to check if the queen data has been changed
  bool get hasQueenChanged {
    if (originalQueen == null) return true; // New queen
    
    return name != originalQueen!.name ||
           queenBreed?.id != originalQueen!.breed.id ||
           birthDate != originalQueen!.birthDate ||
           source != originalQueen!.source ||
           marked != originalQueen!.marked ||
           markColor != originalQueen!.markColor ||
           queenStatus != originalQueen!.status ||
           origin != originalQueen!.origin;
  }
  
  bool get hasLocationChanged {
    if (originalQueen == null) return selectedApiary != null || selectedHive != null;
    
    final originalApiaryId = originalQueen!.apiary?.id;
    final originalHiveId = originalQueen!.hive?.id;
    final currentApiaryId = selectedApiary?.id;
    final currentHiveId = selectedHive?.id;
    
    return originalApiaryId != currentApiaryId || originalHiveId != currentHiveId;
  }
}