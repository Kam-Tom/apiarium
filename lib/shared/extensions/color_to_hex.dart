import 'dart:ui';

extension ColorToHexX on Color {
  String toHex() {
    return '#${toARGB32().toRadixString(16).substring(2)}';
  }
}