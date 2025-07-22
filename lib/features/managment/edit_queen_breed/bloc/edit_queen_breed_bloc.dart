import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_queen_breed/bloc/edit_queen_breed_event.dart';
import 'package:apiarium/features/managment/edit_queen_breed/bloc/edit_queen_breed_state.dart';
import 'package:apiarium/shared/shared.dart';

class EditQueenBreedBloc extends Bloc<EditQueenBreedEvent, EditQueenBreedState> {
  final QueenService _queenService;
  final UserRepository _userRepository;
  
  EditQueenBreedBloc({
    required QueenService queenService,
    required UserRepository userRepository,
  }) : 
    _queenService = queenService,
    _userRepository = userRepository,
    super(const EditQueenBreedState()) {
    on<EditQueenBreedLoadData>(_onLoadData);
    on<EditQueenBreedNameChanged>(_onNameChanged);
    on<EditQueenBreedScientificNameChanged>(_onScientificNameChanged);
    on<EditQueenBreedOriginChanged>(_onOriginChanged);
    on<EditQueenBreedCountryChanged>(_onCountryChanged);
    on<EditQueenBreedTemperamentRatingChanged>(_onTemperamentRatingChanged);
    on<EditQueenBreedHoneyProductionRatingChanged>(_onHoneyProductionRatingChanged);
    on<EditQueenBreedWinterHardinessRatingChanged>(_onWinterHardinessRatingChanged);
    on<EditQueenBreedDiseaseResistanceRatingChanged>(_onDiseaseResistanceRatingChanged);
    on<EditQueenBreedPopularityRatingChanged>(_onPopularityRatingChanged);
    on<EditQueenBreedCharacteristicsChanged>(_onCharacteristicsChanged);
    on<EditQueenBreedCostChanged>(_onCostChanged);
    on<EditQueenBreedToggleStarred>(_onToggleStarred);
    on<EditQueenBreedImageChanged>(_onImageChanged);
    on<EditQueenBreedImageDeleted>(_onImageDeleted);
    on<EditQueenBreedSubmitted>(_onSubmitted);
    on<EditQueenBreedResetValidation>(_onResetValidation);
  }

  Future<void> _onLoadData(
    EditQueenBreedLoadData event,
    Emitter<EditQueenBreedState> emit,
  ) async {
    emit(state.copyWith(status: EditQueenBreedStatus.loading));
    
    try {
      final userCountry = _userRepository.currentUser?.country ?? '';
      
      if (event.breedId != null) {
        final breeds = await _queenService.getAllQueenBreeds();
        final breed = breeds.firstWhere((b) => b.id == event.breedId);
        
        String? imagePath;
        if (breed.imageName != null) {
          imagePath = await breed.getLocalImagePath();
        }
        
        emit(state.copyWith(
          status: EditQueenBreedStatus.loaded,
          breedId: breed.id,
          name: breed.name,
          scientificName: breed.scientificName ?? '',
          origin: breed.origin ?? '',
          country: breed.country ?? userCountry,
          isStarred: breed.isStarred,
          isLocal: breed.isLocal,
          temperamentRating: breed.temperamentRating ?? 0,
          honeyProductionRating: breed.honeyProductionRating ?? 0,
          winterHardinessRating: breed.winterHardinessRating ?? 0,
          diseaseResistanceRating: breed.diseaseResistanceRating ?? 0,
          popularityRating: breed.popularityRating ?? 0,
          characteristics: breed.characteristics ?? '',
          cost: () => breed.cost,
          imageName: () => imagePath,
        ));
      } else {
        emit(state.copyWith(
          status: EditQueenBreedStatus.loaded,
          country: userCountry,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EditQueenBreedStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  void _onCostChanged(EditQueenBreedCostChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(cost: () => event.cost));
  }

  void _onToggleStarred(EditQueenBreedToggleStarred event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(isStarred: !state.isStarred));
  }

  void _onImageChanged(EditQueenBreedImageChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(imageName: () => event.imagePath));
  }

  void _onImageDeleted(EditQueenBreedImageDeleted event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(imageName: () => null));
  }

  void _onNameChanged(EditQueenBreedNameChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onScientificNameChanged(EditQueenBreedScientificNameChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(scientificName: event.scientificName));
  }

  void _onOriginChanged(EditQueenBreedOriginChanged event, Emitter<EditQueenBreedState> emit) {
    String? autoCountry;
    final origin = event.origin.toLowerCase();
    
    // Auto-set country based on common origins
    if (origin.contains('italy') || origin.contains('włochy')) {
      autoCountry = 'IT';
    } else if (origin.contains('slovenia') || origin.contains('słowenia')) {
      autoCountry = 'SI';
    } else if (origin.contains('poland') || origin.contains('polska')) {
      autoCountry = 'PL';
    } else if (origin.contains('germany') || origin.contains('niemcy')) {
      autoCountry = 'DE';
    } else if (origin.contains('france') || origin.contains('francja')) {
      autoCountry = 'FR';
    } else if (origin.contains('spain') || origin.contains('hiszpania')) {
      autoCountry = 'ES';
    }
    
    emit(state.copyWith(
      origin: event.origin,
      country: autoCountry ?? state.country,
    ));
  }

  void _onCountryChanged(EditQueenBreedCountryChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(country: event.country));
  }

