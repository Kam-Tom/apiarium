import 'dart:math';
import 'dart:convert';
import 'package:apiarium/shared/services/services.dart';
import 'package:apiarium/shared/services/settings_repository.dart';
import 'package:flutter/services.dart';

class NameGeneratorService {
  final Random _random = Random();
  final SettingsRepository _settingsRepository;
  bool _isInitialized = false;
  
  late Map<String, dynamic> _nameData;

  NameGeneratorService(this._settingsRepository);
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final jsonString = await rootBundle.loadString('assets/text_data/name_generator.json');
    _nameData = json.decode(jsonString);
    _isInitialized = true;
  }

  Future<String> generateQueenName() async {
    await _ensureInitialized();
    return _generateName('bee_nouns');
  }

  Future<String> generateBeehiveName() async {
    await _ensureInitialized();
    return _generateName('beehive_nouns');
  }

  Future<String> generateBeeStripeName() async {
    await _ensureInitialized();
    return _generateName('bee_stripe_nouns');
  }

  Future<String> generateBeeName() async {
    await _ensureInitialized();
    return _generateName('bee_nouns');
  }
  
  Future<String> generateApiaryName() async {
    await _ensureInitialized();
    return _generateName('apiary_nouns');
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) await initialize();
  }
  String _generateName(String nounCategory) {
    String language = _settingsRepository.settings.language;
    
    if (!_nameData[nounCategory].containsKey(language)) {
      language = 'en';
    }
    
    final genderMap = _nameData[nounCategory][language] as Map<String, dynamic>;
    final availableGenders = genderMap.keys
        .where((gender) => (genderMap[gender] as List).isNotEmpty)
        .toList();
    
    if (availableGenders.isEmpty) return "Queen ${_random.nextInt(999) + 1}";
    
    final gender = availableGenders[_random.nextInt(availableGenders.length)];
    
    // Get random noun
    final noun = _getRandomWord(nounCategory, language, gender);
    
    // For adjectives, use masculine gender for English (since that's where the adjectives are)
    final adjectiveGender = language == 'en' ? 'masculine' : gender;
    
    // Check if adjectives exist for this language and gender
    if (!_nameData['adjectives'].containsKey(language) || 
        !_nameData['adjectives'][language].containsKey(adjectiveGender) ||
        (_nameData['adjectives'][language][adjectiveGender] as List).isEmpty) {
      // No adjectives available, return just the noun
      return noun;
    }
    
    final adjective = _getRandomWord('adjectives', language, adjectiveGender);
    
    return '$adjective $noun';
  }
  
  String _getRandomWord(String category, String language, String gender) {
    final words = _nameData[category][language][gender] as List;
    return words[_random.nextInt(words.length)];
  }
}