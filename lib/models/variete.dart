import '../utils/firebase_normalize.dart';

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
    print('🔍 Model: Parsing variété ${map['nom']}');
    print('🔍 Model: Données reçues: $map');
    
    try {
      if (map['prixParAnnee'] != null) {
        final prixData = map['prixParAnnee'];
        print('🔍 Model: Prix data trouvée: $prixData (type: ${prixData.runtimeType})');
        
        // Normaliser l'objet Firebase en Map<String, dynamic>
        final prixDataNormalized = normalizeToStringKeyMap(prixData);
        print('🔍 Model: Prix data normalisée: $prixDataNormalized');
        
        if (prixDataNormalized != null) {
          prixParAnnee = prixDataNormalized.map((k, v) {
            try {
              final annee = int.parse(k);
              final prix = v.toDouble();
              print('🔍 Model: Prix parsé: $annee -> $prix');
              return MapEntry(annee, prix);
            } catch (e) {
              print('❌ Model: Erreur parsing prix pour année $k: $e');
              return MapEntry(0, 0.0);
            }
          });
        } else {
          print('❌ Model: Impossible de normaliser les prix');
        }
      } else {
        print('🔍 Model: Pas de prixParAnnee dans les données');
      }
    } catch (e) {
      print('❌ Model: Erreur parsing prixParAnnee: $e');
    }
    
    print('🔍 Model: Prix parsés finaux: $prixParAnnee');
    
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