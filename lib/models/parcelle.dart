// Import des modèles individuels si nécessaire
class Parcelle {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String nom;
  final double surface;
  final DateTime dateCreation;
  final String? notes;

  Parcelle({
    this.id,
    this.firebaseId,
    required this.nom,
    required this.surface,
    DateTime? dateCreation,
    this.notes,
  }) : dateCreation = dateCreation ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'nom': nom,
      'surface': surface,
      'date_creation': dateCreation.toIso8601String(),
      'notes': notes,
    };
  }

  factory Parcelle.fromMap(Map<String, dynamic> map) {
    return Parcelle(
      id: map['id'],
      firebaseId: map['firebaseId'],
      nom: map['nom'],
      surface: map['surface'],
      dateCreation: DateTime.parse(map['date_creation']),
      notes: map['notes'],
    );
  }

  @override
  String toString() => 'Parcelle(id: $id, nom: $nom, surface: $surface)';
} 