class ProduitTraitement {
  final String produitId;
  final String nomProduit;
  final double quantite;
  final String mesure;
  final double prixUnitaire;
  final double coutTotal;

  ProduitTraitement({
    required this.produitId,
    required this.nomProduit,
    required this.quantite,
    required this.mesure,
    required this.prixUnitaire,
    required this.coutTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'produitId': produitId,
      'nomProduit': nomProduit,
      'quantite': quantite,
      'mesure': mesure,
      'prixUnitaire': prixUnitaire,
      'coutTotal': coutTotal,
    };
  }

  factory ProduitTraitement.fromMap(Map<String, dynamic> map) {
    return ProduitTraitement(
      produitId: map['produitId'] ?? '',
      nomProduit: map['nomProduit'] ?? '',
      quantite: (map['quantite'] ?? 0).toDouble(),
      mesure: map['mesure'] ?? '',
      prixUnitaire: (map['prixUnitaire'] ?? 0).toDouble(),
      coutTotal: (map['coutTotal'] ?? 0).toDouble(),
    );
  }

  ProduitTraitement copyWith({
    String? produitId,
    String? nomProduit,
    double? quantite,
    String? mesure,
    double? prixUnitaire,
    double? coutTotal,
  }) {
    return ProduitTraitement(
      produitId: produitId ?? this.produitId,
      nomProduit: nomProduit ?? this.nomProduit,
      quantite: quantite ?? this.quantite,
      mesure: mesure ?? this.mesure,
      prixUnitaire: prixUnitaire ?? this.prixUnitaire,
      coutTotal: coutTotal ?? this.coutTotal,
    );
  }
}
