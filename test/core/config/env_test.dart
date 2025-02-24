import 'package:flutter_test/flutter_test.dart';
import 'package:apiarium/core/config/env/env.dev.dart';

void main() {
  group('EnvDev', () {
    test('should load supabaseUrl', () {
      expect(EnvDev.supabaseUrl, isNotNull);
      expect(EnvDev.supabaseUrl, isNotEmpty);
    });

    test('should load supabaseAnonKey', () {
      expect(EnvDev.supabaseAnonKey, isNotNull);
      expect(EnvDev.supabaseAnonKey, isNotEmpty);
    });
  });
}
