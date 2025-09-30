import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primary = Color(0xFF2E7D32); // Vert foncé
  static const Color primaryLight = Color(0xFF4CAF50); // Vert clair
  static const Color primaryDark = Color(0xFF1B5E20); // Vert très foncé
  
  // Couleurs secondaires
  static const Color secondary = Color(0xFF1976D2); // Bleu
  static const Color secondaryLight = Color(0xFF42A5F5); // Bleu clair
  
  // Couleurs d'accent
  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color accentLight = Color(0xFFFFB74D); // Orange clair
  
  // Couleurs de surface
  static const Color surface = Color(0xFFFAFAFA); // Gris très clair
  static const Color surfaceDark = Color(0xFFF5F5F5); // Gris clair
  static const Color background = Color(0xFFFFFFFF); // Blanc
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121); // Noir
  static const Color textSecondary = Color(0xFF757575); // Gris
  static const Color textLight = Color(0xFF9E9E9E); // Gris clair
  
  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50); // Vert
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFF44336); // Rouge
  static const Color info = Color(0xFF2196F3); // Bleu
  
  // Couleurs de bordure
  static const Color border = Color(0xFFE0E0E0); // Gris clair pour les bordures
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
  
  // Ombres
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  // Rayons de bordure
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // Espacements
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Thème principal
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: background,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
        hintStyle: const TextStyle(
          color: textLight,
          fontSize: 16,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  // TextTheme personnalisé
  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: textSecondary,
    ),
  );

  // ========================================
  // SYSTÈME DE DESIGN COMPLET
  // ========================================

  // ========================================
  // COMPOSANTS UI - CARTES
  // ========================================

  /// Style pour les cartes principales avec ombre
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: cardShadow,
    border: Border.all(color: border.withOpacity(0.5)),
  );

  /// Style pour les cartes avec accent coloré
  static BoxDecoration cardDecorationWithAccent(Color accentColor) => BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: cardShadow,
    border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
  );

  /// Style pour les cartes de section (avec fond coloré)
  static BoxDecoration get sectionCardDecoration => BoxDecoration(
    color: primary.withOpacity(0.05),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: primary.withOpacity(0.2)),
  );

  /// Style pour les cartes d'information
  static BoxDecoration get infoCardDecoration => BoxDecoration(
    color: info.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: info.withOpacity(0.3)),
  );

  /// Style pour les cartes de succès
  static BoxDecoration get successCardDecoration => BoxDecoration(
    color: success.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: success.withOpacity(0.3)),
  );

  /// Style pour les cartes d'avertissement
  static BoxDecoration get warningCardDecoration => BoxDecoration(
    color: warning.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: warning.withOpacity(0.3)),
  );

  /// Style pour les cartes d'erreur
  static BoxDecoration get errorCardDecoration => BoxDecoration(
    color: error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: error.withOpacity(0.3)),
  );

  // ========================================
  // COMPOSANTS UI - BOUTONS
  // ========================================

  /// Style pour les boutons principaux
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// Style pour les boutons secondaires
  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: secondary,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// Style pour les boutons d'accent
  static ButtonStyle get accentButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: accent,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// Style pour les boutons outlined
  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: const BorderSide(color: primary, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// Style pour les boutons de texte
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: primary,
    padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  /// Style pour les boutons d'action flottants
  static FloatingActionButtonThemeData get floatingActionButtonTheme => const FloatingActionButtonThemeData(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 4,
  );

  // ========================================
  // COMPOSANTS UI - FORMULAIRES
  // ========================================

  /// Style pour les champs de saisie
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingM),
    labelStyle: const TextStyle(color: textSecondary, fontSize: 16),
    hintStyle: const TextStyle(color: textLight, fontSize: 16),
  );

  /// Style pour les champs de saisie avec icône
  static InputDecoration inputDecorationWithIcon(IconData icon) => InputDecoration(
    filled: true,
    fillColor: surface,
    prefixIcon: Icon(icon, color: primary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: const BorderSide(color: error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingM),
    labelStyle: const TextStyle(color: textSecondary, fontSize: 16),
    hintStyle: const TextStyle(color: textLight, fontSize: 16),
  );

  // ========================================
  // COMPOSANTS UI - LISTES ET ÉLÉMENTS
  // ========================================

  /// Style pour les éléments de liste
  static BoxDecoration get listItemDecoration => BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radiusSmall),
    border: Border.all(color: border),
  );

  /// Style pour les éléments de liste sélectionnés
  static BoxDecoration get selectedListItemDecoration => BoxDecoration(
    color: primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusSmall),
    border: Border.all(color: primary, width: 2),
  );

  /// Style pour les puces de sélection (FilterChip)
  static BoxDecoration get filterChipDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusSmall),
    border: Border.all(color: border),
  );

  /// Style pour les puces de sélection actives
  static BoxDecoration get activeFilterChipDecoration => BoxDecoration(
    color: primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusSmall),
    border: Border.all(color: primary, width: 2),
  );

  // ========================================
  // COMPOSANTS UI - SECTIONS ET CONTAINERS
  // ========================================

  /// Style pour les sections principales
  static BoxDecoration get sectionDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: border),
  );

  /// Style pour les containers avec gradient
  static BoxDecoration get gradientDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radiusLarge),
  );

  /// Style pour les containers d'information
  static BoxDecoration get infoContainerDecoration => BoxDecoration(
    color: info.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: info.withOpacity(0.3)),
  );

  // ========================================
  // COMPOSANTS UI - APP BARS
  // ========================================

  /// Style pour les AppBars principales
  static AppBarTheme get primaryAppBarTheme => const AppBarTheme(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  /// Style pour les AppBars secondaires
  static AppBarTheme get secondaryAppBarTheme => const AppBarTheme(
    backgroundColor: secondary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  /// Style pour les AppBars d'accent
  static AppBarTheme get accentAppBarTheme => const AppBarTheme(
    backgroundColor: accent,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  // ========================================
  // MÉTHODES HELPER POUR LES STYLES COURANTS
  // ========================================

  /// Crée un style de texte avec une couleur personnalisée
  static TextStyle textStyleWithColor(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }

  /// Crée un style de bouton avec une couleur personnalisée
  static ButtonStyle buttonStyleWithColor(Color backgroundColor, Color foregroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  /// Crée un style de carte avec une couleur d'accent personnalisée
  static BoxDecoration cardDecorationWithCustomAccent(Color accentColor) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: cardShadow,
      border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
    );
  }

  /// Crée un style de container avec un gradient personnalisé
  static BoxDecoration containerWithGradient(List<Color> colors) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(radiusLarge),
    );
  }

  // ========================================
  // STYLES SPÉCIALISÉS POUR LES PAGES
  // ========================================

  /// Style pour la page d'accueil
  static BoxDecoration get homeCardDecoration => BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: elevatedShadow,
    border: Border.all(color: border.withOpacity(0.5)),
  );

  /// Style pour les statistiques
  static BoxDecoration get statsCardDecoration => BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: cardShadow,
    border: Border.all(color: primary.withOpacity(0.2)),
  );

  /// Style pour les exports PDF
  static BoxDecoration get exportCardDecoration => BoxDecoration(
    color: accent.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: accent.withOpacity(0.3)),
  );

  /// Style pour les imports
  static BoxDecoration get importCardDecoration => BoxDecoration(
    color: info.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: info.withOpacity(0.3)),
  );

  /// Style pour les traitements
  static BoxDecoration get treatmentCardDecoration => BoxDecoration(
    color: secondary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: secondary.withOpacity(0.3)),
  );

  /// Style pour les semis
  static BoxDecoration get semisCardDecoration => BoxDecoration(
    color: success.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: success.withOpacity(0.3)),
  );

  /// Style pour les parcelles
  static BoxDecoration get parcelleCardDecoration => BoxDecoration(
    color: primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: primary.withOpacity(0.3)),
  );

  /// Style pour les cellules
  static BoxDecoration get celluleCardDecoration => BoxDecoration(
    color: warning.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: warning.withOpacity(0.3)),
  );

  /// Style pour les chargements
  static BoxDecoration get chargementCardDecoration => BoxDecoration(
    color: error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: error.withOpacity(0.3)),
  );
}
