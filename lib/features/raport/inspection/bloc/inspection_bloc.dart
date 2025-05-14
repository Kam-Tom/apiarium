import 'dart:async';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/extensions/date_time_extensions.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:math';

part 'inspection_event.dart';
part 'inspection_state.dart';

class InspectionBloc extends Bloc<InspectionEvent, InspectionState> {
  // MARK: - Constructor & Dependencies
  InspectionBloc({
    required ApiaryService apiaryService, 
    required ReportService reportService,
  }) : 
    _apiaryService = apiaryService, 
    _reportService = reportService,
    super(const InspectionState()) {
      
    on<LoadApiariesEvent>(_onLoadApiaries);
    on<SelectApiaryEvent>(_onSelectApiary);
    on<SelectHiveEvent>(_onSelectHive);
    on<UpdateFieldEvent>(_onUpdateField);
    on<ResetFieldEvent>(_onResetField);
    on<ResetAllFieldsEvent>(_onResetAllFields);
    on<ToggleSectionEvent>(_onToggleSection);
    on<SaveInspectionReport>(_onSaveReport);
    on<UpdateBoxCountEvent>(_onUpdateBoxCount);
  }

  final ApiaryService _apiaryService;
  final ReportService _reportService;

  // MARK: - Event Handlers
  Future<void> _onLoadApiaries(LoadApiariesEvent event, Emitter<InspectionState> emit) async {
    emit(state.copyWith(isLoading: () => true));
    try {
      final apiaries = await _apiaryService.getAllApiaries(
        includeHives: true,
        includeQueen: true
      );
      
      final String? selectedApiaryId = 
          (event.autoSelectApiary && apiaries.isNotEmpty) ? apiaries.first.id : null;
      
      Map<String, List<Field>>? newCache;
      if (selectedApiaryId != null) {
        newCache = await _prefetchHiveData(selectedApiaryId, apiaries);
      }

      emit(state.copyWith(
        apiaries: () => apiaries,
        selectedApiaryId: () => selectedApiaryId,
        hiveFieldCache: () => newCache ?? state.hiveFieldCache,
        isLoading: () => false,
      ));

      if(selectedApiaryId != null && state.selectedHiveId == null && event.autoSelectApiary) {
        final firstApiary = apiaries.first;
        if (firstApiary.hives != null && firstApiary.hives!.isNotEmpty) {
          add(SelectHiveEvent(firstApiary.hives!.first.id));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to load apiaries: $e',
        isLoading: () => false,
      ));
    }
  }

  void _onSelectApiary(SelectApiaryEvent event, Emitter<InspectionState> emit) async {
    final selectedApiary = state.apiaries.firstWhere((apiary) => apiary.id == event.apiaryId);
    final selectedHiveId = (selectedApiary.hives != null && selectedApiary.hives!.isNotEmpty)
        ? selectedApiary.hives!.first.id
        : null;
    emit(state.copyWith(
      selectedApiaryId: () => event.apiaryId,
      selectedHiveId: () => selectedHiveId,
      fields: () => [],
      previousFields: () => [],
      isLoading: () => true, // Show loading until prefetch is done
    ));

    final newCache = await _prefetchHiveData(event.apiaryId, state.apiaries);

    emit(state.copyWith(
      hiveFieldCache: () => newCache ?? state.hiveFieldCache,
      isLoading: () => false,
    ));
  }

  // Cache recent fields for all hives in the selected apiary
  Future<Map<String, List<Field>>?> _prefetchHiveData(String apiaryId, List<Apiary> apiaries) async {
      final batchResult = await _reportService.getRecentFieldsForApiary(
        apiaryId: apiaryId,
        type: ReportType.inspection,
      );
      return batchResult;
  }

  Future<void> _onSelectHive(SelectHiveEvent event, Emitter<InspectionState> emit) async {
    emit(state.copyWith(
      selectedHiveId: () => event.hiveId,
      isLoading: () => true,
    ));
    
    try {
        final cachedFields = state.hiveFieldCache[event.hiveId] ?? [];
        final cachedSavedFields = state.hiveSavedFieldsCache[event.hiveId] ?? [];
        emit(state.copyWith(
          fields: () => [],
          isLoading: () => false,
          previousFields: () => cachedFields,
          savedFields: () => cachedSavedFields,
          savedReportId: () => null,
        ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to load hive data: $e',
        isLoading: () => false,
      ));
    }
  }

