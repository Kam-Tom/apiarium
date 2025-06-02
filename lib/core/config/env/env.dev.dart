import 'package:envied/envied.dart';

part 'env.dev.g.dart';

/// {@template env}
/// Dev Environment variables for backend services
/// {@endtemplate}
@Envied(path: '.env.dev', obfuscate: true)
abstract class EnvDev {
  /// Your backend API base URL
  @EnviedField(varName: 'API_BASE_URL', obfuscate: true)
  static String apiBaseUrl = _EnvDev.apiBaseUrl;

  /// API key for endpoint protection
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static String apiKey = _EnvDev.apiKey;
}