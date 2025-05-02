import '../utils/logger.dart';
import '../services/services.dart';

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
  Future<bool> initialize({
    required String modelUrl,
    required String modelId,
    Function(String status)? onModelStatusChange,
    String language = 'pl-PL',
  }) async {
    if (_isInitialized) return true;
    
    try {
      // Initialize TTS
      final ttsInitialized = await _ttsService.initialize(
        language: language,
      );
      
      if (!ttsInitialized) {
        Logger.e('Failed to initialize TTS service', tag: _tag);
        return false;
      }
      
      // Initialize VOSK
      await _voskService.initialize(
        modelUrl: modelUrl,
        modelId: modelId,
        onModelStatusChange: onModelStatusChange,
        enablePartialResults: true,
      );
      
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
