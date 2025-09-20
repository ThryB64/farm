class VarieteSurfaceHa {
  final String nom;
  final double hectares;

  VarieteSurfaceHa({
    required this.nom,
    required this.hectares,
  });

  // Convertir en pourcentage basé sur la surface totale
  double toPourcentage(double surfaceTotale) {
    if (surfaceTotale <= 0) return 0.0;
    return (hectares / surfaceTotale) * 100;
  }

  // Créer depuis un pourcentage
  factory VarieteSurfaceHa.fromPourcentage(String nom, double pourcentage, double surfaceTotale) {
    return VarieteSurfaceHa(
      nom: nom,
      hectares: (pourcentage / 100) * surfaceTotale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'hectares': hectares,
    };
  }

  factory VarieteSurfaceHa.fromMap(Map<String, dynamic> map) {
    return VarieteSurfaceHa(
      nom: map['nom'],
      hectares: map['hectares']?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() => 'VarieteSurfaceHa(nom: $nom, hectares: $hectares)';
}
