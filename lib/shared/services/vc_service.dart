// import '../utils/logger.dart';
// import '../services/services.dart';
// import '../utils/shared_prefs_helper.dart';
// import '../utils/language_models.dart';
// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;

/// Service for voice control functionality
class VcService {
  // final TtsService _ttsService;
  // final VoskService _voskService;
  // final UserService _userService;
  // static const String _tag = 'VcService';
  
  // bool _isInitialized = false;
  // bool _isListening = false;
  
  // bool get isInitialized => _isInitialized;
  // bool get isListening => _isListening;
  
  // Function(String result)? _resultHandler;

  // VcService({
  //   required TtsService ttsService,
  //   required VoskService voskService,
  //   required UserService userService
  // }) : _ttsService = ttsService, 
  //      _voskService = voskService,
  //      _userService = userService;

  // Future<bool> initialize({
  //   String? modelUrl,
  //   String? modelId,
  //   String? language,
  //   Function(String status)? onModelStatusChange,
  // }) async {
  //   if (_isInitialized) return true;
    
  //   try {
  //     String finalModelId = modelId ?? SharedPrefsHelper.getVcModel();
  //     String finalModelUrl = modelUrl ?? '';
  //     String finalLanguage = language ?? 'en-US';
      
  //     if (finalModelId.isNotEmpty && (finalModelUrl.isEmpty || language == null)) {
  //       final models = langaugeModels();
  //       for (final model in models) {
  //         if (model['id'] == finalModelId) {
  //           finalModelUrl = modelUrl ?? model['url'] ?? '';
  //           finalLanguage = language ?? model['ttsLanguage'] ?? 'en-US';
  //           break;
  //         }
  //       }
  //     }
      
  //     if (finalModelId.isEmpty || finalModelUrl.isEmpty) {
  //       Logger.e('Model ID or URL not found', tag: _tag);
  //       return false;
  //     }
      
  //     final ttsInitialized = await _ttsService.initialize(
  //       language: finalLanguage,
  //     );
      
  //     if (!ttsInitialized) {
  //       Logger.e('Failed to initialize TTS service', tag: _tag);
  //       return false;
  //     }
      
  //     await _voskService.initialize(
  //       modelUrl: finalModelUrl,
  //       modelId: finalModelId,
  //       onModelStatusChange: onModelStatusChange,
  //     );
      
  //     try {
  //       final String jsonString = await rootBundle.loadString('assets/text_data/voice_grammar.json');
  //       var grammarJson = json.decode(jsonString);
  //       List<dynamic> dynamicList = grammarJson[finalLanguage];
  //       List<String> stringList = dynamicList.map((item) => item.toString()).toList();
  //       await _voskService.setGrammar(stringList);
  //       Logger.i('Voice grammar loaded from JSON', tag: _tag);
  //     } catch (e) {
  //       Logger.e('Error loading grammar from JSON', tag: _tag, error: e);
  //     }
      
  //     _voskService.setResultHandler(_handleRecognitionResult);
      
  //     await SharedPrefsHelper.setVcModel(finalModelId);
      
  //     _isInitialized = true;
  //     Logger.i('Voice control service initialized', tag: _tag);
  //     return true;
  //   } catch (e) {
  //     Logger.e('Failed to initialize voice control service', tag: _tag, error: e);
  //     return false;
  //   }
  // }

  // void _handleRecognitionResult(String result) {
  //   if (result.isEmpty) return;
    
  //   Logger.d("Received result: $result", tag: _tag);
    
  //   if (_resultHandler != null) {
  //     _resultHandler!(result);
  //   }
  // }
  
  // void setResultHandler(Function(String result) handler) {
  //   _resultHandler = handler;
  // }
  
  // void removeResultHandler() {
  //   _resultHandler = null;
  // }

  // Future<bool> startListening({Function(String error)? onError}) async {
  //   if (!_isInitialized) {
  //     Logger.e('Voice control service not initialized', tag: _tag);
  //     return false;
  //   }
    
  //   try {
  //     await _voskService.startListening(onError: onError);
  //     _isListening = true;
  //     Logger.i('Started listening for voice commands', tag: _tag);
  //     return true;
  //   } catch (e) {
  //     Logger.e('Failed to start listening', tag: _tag, error: e);
  //     return false;
  //   }
  // }

  // Future<bool> stopListening() async {
  //   if (!_isInitialized || !_isListening) return true;
    
  //   try {
  //     await _voskService.stopListening();
  //     _isListening = false;
  //     Logger.i('Stopped listening for voice commands', tag: _tag);
  //     return true;
  //   } catch (e) {
  //     Logger.e('Failed to stop listening', tag: _tag, error: e);
  //     return false;
  //   }
  // }
  
  // Future<bool> speak(String text) async {
  //   if (!_isInitialized || text.isEmpty) return false;
    
  //   try {
  //     return await _ttsService.speak(text);
  //   } catch (e) {
  //     Logger.e('Failed to speak text', tag: _tag, error: e);
  //     return false;
  //   }
  // }

  // Future<void> dispose() async {
  //   try {
  //     await stopListening();
  //     await _voskService.dispose();
  //     await _ttsService.dispose();
  //     _resultHandler = null;
  //     _isInitialized = false;
  //     _isListening = false;
  //     Logger.i('Voice control service disposed', tag: _tag);
  //   } catch (e) {
  //     Logger.e('Error disposing voice control service', tag: _tag, error: e);
  //   }
  // }
}
