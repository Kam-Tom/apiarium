import 'dart:async';

import 'package:apiarium/shared/shared.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'edit_hive_event.dart';
part 'edit_hive_state.dart';

class EditHiveBloc extends Bloc<EditHiveEvent, EditHiveState> {
  final QueenService _queenService;
  final ApiaryService _apiaryService;
  final HiveService _hiveService;
  
  EditHiveBloc({
    required QueenService queenService,
    required ApiaryService apiaryService,
    required HiveService hiveService,
    bool skipSaving = false,
    bool hideLocation = false,
  }) : 
    _queenService = queenService,
    _apiaryService = apiaryService,
    _hiveService = hiveService,
    super(EditHiveState(acquisitionDate: DateTime.now(), skipSaving: skipSaving, hideLocation: hideLocation)) {
      on<EditHiveLoadData>(_onLoadRequest);
      on<EditHiveNameChanged>(_onNameChanged);
      on<EditHiveApiaryChanged>(_onApiaryChanged);
      on<EditHiveTypeChanged>(_onHiveTypeChanged);
      on<EditHiveQueenChanged>(_onQueenChanged);
      on<EditHiveStatusChanged>(_onStatusChanged);
      on<EditHiveAcquisitionDateChanged>(_onAcquisitionDateChanged);
      on<EditHiveColorChanged>(_onColorChanged);
      on<EditHiveFrameCountChanged>(_onFrameCountChanged);
      on<EditHiveBroodFrameCountChanged>(_onBroodFrameCountChanged);
      on<EditHiveToggleStarHiveType>(_onToggleStarHiveType);
      on<EditHiveSubmitted>(_onSubmitted);
      on<EditHiveAddNewHiveType>(_onAddNewHiveType);
      on<EditHiveBroodBoxCountChanged>(_onBroodBoxCountChanged);
      on<EditHiveHoneySuperBoxCountChanged>(_onHoneySuperBoxCountChanged);
      on<EditHiveCreateDefaultQueen>(_onEditHiveCreateDefaultQueen);
      on<EditHiveUpdateQueen>(_onUpdateQueen);
      on<EditHiveCreateQueen>(_onEditHiveCreateQueen);
    }

  FutureOr<void> _onLoadRequest(EditHiveLoadData event, Emitter<EditHiveState> emit) async {
    emit(state.copyWith(
      formStatus: () => EditHiveStatus.loading,
    ));
    
    try {
      // Load available hive types
      var hiveTypes = await _hiveService.getAllTypes();

      //TODO REMOVE AFTER TESTING
      if(hiveTypes.isEmpty) {
        await _hiveService.insertType(
          type: HiveType(
            id:'',
            name: 'Langstroth',
            defaultFrameCount: 10,
            mainMaterial: HiveMaterial.wood,
            hasFrames: true,
            frameStandard: 'Hoffmann',
            broodBoxCount: 2,
            honeySuperBoxCount: 3,
            hiveCost: 250.0,
            currency: Currency.usd,
            frameUnitCost: 5.0,
            broodFrameUnitCost: 6.0,
            broodBoxUnitCost: 45.0,
            honeySuperBoxUnitCost: 35.0,
          )
        );
        hiveTypes = await _hiveService.getAllTypes();
      }
      //TODO REMOVE AFTER TESTING

      // Load available queens that are not already assigned
      final queens = await _queenService.getUnassignedQueens();
      final canCreateDefaultQueen = await _queenService.canCreateDefaultQueen();
      
      // Load available apiaries
      final apiaries = await _apiaryService.getAllApiaries();

      if (event.hiveId != null) {
        // Load existing hive data if we're editing
        final dbHive = await _hiveService.getHiveById(
          event.hiveId!,
          includeApiary: true,
          includeQueen: true
        );
        
        // hive.Apiary and Apiares dont equal because of hive count that is not loaded from getHiveById
        Apiary? selectedApiary;
        for (var apiary in apiaries) {
          if (apiary.id == dbHive?.apiary?.id) {
            selectedApiary = apiary;
            break;
          }
        }
        final hive = dbHive?.copyWith(apiary: () => selectedApiary);

        if (hive != null) {
          // If hive has a queen, add it to available queens
          if (hive.queen != null) {
            queens.add(hive.queen!);
          }
          
          emit(state.copyWith(
            hiveId: () => hive.id,
            name: () => hive.name,
            selectedApiary: () => selectedApiary,
            hiveType: () => hive.hiveType,
            queen: () => hive.queen,
            status: () => hive.status,
            acquisitionDate: () => hive.acquisitionDate,
            imageUrl: () => hive.imageUrl,
            position: () => hive.position,
            color: () => hive.color,
            currentFrameCount: () => hive.currentFrameCount,
            currentBroodFrameCount: () => hive.currentBroodFrameCount,
            currentBroodBoxCount: () => hive.currentBroodBoxCount,
            currentHoneySuperBoxCount: () => hive.currentHoneySuperBoxCount,
            formStatus: () => EditHiveStatus.loaded,
            availableHiveTypes: () => hiveTypes,
            availableApiaries: () => apiaries,
            availableQueens: () => queens,
            canCreateDefaultQueen: () => canCreateDefaultQueen,
          ));
        } else {
          emit(state.copyWith(
            errorMessage: () => 'Hive not found',
            formStatus: () => EditHiveStatus.failure,
          ));
        }
      } else {
        // Create new hive
        emit(state.copyWith(
          hiveId: () => null,
          formStatus: () => EditHiveStatus.loaded,
          availableHiveTypes: () => hiveTypes,
          availableApiaries: () => apiaries,
          availableQueens: () => queens,
          canCreateDefaultQueen: () => canCreateDefaultQueen,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to load data: ${e.toString()}',
        formStatus: () => EditHiveStatus.failure,
      ));
    }
  }

  FutureOr<void> _onNameChanged(EditHiveNameChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(name: () => event.name));
  }

