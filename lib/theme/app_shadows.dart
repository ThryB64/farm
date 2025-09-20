import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design System Shadows - Effets de profondeur
class AppShadows {
  // Ombres de base
  static const BoxShadow elevation1 = BoxShadow(
    color: Color.fromRGBO(1, 50, 55, 0.12),
    offset: Offset(0, 2),
    blurRadius: 6,
    spreadRadius: 0,
  );

  static const BoxShadow elevation2 = BoxShadow(
    color: Color.fromRGBO(1, 50, 55, 0.18),
    offset: Offset(0, 8),
    blurRadius: 24,
    spreadRadius: 0,
  );

  static const BoxShadow elevation3 = BoxShadow(
    color: Color.fromRGBO(1, 50, 55, 0.25),
    offset: Offset(0, 12),
    blurRadius: 32,
    spreadRadius: 0,
  );

  // Ombres spéciales
  static const BoxShadow glassShadow = BoxShadow(
    color: Color.fromRGBO(1, 50, 55, 0.18),
    offset: Offset(0, 8),
    blurRadius: 24,
    spreadRadius: 0,
  );

  static const BoxShadow glassShadowSmall = BoxShadow(
    color: Color.fromRGBO(1, 50, 55, 0.12),
    offset: Offset(0, 2),
    blurRadius: 6,
    spreadRadius: 0,
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: Color.fromRGBO(1, 50, 55, 0.18),
    offset: Offset(0, 8),
    blurRadius: 20,
    spreadRadius: 0,
  );

  static const BoxShadow fabShadow = BoxShadow(
    color: Color.fromRGBO(1, 50, 55, 0.25),
    offset: Offset(0, 12),
    blurRadius: 24,
    spreadRadius: 0,
  );

  // Ombres pour texte sur dégradé
  static const BoxShadow textShadow = BoxShadow(
    color: Color.fromRGBO(1, 50, 55, 0.2),
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
  );

  // Collections d'ombres
  static const List<BoxShadow> cardShadows = [elevation1, elevation2];
  static const List<BoxShadow> buttonShadows = [buttonShadow];
  static const List<BoxShadow> fabShadows = [fabShadow];
  static const List<BoxShadow> glassShadows = [glassShadow];
}
