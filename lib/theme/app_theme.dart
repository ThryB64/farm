import 'package:flutter/material.dart';
import 'dart:ui';

/// Design system centralisé basé sur le logo maïs/verts/soleil
/// Support des modes sombre et clair avec effets de verre et halos subtils
class AppTheme {
  // ========================================
  // PALETTE BRAND (basée sur le logo)
  // ========================================
  
  // Couleurs principales du logo
  static const Color cornGold = Color(0xFFF6C65B);        // Or du maïs
  static const Color leafDark = Color(0xFF2E7D32);         // Vert foncé des feuilles
  static const Color leafLight = Color(0xFF4CAF50);        // Vert clair des feuilles
  static const Color sunYellow = Color(0xFFFFD54F);        // Jaune du soleil
  
  // ========================================
  // COULEURS MODE SOMBRE
  // ========================================
  
  // Couleurs de base dark premium
  static const Color backgroundDark = Color(0xFF0A0E0B);       // Fond principal très sombre
  static const Color surfaceDark = Color(0xFF1A1F1C);          // Surface principale
  static const Color surfaceElevatedDark = Color(0xFF242A26);   // Surface élevée
  static const Color surfaceGlassDark = Color(0x1AFFFFFF);      // Verre translucide
  
  // Couleurs de texte dark
  static const Color textPrimaryDark = Color(0xFFFFFFFF);      // Texte principal
  static const Color textSecondaryDark = Color(0xFFB8C5BA);    // Texte secondaire
  static const Color textLowDark = Color(0xFF7A8B7D);          // Texte discret
  
  // ========================================
  // COULEURS MODE CLAIR
  // ========================================
  
  // Couleurs de base light premium
  // Couleurs de fond light (remplacées par les vertes)
  // Voir section PALETTE VERTE ci-dessous
  
  // ========================================
  // PALETTE VERTE (mode clair - même structure que le sombre)
  // ========================================
  
  // Couleurs principales vertes premium professionnelles
  static const Color primary = Color(0xFF1B5E20);        // Vert foncé premium
  static const Color primaryLight = Color(0xFF2E7D32);   // Vert clair premium
  static const Color primaryDark = Color(0xFF0D4F14);    // Vert très foncé premium
  
  // Couleurs de fond vertes premium professionnelles
  static const Color backgroundLight = Color(0xFF0D4F14);     // Fond principal vert très sombre premium
  static const Color surfaceLight = Color(0xFF1B5E20);        // Surface vert sombre profond
  static const Color surfaceElevatedLight = Color(0xFF2E7D32); // Surface élevée vert normal
  static const Color surfaceGlassLight = Color(0xFF0D4F14);   // Surface verre vert très sombre
  
  // Couleurs de texte premium professionnelles
  static const Color textPrimaryLight = Color(0xFFFFFFFF);    // Texte principal blanc pur
  static const Color textSecondaryLight = Color(0xFFE8F5E8);    // Texte secondaire vert très clair
  static const Color textLowLight = Color(0xFFB8E6C1);       // Texte discret vert clair premium
  
  // Couleurs d'accent (or maïs conservé)
  // cornGold et leafLight déjà définis plus haut
  
  // ========================================
  // COULEURS D'ÉTAT (communes)
  // ========================================
  
  static const Color success = Color(0xFF4CAF50);          // Succès (vert feuille)
  static const Color warning = Color(0xFFF6C65B);          // Attention (or maïs)
  static const Color error = Color(0xFFE57373);             // Erreur
  static const Color info = Color(0xFF64B5F6);             // Information
  
  // ========================================
  // COULEURS ACTUELLES (pour compatibilité)
  // ========================================
  
  // Par défaut, on utilise le mode sombre
  static const Color background = backgroundDark;
  static const Color surface = surfaceDark;
  static const Color surfaceElevated = surfaceElevatedDark;
  static const Color surfaceGlass = surfaceGlassDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textLow = textLowDark;
  
