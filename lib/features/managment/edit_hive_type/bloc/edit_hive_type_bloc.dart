import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

part 'edit_hive_type_event.dart';
part 'edit_hive_type_state.dart';

class EditHiveTypeBloc extends Bloc<EditHiveTypeEvent, EditHiveTypeState> {
  final HiveService _hiveService;

  EditHiveTypeBloc({
    required HiveService hiveService,
    String? hiveTypeId,
  }) : _hiveService = hiveService,
       super(const EditHiveTypeState()) {
    on<EditHiveTypeLoadData>(_onLoadData);
    on<EditHiveTypeNameChanged>(_onNameChanged);
    on<EditHiveTypeManufacturerChanged>(_onManufacturerChanged);
    on<EditHiveTypeMaterialChanged>(_onMaterialChanged);
    on<EditHiveTypeHasFramesChanged>(_onHasFramesChanged);
    on<EditHiveTypeFrameStandardChanged>(_onFrameStandardChanged);
    on<EditHiveTypeFramesPerBoxChanged>(_onFramesPerBoxChanged);
    on<EditHiveTypeBroodFrameCountChanged>(_onBroodFrameCountChanged);
    on<EditHiveTypeHoneyFrameCountChanged>(_onHoneyFrameCountChanged);
    on<EditHiveTypeBoxCountChanged>(_onBoxCountChanged);
    on<EditHiveTypeSuperBoxCountChanged>(_onSuperBoxCountChanged);
    on<EditHiveTypeCostChanged>(_onCostChanged);
    on<EditHiveTypeIconChanged>(_onIconChanged);
    on<EditHiveTypeImageChanged>(_onImageChanged);
    on<EditHiveTypeImageDeleted>(_onImageDeleted);
    on<EditHiveTypeToggleStarred>(_onToggleStarred);
    on<EditHiveTypeSubmitted>(_onSubmitted);

    add(EditHiveTypeLoadData(hiveTypeId: hiveTypeId));
  }

