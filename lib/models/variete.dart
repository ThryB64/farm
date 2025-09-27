class Variete {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String nom;
  final String? description;
  final DateTime dateCreation;
  final Map<int, double> prixParAnnee; // Prix de la dose par année

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
      'prixParAnnee': prixParAnnee.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  factory Variete.fromMap(Map<String, dynamic> map) {
    // Parser les prix par année
    Map<int, double> prixParAnnee = {};
    if (map['prixParAnnee'] != null) {
      final prixData = map['prixParAnnee'] as Map<String, dynamic>;
      prixParAnnee = prixData.map((k, v) => MapEntry(int.parse(k), v.toDouble()));
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