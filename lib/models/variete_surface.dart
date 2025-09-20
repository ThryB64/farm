
class VarieteSurface {
  final String nom;
  final double surface; // En hectares maintenant

  VarieteSurface({
    required this.nom,
    required this.surface,
  });

  // Getter pour la compatibilité avec l'ancien code
  double get pourcentage => surface; // Pour la compatibilité

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'surface': surface,
      'pourcentage': surface, // Pour la compatibilité
    };
  }

  factory VarieteSurface.fromMap(Map<String, dynamic> map) {
    return VarieteSurface(
      nom: map['nom'],
      surface: map['surface'] ?? map['pourcentage'] ?? 0.0, // Compatibilité
    );
  }
} 