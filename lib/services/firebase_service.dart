import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../utils/poids_utils.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseDatabase _database;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _userRef;

  // Initialiser Firebase
  Future<void> initialize() async {
    try {
      // Forcer l'instance avec la bonne URL
      _database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://farmgaec-default-rtdb.firebaseio.com',
      );
      print('Firebase Database instance created with URL: https://farmgaec-default-rtdb.firebaseio.com');

      // Vérifier la connexion
      _database.ref('.info/connected').onValue.listen((event) {
        print('Firebase connected: ${event.snapshot.value}');
      });

      // Vérifier le décalage serveur
      _database.ref('.info/serverTimeOffset').onValue.listen((event) {
        print('Server time offset: ${event.snapshot.value}');
      });

      // Vérifier si l'utilisateur est déjà connecté
      final user = _auth.currentUser;
      if (user != null) {
        _userRef = _database.ref('users/${user.uid}');
        print('Firebase initialized for existing user: ${user.uid}');
        await _testWrite();
      } else {
        // Essayer l'authentification anonyme
        try {
          final userCred = await _auth.signInAnonymously();
          final newUser = userCred.user;
          if (newUser != null) {
            _userRef = _database.ref('users/${newUser.uid}');
            print('Firebase initialized for new anonymous user: ${newUser.uid}');
            await _testWrite();
          }
        } catch (authError) {
          print('Auth error, continuing without user: $authError');
          // Continuer sans authentification pour permettre l'utilisation hors ligne
        }
      }
    } catch (e) {
      print('Error initializing Firebase: $e');
      // Ne pas rethrow pour permettre l'utilisation hors ligne
    }
  }

  // Test d'écriture pour vérifier la connexion
  Future<void> _testWrite() async {
    try {
      await _database.ref('ping').set({
        'at': ServerValue.timestamp,
        'test': 'Firebase connection test',
      });
      print('✅ Firebase write test successful');
    } catch (e) {
      print('❌ Firebase write test failed: $e');
    }
  }

  // Méthodes pour les parcelles
  Stream<List<Parcelle>> getParcellesStream() {
    if (_userRef == null) {
      print('Firebase not initialized, returning empty stream');
      return Stream.value(<Parcelle>[]);
    }
    return _userRef!.child('parcelles').onValue.map((event) {
      if (event.snapshot.value == null) return <Parcelle>[];
      final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((entry) {
        final Map<String, dynamic> parcelleData = Map<String, dynamic>.from(entry.value as Map);
        parcelleData['id'] = entry.key;
        return Parcelle.fromMap(parcelleData);
      }).toList();
    });
  }

  Future<String> insertParcelle(Parcelle parcelle) async {
    if (_userRef == null) {
      print('Firebase not initialized, generating local ID');
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
    final ref = _userRef!.child('parcelles').push();
    await ref.set(parcelle.toMap());
    return ref.key!;
  }

  Future<void> updateParcelle(Parcelle parcelle) async {
    if (_userRef == null) {
      print('Firebase not initialized, update ignored');
      return;
    }
    if (parcelle.id == null) throw Exception('Parcelle ID is required for update');
    await _userRef!.child('parcelles').child(parcelle.id.toString()).set(parcelle.toMap());
  }

  Future<void> deleteParcelle(String id) async {
    if (_userRef == null) {
      print('Firebase not initialized, delete ignored');
      return;
    }
    await _userRef!.child('parcelles').child(id).remove();
  }

  // Méthodes pour les cellules
  Stream<List<Cellule>> getCellulesStream() {
    if (_userRef == null) {
      print('Firebase not initialized, returning empty stream');
      return Stream.value(<Cellule>[]);
    }
    return _userRef!.child('cellules').onValue.map((event) {
      if (event.snapshot.value == null) return <Cellule>[];
      final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((entry) {
        final Map<String, dynamic> celluleData = Map<String, dynamic>.from(entry.value as Map);
        celluleData['id'] = entry.key;
        return Cellule.fromMap(celluleData);
      }).toList();
    });
  }

  Future<String> insertCellule(Cellule cellule) async {
    if (_userRef == null) {
      print('Firebase not initialized, generating local ID');
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
    final ref = _userRef!.child('cellules').push();
    await ref.set(cellule.toMap());
    return ref.key!;
  }

  Future<void> updateCellule(Cellule cellule) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    if (cellule.id == null) throw Exception('Cellule ID is required for update');
    await _userRef!.child('cellules').child(cellule.id.toString()).set(cellule.toMap());
  }

  Future<void> deleteCellule(String id) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    await _userRef!.child('cellules').child(id).remove();
  }

  // Méthodes pour les chargements
  Stream<List<Chargement>> getChargementsStream() {
    if (_userRef == null) throw Exception('Firebase not initialized');
    return _userRef!.child('chargements').onValue.map((event) {
      if (event.snapshot.value == null) return <Chargement>[];
      final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((entry) {
        final Map<String, dynamic> chargementData = Map<String, dynamic>.from(entry.value as Map);
        chargementData['id'] = entry.key;
        return Chargement.fromMap(chargementData);
      }).toList();
    });
  }

  Future<String> insertChargement(Chargement chargement) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    
    // Validation
    if (chargement.poidsPlein <= chargement.poidsVide) {
      throw Exception('Le poids plein doit être supérieur au poids vide');
    }
    if (chargement.humidite < 0 || chargement.humidite > 100) {
      throw Exception('L\'humidité doit être comprise entre 0 et 100%');
    }

    final ref = _userRef!.child('chargements').push();
    await ref.set(chargement.toMap());
    return ref.key!;
  }

  Future<void> updateChargement(Chargement chargement) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    if (chargement.id == null) throw Exception('Chargement ID is required for update');
    
    // Validation
    if (chargement.poidsPlein <= chargement.poidsVide) {
      throw Exception('Le poids plein doit être supérieur au poids vide');
    }
    if (chargement.humidite < 0 || chargement.humidite > 100) {
      throw Exception('L\'humidité doit être comprise entre 0 et 100%');
    }

    await _userRef!.child('chargements').child(chargement.id.toString()).set(chargement.toMap());
  }

  Future<void> deleteChargement(String id) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    await _userRef!.child('chargements').child(id).remove();
  }

  Future<void> updateAllChargementsPoidsNormes() async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    
    final snapshot = await _userRef!.child('chargements').get();
    if (snapshot.value == null) return;
    
    final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(snapshot.value as Map);
    
    for (var entry in data.entries) {
      final Map<String, dynamic> chargementData = Map<String, dynamic>.from(entry.value as Map);
      
      final double poidsPlein = double.tryParse(chargementData['poids_plein'].toString()) ?? 0.0;
      final double poidsVide = double.tryParse(chargementData['poids_vide'].toString()) ?? 0.0;
      final double humidite = double.tryParse(chargementData['humidite'].toString()) ?? 0.0;
      
      final double poidsNet = PoidsUtils.calculPoidsNet(poidsPlein, poidsVide);
      final double poidsNormes = PoidsUtils.calculPoidsNormes(poidsNet, humidite);
      
      await _userRef!.child('chargements').child(entry.key).update({
        'poids_net': poidsNet,
        'poids_normes': poidsNormes,
      });
    }
  }

  // Méthodes pour les semis
  Stream<List<Semis>> getSemisStream() {
    if (_userRef == null) throw Exception('Firebase not initialized');
    return _userRef!.child('semis').onValue.map((event) {
      if (event.snapshot.value == null) return <Semis>[];
      final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((entry) {
        final Map<String, dynamic> semisData = Map<String, dynamic>.from(entry.value as Map);
        semisData['id'] = entry.key;
        return Semis.fromMap(semisData);
      }).toList();
    });
  }

  Future<String> insertSemis(Semis semis) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    final ref = _userRef!.child('semis').push();
    await ref.set(semis.toMap());
    return ref.key!;
  }

  Future<void> updateSemis(Semis semis) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    if (semis.id == null) throw Exception('Semis ID is required for update');
    await _userRef!.child('semis').child(semis.id.toString()).set(semis.toMap());
  }

  Future<void> deleteSemis(String id) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    await _userRef!.child('semis').child(id).remove();
  }

  // Méthodes pour les variétés
  Stream<List<Variete>> getVarietesStream() {
    if (_userRef == null) throw Exception('Firebase not initialized');
    return _userRef!.child('varietes').onValue.map((event) {
      if (event.snapshot.value == null) return <Variete>[];
      final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((entry) {
        final Map<String, dynamic> varieteData = Map<String, dynamic>.from(entry.value as Map);
        varieteData['id'] = entry.key;
        return Variete.fromMap(varieteData);
      }).toList();
    });
  }

  Future<String> insertVariete(Variete variete) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    final ref = _userRef!.child('varietes').push();
    await ref.set(variete.toMap());
    return ref.key!;
  }

  Future<void> updateVariete(Variete variete) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    if (variete.id == null) throw Exception('Variete ID is required for update');
    await _userRef!.child('varietes').child(variete.id.toString()).set(variete.toMap());
  }

  Future<void> deleteVariete(String id) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    await _userRef!.child('varietes').child(id).remove();
  }

  // Méthodes utilitaires
  Future<List<Parcelle>> getParcelles() async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    final snapshot = await _userRef!.child('parcelles').get();
    if (snapshot.value == null) return <Parcelle>[];
    final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(snapshot.value as Map);
    return data.entries.map((entry) {
      final Map<String, dynamic> parcelleData = Map<String, dynamic>.from(entry.value as Map);
      parcelleData['id'] = entry.key;
      return Parcelle.fromMap(parcelleData);
    }).toList();
  }

  Future<List<Chargement>> getChargements() async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    final snapshot = await _userRef!.child('chargements').get();
    if (snapshot.value == null) return <Chargement>[];
    final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(snapshot.value as Map);
    return data.entries.map((entry) {
      final Map<String, dynamic> chargementData = Map<String, dynamic>.from(entry.value as Map);
      chargementData['id'] = entry.key;
      return Chargement.fromMap(chargementData);
    }).toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    
    final parcelles = await getParcelles();
    final chargements = await getChargements();
    
    // Calculer la surface totale
    final surfaceTotale = parcelles.fold<double>(
      0,
      (sum, p) => sum + p.surface,
    );

    // Obtenir l'année la plus récente avec des chargements
    final derniereAnnee = chargements.isEmpty
        ? DateTime.now().year
        : chargements
            .map((c) => c.dateChargement.year)
            .reduce((a, b) => a > b ? a : b);

    final chargementsDerniereAnnee = chargements.where(
      (c) => c.dateChargement.year == derniereAnnee
    ).toList();

    // Calculer le poids total normé de l'année
    final poidsTotalNormeAnnee = chargementsDerniereAnnee.fold<double>(
      0,
      (sum, c) => sum + c.poidsNormes,
    );

    // Calculer le rendement moyen normé (en T/ha)
    final rendementMoyenNorme = surfaceTotale > 0
        ? (poidsTotalNormeAnnee / 1000) / surfaceTotale
        : 0.0;

    return {
      'surfaceTotale': surfaceTotale,
      'derniereAnnee': derniereAnnee,
      'poidsTotalNormeAnnee': poidsTotalNormeAnnee,
      'rendementMoyenNorme': rendementMoyenNorme,
    };
  }

  Future<void> deleteAllData() async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    await _userRef!.remove();
  }

  Future<void> importData(Map<String, dynamic> data) async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    await _userRef!.set(data);
  }

  Future<Map<String, dynamic>> exportData() async {
    if (_userRef == null) throw Exception('Firebase not initialized');
    final snapshot = await _userRef!.get();
    return Map<String, dynamic>.from(snapshot.value as Map? ?? {});
  }
}
