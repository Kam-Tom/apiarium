import 'package:apiarium/core/theme/text_theme.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.white[200],
      buttonTheme: ButtonThemeData(
        buttonColor: AppColors.primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: AppTextTheme.spinnakerTextTheme,
      appBarTheme: AppBarTheme(color: AppColors.primaryColor),
    );
  }
}
