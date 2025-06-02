import 'package:flutter_test/flutter_test.dart';
import 'package:apiarium/core/config/env/env.dev.dart';

void main() {
  group('EnvDev', () {
    test('should load supabaseUrl', () {
      expect(EnvDev.apiBaseUrl, isNotNull);
      expect(EnvDev.apiKey, isNotEmpty);
    });
  });
}
