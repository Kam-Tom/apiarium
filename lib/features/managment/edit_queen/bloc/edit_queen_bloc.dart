import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

part 'edit_queen_event.dart';
part 'edit_queen_state.dart';

class EditQueenBloc extends Bloc<EditQueenEvent, EditQueenState> {
  final QueenService _queenService;
  final ApiaryService _apiaryService;
  final HiveService _hiveService;
  
  EditQueenBloc({
    required QueenService queenService,
    required ApiaryService apiaryService,
    required HiveService hiveService,
    bool skipSaving = false,
    bool hideLocation = false,
  }) : 
    _queenService = queenService,
    _apiaryService = apiaryService,
    _hiveService = hiveService,
    super(EditQueenState(birthDate: DateTime.now(), skipSaving: skipSaving, hideLocation: hideLocation)) {
    on<EditQueenLoadData>(_onLoadRequest);
    
    // Individual field event handlers
    on<EditQueenNameChanged>(_onNameChanged);
    on<EditQueenBreedChanged>(_onBreedChanged);
    on<EditQueenBirthDateChanged>(_onBirthDateChanged);
    on<EditQueenSourceChanged>(_onSourceChanged);
    on<EditQueenHiveNameChanged>(_onHiveNameChanged);
    on<EditQueenMarkedChanged>(_onMarkedChanged);
    on<EditQueenMarkColorChanged>(_onMarkColorChanged);
    on<EditQueenStatusChanged>(_onStatusChanged);
    on<EditQueenOriginChanged>(_onOriginChanged);
    
    on<EditQueenApiaryChanged>(_onApiaryChanged);
    on<EditQueenHiveChanged>(_onHiveChanged);
    on<EditQueenCreateBreed>(_onCreateBreed);
    on<EditQueenToggleBreedStar>(_onToggleBreedStar);
    on<EditQueenSubmitted>(_onSubmitted);
  }

  Future<void> _onLoadRequest(EditQueenLoadData event, Emitter<EditQueenState> emit) async {
    emit(state.copyWith(status: () => EditQueenStatus.loading));

    var breeds = await _queenService.getAllBreeds();

    //TODO DELETE THIS AFTER TESTING
    if(breeds.isEmpty) {
      await _queenService.insertBreed(
        breed: QueenBreed(
          id: '',
          name: 'Italian',
          scientificName: 'Apis mellifera ligustica',
          origin: 'Italy',
          country: 'Italy',
          isStarred: true,
          priority: 1,
        )
      );
      breeds = await _queenService.getAllBreeds();
    }
    //TODO ---

    final apiaries = await _apiaryService.getAllApiaries();
    
    // Load hives with queen information
    final apiaryHives = await _hiveService.getAllHives(includeQueen: true);
    
    // Filter hives to show only those without a queen or with the queen being edited
    final availableHives = apiaryHives.where((hive) => 
      hive.queen == null || (event.queenId != null && hive.queen?.id == event.queenId)
    ).toList();
        
    if(event.queenId != null) {
      final queen = await _queenService.getQueenById(event.queenId!, includeApiary: true, includeHive: true);
      if (queen != null) {
        // Hive doesn't equal queen.hive because of hive.queen
        Hive? selectedHive = queen.hive != null ? availableHives.firstWhere((hive) => hive.id == queen.hive!.id) : null; 
        Apiary? selectedApiary = queen.apiary != null ? apiaries.firstWhere((apiary) => apiary.id == queen.apiary!.id) : null;

        emit(state.copyWith(
          id:() => queen.id,
          name: () => queen.name,
          queenBreed: () => queen.breed,
          birthDate: () => queen.birthDate,
          source: () => queen.source,
          marked: () => queen.marked,
          markColor: () => queen.markColor,
          queenStatus: () => queen.status,
          origin: () => queen.origin,
          status: () => EditQueenStatus.loaded,
          availableBreeds: () => breeds,
          availableApiaries: () => apiaries,
          availableHives: () => availableHives,
          selectedApiary: () => selectedApiary,
          selectedHive: () => selectedHive,
          originalQueen: () => queen,
        ));
      } else {
        emit(state.copyWith(
          status: () => EditQueenStatus.failure,
          errorMessage: () => 'Queen not found',
        ));
      }
    }
    else {
      final queenNr = await _queenService.getQueensCount();
      emit(state.copyWith(
        name: () => 'Queen ${queenNr + 1}',
        marked: () => true,
        markColor: () => EditQueenState.getColorForYear(DateTime.now().year),
        status: () => EditQueenStatus.loaded,
        availableBreeds: () => breeds,
        availableApiaries: () => apiaries,
        availableHives: () => availableHives,
        originalQueen: () => null, // No original queen for new entries
      ));
    }
  }
  
