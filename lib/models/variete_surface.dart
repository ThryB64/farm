import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';

class VarieteSurface {
  final String nom;
  final double surface; // En hectares maintenant
  final String? varieteId; // ID de la variété pour les calculs

  VarieteSurface({
    required this.nom,
    required this.surface,
    this.varieteId,
  });

  // Getter pour la compatibilité
  double get surfaceHectares => surface;

  // Getter pour la compatibilité avec l'ancien code
  double get pourcentage => surface; // Pour la compatibilité - surface en hectares

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'surface': surface,
      'pourcentage': surface, // Pour la compatibilité
      'varieteId': varieteId,
    };
  }

  factory VarieteSurface.fromMap(Map<String, dynamic> map) {
    return VarieteSurface(
      nom: map['nom'],
      surface: map['surface'] ?? map['pourcentage'] ?? 0.0, // Compatibilité
      varieteId: map['varieteId'],
    );
  }
} 