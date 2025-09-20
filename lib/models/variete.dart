class Variete {
  int? id;
  final String nom;
  final String? description;
  final DateTime dateCreation;
  final String type;
  final double rendement;

  Variete({
    this.id,
    required this.nom,
    this.description,
    required this.dateCreation,
    this.type = 'Maïs',
    this.rendement = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
      'type': type,
      'rendement': rendement,
    };
  }

  factory Variete.fromMap(Map<String, dynamic> map) {
    return Variete(
      id: map['id'],
      nom: map['nom'],
      description: map['description'],
      dateCreation: DateTime.parse(map['date_creation']),
      type: map['type'] ?? 'Maïs',
      rendement: map['rendement'] ?? 0.0,
    );
  }

  @override
  String toString() => 'Variete(id: $id, nom: $nom)';
} 