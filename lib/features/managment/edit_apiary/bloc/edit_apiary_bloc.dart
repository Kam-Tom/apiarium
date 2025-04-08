import 'dart:async';
import 'dart:math';

import 'package:apiarium/shared/shared.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'edit_apiary_event.dart';
part 'edit_apiary_state.dart';

class EditApiaryBloc extends Bloc<EditApiaryEvent, EditApiaryState> {
  final ApiaryRepository _apiaryRepository;
  final HiveRepository _hiveRepository;
  final QueenRepository _queenRepository;
  
  EditApiaryBloc({
    ApiaryRepository? apiaryRepository,
    HiveRepository? hiveRepository,
    QueenRepository? queenRepository,
  }) : 
    _apiaryRepository = apiaryRepository ?? ApiaryRepository(),
    _hiveRepository = hiveRepository ?? HiveRepository(),
    _queenRepository = queenRepository ?? QueenRepository(),
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
      final canCreateDefaultQueen = await _queenRepository.canCreateDefaultQueen();
      final canCreateDefaultHive = await _hiveRepository.canCreateDefaultHive();
      
      // Get hives without an apiary for adding to this apiary
      final availableHives = await _hiveRepository.getHivesWithoutApiary(includeQueen: true);
      
      if (event.apiaryId != null) {
        // Load existing apiary data if we're editing
        final apiary = await _apiaryRepository.getApiaryById(event.apiaryId!);
        if (apiary != null) {
          // Get hives for this apiary to show summary
          final hives = await _hiveRepository.getByApiaryId(event.apiaryId!, includeQueen: true);
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
          savedApiary = await _apiaryRepository.insertApiary(apiary);
        } else {
          savedApiary = await _apiaryRepository.updateApiary(apiary);
        }
      }
      
      // Update hives if they've changed
      if (haveHivesChanged && savedApiary.id.isNotEmpty) {
        // Handle removed hives
        for (final originalHive in state.originalHives) {
          if (!state.apiarySummaryHives.any((h) => h.id == originalHive.id)) {
            // This hive was removed, update it to remove apiary reference
            await _hiveRepository.updateHive(originalHive.copyWith(apiary: null));
          }
        }
        
        // Update hives with positions and apiary
        final hives = state.apiarySummaryHives.map((h) => h.copyWith(apiary: () => savedApiary)).toList();
        await _hiveRepository.updateHivesBatch(hives);
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
    if(state.addQueensWithHives){
      final queen = await _queenRepository.createDefaultQueen();
      final newHive = await _hiveRepository.createDefaultHive(apiaryId: state.apiaryId, queenId: queen.id);
      emit(state.copyWith(
        apiarySummaryHives: () => [...state.apiarySummaryHives, newHive],
      ));
      return;
    }
    
    final newHive = await _hiveRepository.createDefaultHive(apiaryId: state.apiaryId);
    emit(state.copyWith(
      apiarySummaryHives: () => [...state.apiarySummaryHives, newHive],
    ));
  }
  
  FutureOr<void> _onAddHiveWithQueen(EditApiaryAddHiveWithQueen event, Emitter<EditApiaryState> emit) async {
    // Create a new hive with the specified queen
    var newHive = await _hiveRepository.createDefaultHive(apiaryId: state.apiaryId, queenId: event.queen.id);
    newHive = newHive.copyWith(queen:() => event.queen);
    emit(state.copyWith(
      apiarySummaryHives: () => [...state.apiarySummaryHives, newHive],
      canCreateDefaultQueen: () => true,
    ));
  }

  FutureOr<void> _onAddExistingHive(
      EditApiaryAddExistingHive event, Emitter<EditApiaryState> emit) async {
    try {
      if (state.apiaryId != null) {
        // Update the hive to assign it to this apiary
        //final updatedHive = event.hive.copyWith(apiary: () => state.originalApiary);
        //await _hiveRepository.updateHive(updatedHive);
        
        // Add to summary and remove from available hives
        emit(state.copyWith(
          apiarySummaryHives: () => [...state.apiarySummaryHives, event.hive],
          availableHives: () => state.availableHives
              .where((h) => h.id != event.hive.id)
              .toList(),
          canCreateDefaultHive: () => true,
        ));
      } else {
        // For new apiaries, we'll just track it to be assigned when the apiary is created
        emit(state.copyWith(
          apiarySummaryHives: () => [...state.apiarySummaryHives, event.hive],
          availableHives: () => state.availableHives
              .where((h) => h.id != event.hive.id)
              .toList(),
          canCreateDefaultHive: () => true,
        ));
      }
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
        final updatedHive = event.hive.copyWith(apiary: null);
        await _hiveRepository.updateHive(updatedHive);
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
