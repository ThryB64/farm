import 'package:flutter/material.dart';

class AppTheme {
  // === COULEURS (Palette courte) ===
  
  // Primary (Green)
  static const Color primary = Color(0xFF1F8A48);
  static const Color primaryDark = Color(0xFF156036);
  
  // Accent (Amber)
  static const Color accent = Color(0xFFF4A737);
  
  // Surface & Background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7F6);
  
  // Text
  static const Color textMain = Color(0xFF1B2B34);
  static const Color textMuted = Color(0xFF6B7C87);
  
  // Border
  static const Color border = Color(0xFFE4E8EA);
  
  // States
  static const Color success = Color(0xFF1F8A48);
  static const Color warning = Color(0xFFE57E25);
  static const Color danger = Color(0xFFC7423A);
  
  // === TYPOGRAPHIE ===
  
  static const String fontFamily = 'Inter';
  
  // Hiérarchie typographique
  static const TextStyle displayKPI = TextStyle(
    fontSize: 30,
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
    fontWeight: FontWeight.w600,
    color: textMain,
    fontFamily: fontFamily,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
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
    fontWeight: FontWeight.w500,
    color: textMuted,
    fontFamily: fontFamily,
  );
  
  // === RAYONS, OMBRES, ESPACEMENTS ===
  
  // Rayons
  static const double radiusChip = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusModal = 24.0;
  
  // Ombres
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  // Espacements (grille 8-pt)
  static const double spacingXS = 4.0;   // 0.5 * 8
  static const double spacingS = 8.0;    // 1 * 8
  static const double spacingM = 16.0;   // 2 * 8
  static const double spacingL = 24.0;   // 3 * 8
  static const double spacingXL = 32.0;  // 4 * 8
  static const double spacingXXL = 48.0;  // 6 * 8
  
  // Marges page
  static const double pageMarginDesktop = 24.0;
  static const double pageMarginMobile = 16.0;
  
  // Gouttières cartes
  static const double cardGutter = 16.0;
  
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
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: h2,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x0A000000),
      ),
      
      // Cards
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
          foregroundColor: primary,
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
            borderRadius: BorderRadius.circular(radiusChip),
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
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // === COMPOSANTS RÉUTILISABLES ===
  
  // Carte KPI
  static Widget buildKPICard({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    String? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(spacingM),
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
              Icon(icon, size: 32, color: textMuted),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: spacingS,
                    vertical: spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(radiusChip),
                  ),
                  child: Text(
                    trend,
                    style: meta.copyWith(color: success),
                  ),
                ),
            ],
          ),
          const SizedBox(height: spacingM),
          Text(
            label,
            style: meta,
          ),
          const SizedBox(height: spacingXS),
          Text(
            value,
            style: displayKPI.copyWith(
              color: valueColor ?? textMain,
            ),
          ),
        ],
      ),
    );
  }
  
  // Carte menu
  static Widget buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
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
                Icon(icon, size: 48, color: primary),
                const SizedBox(height: spacingM),
                Text(title, style: h2),
                const SizedBox(height: spacingXS),
                Text(subtitle, style: body),
                const SizedBox(height: spacingM),
                Row(
                  children: [
                    Text('Ouvrir', style: body.copyWith(color: primary)),
                    const SizedBox(width: spacingXS),
                    Icon(Icons.arrow_forward, size: 16, color: primary),
                  ],
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
        horizontal: spacingS,
        vertical: spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radiusChip),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: meta.copyWith(color: color),
      ),
    );
  }
}