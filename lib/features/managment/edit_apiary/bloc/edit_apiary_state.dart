part of 'edit_apiary_bloc.dart';

enum EditApiaryStatus { initial, loading, loaded, submitting, success, failure }

class EditApiaryState extends Equatable {
  // Fields for the apiary being edited
  final String? apiaryId;
  final String name;
  final String description;
  final String location;
  final DateTime createdAt;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final bool isMigratory;
  final Color? color;
  final ApiaryStatus status;
  
  // UI state
  final bool showValidationErrors;
  final EditApiaryStatus formStatus;
  final String? errorMessage;
  final bool addQueensWithHives;
  
  // Hive management
  final List<Hive> apiarySummaryHives;
  final List<Hive> availableHives;
  
  // Original state for comparison
  final Apiary? originalApiary;
  final List<Hive> originalHives;

  // Helper state for hive/queen creation capabilities
  final bool canCreateDefaultQueen;
  final bool canCreateDefaultHive;
  
  const EditApiaryState({
    this.apiaryId,
    this.name = '',
    this.description = '',
    this.location = '',
    required this.createdAt,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.isMigratory = false,
    this.color,
    this.status = ApiaryStatus.active,
    this.showValidationErrors = false,
    this.formStatus = EditApiaryStatus.initial,
    this.errorMessage,
    this.addQueensWithHives = false,
    this.apiarySummaryHives = const <Hive>[],
    this.availableHives = const <Hive>[],
    this.originalApiary,
    this.originalHives = const <Hive>[],
    this.canCreateDefaultQueen = false,
    this.canCreateDefaultHive = false,
  });
  
  EditApiaryState copyWith({
    Function()? apiaryId,
    Function()? name,
    Function()? description,
    Function()? location,
    Function()? createdAt,
    Function()? imageUrl,
    Function()? latitude,
    Function()? longitude,
    Function()? isMigratory,
    Function()? color,
    Function()? status,
    Function()? showValidationErrors,
    Function()? formStatus,
    Function()? errorMessage,
    Function()? addQueensWithHives,
    Function()? apiarySummaryHives,
    Function()? availableHives,
    Function()? originalApiary,
    Function()? originalHives,
    Function()? canCreateDefaultQueen,
    Function()? canCreateDefaultHive,
  }) {
    return EditApiaryState(
      apiaryId: apiaryId != null ? apiaryId() : this.apiaryId,
      name: name != null ? name() : this.name,
      description: description != null ? description() : this.description,
      location: location != null ? location() : this.location,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
      isMigratory: isMigratory != null ? isMigratory() : this.isMigratory,
      color: color != null ? color() : this.color,
      status: status != null ? status() : this.status,
      showValidationErrors: showValidationErrors != null ? showValidationErrors() : this.showValidationErrors,
      formStatus: formStatus != null ? formStatus() : this.formStatus,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      addQueensWithHives: addQueensWithHives != null ? addQueensWithHives() : this.addQueensWithHives,
      apiarySummaryHives: apiarySummaryHives != null ? apiarySummaryHives() : this.apiarySummaryHives,
      availableHives: availableHives != null ? availableHives() : this.availableHives,
      originalApiary: originalApiary != null ? originalApiary() : this.originalApiary,
      originalHives: originalHives != null ? originalHives() : this.originalHives,
      canCreateDefaultQueen: canCreateDefaultQueen != null ? canCreateDefaultQueen() : this.canCreateDefaultQueen,
      canCreateDefaultHive: canCreateDefaultHive != null ? canCreateDefaultHive() : this.canCreateDefaultHive,
    );
  }
  
  bool get isValid {
    // Basic validation rule: name must not be empty
    return name.isNotEmpty && location.isNotEmpty;
  }
  
  /// Helper method to check if the apiary data has been changed
  bool get hasApiaryChanged {
    if (originalApiary == null) return true; // New apiary
    
    return name != originalApiary!.name ||
           description != originalApiary!.description ||
           location != originalApiary!.location ||
           latitude != originalApiary!.latitude ||
           longitude != originalApiary!.longitude ||
           isMigratory != originalApiary!.isMigratory ||
           color != originalApiary!.color ||
           status != originalApiary!.status;
  }
  
  /// Helper method to check if the hives associated with the apiary have changed
  bool get haveHivesChanged {
    if (originalApiary == null) return apiarySummaryHives.isNotEmpty; // New apiary with hives
    
    // Check if the number of hives changed
    if (originalHives.length != apiarySummaryHives.length) return true;
    
    // Check if the order or content of hives changed
    for (int i = 0; i < originalHives.length; i++) {
      final originalHive = originalHives[i];
      
      // Check if this hive still exists in the current list
      final currentHiveIndex = apiarySummaryHives.indexWhere((h) => h.id == originalHive.id);
      if (currentHiveIndex == -1) return true; // Hive was removed
      
      // Check if the position changed
      if (currentHiveIndex != i) return true; // Hive order changed
    }
    
    return false;
  }
  
  @override
  List<Object?> get props => [
    apiaryId,
    name,
    description,
    location,
    createdAt,
    imageUrl,
    latitude,
    longitude,
    isMigratory,
    color,
    status,
    showValidationErrors,
    formStatus,
    errorMessage,
    addQueensWithHives,
    apiarySummaryHives,
    availableHives,
    originalApiary,
    originalHives,
    canCreateDefaultQueen,
    canCreateDefaultHive,
  ];
}
