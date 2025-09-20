
class VarieteSurface {
  final String nom;
  final double pourcentage;
  final double surface;

  VarieteSurface({
    required this.nom,
    required this.pourcentage,
    required this.surface,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'pourcentage': pourcentage,
      'surface': surface,
    };
  }

  factory VarieteSurface.fromMap(Map<String, dynamic> map) {
    return VarieteSurface(
      nom: map['nom'],
      pourcentage: map['pourcentage'],
      surface: map['surface'] ?? 0.0,
    );
  }
} 