  // Individual field handlers
  // ...existing code...

  Future<void> _onSubmitted(EditQueenSubmitted event, Emitter<EditQueenState> emit) async {
    // Validate the form first
    final Map<String, String?> validationErrors = {};
    
    // Validate required fields
    if (state.name.trim().isEmpty) {
      validationErrors['name'] = 'Queen name is required';
    }
    
    if (state.queenBreed == null) {
      validationErrors['breed'] = 'Queen breed is required';
    }
    
    // Add any other validations here
    
    // Show validation errors if form is invalid
    if (validationErrors.isNotEmpty) {
      emit(state.copyWith(
        showValidationErrors: () => true,
        validationErrors: () => validationErrors,
      ));
      return;
    }
    
    // Create the queen object
    final Queen queen = Queen(
      id: state.id ?? '',
      name: state.name,
      breed: state.queenBreed!,
      birthDate: state.birthDate,
      source: state.source,
      marked: state.marked,
      markColor: state.markColor,
      status: state.queenStatus,
      origin: state.origin,
      apiary: state.selectedApiary,
      hive: state.selectedHive,
    );
    
    // If skipSaving is true, just emit success with the created queen
    if (state.skipSaving) {
      emit(state.copyWith(
        status: () => EditQueenStatus.success,
        createdQueen: () => queen,
      ));
      return;
    }
    
    emit(state.copyWith(
      status: () => EditQueenStatus.submitting,
    ));
    
    try {
      // Create a group ID for related operations
      final String groupId = _queenService.createGroupId();
      
      final bool hasQueenChanged = state.hasQueenChanged;
      final bool hasLocationChanged = state.hasLocationChanged;
      
      Queen savedQueen = queen;
      if (hasQueenChanged) {
        if (state.id == null) {
          savedQueen = await _queenService.insertQueen(queen, groupId: groupId);
        } else {
          savedQueen = await _queenService.updateQueen(
            queen: queen, 
            groupId: groupId
          );
        }
      }
      
      if (hasLocationChanged && savedQueen.id.isNotEmpty) {
        final newHive = state.selectedHive;
        final oldHive = state.originalQueen?.hive;
        
        if (newHive?.id == oldHive?.id) {
          // No change in hive, no need to update
          return;
        }
        
        if (oldHive != null) {
          // Unassign queen from old hive
          await _hiveService.updateHive(
            hive: oldHive.copyWith(queen: () => null),
            skipHistoryLog: true,  // Skip logging this intermediate step
            groupId: groupId
          );
        }
        
        if (newHive != null) {
          // Assign queen to new hive
          await _hiveService.updateHive(
            hive: newHive.copyWith(queen: () => savedQueen),
            skipHistoryLog: false,  // Log this final change
            groupId: groupId
          );
        }
      }
      
      emit(state.copyWith(
        status: () => EditQueenStatus.success,
        createdQueen: () => queen,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => EditQueenStatus.failure,
        errorMessage: () => 'Failed to save queen: ${e.toString()}',
      ));
    }
  }

