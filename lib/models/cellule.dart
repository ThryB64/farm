class Cellule {
  int? id;
  final String reference;
  final double capacite;
  final DateTime dateCreation;
  final String? notes;
  final String? localisation;
  final String? description;

  Cellule({
    this.id,
    String? reference,
    DateTime? dateCreation,
    this.notes,
    this.localisation,
    this.description,
  }) : dateCreation = dateCreation ?? DateTime.now(),
       reference = reference ?? _generateReference(dateCreation ?? DateTime.now()),
       capacite = 320000; // 320T en kg

  static String _generateReference(DateTime date) {
    return 'CELLULE_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'capacite': capacite,
      'date_creation': dateCreation.toIso8601String(),
      'notes': notes,
      'localisation': localisation,
      'description': description,
    };
  }

  factory Cellule.fromMap(Map<String, dynamic> map) {
    return Cellule(
      id: map['id'],
      reference: map['reference'],
      dateCreation: DateTime.parse(map['date_creation']),
      notes: map['notes'],
      localisation: map['localisation'],
      description: map['description'],
    );
  }

  @override
  String toString() => 'Cellule(id: $id, reference: $reference, capacite: $capacite)';
} 