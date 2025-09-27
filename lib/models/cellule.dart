class Cellule {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String reference;
  final double capacite;
  final DateTime dateCreation;
  final String? notes;
  final String? nom; // Nom optionnel pour l'affichage
  final bool fermee; // Indique si la cellule est fermée
  final double? quantiteGaz; // Quantité de gaz utilisée en m3 (enregistrée à la fermeture)
  final double? prixGaz; // Prix du gaz en €/kWh (enregistré à la fermeture)

  Cellule({
    this.id,
    this.firebaseId,
    String? reference,
    DateTime? dateCreation,
    this.notes,
    this.nom,
    this.fermee = false,
    this.quantiteGaz,
    this.prixGaz,
  }) : dateCreation = dateCreation ?? DateTime.now(),
       reference = reference ?? _generateReference(dateCreation ?? DateTime.now()),
       capacite = 320000; // 320T en kg

  static String _generateReference(DateTime date) {
    return 'CELLULE_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'reference': reference,
      'capacite': capacite,
      'date_creation': dateCreation.toIso8601String(),
      'notes': notes,
      'nom': nom,
      'fermee': fermee,
      'quantite_gaz': quantiteGaz,
      'prix_gaz': prixGaz,
    };
  }

  factory Cellule.fromMap(Map<String, dynamic> map) {
    return Cellule(
      id: map['id'],
      firebaseId: map['firebaseId'],
      reference: map['reference'],
      dateCreation: DateTime.parse(map['date_creation']),
      notes: map['notes'],
      nom: map['nom'],
      fermee: map['fermee'] ?? false,
      quantiteGaz: map['quantite_gaz']?.toDouble(),
      prixGaz: map['prix_gaz']?.toDouble(),
    );
  }
  
  // Getter pour l'affichage (nom si présent, sinon reference)
  String get label => nom?.isNotEmpty == true ? nom! : reference;

  @override
  String toString() => 'Cellule(id: $id, reference: $reference, capacite: $capacite)';
} 