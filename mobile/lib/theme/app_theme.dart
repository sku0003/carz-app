import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color cardDark = Color(0xFF161B22);
  static const Color cardBorderDark = Color(0xFF30363D);

  static const Color primaryGold = Color(0xFFFFD700);
  static const Color secondaryGold = Color(0xFFFFA500);

  static const Color vipGradientStart = Color(0xFFFFD700);
  static const Color vipGradientEnd = Color(0xFFFF8C00);

  static const Color accentBlue = Color(0xFF00E5FF);
  static const Color whatsappGreen = Color(0xFF25D366);

  static const Color textPrimaryDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFF8B949E);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primaryGold,
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: accentBlue,
      surface: cardDark,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(color: textPrimaryDark, fontWeight: FontWeight.bold),
      bodyLarge: const TextStyle(color: textPrimaryDark),
      bodyMedium: const TextStyle(color: textSecondaryDark),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryGold),
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: cardBorderDark, width: 1),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: primaryGold,
      unselectedItemColor: textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
