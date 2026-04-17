import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeData {
  static const Color primaryColor = Color(0xFF6B2A02);
  static const Color secondaryColor = Color(0xFFF5E2C8);
  static const Color identityColor = Color(0xFFF6D000);
  static const Color backgroundColor = Color(0xFFFFFCF5);
  static ThemeData get theme => ThemeData(
    textTheme: GoogleFonts.montserratTextTheme(),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
    ),
    useMaterial3: true,
  );
}
