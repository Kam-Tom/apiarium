import 'dart:async';

import 'package:apiarium/shared/shared.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'edit_apiary_event.dart';
part 'edit_apiary_state.dart';

class EditApiaryBloc extends Bloc<EditApiaryEvent, EditApiaryState> {
  final ApiaryService _apiaryService;
  final HiveService _hiveService;
  final QueenService _queenService;
  
  EditApiaryBloc({
    required ApiaryService apiaryService,
    required HiveService hiveService,
    required QueenService queenService,
  }) : 
    _apiaryService = apiaryService,
    _hiveService = hiveService,
    _queenService = queenService,
    super(EditApiaryState(createdAt: DateTime.now())) {
      on<EditApiaryLoadData>(_onLoadRequest);
      on<EditApiaryNameChanged>(_onNameChanged);
      on<EditApiaryDescriptionChanged>(_onDescriptionChanged);
      on<EditApiaryLocationChanged>(_onLocationChanged);
      on<EditApiaryStatusChanged>(_onStatusChanged);
      on<EditApiaryLocationCoordinatesChanged>(_onLocationCoordinatesChanged);
      on<EditApiaryIsMigratoryChanged>(_onIsMigratoryChanged);
      on<EditApiaryColorChanged>(_onColorChanged);
      on<EditApiaryAddQueensWithHivesToggled>(_onAddQueensWithHivesToggled);
      on<EditApiaryAddHive>(_onAddHive);
      on<EditApiaryAddExistingHive>(_onAddExistingHive);
      on<EditApiaryRemoveHive>(_onRemoveHive);
      on<EditApiaryReorderHives>(_onReorderHives);
      on<EditApiarySubmitted>(_onSubmitted);
      on<EditApiaryAddHiveWithQueen>(_onAddHiveWithQueen);
    }