  void _onTemperamentRatingChanged(EditQueenBreedTemperamentRatingChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(temperamentRating: event.rating));
  }

  void _onHoneyProductionRatingChanged(EditQueenBreedHoneyProductionRatingChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(honeyProductionRating: event.rating));
  }

  void _onWinterHardinessRatingChanged(EditQueenBreedWinterHardinessRatingChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(winterHardinessRating: event.rating));
  }
  void _onDiseaseResistanceRatingChanged(EditQueenBreedDiseaseResistanceRatingChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(diseaseResistanceRating: event.rating));
  }

  void _onPopularityRatingChanged(EditQueenBreedPopularityRatingChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(popularityRating: event.rating));
  }
  void _onCharacteristicsChanged(EditQueenBreedCharacteristicsChanged event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(characteristics: event.characteristics));
  }

  void _onResetValidation(EditQueenBreedResetValidation event, Emitter<EditQueenBreedState> emit) {
    emit(state.copyWith(hasTriedSubmit: false));
  }

  Future<void> _onSubmitted(
    EditQueenBreedSubmitted event,
    Emitter<EditQueenBreedState> emit,
  ) async {
    emit(state.copyWith(hasTriedSubmit: true));
    
    if (!state.isValid) {
      emit(state.copyWith(
        status: EditQueenBreedStatus.error,
        errorMessage: () => 'Breed name is required', // Use plain English text that will be translated in the view
      ));
      return;
    }
    
    emit(state.copyWith(status: EditQueenBreedStatus.saving));
    
    try {
      if (state.isCreating) {
        await _queenService.createQueenBreed(
          name: state.name.trim(),
          scientificName: state.scientificName.trim().isEmpty ? null : state.scientificName.trim(),
          origin: state.origin.trim().isEmpty ? null : state.origin.trim(),
          country: state.country.trim().isEmpty ? null : state.country.trim(),
          isStarred: state.isStarred,
          isLocal: state.isLocal,
          temperamentRating: state.temperamentRating,
          honeyProductionRating: state.honeyProductionRating,
          winterHardinessRating: state.winterHardinessRating,
          diseaseResistanceRating: state.diseaseResistanceRating,
          popularityRating: state.popularityRating,
          characteristics: state.characteristics.trim().isEmpty ? null : state.characteristics.trim(),
          cost: state.cost,
          imageName: state.imageName,
        );
      } else {
        final breeds = await _queenService.getAllQueenBreeds();
        final existingBreed = breeds.firstWhere((b) => b.id == state.breedId);
        
        final updatedBreed = existingBreed.copyWith(
          name: () => state.name.trim(),
          scientificName: () => state.scientificName.trim().isEmpty ? null : state.scientificName.trim(),
          origin: () => state.origin.trim().isEmpty ? null : state.origin.trim(),
          country: () => state.country.trim().isEmpty ? null : state.country.trim(),
          isStarred: () => state.isStarred,
          isLocal: () => state.isLocal,
          temperamentRating: () => state.temperamentRating,
          honeyProductionRating: () => state.honeyProductionRating,
          winterHardinessRating: () => state.winterHardinessRating,
          diseaseResistanceRating: () => state.diseaseResistanceRating,
          popularityRating: () => state.popularityRating,
          characteristics: () => state.characteristics.trim().isEmpty ? null : state.characteristics.trim(),
          cost: () => state.cost,
          imageName: () => state.imageName,
        );
        
        await _queenService.updateQueenBreed(updatedBreed);
      }
      
      emit(state.copyWith(status: EditQueenBreedStatus.saved));
    } catch (e) {
      emit(state.copyWith(
        status: EditQueenBreedStatus.error,
        errorMessage: () => 'Failed to save breed: ${e.toString()}',
      ));
    }
  }
}