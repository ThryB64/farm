import 'package:flutter/material.dart';

class AppTheme {
  // === COULEURS (selon brief) ===
  
  // Vert principal pour actions et accents
  static const Color primary = Color(0xFF1F8A48);
  
  // Gris clair pour fond de page
  static const Color background = Color(0xFFF5F7F6);
  
  // Texte bleu-gris foncé pour contenu
  static const Color textMain = Color(0xFF1B2B34);
  
  // Accent jaune/ambre pour KPI importants
  static const Color accent = Color(0xFFF4A737);
  
  // Couleurs secondaires
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF6B7C87);
  static const Color border = Color(0xFFE4E8EA);
  
  // États
  static const Color success = Color(0xFF1F8A48);
  static const Color warning = Color(0xFFE57E25);
  static const Color danger = Color(0xFFC7423A);
  
  // === TYPOGRAPHIE ===
  
  static const String fontFamily = 'Inter';
  
  // Hiérarchie typographique
  static const TextStyle displayKPI = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textMain,
    fontFamily: fontFamily,
  );
  
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textMain,
    fontFamily: fontFamily,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textMain,
    fontFamily: fontFamily,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textMain,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textMain,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textMain,
    fontFamily: fontFamily,
  );
  
  static const TextStyle meta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textMuted,
    fontFamily: fontFamily,
  );
  
  // === RAYONS, OMBRES, ESPACEMENTS ===
  
  // Rayons (selon brief)
  static const double radiusCard = 16.0;
  
  // Ombres douces
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  // Espacements généreux (selon brief)
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // === THÈME PRINCIPAL ===
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textMain,
        onBackground: textMain,
        onError: Colors.white,
      ),
      
      // AppBar (fond blanc, ombre subtile)
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: h2,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x0A000000),
      ),
      
      // Cards (blanches, arrondies, ombre douce)
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        color: surface,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: EdgeInsets.zero,
      ),
      
      // Buttons
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
            borderRadius: BorderRadius.circular(radiusCard),
          ),
          textStyle: h3,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMuted,
          side: const BorderSide(color: border, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
          textStyle: h3,
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
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: body,
        ),
      ),
      
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          borderSide: const BorderSide(color: danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingM,
        ),
        labelStyle: meta,
        hintStyle: TextStyle(
          color: textMuted,
          fontSize: 14,
        ),
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
  
  // === COMPOSANTS RÉUTILISABLES ===
  
  // Carte KPI (selon brief)
  static Widget buildKPICard({
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(spacingL),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusCard),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (iconColor ?? primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? primary,
                  size: 24,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: spacingL),
          Text(
            label,
            style: meta,
          ),
          const SizedBox(height: spacingS),
          Text(
            value,
            style: displayKPI,
          ),
        ],
      ),
    );
  }
  
  // Carte menu (selon brief)
  static Widget buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radiusCard),
        boxShadow: cardShadow,
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (iconColor ?? primary).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: spacingL),
                Text(
                  title,
                  style: h2,
                ),
                const SizedBox(height: spacingS),
                Text(
                  subtitle,
                  style: body.copyWith(color: textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Badge statut
  static Widget buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: meta.copyWith(color: color),
      ),
    );
  }
}