import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../shared/services/services.dart';
import '../../../shared/utils/shared_prefs_helper.dart';
import '../../../shared/utils/language_models.dart';

part 'vc_event.dart';
part 'vc_state.dart';

class VcBloc extends Bloc<VcEvent, VcState> {
  final VcService _vcService;
  final UserService _userService;
  bool _downloadCancelled = false;
  
  VcBloc({
    required VcService vcService,
    required UserService userService,
  }) : _vcService = vcService,
       _userService = userService,
       super(VcInitial()) {
    
    on<CheckVcModelStatus>(_onCheckVcModelStatus);
    on<DownloadVcModel>(_onDownloadVcModel);
    on<SetVcLanguage>(_onSetVcLanguage);
    on<CancelDownload>(_onCancelDownload);
    on<DisposeVcService>(_onDisposeVcService);
  }
  
  void _onCheckVcModelStatus(CheckVcModelStatus event, Emitter<VcState> emit) async {
    emit(state.copyWith(status: VcModelStatus.checking));
    
    final savedModelId = SharedPrefsHelper.getVcModel();
    final currentLanguage = _userService.language;
    
    if (savedModelId.isEmpty) {
      // No model set yet
      final availableModels = langaugeModels();
      
      // Find matching model for current language
      Map<String, String>? matchingModel;
      for (final model in availableModels) {
        if (model['language']?.substring(0, 2) == currentLanguage) {
          matchingModel = model;
          break;
        }
      }
      
      emit(state.copyWith(
        status: VcModelStatus.notSet,
        currentLanguage: currentLanguage,
        selectedModel: matchingModel,
        wasDownloading: false,
      ));
    } else {
      // Model already set
      emit(state.copyWith(
        status: VcModelStatus.ready,
        currentLanguage: currentLanguage,
        wasDownloading: false,
      ));
    }
  }
  
  void _onDownloadVcModel(DownloadVcModel event, Emitter<VcState> emit) async {
    emit(state.copyWith(
      status: VcModelStatus.downloading,
      selectedModel: event.modelInfo,
      downloadStatus: 'Starting download...',
    ));
    
    _downloadCancelled = false;
    
    try {
      final success = await _vcService.initialize(
        modelUrl: event.modelInfo['url'] ?? '',
        modelId: event.modelInfo['id'] ?? '',
        onModelStatusChange: (status) {
          emit(state.copyWith(downloadStatus: status));
          
          // Check if download was cancelled
          if (_downloadCancelled) {
            throw Exception('Download cancelled');
          }
        },
        language: event.modelInfo['ttsLanguage'] ?? 'en-US',
      );
      
      if (_downloadCancelled) {
        emit(state.copyWith(
          status: VcModelStatus.notSet,
          errorMessage: 'Download cancelled',
          wasDownloading: false,
        ));
        return;
      }
      
      if (success) {
        emit(state.copyWith(
          status: VcModelStatus.ready,
          downloadStatus: 'Download complete!',
          wasDownloading: true,
        ));
      } else {
        emit(state.copyWith(
          status: VcModelStatus.error,
          errorMessage: 'Failed to initialize model',
          wasDownloading: false,
        ));
      }
    } catch (e) {
      if (_downloadCancelled) {
        emit(state.copyWith(
          status: VcModelStatus.notSet,
          errorMessage: 'Download cancelled',
          wasDownloading: false,
        ));
      } else {
        emit(state.copyWith(
          status: VcModelStatus.error,
          errorMessage: e.toString(),
          wasDownloading: false,
        ));
      }
    }
  }
  
  void _onSetVcLanguage(SetVcLanguage event, Emitter<VcState> emit) {
    final availableModels = langaugeModels();
    
    // Find matching model for selected language
    Map<String, String>? matchingModel;
    for (final model in availableModels) {
      if (model['language']?.substring(0, 2) == event.language) {
        matchingModel = model;
        break;
      }
    }
    
    emit(state.copyWith(
      currentLanguage: event.language,
      selectedModel: matchingModel,
    ));
  }
  
  void _onCancelDownload(CancelDownload event, Emitter<VcState> emit) {
    _downloadCancelled = true;
    emit(state.copyWith(
      status: VcModelStatus.notSet,
    ));
  }
  
  void _onDisposeVcService(DisposeVcService event, Emitter<VcState> emit) async {
    await _vcService.dispose();
    emit(state.copyWith(status: VcModelStatus.disposed));
  }
  
  @override
  Future<void> close() {
    // Clean up resources when bloc is closed
    _vcService.dispose();
    return super.close();
  }
}
