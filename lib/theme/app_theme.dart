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
  // COULEURS D'ÉTAT (communes)
  // ========================================
  
  static const Color success = Color(0xFF4CAF50);          // Succès (vert feuille)
  static const Color warning = Color(0xFFF6C65B);          // Attention (or maïs)
  static const Color error = Color(0xFFE57373);             // Erreur
  static const Color info = Color(0xFF64B5F6);             // Information
  
  // ========================================
  // COULEURS DYNAMIQUES (selon le mode)
  // ========================================
  
  // Couleurs de base (changent selon le mode)
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const Color(0xFF0D4F14)  // Vert très sombre premium (mode clair)
        : const Color(0xFF0A0E0B); // Fond principal très sombre (mode sombre)
  }
  
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const Color(0xFF1B5E20)  // Surface vert sombre profond (mode clair)
        : const Color(0xFF1A1F1C); // Surface principale (mode sombre)
  }
  
  static Color surfaceElevated(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const Color(0xFF2E7D32)  // Surface élevée vert normal (mode clair)
        : const Color(0xFF242A26); // Surface élevée (mode sombre)
  }
  
  static Color surfaceGlass(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const Color(0xFF0D4F14)  // Surface verre vert très sombre (mode clair)
        : const Color(0x1AFFFFFF); // Verre translucide (mode sombre)
  }
  
  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const Color(0xFFFFFFFF)  // Texte principal blanc pur (mode clair)
        : const Color(0xFFFFFFFF); // Texte principal (mode sombre)
  }
  
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const Color(0xFFE8F5E8)  // Texte secondaire vert très clair (mode clair)
        : const Color(0xFFB8C5BA); // Texte secondaire (mode sombre)
  }
  
  static Color textLow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const Color(0xFFB8E6C1)  // Texte discret vert clair premium (mode clair)
        : const Color(0xFF7A8B7D); // Texte discret (mode sombre)
  }
  
  // ========================================
  // ALIAS POUR COMPATIBILITÉ
  // ========================================
  
  // Couleurs principales (alias)
  static Color primary(BuildContext context) => cornGold;
  static Color secondary(BuildContext context) => leafLight;
  static Color onPrimary(BuildContext context) => background(context);
  static Color onSecondary(BuildContext context) => background(context);
  static Color onBackground(BuildContext context) => textPrimary(context);
  static Color onSurface(BuildContext context) => textPrimary(context);
  static Color textLight(BuildContext context) => textLow(context);
  static Color border(BuildContext context) => Theme.of(context).brightness == Brightness.light 
      ? const Color(0x1A2E7D32) 
      : const Color(0x1AFFFFFF);
  static Color accent(BuildContext context) => cornGold;
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
  
  // Tailles d'icônes (alias)
  static const double iconSizeXS = 12.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 64.0;
  
  // Élévations (alias)
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  
  // Durées d'animation (alias)
  static const Duration durationFast = Duration(milliseconds: 300);
  static const Duration durationMedium = Duration(milliseconds: 500);
  static const Duration durationSlow = Duration(milliseconds: 800);
  
  // Gradients pour compatibilité
  static LinearGradient primaryGradient(BuildContext context) => brandGradient;
  static LinearGradient secondaryGradient(BuildContext context) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x22F6C65B), Color(0x112E7D32)],
  );
  
  // Thème clair pour compatibilité
  static ThemeData get lightThemeCompat => lightTheme;
  
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
  // GRADIENTS DYNAMIQUES
  // ========================================
  
  // Gradient principal de l'app
  static LinearGradient appBgGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D4F14),  // Vert très sombre premium (coin TL)
              Color(0xFF1B5E20),  // Vert sombre profond (milieu)
              Color(0xFF0D4F14),  // Vert très sombre premium (coin BR)
            ],
            stops: [0.0, 0.5, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E0B),  // Fond sombre
              Color(0xFF1A1F1C), // Surface
              Color(0xFF0F1411), // Retour au sombre
            ],
            stops: [0.0, 0.5, 1.0],
          );
  }
  
  // Gradient verre pour les cartes
  static LinearGradient glassGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x2A0D4F14),  // Vert très sombre premium translucide
              Color(0x1A0D4F14),  // Vert très sombre premium très translucide
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x1AFFFFFF),  // Blanc translucide
              Color(0x0DFFFFFF),  // Blanc très translucide
            ],
          );
  }
  
  // Gradient brand (maïs + feuilles)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cornGold, leafLight],
  );
  
  // ========================================
  // OMBRES & EFFETS
  // ========================================
  
  // Ombres douces pour les cartes
  static List<BoxShadow> cardShadows(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? const [
            BoxShadow(color: Color(0x1A0D4F14), blurRadius: 32, offset: Offset(0, 12)),
            BoxShadow(color: Color(0x0F0D4F14), blurRadius: 16, offset: Offset(0, 4)),
            BoxShadow(color: Color(0x080D4F14), blurRadius: 8, offset: Offset(0, 2)),
          ]
        : const [
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
  }
  
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
  
  // ========================================
  // TYPOGRAPHIE DYNAMIQUE
  // ========================================
  
  // Typographie selon le mode
  static TextTheme textTheme(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textPrimaryColor = textPrimary(context);
    final textSecondaryColor = textSecondary(context);
    final textLowColor = textLow(context);
    
    return TextTheme(
      // Headlines
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      
      // Titles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        height: 1.4,
      ),
      
      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textLowColor,
        height: 1.4,
      ),
      
      // Labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textLowColor,
        height: 1.3,
      ),
    );
  }
  
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
  static InputDecoration createInputDecoration(
    BuildContext context, {
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
      fillColor: surfaceGlass(context),
      hintText: hintText,
      labelText: labelText,
      helperText: helperText,
      contentPadding: contentPadding,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      border: border ?? OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(
          color: AppTheme.border(context),
          width: 1,
        ),
      ),
      enabledBorder: border ?? OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(
          color: AppTheme.border(context),
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
      labelStyle: textTheme(context).bodyMedium,
      hintStyle: textTheme(context).bodyMedium?.copyWith(color: textLow(context)),
      helperStyle: textTheme(context).bodySmall,
      errorStyle: textTheme(context).bodySmall?.copyWith(color: error),
    );
  }
  
  /// Helper pour créer des ButtonStyle avec les styles standard
  static ButtonStyle buttonStyle(
    BuildContext context, {
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsets? padding,
    OutlinedBorder? shape,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? cornGold,
      foregroundColor: foregroundColor ?? background(context),
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
  static BoxDecoration createCardDecoration(
    BuildContext context, {
    Color? color,
    List<BoxShadow>? shadows,
    BorderRadius? borderRadius,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? surfaceElevated(context),
      borderRadius: borderRadius ?? BorderRadius.circular(radiusLg),
      boxShadow: shadows ?? cardShadows(context),
      border: borderColor != null ? Border.all(
        color: borderColor,
        width: 1,
      ) : null,
    );
  }
  
  /// Helper pour créer des décorations de cartes avec accent
  static BoxDecoration cardDecorationWithAccent(BuildContext context, Color accentColor) {
    return BoxDecoration(
      color: surfaceElevated(context),
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: accentColor.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: cardShadows(context),
    );
  }
  
  // ========================================
  // COMPOSANTS PRÉDÉFINIS
  // ========================================
  
  /// Carte en verre avec effet de flou
  static Widget glass(
    BuildContext context, {
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
        gradient: gradient ?? glassGradient(context),
        borderRadius: borderRadius ?? BorderRadius.circular(radiusLg),
        border: Border.all(
          color: AppTheme.border(context),
          width: 1,
        ),
        boxShadow: shadows ?? cardShadows(context),
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
    BuildContext context,
    IconData icon, {
    double size = 24,
    Color? color,
    List<BoxShadow>? shadows,
  }) {
    final iconColor = color ?? textPrimary(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: shadows ?? [
          BoxShadow(
            color: iconColor.withOpacity(0.3),
            offset: const Offset(0, 0),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: iconColor,
      ),
    );
  }
  
  /// Header de section avec titre et sous-titre
  static Widget sectionHeader(
    BuildContext context,
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
                  style: textTheme(context).titleLarge,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: spaceXs),
                  Text(
                    subtitle,
                    style: textTheme(context).bodyMedium,
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
    BuildContext context,
    String text, {
    IconData? icon,
    Color? color,
    Color? backgroundColor,
  }) {
    final chipColor = color ?? textSecondary(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spaceSm,
        vertical: spaceXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radiusSm),
        border: Border.all(
          color: chipColor.withOpacity(0.2),
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
              color: chipColor,
            ),
            const SizedBox(width: spaceXs),
          ],
          Text(
            text,
            style: textTheme(context).labelMedium?.copyWith(color: chipColor),
          ),
        ],
      ),
    );
  }
  
  // ========================================
  // STYLES DE BOUTONS
  // ========================================
  
  /// Style de bouton principal avec glow
  static ButtonStyle primaryButtonStyle(BuildContext context) => ElevatedButton.styleFrom(
    backgroundColor: cornGold,
    foregroundColor: background(context),
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
  static ButtonStyle secondaryButtonStyle(BuildContext context) => ElevatedButton.styleFrom(
    backgroundColor: surfaceElevated(context),
    foregroundColor: textPrimary(context),
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(
      horizontal: spaceLg,
      vertical: spaceMd,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      side: BorderSide(
        color: border(context),
        width: 1,
      ),
    ),
  );
  
  /// Style de bouton avec glow
  static ButtonStyle glowButtonStyle(BuildContext context) => ElevatedButton.styleFrom(
    backgroundColor: cornGold,
    foregroundColor: background(context),
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
  static InputDecoration inputDecoration(
    BuildContext context, {
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
      fillColor: surfaceGlass(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(
          color: AppTheme.border(context),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(
          color: AppTheme.border(context),
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
      labelStyle: textTheme(context).bodyMedium,
      hintStyle: textTheme(context).bodyMedium?.copyWith(color: textLow(context)),
      helperStyle: textTheme(context).bodySmall,
      errorStyle: textTheme(context).bodySmall?.copyWith(color: error),
    );
  }
  
  // ========================================
  // STYLES D'APP BAR
  // ========================================
  
  /// Style d'AppBar translucide
  static AppBarTheme appBarTheme(BuildContext context) => AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: textPrimary(context),
    elevation: 0,
    centerTitle: false,
    titleTextStyle: textTheme(context).titleLarge,
    iconTheme: IconThemeData(
      color: textPrimary(context),
      size: 24,
    ),
  );
  
  // ========================================
  // STYLES DE NAVIGATION
  // ========================================
  
  /// Style de BottomNavigationBar
  static BottomNavigationBarThemeData bottomNavTheme(BuildContext context) => BottomNavigationBarThemeData(
    backgroundColor: surface(context),
    selectedItemColor: cornGold,
    unselectedItemColor: textLow(context),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: textTheme(context).labelSmall,
    unselectedLabelStyle: textTheme(context).labelSmall,
  );
  
  // ========================================
  // STYLES DE SNACKBAR
  // ========================================
  
  /// Style de SnackBar avec effet verre
  static SnackBarThemeData snackBarTheme(BuildContext context) => SnackBarThemeData(
    backgroundColor: surfaceElevated(context),
    contentTextStyle: textTheme(context).bodyMedium,
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
        surface: Color(0xFF1A1F1C),
        background: Color(0xFF0A0E0B),
        error: error,
        onPrimary: Color(0xFF0A0E0B),
        onSecondary: Color(0xFF0A0E0B),
        onSurface: Color(0xFFFFFFFF),
        onBackground: Color(0xFFFFFFFF),
        onError: Color(0xFFFFFFFF),
      ),
      
      // Typographie
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFB8C5BA)),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFB8C5BA)),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF7A8B7D)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFB8C5BA)),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF7A8B7D)),
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF), size: 24),
      ),
      
      // Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1F1C),
        selectedItemColor: cornGold,
        unselectedItemColor: Color(0xFF7A8B7D),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF7A8B7D)),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF7A8B7D)),
      ),
      
      // SnackBar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF242A26),
        contentTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFB8C5BA)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      
      // Inputs
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0x1AFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: cornGold, width: 2),
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(cornGold),
          foregroundColor: MaterialStatePropertyAll(Color(0xFF0A0E0B)),
          elevation: MaterialStatePropertyAll(0),
          shadowColor: MaterialStatePropertyAll(Colors.transparent),
          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
        ),
      ),
      
      // Cards
      cardTheme: const CardTheme(
        color: Color(0xFF242A26),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
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
        surface: Color(0xFF1B5E20),
        background: Color(0xFF0D4F14),
        error: error,
        onPrimary: Color(0xFF0D4F14),
        onSecondary: Color(0xFF0D4F14),
        onSurface: Color(0xFFFFFFFF),
        onBackground: Color(0xFFFFFFFF),
        onError: Color(0xFFFFFFFF),
      ),
      
      // Typographie
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFE8F5E8)),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFE8F5E8)),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFFB8E6C1)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF)),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE8F5E8)),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFB8E6C1)),
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF), size: 24),
      ),
      
      // Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1B5E20),
        selectedItemColor: cornGold,
        unselectedItemColor: Color(0xFFB8E6C1),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFB8E6C1)),
        unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFB8E6C1)),
      ),
      
      // SnackBar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF2E7D32),
        contentTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFE8F5E8)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      
      // Inputs
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF0D4F14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0x1A2E7D32), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0x1A2E7D32), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: cornGold, width: 2),
        ),
      ),
      
      // Boutons
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(cornGold),
          foregroundColor: MaterialStatePropertyAll(Color(0xFF0D4F14)),
          elevation: MaterialStatePropertyAll(0),
          shadowColor: MaterialStatePropertyAll(Colors.transparent),
          padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
        ),
      ),
      
      // Cards
      cardTheme: const CardTheme(
        color: Color(0xFF2E7D32),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
  }
  
  // Thème par défaut (mode sombre)
  static ThemeData get theme => darkTheme;
  
  // ========================================
  // MÉTHODES POUR GESTION DES THÈMES
  // ========================================
  
  /// Obtient le thème complet selon le mode (dark/light)
  static ThemeData getTheme(bool isDark) {
    return isDark ? darkTheme : lightTheme;
  }
  
  // ========================================
  // MÉTHODES POUR FOND ET CARTES GLASS
  // ========================================
  
  /// Fond (dégradé dark/clair auto)
  static BoxDecoration appBackground(BuildContext context) {
    return BoxDecoration(gradient: appBgGradient(context));
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
    final shadow = light ? cardShadows(context) : [const BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8))];

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
// EXTENSIONS POUR FACILITER L'USAGE
// ========================================

