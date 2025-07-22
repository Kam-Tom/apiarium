// part of 'inspection_bloc.dart';

// // MARK: - Enums
// enum FieldState {
//   unset,
//   set,
//   old,
//   saved,
// }

// class InspectionState extends Equatable {
//   // MARK: - Properties
//   // Apiaries and hives
//   final List<Apiary> apiaries;
//   final String? selectedApiaryId;
//   final String? selectedHiveId;
  
//   // Fields and sections
//   final List<Field> fields;
//   final List<Field> previousFields;
//   final List<Field> savedFields;
//   final Map<String, bool> expandedSections;
  
//   // State flags
//   final bool isLoading;
//   final bool isSubmitting;
//   final String? errorMessage;
//   final bool isSubmissionSuccess;
//   final String? savedReportId;
  
//   // Caching
//   final Map<String, List<Field>> hiveFieldCache;
//   final Map<String, List<Field>> hiveSavedFieldsCache;

//   // MARK: - Constructor
//   const InspectionState({
//     this.apiaries = const [],
//     this.selectedApiaryId,
//     this.selectedHiveId,
//     this.fields = const [],
//     this.previousFields = const [],
//     this.expandedSections = const {
//       'quickInspection': true,  
//       'colony': false,
//       'queen': false,
//       'brood': false,
//       'frames': false,
//       'stores': false,
//       'pestsAndDiseases': false,
//       'hiveCondition': false,
//       'weight': false,
//       'weather': false,
//     },
//     this.isLoading = false,
//     this.isSubmitting = false,
//     this.errorMessage,
//     this.isSubmissionSuccess = false,
//     this.hiveFieldCache = const {},
//     this.hiveSavedFieldsCache = const {}, 
//     this.savedFields = const [],
//     this.savedReportId
//   });

//   // MARK: - Computed Properties
//   // Computed getter for modified field IDs
//   Set<String> get modifiedFieldIds => 
//       fields.map((f) => f.attributeId).toSet();
  
//   // Computed getter for previously set field IDs
//   Set<String> get previouslySetFieldIds => 
//       previousFields.map((f) => f.attributeId).toSet();

//   // Computed getter for saved field IDs
//   Set<String> get savedFieldIds =>
//       savedFields.map((f) => f.attributeId).toSet();

//   Apiary? get selectedApiary => apiaries.isNotEmpty && selectedApiaryId != null
//       ? apiaries.firstWhere(
//           (apiary) => apiary.id == selectedApiaryId,
//           orElse: () => apiaries.first,
//         )
//       : null;

//   Hive? get selectedHive => null;//selectedApiary?.hives?.where(
//         //(h) => h.id == selectedHiveId).firstOrNull;

//   // Hive-related getters
//   int get framesPerSuperBox => 0;
//       //selectedHive?.hiveType.defaultFrameCount ?? 10;
//   int get framesPerBroodBox => 0;
//       //selectedHive?.hiveType.defaultFrameCount ?? 10;
//   int get honeySuperBoxCount => 0;
//       //selectedHive?.currentHoneySuperBoxCount ?? 0;
//   int get broodBoxCount =>0;
//       //selectedHive?.currentBroodBoxCount ?? 0;
//   int get totalFrames => 0;//selectedHive?.currentFrameCount ?? 0;
//   int get totalBroodFrames => selectedHive?.currentBroodFrameCount ?? 0;
//   int get maxFrames => honeySuperBoxCount * framesPerSuperBox;
//   int get maxBroodFrames => broodBoxCount * framesPerBroodBox;

//   // MARK: - Helper Methods
//   // Helper to check if a field has been modified
//   bool isFieldModified(String fieldId) {
//     return modifiedFieldIds.contains(fieldId);
//   }

//   // Helper to check if a field was loaded from previous data
//   bool isFieldFromPreviousData(String fieldId) {
//     return previouslySetFieldIds.contains(fieldId);
//   }

//   // Get field state using enum for better type safety
//   FieldState getFieldState(String fieldId) {
//     if (modifiedFieldIds.contains(fieldId)) {
//       return FieldState.set;
//     } else if (savedFieldIds.contains(fieldId)) {
//       return FieldState.saved;
//     } else if (previouslySetFieldIds.contains(fieldId)) {
//       return FieldState.old;
//     } else {
//       return FieldState.unset;
//     }
//   }