  void _onUpdateField(UpdateFieldEvent event, Emitter<InspectionState> emit) {
    final fieldId = event.fieldName;
    
    // Special handling for frame net fields: if value is 0, remove the field instead of setting it
    if ((fieldId.startsWith('framesMoved.') && event.value == 0) || 
        (fieldId.contains('Net') && event.value == 0)) {
      // If the field is set to 0, treat it as a reset
      add(ResetFieldEvent(fieldId));
      return;
    }
    
    final value = event.value.toString();
    final existingFieldIndex = state.fields.indexWhere((f) => f.attributeId == fieldId);
    final newFields = List<Field>.from(state.fields);
    
    final attribute = Attribute.values.firstWhere(
      (attr) => attr.name == fieldId,
      orElse: () => Attribute.none,
    );
    
    final field = Field(
      reportId: '', // Will be set when saving
      attributeId: fieldId,
      value: value,
      attribute: attribute,
      createdAt: DateTime.now(),
    );
    
    if (existingFieldIndex >= 0) {
      newFields[existingFieldIndex] = field;
    } else {
      newFields.add(field);
    }
    
    emit(state.copyWith(
      fields: () => newFields,
    ));
  }

  void _onResetField(ResetFieldEvent event, Emitter<InspectionState> emit) {
    final fieldId = event.fieldName;
    final newFields = state.fields.where((f) => f.attributeId != fieldId).toList();
    
    emit(state.copyWith(
      fields: () => newFields,
    ));
  }

  void _onResetAllFields(ResetAllFieldsEvent event, Emitter<InspectionState> emit) {
    emit(state.copyWith(
      fields: () => [],
    ));
  }

  void _onToggleSection(ToggleSectionEvent event, Emitter<InspectionState> emit) {
    final newExpandedSections = Map<String, bool>.from(state.expandedSections);
    newExpandedSections[event.sectionKey] = !(state.expandedSections[event.sectionKey] ?? false);
    
    emit(state.copyWith(
      expandedSections: () => newExpandedSections,
    ));
  }


