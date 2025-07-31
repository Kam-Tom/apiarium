import 'dart:async';

import 'package:apiarium/shared/shared.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:apiarium/core/di/dependency_injection.dart';

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
  }) : 
    _queenService = queenService,
    _apiaryService = apiaryService,
    _hiveService = hiveService,
    super(EditHiveState(acquisitionDate: DateTime.now())) {
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
      on<EditHiveCreateQueen>(_onEditHiveCreateQueen);

      on<EditHiveUpdateQueen>(_onUpdateQueen);
      on<EditHiveGenerateName>(_onGenerateName);
      on<EditHiveAccessoriesChanged>(_onAccessoriesChanged);
    }

  FutureOr<void> _onLoadRequest(EditHiveLoadData event, Emitter<EditHiveState> emit) async {
    emit(state.copyWith(
      formStatus: () => EditHiveStatus.loading,
    ));
    
    try {
      final queens = await _queenService.getUnassignedQueens();
      final apiaries = await _apiaryService.getAllApiaries();
      final hiveTypes = await _hiveService.getAllHiveTypes();

      if (event.hiveId != null) {
        final hive = await _hiveService.getHiveById(event.hiveId!);

        if (hive != null) {
          Apiary? selectedApiary;
          for (var apiary in apiaries) {
            if (apiary.id == hive.apiaryId) {
              selectedApiary = apiary;
              break;
            }
          }

          HiveType? selectedHiveType;
          for (var hiveType in hiveTypes) {
            if (hiveType.id == hive.hiveTypeId) {
              selectedHiveType = hiveType;
              break;
            }
          }

          Queen? selectedQueen;
          if (hive.queenId != null) {
            try {
              selectedQueen = await _queenService.getQueenById(hive.queenId!);
            } catch (_) {}
          }
          
          emit(state.copyWith(
            hiveId: () => hive.id,
            name: () => hive.name,
            selectedApiary: () => selectedApiary,
            hiveType: () => selectedHiveType,
            status: () => hive.status,
            acquisitionDate: () => hive.acquisitionDate,
            color: () => hive.color,
            broodFrameCount: () => hive.broodFrameCount ?? 0,
            honeyFrameCount: () => hive.honeyFrameCount ?? 0,
            boxCount: () => hive.boxCount ?? 0,
            superBoxCount: () => hive.superBoxCount ?? 0,
            formStatus: () => EditHiveStatus.loaded,
            availableApiaries: () => apiaries,
            availableQueens: () => selectedQueen != null ? [selectedQueen, ...queens] : queens,
            availableHiveTypes: () => hiveTypes,
            hasFrames: () => hive.hasFrames,
            framesPerBox: () => hive.framesPerBox,
            frameStandard: () => hive.frameStandard,
            queen: () => selectedQueen,
            hiveCost: () => hive.cost ?? 0.0,
            imageUrl: () => hive.imageUrl,
            accessories: () => HiveAccessoryHelper.stringListToAccessories(hive.accessories),
          ));
        } else {
          emit(state.copyWith(
            errorMessage: () => 'Hive not found',
            formStatus: () => EditHiveStatus.failure,
          ));
        }
      } else {
        emit(state.copyWith(
          hiveId: () => null,
          formStatus: () => EditHiveStatus.loaded,
          availableApiaries: () => apiaries,
          availableQueens: () => queens,
          availableHiveTypes: () => hiveTypes,
          broodFrameCount: () => 0,
          honeyFrameCount: () => 0,
          boxCount: () => 0,
          superBoxCount: () => 0,
          hasFrames: () => null,
          framesPerBox: () => null,
          frameStandard: () => null,
          accessories: () => [],
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
    final hiveTypeAccessories = HiveAccessoryHelper.stringListToAccessories(event.hiveType.accessories);
    emit(state.copyWith(
      hiveType: () => event.hiveType,
      hasFrames: () => event.hiveType.hasFrames,
      framesPerBox: () => event.hiveType.framesPerBox,
      frameStandard: () => event.hiveType.frameStandard,
      honeyFrameCount: () => 10,
      hiveCost: () => event.hiveType.cost ?? 0.0,
      accessories: () => hiveTypeAccessories,
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
    emit(state.copyWith(honeyFrameCount: () => event.count));
  }

  FutureOr<void> _onBroodFrameCountChanged(EditHiveBroodFrameCountChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(broodFrameCount: () => event.count));
  }

  FutureOr<void> _onBroodBoxCountChanged(EditHiveBroodBoxCountChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(boxCount: () => event.count));
  }

  FutureOr<void> _onHoneySuperBoxCountChanged(EditHiveHoneySuperBoxCountChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(superBoxCount: () => event.count));
  }

  FutureOr<void> _onSubmitted(EditHiveSubmitted event, Emitter<EditHiveState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(showValidationErrors: () => true));
      return;
    }
    emit(state.copyWith(formStatus: () => EditHiveStatus.submitting));
    try {
      Hive savedHive;
      bool isCreation = state.hiveId == null || state.hiveId?.isEmpty == true;
      if (isCreation) {
        savedHive = await _hiveService.createHive(
          name: state.name,
          apiaryId: state.selectedApiary?.id,
          hiveTypeId: state.hiveType!.id,
          acquisitionDate: state.acquisitionDate,
          status: state.status,
          color: state.color,
          imageUrl: state.imageUrl,
          cost: state.hiveCost,
          queenId: state.queen?.id,
          broodFrameCount: state.broodFrameCount,
          honeyFrameCount: state.honeyFrameCount,
          boxCount: state.boxCount,
          superBoxCount: state.superBoxCount,
          framesPerBox: state.framesPerBox,
          accessories: HiveAccessoryHelper.accessoriesToStringList(state.accessories),
        );
      } else {
        final existingHive = await _hiveService.getHiveById(state.hiveId!);
        if (existingHive != null) {
          final updatedHive = existingHive.copyWith(
            name: () => state.name,
            status: () => state.status,
            color: () => state.color,
            cost: () => state.hiveCost,
            broodFrameCount: () => state.broodFrameCount,
            honeyFrameCount: () => state.honeyFrameCount,
            boxCount: () => state.boxCount,
            superBoxCount: () => state.superBoxCount,
            queenId: () => state.queen?.id,
            hiveTypeId: () => state.hiveType!.id,
            apiaryId: () => state.selectedApiary?.id,
            acquisitionDate: () => state.acquisitionDate,
            hasFrames: () => state.hasFrames ?? false,
            framesPerBox: () => state.framesPerBox,
            frameStandard: () => state.frameStandard,
            imageUrl: () => state.imageUrl,
            accessories: () => HiveAccessoryHelper.accessoriesToStringList(state.accessories),
          );
          savedHive = await _hiveService.updateHive(updatedHive);
        } else {
          throw Exception('Hive not found');
        }
      }
      
      emit(state.copyWith(
        formStatus: () => EditHiveStatus.success,
        savedHive: () => savedHive,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to save hive: ${e.toString()}',
        formStatus: () => EditHiveStatus.failure,
      ));
    }
  }

  FutureOr<void> _onToggleStarHiveType(EditHiveToggleStarHiveType event, Emitter<EditHiveState> emit) async {
    try {
      await _hiveService.toggleHiveTypeStar(event.hiveType.id);
      final updatedHiveTypes = state.availableHiveTypes.map((hiveType) {
        if (hiveType.id == event.hiveType.id) {
          return hiveType.copyWith(isStarred: () => !hiveType.isStarred);
        }
        return hiveType;
      }).toList();
      emit(state.copyWith(
        availableHiveTypes: () => updatedHiveTypes,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to toggle star: ${e.toString()}',
        formStatus: () => EditHiveStatus.loaded,
      ));
    }
  }

  FutureOr<void> _onAddNewHiveType(EditHiveAddNewHiveType event, Emitter<EditHiveState> emit) async {
    try {
      final createdHiveType = await _hiveService.createHiveType(
        name: event.hiveType.name,
        manufacturer: event.hiveType.manufacturer,
        material: event.hiveType.material,
        hasFrames: event.hiveType.hasFrames,
        broodFrameCount: event.hiveType.broodFrameCount,
        honeyFrameCount: event.hiveType.honeyFrameCount,
        frameStandard: event.hiveType.frameStandard,
        boxCount: event.hiveType.boxCount,
        superBoxCount: event.hiveType.superBoxCount,
        framesPerBox: event.hiveType.framesPerBox,
        accessories: event.hiveType.accessories,
        country: event.hiveType.country,
        cost: event.hiveType.cost,
      );
      final updatedHiveTypes = [...state.availableHiveTypes, createdHiveType];
      emit(state.copyWith(
        availableHiveTypes: () => updatedHiveTypes,
        hiveType: () => createdHiveType,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: () => 'Failed to create hive type: ${e.toString()}',
        formStatus: () => EditHiveStatus.loaded,
      ));
    }
  }

  FutureOr<void> _onEditHiveCreateQueen(EditHiveCreateQueen event, Emitter<EditHiveState> emit) async {
    final updatedQueens = [...state.availableQueens, event.queen];
    emit(state.copyWith(
      availableQueens: () => updatedQueens,
      queen: () => event.queen,
    ));
  }

  FutureOr<void> _onUpdateQueen(EditHiveUpdateQueen event, Emitter<EditHiveState> emit) async {
    final updatedQueens = state.availableQueens.map((queen) => 
      queen.id == event.queen.id ? event.queen : queen).toList();
    emit(state.copyWith(
      queen: () => event.queen,
      availableQueens: () => updatedQueens,
    ));
  }

  FutureOr<void> _onGenerateName(EditHiveGenerateName event, Emitter<EditHiveState> emit) async {
    try {
      final nameService = getIt<NameGeneratorService>();
      final generatedName = await nameService.generateBeehiveName();
      emit(state.copyWith(name: () => generatedName));
    } catch (e) {
      final fallbackName = "Hive ${DateTime.now().millisecondsSinceEpoch % 1000}";
      emit(state.copyWith(name: () => fallbackName));
    }
  }

  FutureOr<void> _onAccessoriesChanged(EditHiveAccessoriesChanged event, Emitter<EditHiveState> emit) {
    emit(state.copyWith(accessories: () => event.accessories));
  }
}