extension AppThemeContext on BuildContext {
  TextTheme get text => AppTheme.textTheme(this);
  
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

// ========================================
// MÉTHODES CENTRALISÉES POUR DESIGN UNIFORME
// ========================================

/// Méthodes centralisées pour design uniforme
class AppThemePageBuilder {
  /// Structure standardisée pour toutes les pages
  static Widget buildStandardPage({
    required BuildContext context,
    required String title,
    required Widget body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    bool showBackButton = true,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary(context),
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        actions: actions,
      ),
      body: Container(
        decoration: AppTheme.appBackground(context),
        child: SafeArea(
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  /// Structure standardisée pour les pages avec contenu scrollable (style page d'accueil)
  static Widget buildScrollablePage({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    List<Widget>? actions,
    Widget? floatingActionButton,
    bool showBackButton = true,
    EdgeInsets? padding,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary(context),
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        actions: actions,
      ),
      body: Container(
        decoration: AppTheme.appBackground(context),
        child: SafeArea(
          child: ListView(
            padding: padding ?? const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: children,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  /// Structure standardisée pour les pages avec contenu en colonne (style page d'accueil)
  static Widget buildColumnPage({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    List<Widget>? actions,
    Widget? floatingActionButton,
    bool showBackButton = true,
    EdgeInsets? padding,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.stretch,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary(context),
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        actions: actions,
      ),
      body: Container(
        decoration: AppTheme.appBackground(context),
        child: SafeArea(
          child: Padding(
            padding: padding ?? const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  /// Section d'en-tête standardisée
  static Widget buildPageHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
  }) {
    return AppTheme.glass(
      context,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: AppTheme.padding(AppTheme.spacingS),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (iconColor ?? AppTheme.cornGold).withOpacity(0.8),
                    (iconColor ?? AppTheme.cornGold).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? AppTheme.cornGold).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.textTheme(context).titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    subtitle,
                    style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
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

  /// Section de contenu standardisée avec effet de verre
  static Widget buildContentSection({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    Color? gradientColor,
  }) {
    return AppTheme.glass(
      context,
      gradient: gradientColor != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColor.withOpacity(0.2),
                gradientColor.withOpacity(0.1),
              ],
            )
          : null,
      child: Padding(
        padding: padding ?? AppTheme.padding(AppTheme.spacingM),
        child: child,
      ),
    );
  }

  /// Bouton d'action standardisé
  static Widget buildActionButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          foregroundColor: backgroundColor ?? AppTheme.primary(context),
          side: BorderSide(color: backgroundColor ?? AppTheme.primary(context)),
          backgroundColor: Colors.transparent,
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primary(context),
          foregroundColor: textColor ?? AppTheme.onPrimary(context),
        ),
      );
    }
  }

  /// Liste d'éléments standardisée
  static Widget buildItemList({
    required BuildContext context,
    required List<Widget> items,
    EdgeInsets? padding,
  }) {
    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
        child: item,
      )).toList(),
    );
  }

  /// Message d'état vide standardisé (style page d'accueil)
  static Widget buildEmptyState({
    required BuildContext context,
    required String message,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondary(context),
            ),
            const SizedBox(height: AppTheme.spaceLg),
          ],
          Text(
            message,
            style: AppTheme.textTheme(context).bodyLarge?.copyWith(
              color: AppTheme.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: AppTheme.spaceLg),
            buildActionButton(
              context: context,
              text: actionText,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }

  /// Section avec effet de verre (style page d'accueil)
  static Widget buildGlassSection({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    Color? gradientColor,
  }) {
    return AppTheme.glass(
      context,
      gradient: gradientColor != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColor.withOpacity(0.2),
                gradientColor.withOpacity(0.1),
              ],
            )
          : null,
      child: Padding(
        padding: padding ?? AppTheme.padding(AppTheme.spacingM),
        child: child,
      ),
    );
  }

  /// En-tête de section avec icône et titre (style page d'accueil)
  static Widget buildSectionHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
  }) {
    return AppTheme.sectionHeader(
      context,
      title,
      subtitle: subtitle,
      trailing: trailing,
    );
  }

  /// Carte de statistique (style page d'accueil)
  static Widget buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    IconData? icon,
    Color? color,
  }) {
    return AppTheme.statChip(
      context,
      '$label: $value',
      icon: icon,
      color: color,
    );
  }

  /// Icône avec effet de halo (style page d'accueil)
  static Widget buildGlowIcon({
    required BuildContext context,
    required IconData icon,
    Color? color,
    double? size,
  }) {
    return AppTheme.glowIcon(
      context,
      icon,
      color: color,
      size: size ?? 24.0,
    );
  }
}