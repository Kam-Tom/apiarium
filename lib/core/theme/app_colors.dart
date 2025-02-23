import 'package:flutter/material.dart';

class AppColors {
  static const Map<int, Color> primary = {
    100: Color(0xFFFFE728),
    200: Color(0xFFFFD314),
    300: Color(0xFFFFBF00),
    400: Color(0xFFEB9900),
    500: Color(0xFFEB8500),
  };

  static const Map<int, Color> secondary = {
    100: Color(0xFF4AA2FF),
    200: Color(0xFF4098FF),
    300: Color(0xFF227AFF),
    400: Color(0xFF0E66EB),
    500: Color(0xFF0052D7),
  };

  static const Map<int, Color> white = {
    100: Color(0xFFFFFFFF),
    200: Color(0xFFF5F5F5),
    300: Color(0xFFEBEBEB),
    400: Color(0xFFE1E1E1),
    500: Color(0xFFACACAC),
  };

  static const Map<int, Color> black = {
    100: Color(0xFF000000),
    200: Color(0xFF1E1E1E),
    300: Color(0xFF3C3C3C),
    400: Color(0xFF5A5A5A),
    500: Color(0xFF787878),
  };

  static Color get primaryColor => primary[300]!;
  static Color get secondaryColor => secondary[300]!;
  static Color get whiteColor => white[100]!;
  static Color get blackColor => black[100]!;
}