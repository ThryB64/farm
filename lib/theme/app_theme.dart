import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const sand = Color(0xFFF6E8DF);
  static const coral = Color(0xFFFEAE96);
  static const salmon = Color(0xFFFE979C);
  static const navy = Color(0xFF013237);

  static const textPrimary = Color(0xFF013237);
  static const textSecondary = Color(0xAA013237);
  static const textTertiary = Color(0x80013237);
}

class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.coral, AppColors.salmon],
  );

  static const backgroundGlow = RadialGradient(
    colors: [
      Color.fromRGBO(254, 174, 150, 0.12),
      Color.fromRGBO(254, 151, 156, 0.10),
      Colors.transparent,
    ],
    radius: 1.0,
    stops: [0.0, 0.35, 1.0],
    center: Alignment.topLeft,
  );

  static const navyTint = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(1, 50, 55, 0.24),
      Color.fromRGBO(1, 50, 55, 0.0),
    ],
  );
}

class AppShadows {
  static const glass = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color.fromRGBO(1, 50, 55, 0.18),
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 6,
      color: Color.fromRGBO(1, 50, 55, 0.12),
    ),
  ];

  static const button = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 20,
      color: Color.fromRGBO(1, 50, 55, 0.18),
    ),
  ];

  static const card = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 12,
      color: Color.fromRGBO(1, 50, 55, 0.15),
    ),
  ];
}

class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: false);
  
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.sand,
    primaryColor: AppColors.coral,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.coral,
      secondary: AppColors.salmon,
      surface: Colors.white,
      onSurface: AppColors.navy,
      background: AppColors.sand,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: AppColors.textPrimary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.sand,
      elevation: 0,
      foregroundColor: AppColors.navy,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.navy),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
