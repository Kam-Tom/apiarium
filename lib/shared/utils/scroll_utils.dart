import 'package:flutter/material.dart';

class ScrollUtils {
  static void scrollToTop(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}
