class Produit {
  int? id;
  String? firebaseId;
  final String nom;
  final String mesure; // L, kg, etc.
  final String? notes;
  final Map<int, double> prixParAnnee; // Prix par année

  Produit({
    this.id,
    this.firebaseId,
    required this.nom,
    required this.mesure,
    this.notes,
    required this.prixParAnnee,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'nom': nom,
      'mesure': mesure,
      'notes': notes,
      'prixParAnnee': prixParAnnee,
    };
  }

  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id'],
      firebaseId: map['firebaseId'],
      nom: map['nom'] ?? '',
      mesure: map['mesure'] ?? '',
      notes: map['notes'],
      prixParAnnee: Map<int, double>.from(map['prixParAnnee'] ?? {}),
    );
  }

  Produit copyWith({
    int? id,
    String? firebaseId,
    String? nom,
    String? mesure,
    String? notes,
    Map<int, double>? prixParAnnee,
  }) {
    return Produit(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      nom: nom ?? this.nom,
      mesure: mesure ?? this.mesure,
      notes: notes ?? this.notes,
      prixParAnnee: prixParAnnee ?? this.prixParAnnee,
    );
  }

  // Obtenir le prix pour une année donnée
  double getPrixPourAnnee(int annee) {
    return prixParAnnee[annee] ?? 0.0;
  }


  // Calculer le prix unitaire pour une année donnée (prix par unité de mesure)
  double getPrixUnitairePourAnnee(int annee) {
    return getPrixPourAnnee(annee);
  }
}
