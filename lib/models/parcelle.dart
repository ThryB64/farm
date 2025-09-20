class Parcelle {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String nom;
  final String code;
  final double surface;
  final int annee;
  final DateTime dateCreation;
  final String? notes;
  final String? description;

  Parcelle({
    this.id,
    this.firebaseId,
    required this.nom,
    required this.code,
    required this.surface,
    required this.annee,
    DateTime? dateCreation,
    this.notes,
    this.description,
  }) : dateCreation = dateCreation ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'nom': nom,
      'code': code,
      'surface': surface,
      'annee': annee,
      'date_creation': dateCreation.toIso8601String(),
      'notes': notes,
      'description': description,
    };
  }

  factory Parcelle.fromMap(Map<String, dynamic> map) {
    return Parcelle(
      id: map['id'],
      firebaseId: map['firebaseId'],
      nom: map['nom'],
      code: map['code'] ?? '',
      surface: map['surface'],
      annee: map['annee'] ?? DateTime.now().year,
      dateCreation: DateTime.parse(map['date_creation']),
      notes: map['notes'],
      description: map['description'],
    );
  }

  @override
  String toString() => 'Parcelle(id: $id, nom: $nom, surface: $surface)';
} 