import 'dart:convert';

class Settings {
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final String voiceControlModel;
  final bool isFirstTime;

  const Settings({
    this.language = 'en',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.voiceControlModel = '',
    this.isFirstTime = true,
  });

  Settings copyWith({
    String? language,
    String? theme,
    bool? notificationsEnabled,
    String? voiceControlModel,
    bool? isFirstTime,
  }) {
    return Settings(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      voiceControlModel: voiceControlModel ?? this.voiceControlModel,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'voiceControlModel': voiceControlModel,
      'isFirstTime': isFirstTime,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      language: json['language'] ?? 'en',
      theme: json['theme'] ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      voiceControlModel: json['voiceControlModel'] ?? '',
      isFirstTime: json['isFirstTime'] ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());
  
  factory Settings.fromJsonString(String jsonString) {
    return Settings.fromJson(jsonDecode(jsonString));
  }
}