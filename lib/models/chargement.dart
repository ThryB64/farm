class Chargement {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String celluleId; // String pour compatibilité JSON
  final String parcelleId; // String pour compatibilité JSON
  final String remorque;
  final DateTime dateChargement;
  final double poidsPlein;
  final double poidsVide;
  double _poidsNet;
  double _poidsNormes;
  final double humidite;
  final String variete;

  Chargement({
    this.id,
    this.firebaseId,
    required this.celluleId,
    required this.parcelleId,
    required this.remorque,
    required this.dateChargement,
    required this.poidsPlein,
    required this.poidsVide,
    required double poidsNet,
    required double poidsNormes,
    required this.humidite,
    required this.variete,
  }) : _poidsNet = poidsNet,
       _poidsNormes = poidsNormes;

  double get poidsNet => _poidsNet;
  set poidsNet(double value) => _poidsNet = value;

  double get poidsNormes => _poidsNormes;
  set poidsNormes(double value) => _poidsNormes = value;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'cellule_id': celluleId,
      'parcelle_id': parcelleId,
      'remorque': remorque,
      'date_chargement': dateChargement.toIso8601String(),
      'poids_plein': poidsPlein,
      'poids_vide': poidsVide,
      'poids_net': _poidsNet,
      'poids_normes': _poidsNormes,
      'humidite': humidite,
      'variete': variete,
    };
  }

  factory Chargement.fromMap(Map<String, dynamic> map) {
    return Chargement(
      id: map['id'],
      firebaseId: map['firebaseId'],
      celluleId: _pick(map, ['celluleId', 'cellule_id', 'cellule', 'celluleRef'])?.toString() ?? '',
      parcelleId: _pick(map, ['parcelleId', 'parcelle_id', 'parcelle', 'parcelleRef'])?.toString() ?? '',
      remorque: map['remorque'],
      dateChargement: DateTime.parse(map['date_chargement']),
      poidsPlein: map['poids_plein'],
      poidsVide: map['poids_vide'],
      poidsNet: map['poids_net'],
      poidsNormes: map['poids_normes'],
      humidite: map['humidite'],
      variete: map['variete'],
    );
  }

  @override
  String toString() => 'Chargement(id: $id, celluleId: $celluleId, parcelleId: $parcelleId, poidsNet: $_poidsNet, poidsNormes: $_poidsNormes, variete: $variete)';
  
  // Méthode utilitaire pour récupérer une valeur parmi plusieurs clés possibles
  static T? _pick<T>(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key] as T?;
      }
    }
    return null;
  }
} 