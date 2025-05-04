import '../utils/logger.dart';
import '../services/services.dart';
import '../utils/shared_prefs_helper.dart';
import '../utils/language_models.dart';

/// Service for voice control functionality, combining speech recognition and text-to-speech
class VcService {
  final TtsService _ttsService;
  final VoskService _voskService;
  final UserService _userService;
  static const String _tag = 'VcService';
  
  bool _isInitialized = false;
  bool _isListening = false;
  
  /// Whether the voice control service has been initialized
  bool get isInitialized => _isInitialized;
  
  /// Whether the service is currently listening for voice commands
  bool get isListening => _isListening;

  VcService({
    required TtsService ttsService,
    required VoskService voskService,
    required UserService userService
  }) : _ttsService = ttsService, 
       _voskService = voskService,
       _userService = userService;

  /// Initialize both TTS and VOSK services
  /// If modelUrl, modelId, or language are not provided, they will be retrieved from SharedPreferences
  Future<bool> initialize({
    String? modelUrl,
    String? modelId,
    String? language,
    Function(String status)? onModelStatusChange,
  }) async {
    if (_isInitialized) return true;
    
    try {
      // If model details aren't provided, get them from SharedPreferences
      String finalModelId = modelId ?? SharedPrefsHelper.getVcModel();
      String finalModelUrl = modelUrl ?? '';
      String finalLanguage = language ?? 'en-US';
      
      // If we only have the modelId but not the URL or language, look up the complete model info
      if (finalModelId.isNotEmpty && (finalModelUrl.isEmpty || language == null)) {
        final models = langaugeModels();
        for (final model in models) {
          if (model['id'] == finalModelId) {
            finalModelUrl = modelUrl ?? model['url'] ?? '';
            finalLanguage = language ?? model['ttsLanguage'] ?? 'en-US';
            break;
          }
        }
      }
      
      // Check if we have the required information
      if (finalModelId.isEmpty || finalModelUrl.isEmpty) {
        Logger.e('Model ID or URL not found', tag: _tag);
        return false;
      }
      
      // Initialize TTS
      final ttsInitialized = await _ttsService.initialize(
        language: finalLanguage,
      );
      
      if (!ttsInitialized) {
        Logger.e('Failed to initialize TTS service', tag: _tag);
        return false;
      }
      
      // Initialize VOSK
      await _voskService.initialize(
        modelUrl: finalModelUrl,
        modelId: finalModelId,
        onModelStatusChange: onModelStatusChange,
        enablePartialResults: true,
      );
      
      // Save model ID to shared preferences
      await SharedPrefsHelper.setVcModel(finalModelId);
      Logger.d('Voice model ID saved to preferences: $finalModelId', tag: _tag);
      
      // Setup command handler to repeat speech
      _voskService.setResultHandler(_handleRecognitionResult);
      
      _isInitialized = true;
      Logger.i('Voice control service initialized', tag: _tag);
      return true;
    } catch (e) {
      Logger.e('Failed to initialize voice control service', tag: _tag, error: e);
      return false;
    }
  }

  /// Handle speech recognition result
  void _handleRecognitionResult(String resultText) {
    Logger.d('Recognition result: $resultText', tag: _tag);
    // Further processing can be added here
  }

  /// Set a custom result handler
  void setResultHandler(Function(String result) handler) {
    _voskService.setResultHandler(handler);
  }

  /// Reset to default result handler
  void resetResultHandler() {
    _voskService.setResultHandler(_handleRecognitionResult);
  }

  /// Start listening for voice commands
  Future<bool> startListening({Function(String error)? onError}) async {
    if (!_isInitialized) {
      Logger.e('Voice control service not initialized', tag: _tag);
      return false;
    }
    
    try {
      await _voskService.startListening(onError: onError);
      _isListening = true;
      Logger.i('Started listening for voice commands', tag: _tag);
      return true;
    } catch (e) {
      Logger.e('Failed to start listening', tag: _tag, error: e);
      return false;
    }
  }

  /// Stop listening for voice commands
  Future<bool> stopListening() async {
    if (!_isInitialized || !_isListening) return true;
    
    try {
      await _voskService.stopListening();
      _isListening = false;
      Logger.i('Stopped listening for voice commands', tag: _tag);
      return true;
    } catch (e) {
      Logger.e('Failed to stop listening', tag: _tag, error: e);
      return false;
    }
  }

  /// Repeat the given text using text-to-speech
  Future<bool> repeatText(String text) async {
    if (!_isInitialized || text.isEmpty) return false;
    
    try {
      return await _ttsService.speak(text);
    } catch (e) {
      Logger.e('Failed to repeat text', tag: _tag, error: e);
      return false;
    }
  }

  /// Automatically repeat what the user says (echo)
  Future<bool> enableEchoMode({bool enable = true}) async {
    if (!_isInitialized) {
      Logger.e('Voice control service not initialized', tag: _tag);
      return false;
    }
    
    try {
      if (enable) {
        // Set up handler to speak recognized text
        _voskService.setResultHandler((text) {
          if (text.isNotEmpty) {
            Logger.d('Echo mode repeating: $text', tag: _tag);
            _ttsService.speak(text);
          }
        });
        
        Logger.i('Echo mode enabled', tag: _tag);
      } else {
        // Reset to default handler
        _voskService.setResultHandler(_handleRecognitionResult);
        Logger.i('Echo mode disabled', tag: _tag);
      }
      
      return true;
    } catch (e) {
      Logger.e('Failed to configure echo mode', tag: _tag, error: e);
      return false;
    }
  }

  /// Dispose both services
  Future<void> dispose() async {
    try {
      await stopListening();
      await _voskService.dispose();
      await _ttsService.dispose();
      _isInitialized = false;
      _isListening = false;
      Logger.i('Voice control service disposed', tag: _tag);
    } catch (e) {
      Logger.e('Error disposing voice control service', tag: _tag, error: e);
    }
  }
}
