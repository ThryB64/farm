import 'produit_traitement.dart';
import '../utils/firebase_normalize.dart';

class Traitement {
  int? id;
  String? firebaseId;
  final String parcelleId;
  final DateTime date;
  final int annee;
  final String? notes;
  final List<ProduitTraitement> produits;
  final double coutTotal;

  Traitement({
    this.id,
    this.firebaseId,
    required this.parcelleId,
    required this.date,
    required this.annee,
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
      'notes': notes,
      'produits': produits.map((p) => p.toMap()).toList(),
      'coutTotal': coutTotal,
    };
  }

  factory Traitement.fromMap(Map<String, dynamic> map) {
    // Normaliser la liste des produits
    final produitsList = map['produits'];
    List<ProduitTraitement> produits = [];
    
    if (produitsList != null) {
      try {
        if (produitsList is List) {
          produits = produitsList.map((p) {
            try {
              final normalizedP = normalizeLoose(p);
              return ProduitTraitement.fromMap(normalizedP);
            } catch (e) {
              print('Error parsing produit in traitement: $e');
              return null;
            }
          }).where((p) => p != null).cast<ProduitTraitement>().toList();
        }
      } catch (e) {
        print('Error parsing produits list in traitement: $e');
      }
    }
    
    return Traitement(
      id: map['id'],
      firebaseId: map['firebaseId'],
      parcelleId: map['parcelleId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      annee: map['annee'] ?? DateTime.fromMillisecondsSinceEpoch(map['date']).year,
      notes: map['notes'],
      produits: produits,
      coutTotal: (map['coutTotal'] ?? 0).toDouble(),
    );
  }

  Traitement copyWith({
    int? id,
    String? firebaseId,
    String? parcelleId,
    DateTime? date,
    int? annee,
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
