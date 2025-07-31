import 'package:flutter_tts/flutter_tts.dart';
import 'package:apiarium/shared/shared.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  static const String _tag = 'TtsService';
  
  TtsState _ttsState = TtsState.stopped;
  bool _isInitialized = false;

  TtsState get state => _ttsState;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _ttsState == TtsState.playing;

  Function(TtsState)? onStateChanged;

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
      onStateChanged?.call(_ttsState);
    });
    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      Logger.d('TTS completed', tag: _tag);
      onStateChanged?.call(_ttsState);
    });
    _flutterTts.setCancelHandler(() {
      _ttsState = TtsState.stopped;
      Logger.d('TTS cancelled', tag: _tag);
      onStateChanged?.call(_ttsState);
    });
    _flutterTts.setErrorHandler((message) {
      _ttsState = TtsState.stopped;
      Logger.e('TTS error: $message', tag: _tag);
      onStateChanged?.call(_ttsState);
    });
    _flutterTts.setPauseHandler(() {
      _ttsState = TtsState.paused;
      Logger.d('TTS paused', tag: _tag);
      onStateChanged?.call(_ttsState);
    });
    _flutterTts.setContinueHandler(() {
      _ttsState = TtsState.continued;
      Logger.d('TTS continued', tag: _tag);
      onStateChanged?.call(_ttsState);
    });
  }

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

  Future<bool> setVolume(double volume) async {
    volume = volume.clamp(0.0, 1.0);
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

  Future<bool> setSpeechRate(double rate) async {
    rate = rate.clamp(0.0, 1.0);
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

  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.cast<String>();
    } catch (e) {
      Logger.e('Error getting available languages', tag: _tag, error: e);
      return [];
    }
  }

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