  // ========================================
  // ALIAS POUR COMPATIBILITÉ
  // ========================================
  
  // Couleurs principales (alias)
  // primary défini dans la section PALETTE VERTE
  static const Color secondary = leafLight;
  static const Color onPrimary = background;
  static const Color onSecondary = background;
  static const Color onBackground = textPrimary;
  static const Color onSurface = textPrimary;
  static const Color textLight = textLow;
  static const Color border = Color(0x1AFFFFFF);
  static const Color accent = cornGold;
  static const Color transparent = Color(0x00000000);
  
  // Espacements (alias)
  static const double spacingXS = spaceXs;
  static const double spacingS = spaceSm;
  static const double spacingM = spaceMd;
  static const double spacingL = spaceLg;
  static const double spacingXL = spaceXl;
  static const double spacingXXL = spaceXxl;
  
  // Rayons (alias)
  static const double radiusXS = radiusXs;
  static const double radiusS = radiusSm;
  static const double radiusSmall = radiusSm;
  static const double radiusMedium = radiusMd;
  static const double radiusLarge = radiusLg;
  static const double radiusXL = radiusXl;
  static const double radiusXXL = radiusXxl;
  
  // Tailles d'icônes
  static const double iconSizeXS = 12.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 64.0;
  
  // Élévations
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  
  // Durées d'animation
  static const Duration durationFast = Duration(milliseconds: 300);
  static const Duration durationMedium = Duration(milliseconds: 500);
  static const Duration durationSlow = Duration(milliseconds: 800);
  
  // ========================================
  // GRADIENTS
  // ========================================
  
