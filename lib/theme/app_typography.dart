import 'package:flutter/material.dart';

/// Design System Typography - Circular Std
class AppTypography {
  // Tailles de police
  static const double displayLarge = 40.0;
  static const double displayMedium = 34.0;
  static const double h1 = 28.0;
  static const double h2 = 22.0;
  static const double h3 = 18.0;
  static const double body = 16.0;
  static const double caption = 13.0;
  static const double meta = 12.0;

  // Tracking (letter spacing)
  static const double trackingTight = -0.02;
  static const double trackingNormal = 0.0;
  static const double trackingWide = 0.01;

  // Styles de texte
  static const TextStyle displayLargeStyle = TextStyle(
    fontSize: displayLarge,
    fontWeight: FontWeight.bold,
    letterSpacing: trackingTight,
    color: Color(0xFF013237),
  );

  static const TextStyle displayMediumStyle = TextStyle(
    fontSize: displayMedium,
    fontWeight: FontWeight.bold,
    letterSpacing: trackingTight,
    color: Color(0xFF013237),
  );

  static const TextStyle h1Style = TextStyle(
    fontSize: h1,
    fontWeight: FontWeight.bold,
    letterSpacing: trackingNormal,
    color: Color(0xFF013237),
  );

  static const TextStyle h2Style = TextStyle(
    fontSize: h2,
    fontWeight: FontWeight.bold,
    letterSpacing: trackingNormal,
    color: Color(0xFF013237),
  );

  static const TextStyle h3Style = TextStyle(
    fontSize: h3,
    fontWeight: FontWeight.w500,
    letterSpacing: trackingNormal,
    color: Color(0xFF013237),
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: body,
    fontWeight: FontWeight.w400,
    letterSpacing: trackingNormal,
    color: Color(0xFF013237),
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: caption,
    fontWeight: FontWeight.w400,
    letterSpacing: trackingNormal,
    color: Color(0xFF013237),
  );

  static const TextStyle metaStyle = TextStyle(
    fontSize: meta,
    fontWeight: FontWeight.w400,
    letterSpacing: trackingWide,
    color: Color(0xFF013237),
  );

  // Styles avec opacité
  static TextStyle get bodySecondary => bodyStyle.copyWith(
    color: bodyStyle.color!.withOpacity(0.7),
  );

  static TextStyle get captionSecondary => captionStyle.copyWith(
    color: captionStyle.color!.withOpacity(0.5),
  );

  // Styles pour glass overlays
  static const TextStyle whiteStyle = TextStyle(
    fontSize: body,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static const TextStyle whiteBoldStyle = TextStyle(
    fontSize: h3,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
