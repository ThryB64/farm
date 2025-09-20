import 'package:flutter/material.dart';

/// Design System Colors - Palette complète
class AppColors {
  // Couleurs principales (Image 2)
  static const Color sand = Color(0xFFF6E8DF);        // Fond crème principal
  static const Color coral = Color(0xFFFEAE96);       // Primaire 1 (CTA, curseurs)
  static const Color salmon = Color(0xFFFE979C);     // Primaire 2 (dégradés)
  static const Color deepNavy = Color(0xFF013237);    // Texte/titres/icônes

  // Couleurs sémantiques
  static const Color success = Color(0xFF21A179);
  static const Color warning = Color(0xFFE5A100);
  static const Color danger = Color(0xFFE05260);

  // Couleurs de texte avec opacité
  static Color get navy90 => deepNavy.withOpacity(0.9);
  static Color get navy70 => deepNavy.withOpacity(0.7);
  static Color get navy50 => deepNavy.withOpacity(0.5);
  static Color get navy40 => deepNavy.withOpacity(0.4);
  static Color get navy24 => deepNavy.withOpacity(0.24);
  static Color get navy10 => deepNavy.withOpacity(0.1);

  // Glass effects
  static const Color glassLight = Color.fromRGBO(255, 255, 255, 0.16);
  static const Color glassDark = Color.fromRGBO(1, 50, 55, 0.35);
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.35);
  static const Color glassBorderDark = Color.fromRGBO(255, 255, 255, 0.22);

  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coral, salmon],
    stops: [0.0, 1.0],
  );

  static const LinearGradient navyTint = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(1, 50, 55, 0.24),
      Color.fromRGBO(1, 50, 55, 0.0),
    ],
  );

  // Background glow
  static const RadialGradient backgroundGlow = RadialGradient(
    center: Alignment.center,
    radius: 1.5,
    colors: [
      Color.fromRGBO(254, 174, 150, 0.1),
      Color.fromRGBO(254, 151, 156, 0.08),
    ],
  );
}