  // Gradient principal de l'app (mode sombre)
  static const LinearGradient appBgGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0E0B),  // Fond sombre
      Color(0xFF1A1F1C), // Surface
      Color(0xFF0F1411), // Retour au sombre
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Dégradé vert premium professionnel
  static const LinearGradient appBgGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D4F14),  // Vert très sombre premium (coin TL)
      Color(0xFF1B5E20),  // Vert sombre profond (milieu)
      Color(0xFF0D4F14),  // Vert très sombre premium (coin BR)
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Gradient verre pour les cartes (mode sombre)
  static const LinearGradient glassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),  // Blanc translucide
      Color(0x0DFFFFFF),  // Blanc très translucide
    ],
  );
  
  // Gradient verre premium pour les cartes (mode clair - vert sombre)
  static const LinearGradient glassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x2A0D4F14),  // Vert très sombre premium translucide
      Color(0x1A0D4F14),  // Vert très sombre premium très translucide
    ],
  );
  
  // Gradient brand (maïs + feuilles)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cornGold, leafLight],
  );
  
  // Gradients pour compatibilité (mode sombre par défaut)
  static const LinearGradient appBgGradient = appBgGradientDark;
  static const LinearGradient glassGradient = glassGradientDark;
  static const LinearGradient primaryGradient = appBgGradientDark;
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x22F6C65B), Color(0x112E7D32)],
  );
  
  // ========================================
  // ESPACEMENTS & RAYONS
  // ========================================
  
  // Espacements
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;
  
  // Rayons de bordure
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  
  // ========================================
  // OMBRES & EFFETS
  // ========================================
  
  // Ombres douces pour les cartes
  static const List<BoxShadow> cardShadows = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  // Ombres pour les boutons glow
  static const List<BoxShadow> glowShadows = [
    BoxShadow(
      color: Color(0x33F6C65B),
      offset: Offset(0, 0),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1AF6C65B),
      offset: Offset(0, 0),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  // Ombres pour compatibilité
  static const List<BoxShadow> cardShadow = cardShadows;
  
  // Ombres soft pour le mode clair menthe
  static const List<BoxShadow> softShadowLight = [
    BoxShadow(color: Color(0x1A0D4F14), blurRadius: 32, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0F0D4F14), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x080D4F14), blurRadius: 8, offset: Offset(0, 2)),
  ];
  
  // ========================================
  // TYPOGRAPHIE
  // ========================================
  
  // Typographie mode sombre
  static const TextTheme textThemeDark = TextTheme(
    // Headlines
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textPrimaryDark,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
      height: 1.3,
    ),
    
    // Titles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: textPrimaryDark,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textPrimaryDark,
      height: 1.4,
    ),
    
    // Body
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textSecondaryDark,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondaryDark,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textLowDark,
      height: 1.4,
    ),
    
    // Labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimaryDark,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondaryDark,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: textLowDark,
      height: 1.3,
    ),
  );
  
  // Typographie mode clair
  static const TextTheme textThemeLight = TextTheme(
    // Headlines
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: textPrimaryLight,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: textPrimaryLight,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textPrimaryLight,
      height: 1.3,
    ),
    
    // Titles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: textPrimaryLight,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: textPrimaryLight,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textPrimaryLight,
      height: 1.4,
    ),
    
    // Body
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textSecondaryLight,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textSecondaryLight,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textLowLight,
      height: 1.4,
    ),
    
    // Labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimaryLight,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondaryLight,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: textLowLight,
      height: 1.3,
    ),
  );
  
  // Typographie par défaut (mode sombre)
  static const TextTheme textTheme = textThemeDark;
  
  // ========================================
  // MÉTHODES DE COMPATIBILITÉ
  // ========================================
  
  /// Helper pour créer des EdgeInsets avec les espacements standard
  static EdgeInsets padding(double all) {
    return EdgeInsets.all(all);
  }
  
  static EdgeInsets paddingNamed({double? all, double? horizontal, double? vertical}) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }
  
  /// Helper pour créer des BorderRadius avec les rayons standard
  static BorderRadius radius(double radius) {
    return BorderRadius.circular(radius);
  }
  
  /// Helper pour créer des InputDecoration avec les styles standard
  static InputDecoration createInputDecoration({
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? helperText,
    EdgeInsetsGeometry? contentPadding,
    InputBorder? border,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: surfaceGlass,
      hintText: hintText,
      labelText: labelText,
      helperText: helperText,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      border: border ?? OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      enabledBorder: border ?? OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      focusedBorder: border ?? OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: cornGold,
          width: 2,
        ),
      ),
      errorBorder: border ?? OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: error,
          width: 1,
        ),
      ),
      focusedErrorBorder: border ?? OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: error,
          width: 2,
        ),
      ),
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodyMedium?.copyWith(color: textLow),
      helperStyle: textTheme.bodySmall,
      errorStyle: textTheme.bodySmall?.copyWith(color: error),
    );
  }
  
  /// Helper pour créer des ButtonStyle avec les styles standard
  static ButtonStyle buttonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsets? padding,
    OutlinedBorder? shape,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? cornGold,
      foregroundColor: foregroundColor ?? background,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: spaceLg,
        vertical: spaceMd,
      ),
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusMd),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  /// Helper pour créer des décorations de cartes
  static BoxDecoration createCardDecoration({
    Color? color,
    List<BoxShadow>? shadows,
    BorderRadius? borderRadius,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? surfaceElevated,
      borderRadius: borderRadius ?? BorderRadius.circular(radiusLg),
      boxShadow: shadows ?? cardShadows,
      border: borderColor != null ? Border.all(
        color: borderColor,
        width: 1,
      ) : null,
    );
  }
  
  /// Helper pour créer des décorations de cartes avec accent
  static BoxDecoration cardDecorationWithAccent(Color accentColor) {
    return BoxDecoration(
      color: surfaceElevated,
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: accentColor.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: cardShadows,
    );
  }
  
  /// Thème clair pour compatibilité
  static ThemeData get lightThemeCompat => lightTheme;
  
  // ========================================
  // COMPOSANTS PRÉDÉFINIS
  // ========================================
  
  /// Carte en verre avec effet de flou
  static Widget glass({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    LinearGradient? gradient,
    List<BoxShadow>? shadows,
    BorderRadius? borderRadius,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? glassGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(radiusLg),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
        boxShadow: shadows ?? cardShadows,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(spaceMd),
            child: child,
          ),
        ),
      ),
    );
  }
  
  /// Icône avec effet glow
  static Widget glowIcon(
    IconData icon, {
    double size = 24,
    Color color = textPrimary,
    List<BoxShadow>? shadows,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: shadows ?? [
          BoxShadow(
            color: color.withOpacity(0.3),
            offset: const Offset(0, 0),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
  
  /// Header de section avec titre et sous-titre
  static Widget sectionHeader(
    String title, {
    String? subtitle,
    Widget? trailing,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: spaceSm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: spaceXs),
                  Text(
                    subtitle,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
  
  /// Chip pour les statistiques
  static Widget statChip(
    String text, {
    IconData? icon,
    Color color = textSecondary,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spaceSm,
        vertical: spaceXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: spaceXs),
          ],
          Text(
            text,
            style: textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
  
  // ========================================
  // STYLES DE BOUTONS
  // ========================================
  
  /// Style de bouton principal avec glow
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: cornGold,
    foregroundColor: background,
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(
      horizontal: spaceLg,
      vertical: spaceMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );
  
  /// Style de bouton secondaire
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: surfaceElevated,
    foregroundColor: textPrimary,
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(
      horizontal: spaceLg,
      vertical: spaceMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      side: const BorderSide(
        color: Color(0x1AFFFFFF),
        width: 1,
      ),
    ),
  );
  
  /// Style de bouton avec glow
  static ButtonStyle glowButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: cornGold,
    foregroundColor: background,
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(
      horizontal: spaceLg,
      vertical: spaceMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
  );
  
  // ========================================
  // STYLES D'INPUTS
  // ========================================
  
  /// Style d'input avec effet verre
  static InputDecoration inputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? helperText,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceGlass,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: cornGold,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(
          color: error,
          width: 2,
        ),
      ),
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodyMedium?.copyWith(color: textLow),
      helperStyle: textTheme.bodySmall,
      errorStyle: textTheme.bodySmall?.copyWith(color: error),
    );
  }
  
  // ========================================
  // STYLES D'APP BAR
  // ========================================
  
  /// Style d'AppBar translucide
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: textPrimary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: textTheme.titleLarge,
    iconTheme: const IconThemeData(
      color: textPrimary,
      size: 24,
    ),
  );
  
  // ========================================
  // STYLES DE NAVIGATION
  // ========================================
  
  /// Style de BottomNavigationBar
  static BottomNavigationBarThemeData bottomNavTheme = BottomNavigationBarThemeData(
    backgroundColor: surface,
    selectedItemColor: cornGold,
    unselectedItemColor: textLow,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: textTheme.labelSmall,
    unselectedLabelStyle: textTheme.labelSmall,
  );
  
  // ========================================
  // STYLES DE SNACKBAR
  // ========================================
  
  /// Style de SnackBar avec effet verre
  static SnackBarThemeData snackBarTheme = SnackBarThemeData(
    backgroundColor: surfaceElevated,
    contentTextStyle: textTheme.bodyMedium,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
  );
  
  // ========================================
  // THÈMES COMPLETS
  // ========================================
  
  // Thème mode sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Couleurs
      colorScheme: const ColorScheme.dark(
        primary: cornGold,
        secondary: leafLight,
        surface: surfaceDark,
        background: backgroundDark,
        error: error,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
        onError: textPrimaryDark,
      ),
      
      // Typographie
      textTheme: textThemeDark,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textThemeDark.titleLarge,
        iconTheme: const IconThemeData(
          color: textPrimaryDark,
          size: 24,
        ),
      ),
      
      // Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: cornGold,
        unselectedItemColor: textLowDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textThemeDark.labelSmall,
        unselectedLabelStyle: textThemeDark.labelSmall,
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevatedDark,
        contentTextStyle: textThemeDark.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      
      // Inputs
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceGlassDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(
            color: Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(
            color: Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(
            color: cornGold,
            width: 2,
          ),
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cornGold,
          foregroundColor: backgroundDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLg,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: surfaceElevatedDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
    );
  }
  
  // Thème mode clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Couleurs
      colorScheme: const ColorScheme.light(
        primary: cornGold,
        secondary: leafLight,
        surface: surfaceLight,
        background: backgroundLight,
        error: error,
        onPrimary: backgroundLight,
        onSecondary: backgroundLight,
        onSurface: textPrimaryLight,
        onBackground: textPrimaryLight,
        onError: textPrimaryLight,
      ),
      
      // Typographie
      textTheme: textThemeLight,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textThemeLight.titleLarge,
        iconTheme: const IconThemeData(
          color: textPrimaryLight,
          size: 24,
        ),
      ),
      
      // Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: cornGold,
        unselectedItemColor: textLowLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textThemeLight.labelSmall,
        unselectedLabelStyle: textThemeLight.labelSmall,
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevatedLight,
        contentTextStyle: textThemeLight.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      
      // Inputs
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceGlassLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(
            color: Color(0x1A000000),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(
            color: Color(0x1A000000),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
          borderSide: BorderSide(
            color: cornGold,
            width: 2,
          ),
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cornGold,
          foregroundColor: backgroundLight,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLg,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: surfaceElevatedLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
    );
  }
  
  // Thème clair (même structure que le sombre mais en vert)
  static ThemeData get lightThemeMint => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: cornGold,
      surface: surfaceLight,
      background: backgroundLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: textPrimaryLight,
      onBackground: textPrimaryLight,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textPrimaryLight),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimaryLight),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimaryLight),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textSecondaryLight),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryLight),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondaryLight),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textLowLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimaryLight),
      surfaceTintColor: Colors.transparent,
      foregroundColor: textPrimaryLight,
    ),
    cardTheme: CardTheme(
      color: surfaceElevatedLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceGlassLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textLowLight, fontWeight: FontWeight.w600),
      labelStyle: const TextStyle(color: textSecondaryLight, fontWeight: FontWeight.w700),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0x1A2E7D32)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary, width: 1.6),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0x1A2E7D32)),
      ),
    ),
  );
  
  // Thème par défaut (mode sombre)
  static ThemeData get theme => darkTheme;
  
  // ========================================
  // MÉTHODES POUR GESTION DES THÈMES
  // ========================================
  
  /// Obtient les couleurs selon le mode (dark/light)
  static AppThemeColors getColors(bool isDark) {
    return isDark ? AppThemeColors.dark() : AppThemeColors.light();
  }
  
  /// Obtient les gradients selon le mode (dark/light)
  static AppThemeGradients getGradients(bool isDark) {
    return isDark ? AppThemeGradients.dark() : AppThemeGradients.light();
  }
  
  /// Obtient la typographie selon le mode (dark/light)
  static TextTheme getTextTheme(bool isDark) {
    return isDark ? textThemeDark : textThemeLight;
  }
  
  /// Obtient le thème complet selon le mode (dark/light)
  static ThemeData getTheme(bool isDark) {
    return isDark ? darkTheme : lightThemeMint;
  }
  
  // ========================================
  // MÉTHODES POUR FOND ET CARTES GLASS
  // ========================================
  
  /// Fond (dégradé dark/clair auto)
  static BoxDecoration appBackground(BuildContext ctx) {
    final light = Theme.of(ctx).brightness == Brightness.light;
    return BoxDecoration(gradient: light ? appBgGradientLight : appBgGradientDark);
  }
  
  /// Carte glass premium adaptée
  static Widget glassAdapted({
    required BuildContext context,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    double radius = 20,
  }) {
    final light = Theme.of(context).brightness == Brightness.light;
    final overlay = light ? const Color(0x800D4F14) : const Color(0x66131F19);
    final stroke = light ? const Color(0x2A0D4F14) : const Color(0x22FFFFFF);
    final shadow = light ? softShadowLight : [const BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8))];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: stroke, width: 1.5),
        boxShadow: shadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: overlay,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ========================================
