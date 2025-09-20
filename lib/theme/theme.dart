import 'package:flutter/material.dart';

class AppColors {
  static const sand   = Color(0xFFF6E8DF);
  static const coral  = Color(0xFFFEAE96);
  static const salmon = Color(0xFFFE979C);
  static const navy   = Color(0xFF013237);

  static const textPrimary   = Color(0xFF013237); // navy
  static const textSecondary = Color(0xAA013237);
}

LinearGradient primaryGradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.coral, AppColors.salmon],
);

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
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sand,
      elevation: 0,
      foregroundColor: AppColors.navy,
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(color: AppColors.navy),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.08),
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

TextTheme appTextTheme(TextTheme base) => base.copyWith(
  displayLarge: base.displayLarge?.copyWith(fontSize: 38, fontWeight: FontWeight.w700),
  headlineMedium: base.headlineMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
  titleLarge: base.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
  bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
  bodyMedium: base.bodyMedium?.copyWith(fontSize: 14),
  labelMedium: base.labelMedium?.copyWith(fontSize: 12, letterSpacing: .3),
);
