import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_shadows.dart';

/// Thème principal de l'application
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false, // Désactiver Material 3 pour garder l'esthétique custom
      brightness: Brightness.light,
      primaryColor: AppColors.coral,
      scaffoldBackgroundColor: AppColors.sand,
      fontFamily: 'CircularStd', // À ajouter dans pubspec.yaml
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.sand,
        foregroundColor: AppColors.deepNavy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: AppColors.deepNavy,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Couleurs
      colorScheme: const ColorScheme.light(
        primary: AppColors.coral,
        secondary: AppColors.salmon,
        surface: AppColors.sand,
        background: AppColors.sand,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.deepNavy,
        onBackground: AppColors.deepNavy,
        onError: Colors.white,
      ),

      // Typographie
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLargeStyle,
        displayMedium: AppTypography.displayMediumStyle,
        headlineLarge: AppTypography.h1Style,
        headlineMedium: AppTypography.h2Style,
        headlineSmall: AppTypography.h3Style,
        bodyLarge: AppTypography.bodyStyle,
        bodyMedium: AppTypography.bodyStyle,
        bodySmall: AppTypography.captionStyle,
        labelLarge: AppTypography.metaStyle,
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepNavy,
          side: const BorderSide(color: AppColors.glassBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),

      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.coral, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        labelStyle: AppTypography.bodyStyle.copyWith(
          color: AppColors.navy70,
        ),
        hintStyle: AppTypography.bodyStyle.copyWith(
          color: AppColors.navy50,
        ),
      ),

      // Cartes
      cardTheme: CardTheme(
        color: AppColors.glassLight,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),

      // Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.sand,
        selectedItemColor: AppColors.coral,
        unselectedItemColor: AppColors.navy50,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.glassDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppSpacing.radiusXl),
            bottomRight: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.navy10,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.deepNavy,
        size: AppSpacing.iconSize,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusXl)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      primaryColor: AppColors.coral,
      scaffoldBackgroundColor: const Color(0xFF021A1C), // Deep Navy 96%
      fontFamily: 'CircularStd',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF021A1C),
        foregroundColor: AppColors.sand,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: AppColors.sand,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      colorScheme: const ColorScheme.dark(
        primary: AppColors.coral,
        secondary: AppColors.salmon,
        surface: Color(0xFF021A1C),
        background: Color(0xFF021A1C),
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.sand,
        onBackground: AppColors.sand,
        onError: Colors.white,
      ),

      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLargeStyle,
        displayMedium: AppTypography.displayMediumStyle,
        headlineLarge: AppTypography.h1Style,
        headlineMedium: AppTypography.h2Style,
        headlineSmall: AppTypography.h3Style,
        bodyLarge: AppTypography.bodyStyle,
        bodyMedium: AppTypography.bodyStyle,
        bodySmall: AppTypography.captionStyle,
        labelLarge: AppTypography.metaStyle,
      ),
    );
  }
}