  FutureOr<void> _onApiaryChanged(EditQueenApiaryChanged event, Emitter<EditQueenState> emit) async {
    if(event.apiary == null) {
      // Show hives without an apiary
      final hivesWithoutApiary = await _hiveService.getHivesWithoutApiary(includeQueen: true);
      
      // Filter to only show hives without a queen or with the queen being edited
      final availableHives = hivesWithoutApiary.where((hive) => 
        hive.queen == null || hive.queen?.id == state.id
      ).toList();
      
      emit(state.copyWith(
        selectedApiary: () => null,
        selectedHive: () => null,
        availableHives: () => availableHives,
      ));
    }
    else {
      // Get hives for this apiary with queen information
      final apiaryHives = await _hiveService.getByApiaryId(event.apiary!.id, includeQueen: true);
      
      // Filter to only show hives without a queen or with the queen being edited
      final availableHives = apiaryHives.where((hive) => 
        hive.queen == null || hive.queen?.id == state.id
      ).toList();

      emit(state.copyWith(
        selectedApiary: () => event.apiary,
        availableHives: () => availableHives,
        selectedHive: () => null,
      ));
    }
  }

  FutureOr<void> _onCreateBreed(EditQueenCreateBreed event, Emitter<EditQueenState> emit) async {
    try {
      final newBreed = QueenBreed(
        id: '', 
        name: event.name,
        scientificName: event.scientificName,
        origin: event.origin,
        country: event.country,
        isStarred: event.isStarred,
        priority: event.isStarred ? 1 : 0, 
      );
      
      final savedBreed = await _queenService.insertBreed(breed: newBreed);
      
      final updatedBreeds = [...state.availableBreeds, savedBreed];
      
      updatedBreeds.sort((a, b) {
        if (a.isStarred && !b.isStarred) return -1;
        if (!a.isStarred && b.isStarred) return 1;
        if (a.isStarred == b.isStarred) {
          return b.priority.compareTo(a.priority); 
        }
        return a.name.compareTo(b.name);
      });
      
      emit(state.copyWith(
        availableBreeds: () => updatedBreeds,
        queenBreed: () => savedBreed, 
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to create breed: ${e.toString()}',
      ));
    }
  }

  FutureOr<void> _onHiveChanged(EditQueenHiveChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(
      selectedHive: () => event.hive,
    ));
  }

  FutureOr<void> _onToggleBreedStar(EditQueenToggleBreedStar event, Emitter<EditQueenState> emit) async {
    try {
      final updatedBreed = event.breed.copyWith(
        isStarred: () => !event.breed.isStarred
      );
      
      final savedBreed = await _queenService.updateBreed(breed: updatedBreed);
      
      final updatedBreeds = state.availableBreeds.map((breed) => 
        breed.id == savedBreed.id ? savedBreed : breed
      ).toList();
      
      // Sort by isStarred first, then by priority
      updatedBreeds.sort((a, b) {
        if (a.isStarred && !b.isStarred) return -1;
        if (!a.isStarred && b.isStarred) return 1;
        if (a.isStarred == b.isStarred) {
          return b.priority.compareTo(a.priority);
        }
        return a.name.compareTo(b.name);
      });
      
      emit(state.copyWith(
        availableBreeds: () => updatedBreeds,
        queenBreed: state.queenBreed?.id == savedBreed.id ? () => savedBreed : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to update breed star status: ${e.toString()}',
      ));
    }
  }
  
  // Keep the other field event handlers as they are
  void _onNameChanged(EditQueenNameChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(name: () => event.name));
  }

  void _onBreedChanged(EditQueenBreedChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(queenBreed: () => event.breed));
  }

  void _onBirthDateChanged(EditQueenBirthDateChanged event, Emitter<EditQueenState> emit) {
    if(state.marked) {
      emit(state.copyWith(
        birthDate: () => event.birthDate,
        markColor: () => EditQueenState.getColorForYear(event.birthDate.year)));
    }
    else {
      emit(state.copyWith(birthDate: () => event.birthDate));
    }
  }

  void _onSourceChanged(EditQueenSourceChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(source: () => event.source));
  }

  void _onHiveNameChanged(EditQueenHiveNameChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(hiveName: () => event.hiveName));
  }

  void _onMarkedChanged(EditQueenMarkedChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(marked: () => event.marked));
  }

  void _onMarkColorChanged(EditQueenMarkColorChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(markColor: () => event.markColor));
  }

  void _onStatusChanged(EditQueenStatusChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(queenStatus: () => event.status));
  }

  void _onOriginChanged(EditQueenOriginChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(origin: () => event.origin));
  }
}