// CLASSES POUR GESTION DES COULEURS
// ========================================

class AppThemeColors {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceGlass;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLow;
  final Color primary;
  final Color onPrimary;
  final Color success;
  final Color error;
  
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceGlass,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLow,
    required this.primary,
    required this.onPrimary,
    required this.success,
    required this.error,
  });
  
  factory AppThemeColors.dark() {
    return const AppThemeColors(
      background: AppTheme.backgroundDark,
      surface: AppTheme.surfaceDark,
      surfaceElevated: AppTheme.surfaceElevatedDark,
      surfaceGlass: AppTheme.surfaceGlassDark,
      textPrimary: AppTheme.textPrimaryDark,
      textSecondary: AppTheme.textSecondaryDark,
      textLow: AppTheme.textLowDark,
      primary: AppTheme.primary,
      onPrimary: AppTheme.onPrimary,
      success: AppTheme.success,
      error: AppTheme.error,
    );
  }
  
  factory AppThemeColors.light() {
    return const AppThemeColors(
      background: AppTheme.backgroundLight,
      surface: AppTheme.surfaceLight,
      surfaceElevated: AppTheme.surfaceElevatedLight,
      surfaceGlass: AppTheme.surfaceGlassLight,
      textPrimary: AppTheme.textPrimaryLight,
      textSecondary: AppTheme.textSecondaryLight,
      textLow: AppTheme.textLowLight,
      primary: AppTheme.primary,
      onPrimary: AppTheme.onPrimary,
      success: AppTheme.success,
      error: AppTheme.error,
    );
  }
}

