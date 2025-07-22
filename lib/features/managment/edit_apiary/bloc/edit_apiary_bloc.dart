import 'dart:async';
import 'dart:io';

import 'package:apiarium/core/di/dependency_injection.dart';
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
      on<EditApiaryGenerateName>(_onGenerateName);
      on<EditApiaryImageChanged>(_onImageChanged);
      on<EditApiaryImageDeleted>(_onImageDeleted);
    }

  FutureOr<void> _onLoadRequest(EditApiaryLoadData event, Emitter<EditApiaryState> emit) async {
    emit(state.copyWith(
      formStatus: () => EditApiaryStatus.loading,
    ));
    
    try {
      final allHives = await _hiveService.getAllHives();
      final availableHives = allHives.where((hive) => 
        hive.apiaryId == null || 
        hive.apiaryId?.isEmpty == true ||
        hive.apiaryId == event.apiaryId
      ).toList();

      if (event.apiaryId != null) {
        // Load existing apiary data if we're editing
        final apiary = await _apiaryService.getApiaryById(event.apiaryId!);
        if (apiary != null) {
          String? imagePath;
          if (apiary.imageName != null) {
            imagePath = await apiary.getLocalImagePath();
            // Optionally, check if file exists, else use cloud URL
            if (imagePath == null || !(await File(imagePath).exists())) {
              // If you want to fallback to cloud, you can add logic here
              imagePath = null;
            }
          }

          // Load hives currently assigned to this apiary
          final apiaryHives = await _hiveService.getHivesByApiaryId(event.apiaryId!);
          
          emit(state.copyWith(
            apiaryId: () => apiary.id,
            name: () => apiary.name,
            description: () => apiary.description,
            location: () => apiary.location,
            createdAt: () => apiary.createdAt,
            imageUrl: () => imagePath,
            latitude: () => apiary.latitude,
            longitude: () => apiary.longitude,
            isMigratory: () => apiary.isMigratory,
            color: () => apiary.color,
            status: () => apiary.status,
            formStatus: () => EditApiaryStatus.loaded,
            originalApiary: () => apiary,
            apiarySummaryHives: () => apiaryHives,
            availableHives: () => availableHives.where((h) => h.apiaryId != event.apiaryId).toList(),
          ));
        } else {
          emit(state.copyWith(
            errorMessage: () => 'Apiary not found',
            formStatus: () => EditApiaryStatus.failure,
          ));
        }
      } else {
        // Create new apiary and generate name
        final nameService = getIt<NameGeneratorService>();
        await nameService.initialize();
        final generatedName = await nameService.generateApiaryName();

        emit(state.copyWith(
          apiaryId: () => null,
          name: () => generatedName,
          formStatus: () => EditApiaryStatus.loaded,
          originalApiary: () => null,
          apiarySummaryHives: () => <Hive>[],
          availableHives: () => availableHives,
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

  Future<void> _onGenerateName(EditApiaryGenerateName event, Emitter<EditApiaryState> emit) async {
    try {
      final nameService = getIt<NameGeneratorService>();
      await nameService.initialize();
      final generatedName = await nameService.generateApiaryName();
      emit(state.copyWith(name: () => generatedName));
    } catch (e) {
      final fallbackName = "Apiary ${DateTime.now().millisecondsSinceEpoch % 1000}";
      emit(state.copyWith(name: () => fallbackName));
    }
  }

  Future<void> _onImageChanged(EditApiaryImageChanged event, Emitter<EditApiaryState> emit) async {
    emit(state.copyWith(imageUrl: () => event.imagePath));
  }

  Future<void> _onImageDeleted(EditApiaryImageDeleted event, Emitter<EditApiaryState> emit) async {
    emit(state.copyWith(
      imageUrl: () => null,
    ));
  }

  FutureOr<void> _onSubmitted(EditApiarySubmitted event, Emitter<EditApiaryState> emit) async {
    // Show validation errors if the form is invalid
    if (!state.isValid) {
      emit(state.copyWith(showValidationErrors: () => true));
      return;
    }
    
    emit(state.copyWith(formStatus: () => EditApiaryStatus.submitting));
    
    try {
      if (state.apiaryId == null || state.apiaryId?.isEmpty == true) {
        // Create new apiary - image will be saved in service
        await _apiaryService.createApiary(
          name: state.name,
          description: state.description,
          location: state.location,
          imageName: state.imageUrl,
          latitude: state.latitude,
          longitude: state.longitude,
          isMigratory: state.isMigratory,
          color: state.color,
          status: state.status,
        );
      } else {
        // Update existing apiary
        final originalApiary = state.originalApiary!;
        
        final updatedApiary = originalApiary.copyWith(
          name: () => state.name,
          description: () => state.description,
          location: () => state.location,
          latitude: () => state.latitude,
          longitude: () => state.longitude,
          isMigratory: () => state.isMigratory,
          color: () => state.color,
          status: () => state.status,
          imageName: () => state.imageUrl,
        );
        
        await _apiaryService.updateApiary(updatedApiary);
      }
      
      emit(state.copyWith(formStatus: () => EditApiaryStatus.success));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to save apiary: ${e.toString()}',
        formStatus: () => EditApiaryStatus.failure,
      ));
    }
  }

  // Simplified hive management methods - just for UI navigation
  FutureOr<void> _onAddHive(EditApiaryAddHive event, Emitter<EditApiaryState> emit) async {
    // This event is no longer used since we always navigate to edit pages
    // Kept for compatibility but does nothing
  }
  
  FutureOr<void> _onAddHiveWithQueen(EditApiaryAddHiveWithQueen event, Emitter<EditApiaryState> emit) async {
    // This event is no longer used since we always navigate to edit pages
    // Kept for compatibility but does nothing
  }

  FutureOr<void> _onAddExistingHive(
      EditApiaryAddExistingHive event, Emitter<EditApiaryState> emit) async {
    // Add hive to the apiary's hive list
    final updatedHives = [...state.apiarySummaryHives, event.hive];
    // Remove hive from available hives
    final updatedAvailableHives = state.availableHives.where((h) => h.id != event.hive.id).toList();
    
    emit(state.copyWith(
      apiarySummaryHives: () => updatedHives,
      availableHives: () => updatedAvailableHives,
    ));
  }

  FutureOr<void> _onRemoveHive(
      EditApiaryRemoveHive event, Emitter<EditApiaryState> emit) async {
    // Remove hive from the apiary's hive list
    final updatedHives = state.apiarySummaryHives.where((h) => h.id != event.hive.id).toList();
    // Add hive back to available hives
    final updatedAvailableHives = [...state.availableHives, event.hive];
    
    emit(state.copyWith(
      apiarySummaryHives: () => updatedHives,
      availableHives: () => updatedAvailableHives,
    ));
  }

  FutureOr<void> _onReorderHives(
      EditApiaryReorderHives event, Emitter<EditApiaryState> emit) async {
    emit(state.copyWith(
      apiarySummaryHives: () => event.reorderedHives,
    ));
  }
}