import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:vosk_flutter/vosk_flutter.dart';
import '../utils/logger.dart';

class VoskService {
  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  final ModelLoader _modelLoader = ModelLoader();
  static const String _tag = 'VoskService';
  static const int _sampleRate = 16000;
  
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;
  
  bool get isInitialized => _model != null && _recognizer != null;
  bool get isListening => _isListening;
  bool _isListening = false;
  
  // Callbacks
  Function(String command)? _onCommand;
  Function(String partialText)? _onPartialResult;
  Function(String resultText)? _onResult;
  
  // Set handlers
  void setCommandHandler(Function(String command) onCommand) => _onCommand = onCommand;
  void setPartialResultHandler(Function(String partialText) onPartialResult) => _onPartialResult = onPartialResult;
  void setResultHandler(Function(String resultText) onResult) => _onResult = onResult;

  Future<bool> initialize({
    required String modelUrl, 
    required String modelId,
    Function(String status)? onModelStatusChange,
    Function(String status)? onRecognizerStatusChange,
    bool enablePartialResults = false,
  }) async {
    try {
      if (onModelStatusChange != null) {
        onModelStatusChange('Preparing for download...');
      }
      
      final modelPath = await _modelLoader.loadFromNetwork(modelUrl);
      
      if (onModelStatusChange != null) {
        onModelStatusChange('Creating model from: $modelPath');
      }
      
      _model = await _vosk.createModel(modelPath);
      
      if (onModelStatusChange != null) {
        onModelStatusChange('Model created: $_model');
      }
      
      if (onRecognizerStatusChange != null) {
        onRecognizerStatusChange('Creating recognizer...');
      }
      
      _recognizer = await _vosk.createRecognizer(
        model: _model!, 
        sampleRate: _sampleRate
      );
      
      if (onRecognizerStatusChange != null) {
        onRecognizerStatusChange('Recognizer created');
      }
      
      if (Platform.isAndroid) {
        if (onRecognizerStatusChange != null) {
          onRecognizerStatusChange('Initializing speech service...');
        }
        
        _speechService = await _vosk.initSpeechService(_recognizer!);
        
        if (onRecognizerStatusChange != null) {
          onRecognizerStatusChange('Speech service initialized');
        }
        
        // Result listener
        _speechService!.onResult().listen((result) {
          final jsonResult = result.toString();
          final resultText = _extractCommand(jsonResult);
          
          if (_onResult != null && resultText.isNotEmpty) {
            _onResult!(resultText);
          }
          
          if (_onCommand != null && resultText.isNotEmpty) {
            _onCommand!(resultText);
          }
        });
        
        // Partial result listener
        if(enablePartialResults) {
          _speechService!.onPartial().listen((result) {
            final jsonResult = result.toString();
            final partialText = _extractPartialText(jsonResult);
            
            if (partialText.isNotEmpty) {
              Logger.d("Partial: $partialText", tag: _tag);
              
              if (_onPartialResult != null) {
                _onPartialResult!(partialText);
              }
            }
          });
        }
      } else {
        throw Exception('Voice control is currently only available on Android');
      }
      
      return true;
    } catch (e) {
      Logger.e('Failed to initialize', tag: _tag, error: e);
      throw Exception('Failed to initialize: $e');
    }
  }
  
  String _extractCommand(String jsonResult) {
    try {
      final Map<String, dynamic> result = json.decode(jsonResult);
      if (result.containsKey('text')) {
        return result['text'].toString().trim();
      }
    } catch (e) {
      Logger.e("Error extracting command", tag: _tag, error: e);
    }
    return '';
  }
  
  String _extractPartialText(String jsonResult) {
    try {
      final Map<String, dynamic> result = json.decode(jsonResult);
      if (result.containsKey('partial')) {
        return result['partial'].toString().trim();
      }
    } catch (e) {
      Logger.e("Error extracting partial text", tag: _tag, error: e);
    }
    return '';
  }

  Future<void> setCommands(List<String> commands, {bool enableGrammar = true}) async {
    if (_recognizer == null) {
      throw Exception('Recognizer not initialized');
    }
    
    try {
      if (commands.isEmpty || !enableGrammar) {
        await _recognizer!.setGrammar([]);
        return;
      }
      
      await _recognizer!.setGrammar(commands);
      Logger.i("Grammar set with ${commands.length} words", tag: _tag);
    } catch (e) {
      Logger.e("Error in setCommands", tag: _tag, error: e);
    }
  }

  Future<bool> startListening({Function(String error)? onError}) async {
    if (_speechService == null) {
      throw Exception('Speech service not initialized');
    }
    
    if (_isListening) return true;
    
    try {
      await _speechService!.start(
        onRecognitionError: (error) {
          Logger.e("Recognition error", tag: _tag, error: error);
          if (onError != null) {
            onError(error.toString());
          }
        }
      );
      
      _isListening = true;
      return true;
    } catch (e) {
      Logger.e("Failed to start listening", tag: _tag, error: e);
      throw Exception('Failed to start listening: $e');
    }
  }

  Future<bool> stopListening() async {
    if (_speechService == null || !_isListening) {
      return true;
    }
    
    try {
      await _speechService!.stop();
      _isListening = false;
      return true;
    } catch (e) {
      Logger.e("Failed to stop listening", tag: _tag, error: e);
      throw Exception('Failed to stop listening: $e');
    }
  }
  
  Future<void> setPause(bool paused) async {
    if (_speechService == null) {
      throw Exception('Speech service not initialized');
    }
    
    try {
      await _speechService!.setPause(paused: paused);
    } catch (e) {
      Logger.e("Failed to pause/resume", tag: _tag, error: e);
      throw Exception('Failed to pause/resume: $e');
    }
  }
  
  Future<void> reset() async {
    if (_speechService == null) {
      throw Exception('Speech service not initialized');
    }
    
    try {
      await _speechService!.reset();
    } catch (e) {
      Logger.e("Failed to reset", tag: _tag, error: e);
      throw Exception('Failed to reset: $e');
    }
  }

  Future<void> dispose() async {
    _isListening = false;
    
    if (_speechService != null) {
      try {
        await _speechService!.dispose();
      } catch (e) {
        Logger.e("Error disposing speech service", tag: _tag, error: e);
      }
      _speechService = null;
    }
    
    if (_recognizer != null) {
      try {
        await _recognizer!.dispose();
      } catch (e) {
        Logger.e("Error disposing recognizer", tag: _tag, error: e);
      }
      _recognizer = null;
    }
    
    _model = null;
  }
}