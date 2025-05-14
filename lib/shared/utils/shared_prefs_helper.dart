import 'package:shared_preferences/shared_preferences.dart';

/// Simple helper class for managing app preferences
class SharedPrefsHelper {
  static SharedPreferences? _prefs;
  
  // Keys
  static const String keyLanguage = 'language';
  static const String keyVcModel = 'voice_control_model';
  
  // Initialize shared preferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // String methods
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }
  
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }
  
  // Bool methods
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }
  
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }
  
  // Convenience methods
  static String getLanguage() {
    return getString(keyLanguage);
  }
  
  static Future<bool> setLanguage(String language) async {
    return await setString(keyLanguage, language);
  }
  
  static String getVcModel() {
    return getString(keyVcModel);
  }
  
  static Future<bool> setVcModel(String model) async {
    return await setString(keyVcModel, model);
  }
  
  /// Clear all preferences
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}
