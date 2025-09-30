import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import '../utils/poids_utils.dart';

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
       _poidsNormes = poidsNormes {
    // Calculer automatiquement le poids aux normes si pas fourni
    if (_poidsNormes == 0 && _poidsNet > 0 && humidite > 0) {
      _poidsNormes = PoidsUtils.calculPoidsNormes(_poidsNet, humidite);
    }
  }

  double get poidsNet => _poidsNet;
  set poidsNet(double value) {
    _poidsNet = value;
    // Recalculer automatiquement le poids aux normes
    if (humidite > 0) {
      _poidsNormes = PoidsUtils.calculPoidsNormes(_poidsNet, humidite);
    }
  }

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
    final poidsNet = (map['poids_net'] ?? 0).toDouble();
    final humidite = (map['humidite'] ?? 0).toDouble();
    final poidsNormes = (map['poids_normes'] ?? 0).toDouble();
    
    // Calculer le poids aux normes si pas fourni ou si les données ont changé
    double poidsNormesCalcule = poidsNormes;
    if (poidsNormes == 0 && poidsNet > 0 && humidite > 0) {
      poidsNormesCalcule = PoidsUtils.calculPoidsNormes(poidsNet, humidite);
    }
    
    return Chargement(
      id: map['id'],
      firebaseId: map['firebaseId'],
      celluleId: _pick(map, ['celluleId', 'cellule_id', 'cellule', 'celluleRef'])?.toString() ?? '',
      parcelleId: _pick(map, ['parcelleId', 'parcelle_id', 'parcelle', 'parcelleRef'])?.toString() ?? '',
      remorque: map['remorque'] ?? '',
      dateChargement: DateTime.parse(map['date_chargement']),
      poidsPlein: (map['poids_plein'] ?? 0).toDouble(),
      poidsVide: (map['poids_vide'] ?? 0).toDouble(),
      poidsNet: poidsNet,
      poidsNormes: poidsNormesCalcule,
      humidite: humidite,
      variete: map['variete'] ?? '',
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