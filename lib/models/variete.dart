class Variete {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String nom;
  final String? description;
  final DateTime dateCreation;
  final Map<int, double> prixParAnnee; // Prix de la dose par année (€/dose)

  Variete({
    this.id,
    this.firebaseId,
    required this.nom,
    this.description,
    required this.dateCreation,
    this.prixParAnnee = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'nom': nom,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
      'prixParAnnee': prixParAnnee.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory Variete.fromMap(Map<String, dynamic> map) {
    // Parser prixParAnnee avec gestion des types (int vs String)
    Map<int, double> prixParAnnee = {};
    if (map['prixParAnnee'] != null) {
      final prixData = map['prixParAnnee'] as Map;
      prixData.forEach((key, value) {
        final annee = int.tryParse(key.toString());
        final prix = double.tryParse(value.toString());
        if (annee != null && prix != null) {
          prixParAnnee[annee] = prix;
        }
      });
    }
    
    return Variete(
      id: map['id'],
      firebaseId: map['firebaseId'],
      nom: map['nom'],
      description: map['description'],
      dateCreation: DateTime.parse(map['date_creation']),
      prixParAnnee: prixParAnnee,
    );
  }

  @override
  String toString() => 'Variete(id: $id, nom: $nom)';
} 