  Future<void> _onSaveReport(SaveInspectionReport event, Emitter<InspectionState> emit) async {
    if (state.selectedHiveId == null) {
      emit(state.copyWith(
        errorMessage: () => 'Please select a hive first',
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: () => true,
    ));
    
    try {
      // Only use the newly modified fields for saving the report
      final List<Field> allFields = List<Field>.from(state.fields);

      String reportId = '';
      if (state.savedReportId != null) {
        // Update the existing report
        final existingReport = await _reportService.getReport(
          id: state.savedReportId,
        );
        if (existingReport != null) {
          final updatedReport = existingReport.copyWith(
            fields: () => allFields,
            name: () => existingReport.name,
            createdAt: () => existingReport.createdAt,
            queenId: () => state.selectedHive?.queen?.id,
            apiaryId: () => state.selectedApiaryId,
          );
          
          await _reportService.updateReport(report: updatedReport);
          reportId = updatedReport.id;
        } else {
          // fallback: insert new if not found
          final report = Report(
            id: '',
            name: 'Inspection ${DateTime.now().toIso8601String()}',
            type: ReportType.inspection,
            createdAt: DateTime.now(),
            fields: allFields,
            hiveId: state.selectedHiveId!,
            queenId: state.selectedHive?.queen?.id,
            apiaryId: state.selectedApiaryId,
          );
          reportId = await _reportService.insertReport(report: report);
        }
      } else {
        // Create a new report
        final report = Report(
          id: '',
          name: 'Inspection ${DateTime.now().toIso8601String()}',
          type: ReportType.inspection,
          createdAt: DateTime.now(),
          fields: allFields,
          hiveId: state.selectedHiveId!,
          queenId: state.selectedHive?.queen?.id,
          apiaryId: state.selectedApiaryId,
        );
        reportId = await _reportService.insertReport(report: report);
      }

      // Cache the saved fields for this hive
      final newCache = Map<String, List<Field>>.from(state.hiveFieldCache);
      var cachedFileds = [...allFields];
      final oldFields = state.hiveFieldCache[state.selectedHiveId];
      for (var field in oldFields ?? []) {
        if(cachedFileds.any((f) => f.attributeId == field.attributeId)) {
          continue;
        }
        cachedFileds.add(field);
      }
      
      newCache[state.selectedHiveId!] = cachedFileds;

      // Only store the newly modified fields in savedFields and hiveSavedFieldsCache
      final newSavedFieldsCache = Map<String, List<Field>>.from(state.hiveSavedFieldsCache);
      newSavedFieldsCache[state.selectedHiveId!] = List<Field>.from(state.fields);

      emit(state.copyWith(
        isSubmitting: () => false,
        isSubmissionSuccess: () => true,
        savedFields: () => List<Field>.from(state.fields), // Only modified fields
        savedReportId: () => reportId,
        hiveFieldCache: () => newCache, // Update cache for this hive
        hiveSavedFieldsCache: () => newSavedFieldsCache, // Only modified fields
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: () => false,
        errorMessage: () => 'Error saving inspection: $e',
      ));
    }
  }

  void _onUpdateBoxCount(UpdateBoxCountEvent event, Emitter<InspectionState> emit) {
    // First update the box count field
    final boxFieldName = event.boxType == 'brood' 
        ? 'framesMoved.broodBoxNet' 
        : 'framesMoved.honeySuperBoxNet';
    
    add(UpdateFieldEvent(boxFieldName, event.newValue));
    
    // Calculate frames change based on box difference
    final frameDifference = (event.newValue - event.oldValue) * 
        (event.boxType == 'brood' ? state.framesPerBroodBox : state.framesPerSuperBox);
    
    if (frameDifference == 0) return; // No frame changes needed
    
    // Check if it's winter season using the extension
    final bool isWinter = BeekeepingDateTime.isWinterSeason();
    
    // Update frame counts based on box type
    if (event.boxType == 'brood') {
      if (frameDifference > 0) {
        // Adding boxes: add frames based on season
        if (isWinter) {
          // In winter, mostly empty frames are added in brood area
          add(UpdateFieldEvent('framesMoved.emptyBroodNet', 
              (state.getFieldValue<int>('framesMoved.emptyBroodNet') ?? 0) + frameDifference));
        } else {
          // In summer, mostly brood frames are added
          add(UpdateFieldEvent('framesMoved.broodNet', 
              (state.getFieldValue<int>('framesMoved.broodNet') ?? 0) + frameDifference));
        }
      } else {
        // Removing boxes: remove frames based on season
        if (isWinter) {
          // In winter, reduce empty frames first
          final currentEmptyBroodNet = state.getFieldValue<int>('framesMoved.emptyBroodNet') ?? 0;
          final currentBroodNet = state.getFieldValue<int>('framesMoved.broodNet') ?? 0;
          final newNet = state.totalBroodFrames + min(0,currentBroodNet) + currentEmptyBroodNet + frameDifference;
          if(newNet > 0) {
            add(UpdateFieldEvent('framesMoved.emptyBroodNet', currentEmptyBroodNet + frameDifference));
          }
          else if(newNet - frameDifference > 0) {
            add(UpdateFieldEvent('framesMoved.emptyBroodNet', currentEmptyBroodNet + newNet - frameDifference));
          }
        } else {
          // In winter, reduce empty frames first
          final currentBroodNet = state.getFieldValue<int>('framesMoved.broodNet') ?? 0;
          final currentEmptyBroodNet = state.getFieldValue<int>('framesMoved.emptyBroodNet') ?? 0;
          final newNet = state.totalBroodFrames + min(0,currentEmptyBroodNet) + currentBroodNet + frameDifference;
          if(newNet > 0) {
            add(UpdateFieldEvent('framesMoved.broodNet', currentBroodNet + frameDifference));
          }
          else if(newNet-frameDifference > 0) {
            add(UpdateFieldEvent('framesMoved.broodNet', currentBroodNet - newNet + frameDifference ));
          }
        }
      }

    } 
    else { // Honey supers
    if (frameDifference > 0) {
        // Adding boxes: add frames based on season
        if (isWinter) {
          // In winter, mostly empty frames are added in brood area
          add(UpdateFieldEvent('framesMoved.emptyNet', 
              (state.getFieldValue<int>('framesMoved.emptyNet') ?? 0) + frameDifference));
        } else {
          // In summer, mostly brood frames are added
          add(UpdateFieldEvent('framesMoved.honeyNet', 
              (state.getFieldValue<int>('framesMoved.honeyNet') ?? 0) + frameDifference));
        }
      } else {
        // Removing boxes: remove frames based on season
        if (isWinter) {
          // In winter, reduce empty frames first
          final currentEmptyNet = state.getFieldValue<int>('framesMoved.emptyNet') ?? 0;
          final currentNet = state.getFieldValue<int>('framesMoved.honeyNet') ?? 0;
          final newNet = state.totalBroodFrames + min(0,currentNet) + currentEmptyNet + frameDifference;
          if(newNet > 0) {
            add(UpdateFieldEvent('framesMoved.emptyNet', currentEmptyNet + frameDifference));
          }
          else if(newNet - frameDifference > 0) {
            add(UpdateFieldEvent('framesMoved.emptyNet', currentEmptyNet - newNet + frameDifference ));
          }
        } else {
          // In winter, reduce empty frames first
          final currentNet = state.getFieldValue<int>('framesMoved.honeyNet') ?? 0;
          final currentEmptyNet = state.getFieldValue<int>('framesMoved.emptyNet') ?? 0;
          final newNet = state.totalBroodFrames + min(0,currentEmptyNet) + currentNet + frameDifference;
          if(newNet > 0) {
            add(UpdateFieldEvent('framesMoved.honeyNet', currentNet + frameDifference));
          }
          else if(newNet - frameDifference > 0) {
            add(UpdateFieldEvent('framesMoved.honeyNet', currentNet - newNet + frameDifference ));
          }
        }
      }
    }
  }
}