//   Field? getField(String fieldId) {
//     final modifiedField = fields.where((f) => f.attributeId == fieldId).firstOrNull;
//     if (modifiedField != null) {
//       return modifiedField;
//     }
//     // Then check in saved fields
//     final savedField = savedFields.where((f) => f.attributeId == fieldId).firstOrNull;
//     if (savedField != null) {
//       return savedField;
//     }
//     // Then check in previous fields
//     return previousFields.where((f) => f.attributeId == fieldId).firstOrNull;
//   }

//   // Get field value with default value
//   T? getFieldValue<T>(String fieldId, {T? defaultValue}) {
//     final field = getField(fieldId);
//     if (field == null) return defaultValue;
//     return field.getValue<T>(defaultValue: defaultValue);
//   }

//   // Get old field value (for display purposes only)
//   T? getOldFieldValue<T>(String fieldId, {T? defaultValue}) {
//     // Only get from previous fields, not from current fields
//     final field = previousFields.where((f) => f.attributeId == fieldId).firstOrNull;
//     if (field == null) return defaultValue;
//     return field.getValue<T>(defaultValue: defaultValue);
//   }

//   // Count modified fields in a category
//   int countModifiedFieldsInCategory(List<String> categoryFields) {
//     return categoryFields.where((field) => modifiedFieldIds.contains(field)).length;
//   }

//   // Check if any field in category is modified
//   bool isCategoryActive(List<String> categoryFields) {
//     return categoryFields.any((field) => modifiedFieldIds.contains(field));
//   }

//   // MARK: - State Management
//   InspectionState copyWith({
//     List<Apiary> Function()? apiaries,
//     String? Function()? selectedApiaryId,
//     String? Function()? selectedHiveId,
//     List<Field> Function()? fields,
//     List<Field> Function()? previousFields,
//     Map<String, bool> Function()? expandedSections,
//     bool Function()? isLoading,
//     bool Function()? isSubmitting,
//     String? Function()? errorMessage,
//     bool Function()? isSubmissionSuccess,
//     Map<String, List<Field>> Function()? hiveFieldCache,
//     Map<String, List<Field>> Function()? hiveSavedFieldsCache,
//     List<Field> Function()? savedFields,
//     String? Function()? savedReportId,
//   }) {
//     return InspectionState(
//       apiaries: apiaries != null ? apiaries() : this.apiaries,
//       selectedApiaryId: selectedApiaryId != null ? selectedApiaryId() : this.selectedApiaryId,
//       selectedHiveId: selectedHiveId != null ? selectedHiveId() : this.selectedHiveId,
//       fields: fields != null ? fields() : this.fields,
//       previousFields: previousFields != null ? previousFields() : this.previousFields,
//       expandedSections: expandedSections != null ? expandedSections() : this.expandedSections,
//       isLoading: isLoading != null ? isLoading() : this.isLoading,
//       isSubmitting: isSubmitting != null ? isSubmitting() : this.isSubmitting,
//       errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
//       isSubmissionSuccess: isSubmissionSuccess != null ? isSubmissionSuccess() : this.isSubmissionSuccess,
//       hiveFieldCache: hiveFieldCache != null ? hiveFieldCache() : this.hiveFieldCache,
//       hiveSavedFieldsCache: hiveSavedFieldsCache != null ? hiveSavedFieldsCache() : this.hiveSavedFieldsCache, 
//       savedFields: savedFields != null ? savedFields() : this.savedFields,
//       savedReportId: savedReportId != null ? savedReportId() : this.savedReportId,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         apiaries,
//         selectedApiaryId,
//         selectedHiveId,
//         fields,
//         previousFields,
//         expandedSections,
//         isLoading,
//         isSubmitting,
//         errorMessage,
//         isSubmissionSuccess,
//         hiveFieldCache,
//         hiveSavedFieldsCache,
//         savedFields,
//         savedReportId,
//       ];
// }

// class Field {
//   T? getValue<T>({T? defaultValue}) {
//     // Implement your logic here, for now just return defaultValue
//     return defaultValue;
//   }
// }
