class Vente {
  int? id;
  String? firebaseId;
  final DateTime date;
  final String numeroTicket;
  final String client;
  final String immatriculationRemorque;
  final String cmr;
  final double poidsVide;
  final double poidsPlein;
  final double? poidsNet;
  final double? ecartPoidsNet;
  final bool payer;
  final double? prix;
  final bool terminee;

  Vente({
    this.id,
    this.firebaseId,
    required this.date,
    required this.numeroTicket,
    required this.client,
    required this.immatriculationRemorque,
    required this.cmr,
    required this.poidsVide,
    required this.poidsPlein,
    this.poidsNet,
    this.ecartPoidsNet,
    this.payer = false,
    this.prix,
    this.terminee = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'date': date.millisecondsSinceEpoch,
      'numeroTicket': numeroTicket,
      'client': client,
      'immatriculationRemorque': immatriculationRemorque,
      'cmr': cmr,
      'poidsVide': poidsVide,
      'poidsPlein': poidsPlein,
      'poidsNet': poidsNet,
      'ecartPoidsNet': ecartPoidsNet,
      'payer': payer,
      'prix': prix,
      'terminee': terminee,
    };
  }

  factory Vente.fromMap(Map<String, dynamic> map) {
    return Vente(
      id: map['id'],
      firebaseId: map['firebaseId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      numeroTicket: map['numeroTicket'] ?? '',
      client: map['client'] ?? '',
      immatriculationRemorque: map['immatriculationRemorque'] ?? '',
      cmr: map['cmr'] ?? '',
      poidsVide: (map['poidsVide'] ?? 0).toDouble(),
      poidsPlein: (map['poidsPlein'] ?? 0).toDouble(),
      poidsNet: map['poidsNet']?.toDouble(),
      ecartPoidsNet: map['ecartPoidsNet']?.toDouble(),
      payer: map['payer'] ?? false,
      prix: map['prix']?.toDouble(),
      terminee: map['terminee'] ?? false,
    );
  }

  Vente copyWith({
    int? id,
    String? firebaseId,
    DateTime? date,
    String? numeroTicket,
    String? client,
    String? immatriculationRemorque,
    String? cmr,
    double? poidsVide,
    double? poidsPlein,
    double? poidsNet,
    double? ecartPoidsNet,
    bool? payer,
    double? prix,
    bool? terminee,
  }) {
    return Vente(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      date: date ?? this.date,
      numeroTicket: numeroTicket ?? this.numeroTicket,
      client: client ?? this.client,
      immatriculationRemorque: immatriculationRemorque ?? this.immatriculationRemorque,
      cmr: cmr ?? this.cmr,
      poidsVide: poidsVide ?? this.poidsVide,
      poidsPlein: poidsPlein ?? this.poidsPlein,
      poidsNet: poidsNet ?? this.poidsNet,
      ecartPoidsNet: ecartPoidsNet ?? this.ecartPoidsNet,
      payer: payer ?? this.payer,
      prix: prix ?? this.prix,
      terminee: terminee ?? this.terminee,
    );
  }

  // Calculer le poids net automatiquement
  double get poidsNetCalcule => poidsPlein - poidsVide;

  // Calculer l'écart entre le poids net calculé et le poids net saisi
  double? get ecartCalcule {
    if (poidsNet != null) {
      return poidsNetCalcule - poidsNet!;
    }
    return null;
  }
}
