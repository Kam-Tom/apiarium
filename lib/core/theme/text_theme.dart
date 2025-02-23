import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  static TextTheme get spinnakerTextTheme {
    return GoogleFonts.spinnakerTextTheme().copyWith(
      displayLarge: GoogleFonts.spinnaker(fontSize: 57.0),
      displayMedium: GoogleFonts.spinnaker(fontSize: 45.0),
      displaySmall: GoogleFonts.spinnaker(fontSize: 36.0),
      headlineLarge: GoogleFonts.spinnaker(fontSize: 32.0),
      headlineMedium: GoogleFonts.spinnaker(fontSize: 28.0),
      headlineSmall: GoogleFonts.spinnaker(fontSize: 24.0),
      titleLarge: GoogleFonts.spinnaker(fontSize: 22.0),
      titleMedium: GoogleFonts.spinnaker(fontSize: 16.0),
      titleSmall: GoogleFonts.spinnaker(fontSize: 14.0),
      bodyLarge: GoogleFonts.spinnaker(fontSize: 16.0),
      bodyMedium: GoogleFonts.spinnaker(fontSize: 14.0),
      bodySmall: GoogleFonts.spinnaker(fontSize: 12.0),
      labelLarge: GoogleFonts.spinnaker(fontSize: 14.0),
      labelMedium: GoogleFonts.spinnaker(fontSize: 12.0),
      labelSmall: GoogleFonts.spinnaker(fontSize: 11.0),
    );
  }
}