  FutureOr<void> _onApiaryChanged(EditHiveApiaryChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(selectedApiary: () => event.apiary));
  }

  FutureOr<void> _onHiveTypeChanged(EditHiveTypeChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(
      hiveType: () => event.hiveType,
      currentFrameCount: () => event.hiveType.defaultFrameCount,
    ));
  }

  FutureOr<void> _onQueenChanged(EditHiveQueenChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(queen: () => event.queen));
  }

  FutureOr<void> _onStatusChanged(EditHiveStatusChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(status: () => event.status));
  }

  FutureOr<void> _onAcquisitionDateChanged(EditHiveAcquisitionDateChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(acquisitionDate: () => event.date));
  }

  FutureOr<void> _onColorChanged(EditHiveColorChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(color: () => event.color));
  }

  FutureOr<void> _onFrameCountChanged(EditHiveFrameCountChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(currentFrameCount: () => event.count));
  }

  FutureOr<void> _onBroodFrameCountChanged(EditHiveBroodFrameCountChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(currentBroodFrameCount: () => event.count));
  }

  FutureOr<void> _onBroodBoxCountChanged(EditHiveBroodBoxCountChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(currentBroodBoxCount: () => event.count));
  }

  FutureOr<void> _onHoneySuperBoxCountChanged(EditHiveHoneySuperBoxCountChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(currentHoneySuperBoxCount: () => event.count));
  }

  FutureOr<void> _onSubmitted(EditHiveSubmitted event, Emitter<EditHiveState> emit) async {
    // Show validation errors if the form is invalid
    if (!state.isValid) {
      emit(state.copyWith(showValidationErrors: () => true));
      return;
    }
    
    // Create the hive object
    final hive = Hive(
      id: state.hiveId ?? '',
      name: state.name,
      apiary: state.selectedApiary,
      hiveType: state.hiveType!,
      queen: state.queen,
      status: state.status,
      acquisitionDate: state.acquisitionDate,
      imageUrl: state.imageUrl,
      position: state.position,
      color: state.color,
      currentFrameCount: state.currentFrameCount,
      currentBroodFrameCount: state.currentBroodFrameCount,
      currentBroodBoxCount: state.currentBroodBoxCount,
      currentHoneySuperBoxCount: state.currentHoneySuperBoxCount,
    );
    
    // If skipSaving is true, just return the hive object without saving
    if (state.skipSaving) {
      emit(state.copyWith(
        formStatus: () => EditHiveStatus.success,
        createdHive: () => hive,
      ));
      return;
    }
    
    // Otherwise proceed with normal save
    emit(state.copyWith(formStatus: () => EditHiveStatus.submitting));
    
    try {
      
      if (state.hiveId == null || state.hiveId?.isEmpty == true) {
        await _hiveService.insertHive(hive);
      } else {
        await _hiveService.updateHive(
          hive: hive,
        );
      }
      
      emit(state.copyWith(
        formStatus: () => EditHiveStatus.success,
        createdHive: () => hive,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to save hive: ${e.toString()}',
        formStatus: () => EditHiveStatus.failure,
      ));
    }
  }

  FutureOr<void> _onAddNewHiveType(EditHiveAddNewHiveType event, Emitter<EditHiveState> emit) async {
    try {
      emit(state.copyWith(formStatus: () => EditHiveStatus.loading));
      
      final savedHiveType = await _hiveService.insertType(type: event.hiveType);
      
      final updatedTypes = [...state.availableHiveTypes, savedHiveType];
      
      emit(state.copyWith(
        availableHiveTypes: () => updatedTypes,
        hiveType: () => savedHiveType,
        formStatus: () => EditHiveStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to add hive type: ${e.toString()}',
        formStatus: () => EditHiveStatus.failure,
      ));
    }
  }

  FutureOr<void> _onToggleStarHiveType(EditHiveToggleStarHiveType event, Emitter<EditHiveState> emit) async {
    final updateType = event.hiveType.copyWith(isStarred: () => !event.hiveType.isStarred);
    await _hiveService.updateType(type: updateType);

    final availableTypes = state.availableHiveTypes.map((type) => 
      type.id == updateType.id ? updateType : type).toList();

    final updatedSelectedType = state.hiveType?.id == updateType.id 
      ? updateType 
      : state.hiveType;

    emit(state.copyWith(
      availableHiveTypes: () => availableTypes,
      hiveType: () => updatedSelectedType,
    ));
  }

  FutureOr<void> _onEditHiveCreateDefaultQueen(EditHiveCreateDefaultQueen event, Emitter<EditHiveState> emit) async {
    final newQueen = await _queenService.createDefaultQueen();
    emit(state.copyWith(queen: () => newQueen));
    emit(state.copyWith(availableQueens: () => [...state.availableQueens, newQueen]));
  }

  FutureOr<void> _onEditHiveCreateQueen(EditHiveCreateQueen event, Emitter<EditHiveState> emit) async {
    final newQueen = await _queenService.insertQueen(event.queen);
    emit(state.copyWith(
      queen: () => newQueen,
      availableQueens: () => [...state.availableQueens, newQueen]
    ));
  }

  FutureOr<void> _onUpdateQueen(EditHiveUpdateQueen event, Emitter<EditHiveState> emit) async {
    await _queenService.updateQueen(queen: event.queen);
    
    emit(state.copyWith(
      queen: () => event.queen,
      availableQueens: () => state.availableQueens.map((queen) => 
        queen.id == event.queen.id ? event.queen : queen).toList(),
    ));
  }
}
