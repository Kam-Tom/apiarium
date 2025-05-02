import 'dart:math';
import 'dart:convert';
import 'package:apiarium/shared/services/services.dart';
import 'package:flutter/services.dart';

class NameGeneratorService {
  final Random _random = Random();
  final UserService _userRepository;
  bool _isInitialized = false;
  
  late Map<String, dynamic> _nameData;

  NameGeneratorService(this._userRepository);
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final jsonString = await rootBundle.loadString('assets/data/name_generator.json');
    _nameData = json.decode(jsonString);
    _isInitialized = true;
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
  
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) await initialize();
  }
  
  String _generateName(String nounCategory) {
    String language = _userRepository.language;
    
    if (!_nameData[nounCategory].containsKey(language)) {
      language = 'english';
    }
    
    final genderMap = _nameData[nounCategory][language] as Map<String, dynamic>;
    final availableGenders = genderMap.keys
        .where((gender) => (genderMap[gender] as List).isNotEmpty)
        .toList();
    
    if (availableGenders.isEmpty) return "Name Unavailable";
    
    final gender = availableGenders[_random.nextInt(availableGenders.length)];
    
    // Get random noun and adjective
    final noun = _getRandomWord(nounCategory, language, gender);
    final adjective = _getRandomWord('adjectives', language, gender);
    
    return '$adjective $noun';
  }
  
  String _getRandomWord(String category, String language, String gender) {
    final words = _nameData[category][language][gender] as List;
    return words[_random.nextInt(words.length)];
  }
}
