import 'package:flutter/services.dart';
import 'package:apiarium/shared/utils/logger.dart';

/// Utility class for managing custom UI modes via platform channels.
/// Currently supports hiding the navigation bar in sticky immersive mode on Android.
class UIHelper {
  static const _channel = MethodChannel('custom_ui_mode');

  /// Hides the navigation bar with sticky immersive mode
  static Future<void> hideNavigationBarSticky() async {
    try {
      await _channel.invokeMethod('hideNavigationBarSticky');
    } on PlatformException catch (e) {
      Logger.w("Failed to set UI mode: '${e.message}'.", tag: "UIHelper");
    }
  }
}
