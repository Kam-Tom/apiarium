part of 'edit_apiary_bloc.dart';

enum EditApiaryStatus { initial, loading, loaded, submitting, success, failure }

class EditApiaryState extends Equatable {
  // Fields for the apiary being edited
  final String? apiaryId;
  final String name;
  final String description;
  final String location;
  final String? imageUrl;
  final DateTime createdAt;
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

  const EditApiaryState({
    this.apiaryId,
    this.name = '',
    this.description = '',
    this.location = '',
    this.imageUrl,
    required this.createdAt,
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
  });
  
  EditApiaryState copyWith({
    String? Function()? apiaryId,
    String? Function()? name,
    String? Function()? description,
    String? Function()? location,
    DateTime? Function()? createdAt,
    String? Function()? imageUrl,
    double? Function()? latitude,
    double? Function()? longitude,
    bool? Function()? isMigratory,
    Color? Function()? color,
    ApiaryStatus? Function()? status,
    bool? Function()? showValidationErrors,
    EditApiaryStatus? Function()? formStatus,
    String? Function()? errorMessage,
    bool? Function()? addQueensWithHives,
    List<Hive>? Function()? apiarySummaryHives,
    List<Hive>? Function()? availableHives,
    Apiary? Function()? originalApiary,
    List<Hive>? Function()? originalHives,
  }) {
    return EditApiaryState(
      apiaryId: apiaryId?.call() ?? this.apiaryId,
      name: name?.call() ?? this.name,
      description: description?.call() ?? this.description,
      location: location?.call() ?? this.location,
      createdAt: createdAt?.call() ?? this.createdAt,
      imageUrl: imageUrl?.call() ?? this.imageUrl,
      latitude: latitude?.call() ?? this.latitude,
      longitude: longitude?.call() ?? this.longitude,
      isMigratory: isMigratory?.call() ?? this.isMigratory,
      color: color?.call() ?? this.color,
      status: status?.call() ?? this.status,
      showValidationErrors: showValidationErrors?.call() ?? this.showValidationErrors,
      formStatus: formStatus?.call() ?? this.formStatus,
      errorMessage: errorMessage?.call() ?? this.errorMessage,
      addQueensWithHives: addQueensWithHives?.call() ?? this.addQueensWithHives,
      apiarySummaryHives: apiarySummaryHives?.call() ?? this.apiarySummaryHives,
      availableHives: availableHives?.call() ?? this.availableHives,
      originalApiary: originalApiary?.call() ?? this.originalApiary,
      originalHives: originalHives?.call() ?? this.originalHives,
    );
  }
  
  bool get isValid {
    // Basic validation rule: name must not be empty
    return name.isNotEmpty;
  }
  
  /// Returns true if apiary data has changed compared to the original
  bool get hasApiaryChanged {
    if (originalApiary == null) return true;
    return name != originalApiary!.name ||
           description != originalApiary!.description ||
           location != originalApiary!.location ||
           latitude != originalApiary!.latitude ||
           longitude != originalApiary!.longitude ||
           isMigratory != originalApiary!.isMigratory ||
           color != originalApiary!.color ||
           status != originalApiary!.status;
  }
  
  /// Returns true if the hives associated with the apiary have changed
  bool get haveHivesChanged {
    if (originalApiary == null) return apiarySummaryHives.isNotEmpty;
    if (originalHives.length != apiarySummaryHives.length) return true;
    for (int i = 0; i < originalHives.length; i++) {
      final originalHive = originalHives[i];
      final currentHiveIndex = apiarySummaryHives.indexWhere((h) => h.id == originalHive.id);
      if (currentHiveIndex == -1) return true;
      if (currentHiveIndex != i) return true;
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
  ];
}
