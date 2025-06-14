import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsRepository {
  final SharedPreferences _prefs;
  static const String _settingsKey = 'app_settings';

  Settings? _currentSettings;

  SettingsRepository._(this._prefs);

  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = SettingsRepository._(prefs);
    await repository._loadSettings();
    return repository;
  }

  Settings get settings => _currentSettings ?? const Settings();

  Future<void> updateSettings(Settings newSettings) async {
    _currentSettings = newSettings;
    await _prefs.setString(_settingsKey, newSettings.toJsonString());
  }

  Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson != null) {
        _currentSettings = Settings.fromJsonString(settingsJson);
      } else {
        _currentSettings = const Settings();
      }
    } catch (e) {
      _currentSettings = const Settings();
    }
  }

  Future<void> clearAll() async {
    await _prefs.clear();
    _currentSettings = const Settings();
  }
}