import 'package:flutter_tts/flutter_tts.dart';
import '../utils/logger.dart';

/// States for Text-to-Speech engine
enum TtsState { playing, stopped, paused, continued }

/// Service for handling text-to-speech functionality
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  static const String _tag = 'TtsService';
  
  TtsState _ttsState = TtsState.stopped;
  bool _isInitialized = false;

  /// Current state of the TTS engine
  TtsState get state => _ttsState;
  
  /// Whether the TTS service has been initialized
  bool get isInitialized => _isInitialized;
  
  /// Whether the TTS is currently playing speech
  bool get isPlaying => _ttsState == TtsState.playing;

  /// Function to be called when TTS state changes
  Function(TtsState)? onStateChanged;

  /// Initialize the TTS service with configurable settings
  Future<bool> initialize({
    String language = 'en-US',
    double volume = 1.0,
    double pitch = 0.8,
    double rate = 0.5,
  }) async {
    try {
      if (_isInitialized) return true;

      await _flutterTts.awaitSpeakCompletion(true);
      _setupEventHandlers();
      
      await _flutterTts.setVolume(volume);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(rate);
      
      final isLanguageAvailable = await _flutterTts.isLanguageAvailable(language);
      if (isLanguageAvailable) {
        await _flutterTts.setLanguage(language);
      } else {
        Logger.w('Language $language is not available, using system default', tag: _tag);
      }
      
      _isInitialized = true;
      Logger.i('TTS initialized successfully', tag: _tag);
      return true;
    } catch (e) {
      Logger.e('Failed to initialize TTS', tag: _tag, error: e);
      return false;
    }
  }

  void _setupEventHandlers() {
    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
      Logger.d('TTS started', tag: _tag);
      if (onStateChanged != null) onStateChanged!(_ttsState);
    });

    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      Logger.d('TTS completed', tag: _tag);
      if (onStateChanged != null) onStateChanged!(_ttsState);
    });

    _flutterTts.setCancelHandler(() {
      _ttsState = TtsState.stopped;
      Logger.d('TTS cancelled', tag: _tag);
      if (onStateChanged != null) onStateChanged!(_ttsState);
    });

    _flutterTts.setErrorHandler((message) {
      _ttsState = TtsState.stopped;
      Logger.e('TTS error: $message', tag: _tag);
      if (onStateChanged != null) onStateChanged!(_ttsState);
    });

    _flutterTts.setPauseHandler(() {
      _ttsState = TtsState.paused;
      Logger.d('TTS paused', tag: _tag);
      if (onStateChanged != null) onStateChanged!(_ttsState);
    });

    _flutterTts.setContinueHandler(() {
      _ttsState = TtsState.continued;
      Logger.d('TTS continued', tag: _tag);
      if (onStateChanged != null) onStateChanged!(_ttsState);
    });
  }

  /// Speak the provided text
  Future<bool> speak(String text) async {
    if (text.isEmpty) {
      Logger.w('Empty text provided for TTS', tag: _tag);
      return false;
    }
    
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }
    
    try {
      final result = await _flutterTts.speak(text);
      return result == 1;
    } catch (e) {
      Logger.e('Error speaking text', tag: _tag, error: e);
      return false;
    }
  }

  /// Stop the current speech
  Future<bool> stop() async {
    if (!_isInitialized || _ttsState == TtsState.stopped) return true;
    
    try {
      final result = await _flutterTts.stop();
      return result == 1;
    } catch (e) {
      Logger.e('Error stopping TTS', tag: _tag, error: e);
      return false;
    }
  }

  /// Pause the current speech
  Future<bool> pause() async {
    if (!_isInitialized || _ttsState != TtsState.playing) return true;
    
    try {
      final result = await _flutterTts.pause();
      return result == 1;
    } catch (e) {
      Logger.e('Error pausing TTS', tag: _tag, error: e);
      return false;
    }
  }

  /// Set the language for speech
  Future<bool> setLanguage(String language) async {
    if (!_isInitialized) {
      final initialized = await initialize(language: language);
      return initialized;
    }
    
    try {
      final isAvailable = await _flutterTts.isLanguageAvailable(language);
      if (!isAvailable) {
        Logger.w('Language $language is not available', tag: _tag);
        return false;
      }
      
      await _flutterTts.setLanguage(language);
      Logger.d('Language set to: $language', tag: _tag);
      return true;
    } catch (e) {
      Logger.e('Error setting language', tag: _tag, error: e);
      return false;
    }
  }

  /// Set the speech volume
  Future<bool> setVolume(double volume) async {
    if (volume < 0.0) volume = 0.0;
    if (volume > 1.0) volume = 1.0;
    
    if (!_isInitialized) {
      final initialized = await initialize(volume: volume);
      return initialized;
    }
    
    try {
      await _flutterTts.setVolume(volume);
      Logger.d('Volume set to: $volume', tag: _tag);
      return true;
    } catch (e) {
      Logger.e('Error setting volume', tag: _tag, error: e);
      return false;
    }
  }

  /// Set the speech rate
  Future<bool> setSpeechRate(double rate) async {
    if (rate < 0.0) rate = 0.0;
    if (rate > 1.0) rate = 1.0;
    
    if (!_isInitialized) {
      final initialized = await initialize(rate: rate);
      return initialized;
    }
    
    try {
      await _flutterTts.setSpeechRate(rate);
      Logger.d('Speech rate set to: $rate', tag: _tag);
      return true;
    } catch (e) {
      Logger.e('Error setting speech rate', tag: _tag, error: e);
      return false;
    }
  }

  /// Set the speech pitch
  Future<bool> setPitch(double pitch) async {
    
    if (!_isInitialized) {
      final initialized = await initialize(pitch: pitch);
      return initialized;
    }
    
    try {
      await _flutterTts.setPitch(pitch);
      Logger.d('Pitch set to: $pitch', tag: _tag);
      return true;
    } catch (e) {
      Logger.e('Error setting pitch', tag: _tag, error: e);
      return false;
    }
  }

  /// Get available languages for TTS
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.cast<String>();
    } catch (e) {
      Logger.e('Error getting available languages', tag: _tag, error: e);
      return [];
    }
  }

  /// Dispose the TTS service
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await stop();
        _isInitialized = false;
      } catch (e) {
        Logger.e('Error disposing TTS', tag: _tag, error: e);
      }
    }
  }
}
