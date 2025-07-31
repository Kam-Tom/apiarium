import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:apiarium/core/di/dependency_injection.dart';

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
    String? queenId,
    bool hideLocation = false,
    bool fromHive = false,
  }) : 
    _queenService = queenService,
    _apiaryService = apiaryService,
    _hiveService = hiveService,
    super(EditQueenState(
      birthDate: DateTime.now(),
      marked: true,
      markColor: _getQueenMarkColorByYear(DateTime.now().year),
      isCreatedFromHive: fromHive,
      shouldShowLocation: !hideLocation,
    )) {
    on<EditQueenLoadData>(_onLoad);
    on<EditQueenNameChanged>(_onNameChanged);
    on<EditQueenBreedChanged>(_onBreedChanged);
    on<EditQueenBirthDateChanged>(_onBirthDateChanged);
    on<EditQueenSourceChanged>(_onSourceChanged);
    on<EditQueenMarkedChanged>(_onMarkedChanged);
    on<EditQueenMarkColorChanged>(_onMarkColorChanged);
    on<EditQueenStatusChanged>(_onStatusChanged);
    on<EditQueenOriginChanged>(_onOriginChanged);
    on<EditQueenApiaryChanged>(_onApiaryChanged);
    on<EditQueenHiveChanged>(_onHiveChanged);
    on<EditQueenGenerateName>(_onGenerateName);
    on<EditQueenSubmitted>(_onSubmitted);
    
    if (queenId != null) {
      add(EditQueenLoadData(queenId: queenId));
    } else {
      add(EditQueenLoadData());
    }
  }

  Future<void> _onLoad(EditQueenLoadData event, Emitter<EditQueenState> emit) async {
    emit(state.copyWith(status: () => EditQueenStatus.loading));

    try {
      final breeds = await _queenService.getAllQueenBreeds();
      final apiaries = await _apiaryService.getAllApiaries();
      final hives = await _hiveService.getAllHives();

      if (event.queenId != null) {
        final queen = await _queenService.getQueenById(event.queenId!);
        if (queen != null) {
          Apiary? selectedApiary;
          Hive? selectedHive;
          QueenBreed? selectedBreed;
          
          if (queen.apiaryId != null) {
            selectedApiary = apiaries.where((a) => a.id == queen.apiaryId).firstOrNull;
          }
          
          if (queen.hiveId != null) {
            selectedHive = hives.where((h) => h.id == queen.hiveId).firstOrNull;
          }
          
          selectedBreed = breeds.where((b) => b.id == queen.breedId).firstOrNull;
          
          emit(state.copyWith(
            id: () => queen.id,
            name: () => queen.name,
            queenBreed: () => selectedBreed,
            queenCost: () => queen.cost ?? selectedBreed?.cost ?? 0.0, // Set cost from queen or breed
            birthDate: () => queen.birthDate,
            source: () => queen.source,
            marked: () => queen.marked,
            markColor: () => queen.markColor,
            queenStatus: () => queen.status,
            origin: () => queen.origin,
            selectedApiary: () => selectedApiary,
            selectedHive: () => selectedHive,
            status: () => EditQueenStatus.loaded,
            availableBreeds: () => breeds,
            availableApiaries: () => apiaries,
            availableHives: () => hives,
            shouldShowLocation: () => true,
          ));
        } else {
          emit(state.copyWith(
            status: () => EditQueenStatus.failure,
            errorMessage: () => 'Queen not found',
          ));
        }
      } else {
        String generatedName;
        try {
          final nameService = getIt<NameGeneratorService>();
          generatedName = await nameService.generateQueenName();
        } catch (_) {
          final queenCount = await _queenService.getAllQueens();
          generatedName = 'Queen ${queenCount.length + 1}';
        }
        emit(state.copyWith(
          name: () => generatedName,
          marked: () => true,
          markColor: () => EditQueenState.getColorForYear(DateTime.now().year),
          queenCost: () => 0.0, // Default cost for new queen
          status: () => EditQueenStatus.loaded,
          availableBreeds: () => breeds,
          availableApiaries: () => apiaries,
          availableHives: () => hives,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: () => EditQueenStatus.failure,
        errorMessage: () => 'Failed to load data: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSubmitted(EditQueenSubmitted event, Emitter<EditQueenState> emit) async {
    if (state.name.trim().isEmpty || state.queenBreed == null) {
      emit(state.copyWith(
        status: () => EditQueenStatus.failure,
        errorMessage: () => 'Please fill in all required fields',
      ));
      return;
    }
    
    emit(state.copyWith(status: () => EditQueenStatus.submitting));
    
    try {
      Queen queen;
      
      if (state.id == null || state.id?.isEmpty == true) {
        // Create new queen with cost from breed
        queen = await _queenService.createQueen(
          name: state.name,
          birthDate: state.birthDate,
          breedId: state.queenBreed!.id,
          source: state.source,
          marked: state.marked,
          markColor: state.markColor,
          status: state.queenStatus,
          origin: state.origin,
          hiveId: !state.isCreatedFromHive ? state.selectedHive?.id : null,
          cost: state.queenCost, // Pass the cost from breed
        );
      } else {
        // Update existing queen
        final existingQueen = await _queenService.getQueenById(state.id!);
        if (existingQueen != null) {
          queen = existingQueen.copyWith(
            name: () => state.name,
            birthDate: () => state.birthDate,
            source: () => state.source,
            marked: () => state.marked,
            markColor: () => state.markColor,
            status: () => state.queenStatus,
            origin: () => state.origin,
            cost: () => state.queenCost, // Update cost
            // Update hive assignment
            hiveId: () => !state.isCreatedFromHive ? state.selectedHive?.id : existingQueen.hiveId,
            hiveName: () => !state.isCreatedFromHive ? state.selectedHive?.name : existingQueen.hiveName,
            apiaryId: () => !state.isCreatedFromHive ? state.selectedHive?.apiaryId : existingQueen.apiaryId,
            apiaryName: () => !state.isCreatedFromHive ? state.selectedHive?.apiaryName : existingQueen.apiaryName,
            apiaryLocation: () => !state.isCreatedFromHive ? state.selectedHive?.apiaryLocation : existingQueen.apiaryLocation,
          );
          queen = await _queenService.updateQueen(queen);
        } else {
          throw Exception('Queen not found');
        }
      }
      
      emit(state.copyWith(
        status: () => EditQueenStatus.success,
        queen: () => queen,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => EditQueenStatus.failure,
        errorMessage: () => 'Failed to save queen: ${e.toString()}',
      ));
    }
  }

  void _onNameChanged(EditQueenNameChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(name: () => event.name));
  }

  void _onBreedChanged(EditQueenBreedChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(
      queenBreed: () => event.breed,
      queenCost: () => event.breed.cost ?? 0.0, // Set cost from breed
    ));
  }

  void _onBirthDateChanged(EditQueenBirthDateChanged event, Emitter<EditQueenState> emit) {
    final markColor = _getQueenMarkColorByYear(event.birthDate.year);
    emit(state.copyWith(
      birthDate: () => event.birthDate,
      marked: () => true,
      markColor: () => markColor,
    ));
  }

  void _onSourceChanged(EditQueenSourceChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(source: () => event.source));
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

  void _onApiaryChanged(EditQueenApiaryChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(
      selectedApiary: () => event.apiary,
      selectedHive: () => null,
    ));
  }

  void _onHiveChanged(EditQueenHiveChanged event, Emitter<EditQueenState> emit) {
    emit(state.copyWith(selectedHive: () => event.hive));
  }

  Future<void> _onGenerateName(EditQueenGenerateName event, Emitter<EditQueenState> emit) async {
    try {
      final nameService = getIt<NameGeneratorService>();
      final generatedName = await nameService.generateQueenName();
      emit(state.copyWith(name: () => generatedName));
    } catch (e) {
      final fallbackName = "Queen ${DateTime.now().millisecondsSinceEpoch % 1000}";
      emit(state.copyWith(name: () => fallbackName));
    }
  }

  static Color _getQueenMarkColorByYear(int year) {
    final lastDigit = year % 10;
    switch (lastDigit) {
      case 1:
      case 6:
        return Colors.white;
      case 2:
      case 7:
        return Colors.yellow;
      case 3:
      case 8:
        return Colors.red;
      case 4:
      case 9:
        return Colors.green;
      case 0:
      case 5:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }
}