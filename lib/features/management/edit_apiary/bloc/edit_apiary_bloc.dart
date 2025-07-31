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
  
  EditApiaryBloc({
    required ApiaryService apiaryService,
    required HiveService hiveService,
  }) : 
    _apiaryService = apiaryService,
    _hiveService = hiveService,
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
      on<EditApiaryAddExistingHive>(_onAddExistingHive);
      on<EditApiaryRemoveHive>(_onRemoveHive);
      on<EditApiaryReorderHives>(_onReorderHives);
      on<EditApiarySubmitted>(_onSubmitted);
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

          // Load hives assigned to this apiary and preserve their order
          final apiaryHives = allHives
              .where((hive) => hive.apiaryId == event.apiaryId)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order)); // Preserve order
          
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
      // Update hive orders based on current state
      final hivesWithUpdatedOrder = state.apiarySummaryHives
          .asMap()
          .entries
          .map((entry) => entry.value.copyWith(
                order: () => entry.key + 1, // 1-based order
                apiaryId: () => state.apiaryId ?? 'temp-id', // Will be updated by service
              ))
          .toList();

      if (state.apiaryId == null || state.apiaryId?.isEmpty == true) {
        // Create new apiary - ApiaryService will handle hive assignments
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
          hives: hivesWithUpdatedOrder, // Pass hives to be assigned
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
        
        // ApiaryService will handle updating hive assignments and order
        await _apiaryService.updateApiary(updatedApiary, hives: hivesWithUpdatedOrder);
      }
      
      emit(state.copyWith(formStatus: () => EditApiaryStatus.success));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to save apiary: ${e.toString()}',
        formStatus: () => EditApiaryStatus.failure,
      ));
    }
  }

  FutureOr<void> _onAddExistingHive(
      EditApiaryAddExistingHive event, Emitter<EditApiaryState> emit) async {
    final updatedHives = List<Hive>.from(state.apiarySummaryHives)..add(event.hive);
    final updatedAvailableHives = List<Hive>.from(state.availableHives)
      ..removeWhere((h) => h.id == event.hive.id);
    
    emit(state.copyWith(
      apiarySummaryHives: () => updatedHives,
      availableHives: () => updatedAvailableHives,
    ));
  }

  FutureOr<void> _onRemoveHive(
      EditApiaryRemoveHive event, Emitter<EditApiaryState> emit) async {
    final updatedHives = List<Hive>.from(state.apiarySummaryHives)
      ..removeWhere((h) => h.id == event.hive.id);
    final updatedAvailableHives = List<Hive>.from(state.availableHives)..add(event.hive);
    
    emit(state.copyWith(
      apiarySummaryHives: () => updatedHives,
      availableHives: () => updatedAvailableHives,
    ));
  }

  FutureOr<void> _onReorderHives(
      EditApiaryReorderHives event, Emitter<EditApiaryState> emit) async {
      int order = 1;
      final updatedHives = event.reorderedHives.map((hive) {
        order++;
        return hive.copyWith(order: () => order);
      }).toList();
    
    emit(state.copyWith(
      apiarySummaryHives: () => updatedHives,
    ));
  }
}