  Future<void> _onLoadData(EditHiveTypeLoadData event, Emitter<EditHiveTypeState> emit) async {
    emit(state.copyWith(status: () => EditHiveTypeStatus.loading));

    try {
      if (event.hiveTypeId != null) {
        final hiveType = await _hiveService.getHiveTypeById(event.hiveTypeId!);
        if (hiveType != null) {
          String? imagePath;
          if (hiveType.imageName != null) {
            imagePath = await hiveType.getLocalImagePath();
          }

          emit(state.copyWith(
            status: () => EditHiveTypeStatus.loaded,
            id: () => hiveType.id,
            name: () => hiveType.name,
            manufacturer: () => hiveType.manufacturer,
            material: () => hiveType.material,
            hasFrames: () => hiveType.hasFrames,
            broodFrameCount: () => hiveType.broodFrameCount,
            honeyFrameCount: () => hiveType.honeyFrameCount,
            frameStandard: () => hiveType.frameStandard,
            boxCount: () => hiveType.boxCount,
            superBoxCount: () => hiveType.superBoxCount,
            framesPerBox: () => hiveType.framesPerBox,
            maxBroodFrameCount: () => hiveType.maxBroodFrameCount,
            maxHoneyFrameCount: () => hiveType.maxHoneyFrameCount,
            maxBoxCount: () => hiveType.maxBoxCount,
            maxSuperBoxCount: () => hiveType.maxSuperBoxCount,
            accessories: () => hiveType.accessories,
            country: () => hiveType.country,
            isLocal: () => hiveType.isLocal,
            isStarred: () => hiveType.isStarred,
            cost: () => hiveType.cost,
            imageName: () => imagePath,
            icon: () => hiveType.icon,
          ));
        } else {
          emit(state.copyWith(
            status: () => EditHiveTypeStatus.failure,
            errorMessage: () => 'Hive type not found',
          ));
        }
      } else {
        emit(state.copyWith(
          status: () => EditHiveTypeStatus.loaded,
          name: () => 'New Hive Type',
          isStarred: () => false, // Don't auto-star new hive types
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: () => EditHiveTypeStatus.failure,
        errorMessage: () => 'Failed to load data: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSubmitted(EditHiveTypeSubmitted event, Emitter<EditHiveTypeState> emit) async {
    if (!state.isValid) {
      emit(state.copyWith(
        showValidationErrors: () => true,
        errorMessage: () => state.validationErrors.join('\n'),
      ));
      return;
    }

    emit(state.copyWith(status: () => EditHiveTypeStatus.submitting));

    try {
      HiveType hiveType;

      if (state.id == null || state.id!.isEmpty) {
        hiveType = await _hiveService.createHiveType(
          name: state.name,
          manufacturer: state.manufacturer,
          material: state.material,
          hasFrames: state.hasFrames,
          broodFrameCount: state.broodFrameCount,
          honeyFrameCount: state.honeyFrameCount,
          frameStandard: state.frameStandard,
          boxCount: state.boxCount,
          superBoxCount: state.superBoxCount,
          framesPerBox: state.framesPerBox,
          maxBroodFrameCount: state.maxBroodFrameCount,
          maxHoneyFrameCount: state.maxHoneyFrameCount,
          maxBoxCount: state.maxBoxCount,
          maxSuperBoxCount: state.maxSuperBoxCount,
          accessories: state.accessories,
          country: state.country,
          isLocal: state.isLocal,
          cost: state.cost,
          imageName: state.imageName,
          icon: state.icon,
        );
        
        // Set the star after creation if it's starred
        if (state.isStarred) {
          await _hiveService.toggleHiveTypeStar(hiveType.id);
          hiveType = hiveType.copyWith(isStarred: () => true);
        }
      } else {
        final existingHiveType = await _hiveService.getHiveTypeById(state.id!);
        if (existingHiveType != null) {
          hiveType = existingHiveType.copyWith(
            name: () => state.name,
            manufacturer: () => state.manufacturer,
            material: () => state.material,
            hasFrames: () => state.hasFrames,
            broodFrameCount: () => state.broodFrameCount,
            honeyFrameCount: () => state.honeyFrameCount,
            frameStandard: () => state.frameStandard,
            boxCount: () => state.boxCount,
            superBoxCount: () => state.superBoxCount,
            framesPerBox: () => state.framesPerBox,
            maxBroodFrameCount: () => state.maxBroodFrameCount,
            maxHoneyFrameCount: () => state.maxHoneyFrameCount,
            maxBoxCount: () => state.maxBoxCount,
            maxSuperBoxCount: () => state.maxSuperBoxCount,
            accessories: () => state.accessories,
            country: () => state.country,
            cost: () => state.cost,
            imageName: () => state.imageName,
            isStarred: () => state.isStarred,
            icon: () => state.icon,
          );
          hiveType = await _hiveService.updateHiveType(hiveType);
        } else {
          throw Exception('Hive type not found');
        }
      }

      emit(state.copyWith(
        status: () => EditHiveTypeStatus.success,
        hiveType: () => hiveType,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: () => EditHiveTypeStatus.failure,
        errorMessage: () => 'Failed to save hive type: ${e.toString()}',
      ));
    }
  }

  void _onToggleStarred(EditHiveTypeToggleStarred event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(isStarred: () => !state.isStarred));
  }

  void _onNameChanged(EditHiveTypeNameChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(name: () => event.name));
  }

  void _onManufacturerChanged(EditHiveTypeManufacturerChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(manufacturer: () => event.manufacturer));
  }

  void _onMaterialChanged(EditHiveTypeMaterialChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(material: () => event.material));
  }

  void _onHasFramesChanged(EditHiveTypeHasFramesChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(hasFrames: () => event.hasFrames));
  }

  void _onFrameStandardChanged(EditHiveTypeFrameStandardChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(frameStandard: () => event.frameStandard));
  }

  void _onFramesPerBoxChanged(EditHiveTypeFramesPerBoxChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(framesPerBox: () => event.framesPerBox));
  }

  void _onBroodFrameCountChanged(EditHiveTypeBroodFrameCountChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(broodFrameCount: () => event.count));
  }

  void _onHoneyFrameCountChanged(EditHiveTypeHoneyFrameCountChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(honeyFrameCount: () => event.count));
  }

  void _onBoxCountChanged(EditHiveTypeBoxCountChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(boxCount: () => event.count));
  }

  void _onSuperBoxCountChanged(EditHiveTypeSuperBoxCountChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(superBoxCount: () => event.count));
  }

  void _onCostChanged(EditHiveTypeCostChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(cost: () => event.cost));
  }

  void _onIconChanged(EditHiveTypeIconChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(icon: () => event.icon));
  }

  void _onImageChanged(EditHiveTypeImageChanged event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(imageName: () => event.imagePath));
  }

  void _onImageDeleted(EditHiveTypeImageDeleted event, Emitter<EditHiveTypeState> emit) {
    emit(state.copyWith(imageName: () => null));
  }
}