class AppThemeGradients {
  final LinearGradient appBg;
  final LinearGradient glass;
  
  const AppThemeGradients({
    required this.appBg,
    required this.glass,
  });
  
  factory AppThemeGradients.dark() {
    return const AppThemeGradients(
      appBg: AppTheme.appBgGradientDark,
      glass: AppTheme.glassGradientDark,
    );
  }
  
  factory AppThemeGradients.light() {
    return const AppThemeGradients(
      appBg: AppTheme.appBgGradientLight,
      glass: AppTheme.glassGradientLight,
    );
  }
}

// ========================================
// EXTENSIONS POUR FACILITER L'USAGE
// ========================================

extension AppThemeContext on BuildContext {
  TextTheme get text => AppTheme.textTheme;
  
  Widget get gapXs => const SizedBox(height: AppTheme.spaceXs);
  Widget get gapSm => const SizedBox(height: AppTheme.spaceSm);
  Widget get gapMd => const SizedBox(height: AppTheme.spaceMd);
  Widget get gapLg => const SizedBox(height: AppTheme.spaceLg);
  Widget get gapXl => const SizedBox(height: AppTheme.spaceXl);
  Widget get gapXxl => const SizedBox(height: AppTheme.spaceXxl);
  
  Widget get gapXsW => const SizedBox(width: AppTheme.spaceXs);
  Widget get gapSmW => const SizedBox(width: AppTheme.spaceSm);
  Widget get gapMdW => const SizedBox(width: AppTheme.spaceMd);
  Widget get gapLgW => const SizedBox(width: AppTheme.spaceLg);
  Widget get gapXlW => const SizedBox(width: AppTheme.spaceXl);
  Widget get gapXxlW => const SizedBox(width: AppTheme.spaceXxl);
}