  FutureOr<void> _onLoadRequest(EditApiaryLoadData event, Emitter<EditApiaryState> emit) async {
    emit(state.copyWith(
      formStatus: () => EditApiaryStatus.loading,
    ));
    
    try {
      // Check if we can create default queen and default hive directly
      final canCreateDefaultQueen = await _queenService.canCreateDefaultQueen();
      final canCreateDefaultHive = await _hiveService.canCreateDefaultHive();
      
      // Get hives without an apiary for adding to this apiary
      final availableHives = await _hiveService.getHivesWithoutApiary(includeQueen: true);
      
      if (event.apiaryId != null) {
        // Load existing apiary data if we're editing
        final apiary = await _apiaryService.getApiaryById(event.apiaryId!);
        if (apiary != null) {
          // Get hives for this apiary to show summary
          final hives = await _hiveService.getByApiaryId(event.apiaryId!, includeQueen: true);
          emit(state.copyWith(
            availableHives: () => availableHives,
            apiaryId: () => apiary.id,
            name: () => apiary.name,
            description: () => apiary.description,
            location: () => apiary.location,
            createdAt: () => apiary.createdAt,
            imageUrl: () => apiary.imageUrl,
            latitude: () => apiary.latitude,
            longitude: () => apiary.longitude,
            isMigratory: () => apiary.isMigratory,
            color: () => apiary.color,
            status: () => apiary.status,
            formStatus: () => EditApiaryStatus.loaded,
            apiarySummaryHives: () => hives,
            originalApiary: () => apiary,
            originalHives: () => hives,
            canCreateDefaultQueen: () => canCreateDefaultQueen,
            canCreateDefaultHive: () => canCreateDefaultHive,
          ));
          
        } else {
          emit(state.copyWith(
            errorMessage: () => 'Apiary not found',
            formStatus: () => EditApiaryStatus.failure,
          ));
        }
      } else {
        // Create new apiary
        emit(state.copyWith(
          apiaryId: () => null,
          formStatus: () => EditApiaryStatus.loaded,
          originalApiary: () => null,
          originalHives: () => List<Hive>.empty(),
          availableHives: () => availableHives,
          canCreateDefaultQueen: () => canCreateDefaultQueen,
          canCreateDefaultHive: () => canCreateDefaultHive,
        ));
        
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to load data: ${e.toString()}',
        formStatus: () => EditApiaryStatus.failure,
      ));
    }
  }

  FutureOr<void> _onNameChanged(EditApiaryNameChanged event, Emitter<EditApiaryState> emit) {
    emit(state.copyWith(name: () => event.name));
  }

  FutureOr<void> _onDescriptionChanged(EditApiaryDescriptionChanged event, Emitter<EditApiaryState> emit) {
    emit(state.copyWith(description: () => event.description));
  }

  FutureOr<void> _onLocationChanged(EditApiaryLocationChanged event, Emitter<EditApiaryState> emit) {
    emit(state.copyWith(location: () => event.location));
  }

  FutureOr<void> _onStatusChanged(EditApiaryStatusChanged event, Emitter<EditApiaryState> emit) {
    emit(state.copyWith(status: () => event.status));
  }

  FutureOr<void> _onLocationCoordinatesChanged(
      EditApiaryLocationCoordinatesChanged event, Emitter<EditApiaryState> emit) {
    emit(state.copyWith(
      latitude: () => event.latitude,
      longitude: () => event.longitude,
    ));
  }

  FutureOr<void> _onIsMigratoryChanged(EditApiaryIsMigratoryChanged event, Emitter<EditApiaryState> emit) {
    emit(state.copyWith(isMigratory: () => event.isMigratory));
  }

  FutureOr<void> _onColorChanged(EditApiaryColorChanged event, Emitter<EditApiaryState> emit) {
    emit(state.copyWith(color: () => event.color));
  }

  FutureOr<void> _onAddQueensWithHivesToggled(
      EditApiaryAddQueensWithHivesToggled event, Emitter<EditApiaryState> emit) {
    emit(state.copyWith(addQueensWithHives: () => event.addQueensWithHives));
  }

  FutureOr<void> _onSubmitted(EditApiarySubmitted event, Emitter<EditApiaryState> emit) async {
    // Show validation errors if the form is invalid
    if (!state.isValid) {
      emit(state.copyWith(showValidationErrors: () => true));
      return;
    }
    
    emit(state.copyWith(formStatus: () => EditApiaryStatus.submitting));
    
    try {
      // Create a group ID to link related operations in history
      final String groupId = _apiaryService.createGroupId();
      
      final apiary = Apiary(
        id: state.apiaryId ?? '',
        name: state.name,
        description: state.description,
        location: state.location,
        position: 0, // This would need to be handled properly in a real app
        createdAt: state.apiaryId == null ? DateTime.now() : state.createdAt,
        imageUrl: state.imageUrl,
        latitude: state.latitude,
        longitude: state.longitude,
        isMigratory: state.isMigratory,
        color: state.color,
        status: state.status,
      );
      
      // Check if apiary data has changed
      final bool hasApiaryChanged = state.hasApiaryChanged;
      final bool haveHivesChanged = state.haveHivesChanged;
      
      Apiary savedApiary = apiary;
      
      if (hasApiaryChanged) {
        if (state.apiaryId == null || state.apiaryId?.isEmpty == true) {
          savedApiary = await _apiaryService.insertApiary(apiary, groupId: groupId);
        } else {
          savedApiary = await _apiaryService.updateApiary(
            apiary: apiary, 
            groupId: groupId
          );
        }
      }
      
      // Update hives if they've changed
      if (haveHivesChanged && savedApiary.id.isNotEmpty) {
        // Handle removed hives
        for (final originalHive in state.originalHives) {
          if (!state.apiarySummaryHives.any((h) => h.id == originalHive.id)) {
            // This hive was removed, update it to remove apiary reference
            // Skip history log as it's a bulk operation
            await _hiveService.updateHive(
              hive: originalHive.copyWith(apiary: null),
              skipHistoryLog: true,
              groupId: groupId
            );
          }
        }
        
        // Update hives with positions and apiary
        final hives = state.apiarySummaryHives.map((h) => h.copyWith(apiary: () => savedApiary)).toList();
        await _hiveService.updateHivesBatch(
          hives,
          groupId: groupId,
          skipHistoryLog: false  // Log the batch update
        );
      }
      
      emit(state.copyWith(formStatus: () => EditApiaryStatus.success));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to save apiary: ${e.toString()}',
        formStatus: () => EditApiaryStatus.failure,
      ));
    }
  }

  FutureOr<void> _onAddHive(EditApiaryAddHive event, Emitter<EditApiaryState> emit) async {
    if (state.addQueensWithHives) {
      // Only use groupId when we're creating both a queen and a hive together
      final String groupId = _apiaryService.createGroupId();
      
      // Create a new queen - this should be logged in history
      final queen = await _queenService.createDefaultQueen(
        groupId: groupId, 
        skipHistoryLog: false
      );
      
      // Create a new hive with the queen - this should be logged in history
      final newHive = await _hiveService.createDefaultHive(
        apiaryId: state.apiaryId, 
        queenId: queen.id,
        name: 'New Hive',
        groupId: groupId,
        skipHistoryLog: false
      );
      
      emit(state.copyWith(
        apiarySummaryHives: () => [...state.apiarySummaryHives, newHive],
      ));
      return;
    }
    
    // Creating just a hive - no need for groupId as it's a single operation
    final newHive = await _hiveService.createDefaultHive(
      apiaryId: state.apiaryId,
      name: 'New Hive',
      skipHistoryLog: false
    );
    
    emit(state.copyWith(
      apiarySummaryHives: () => [...state.apiarySummaryHives, newHive],
    ));
  }
  
  FutureOr<void> _onAddHiveWithQueen(EditApiaryAddHiveWithQueen event, Emitter<EditApiaryState> emit) async {
    // No groupId needed here as we're just creating a single hive
    // (we're not creating a queen, just associating with an existing one)
    var newHive = await _hiveService.createDefaultHive(
      apiaryId: state.apiaryId, 
      queenId: event.queen.id,
      name: 'New Hive',
      skipHistoryLog: false
    );
    
    newHive = newHive.copyWith(queen:() => event.queen);
    emit(state.copyWith(
      apiarySummaryHives: () => [...state.apiarySummaryHives, newHive],
      canCreateDefaultQueen: () => true,
    ));
  }

  FutureOr<void> _onAddExistingHive(
      EditApiaryAddExistingHive event, Emitter<EditApiaryState> emit) async {
    try {
      // Do not perform actual database updates until form submission
      // Just update the UI state
      emit(state.copyWith(
        apiarySummaryHives: () => [...state.apiarySummaryHives, event.hive],
        availableHives: () => state.availableHives
            .where((h) => h.id != event.hive.id)
            .toList(),
        canCreateDefaultHive: () => true,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to add existing hive: ${e.toString()}',
      ));
    }
  }

  FutureOr<void> _onRemoveHive(
      EditApiaryRemoveHive event, Emitter<EditApiaryState> emit) async {
    try {
      if (state.apiaryId != null) {
        // Only update the hive to unassign it, don't delete it
        // This is an intermediate operation, so we skip history logging
        // No groupId needed as it's a single operation
        final updatedHive = event.hive.copyWith(apiary: null);
        await _hiveService.updateHive(
          hive: updatedHive,
          skipHistoryLog: true
        );
      }
      
      // Remove from summary and add to available hives
      emit(state.copyWith(
        apiarySummaryHives: () => state.apiarySummaryHives
            .where((h) => h.id != event.hive.id)
            .toList(),
        availableHives: () => [...state.availableHives, event.hive],
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to remove hive: ${e.toString()}',
      ));
    }
  }

  FutureOr<void> _onReorderHives(
      EditApiaryReorderHives event, Emitter<EditApiaryState> emit) async {
    
    // Assign consecutive position values to all hives in the reordered list
    final hivesWithNewPositions = List<Hive>.generate(
      event.reorderedHives.length,
      (index) => event.reorderedHives[index].copyWith(
        position: () => index,
      ),
    );
    
    // Emit the new state with reordered hives
    emit(state.copyWith(
      apiarySummaryHives: () => hivesWithNewPositions,
    ));
    
    // We don't save changes to the database here - that will happen when the form is submitted
    // This keeps all changes in the form state until explicitly saved
  }

}
