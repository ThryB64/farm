import 'produit_traitement.dart';

class Traitement {
  int? id;
  String? firebaseId;
  final String parcelleId;
  final DateTime date;
  final int annee;
  final String type; // Herbicide, Fongicide, Insecticide, etc.
  final String? notes;
  final List<ProduitTraitement> produits;
  final double coutTotal;

  Traitement({
    this.id,
    this.firebaseId,
    required this.parcelleId,
    required this.date,
    required this.annee,
    required this.type,
    this.notes,
    required this.produits,
    required this.coutTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'parcelleId': parcelleId,
      'date': date.millisecondsSinceEpoch,
      'annee': annee,
      'type': type,
      'notes': notes,
      'produits': produits.map((p) => p.toMap()).toList(),
      'coutTotal': coutTotal,
    };
  }

  factory Traitement.fromMap(Map<String, dynamic> map) {
    return Traitement(
      id: map['id'],
      firebaseId: map['firebaseId'],
      parcelleId: map['parcelleId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      annee: map['annee'] ?? DateTime.fromMillisecondsSinceEpoch(map['date']).year,
      type: map['type'] ?? '',
      notes: map['notes'],
      produits: (map['produits'] as List<dynamic>? ?? [])
          .map((p) => ProduitTraitement.fromMap(p))
          .toList(),
      coutTotal: (map['coutTotal'] ?? 0).toDouble(),
    );
  }

  Traitement copyWith({
    int? id,
    String? firebaseId,
    String? parcelleId,
    DateTime? date,
    int? annee,
    String? type,
    String? notes,
    List<ProduitTraitement>? produits,
    double? coutTotal,
  }) {
    return Traitement(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      parcelleId: parcelleId ?? this.parcelleId,
      date: date ?? this.date,
      annee: annee ?? this.annee,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      produits: produits ?? this.produits,
      coutTotal: coutTotal ?? this.coutTotal,
    );
  }

  // Calculer le coût total à partir des produits
  double calculerCoutTotal() {
    return produits.fold(0.0, (sum, produit) => sum + produit.coutTotal);
  }
}
