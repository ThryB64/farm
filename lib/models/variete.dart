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
    // Parser les prix par année de manière robuste
    Map<int, double> prixParAnnee = {};
    try {
      if (map['prixParAnnee'] != null) {
        final prixData = map['prixParAnnee'];
        if (prixData is Map<String, dynamic>) {
          prixParAnnee = prixData.map((k, v) {
            try {
              return MapEntry(int.parse(k), v.toDouble());
            } catch (e) {
              print('Erreur parsing prix pour année $k: $e');
              return MapEntry(0, 0.0);
            }
          });
        }
      }
    } catch (e) {
      print('Erreur parsing prixParAnnee: $e');
    }
    
    return Variete(
      id: map['id'],
      firebaseId: map['firebaseId'],
      nom: map['nom'] ?? '',
      description: map['description'],
      dateCreation: DateTime.tryParse(map['date_creation'] ?? '') ?? DateTime.now(),
      prixParAnnee: prixParAnnee,
    );
  }

  @override
  String toString() => 'Variete(id: $id, nom: $nom)';
} 