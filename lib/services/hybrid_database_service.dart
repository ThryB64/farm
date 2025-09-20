import 'dart:convert';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../utils/poids_utils.dart';

class HybridDatabaseService {
  static final HybridDatabaseService _instance = HybridDatabaseService._internal();
  factory HybridDatabaseService() => _instance;
  HybridDatabaseService._internal();

  late final FirebaseDatabase _database;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _userRef;
  
  static const String _storageKey = 'mais_tracker_data';

  // Initialiser le service hybride
  Future<void> initialize() async {
    try {
      // Forcer l'instance avec la bonne URL
      _database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://farmgaec-default-rtdb.firebaseio.com',
      );
      print('Hybrid Database: Firebase instance created with URL: https://farmgaec-default-rtdb.firebaseio.com');

      // Note: setPersistenceEnabled() n'est pas supporté sur le web
      // La persistance est gérée automatiquement par Firebase sur le web
      print('Hybrid Database: Web platform - persistence handled automatically');

      // Vérifier la connexion
      _database.ref('.info/connected').onValue.listen((event) {
        print('Hybrid Database connected: ${event.snapshot.value}');
      });

      // Essayer Firebase d'abord
      final user = _auth.currentUser;
      if (user != null) {
        _userRef = _database.ref('users/${user.uid}');
        print('Hybrid Database: Firebase initialized for user: ${user.uid}');
        await _testWrite();
      } else {
        // Essayer l'auth anonyme
        try {
          final userCred = await _auth.signInAnonymously();
          final newUser = userCred.user;
          if (newUser != null) {
            _userRef = _database.ref('users/${newUser.uid}');
            print('Hybrid Database: Firebase initialized for anonymous user: ${newUser.uid}');
            await _testWrite();
          }
        } catch (authError) {
          print('Hybrid Database: Auth failed, using localStorage: $authError');
        }
      }
      
      // Vérifier que _userRef est défini
      if (_userRef != null) {
        print('Hybrid Database: User reference created successfully');
      } else {
        print('Hybrid Database: No user reference - will use localStorage only');
      }
    } catch (e) {
      print('Hybrid Database: Firebase init failed, using localStorage: $e');
    }
  }

  // Test d'écriture pour vérifier la connexion
  Future<void> _testWrite() async {
    try {
      await _database.ref('ping').set({
        'at': ServerValue.timestamp,
        'test': 'Hybrid Database connection test',
      });
      print('✅ Hybrid Database write test successful');
    } catch (e) {
      print('❌ Hybrid Database write test failed: $e');
    }
  }

  // Synchroniser les données entre Firebase et localStorage
  Future<void> syncData() async {
    if (_userRef == null) {
      print('Hybrid Database: No user reference, trying to reconnect...');
      // Essayer de reconnecter
      final user = _auth.currentUser;
      if (user != null) {
        _userRef = _database.ref('users/${user.uid}');
        print('Hybrid Database: Reconnected with user: ${user.uid}');
      } else {
        print('Hybrid Database: No user available, skipping sync');
        return;
      }
    }

    try {
      print('Hybrid Database: Starting data synchronization...');
      
      // Synchroniser les parcelles
      await _syncParcelles();
      
      // Synchroniser les cellules
      await _syncCellules();
      
      // Synchroniser les chargements
      await _syncChargements();
      
      // Synchroniser les semis
      await _syncSemis();
      
      // Synchroniser les variétés
      await _syncVarietes();
      
      print('✅ Hybrid Database: Data synchronization completed');
    } catch (e) {
      print('❌ Hybrid Database: Sync failed: $e');
    }
  }

  // Synchroniser les parcelles
  Future<void> _syncParcelles() async {
    try {
      // Charger depuis localStorage
      final localData = await _loadDataFromStorage();
      final localParcelles = localData['parcelles'] as List<dynamic>? ?? [];
      
      // Sauvegarder dans Firebase
      for (final parcelleData in localParcelles) {
        if (parcelleData['firebaseId'] == null) {
          // Créer une nouvelle entrée Firebase
          final ref = _userRef!.child('parcelles').push();
          await ref.set(parcelleData);
          print('Hybrid Database: Synced parcelle to Firebase: ${ref.key}');
        }
      }
    } catch (e) {
      print('Hybrid Database: Error syncing parcelles: $e');
    }
  }

  // Synchroniser les cellules
  Future<void> _syncCellules() async {
    try {
      final localData = await _loadDataFromStorage();
      final localCellules = localData['cellules'] as List<dynamic>? ?? [];
      
      for (final celluleData in localCellules) {
        if (celluleData['firebaseId'] == null) {
          final ref = _userRef!.child('cellules').push();
          await ref.set(celluleData);
          print('Hybrid Database: Synced cellule to Firebase: ${ref.key}');
        }
      }
    } catch (e) {
      print('Hybrid Database: Error syncing cellules: $e');
    }
  }

  // Synchroniser les chargements
  Future<void> _syncChargements() async {
    try {
      final localData = await _loadDataFromStorage();
      final localChargements = localData['chargements'] as List<dynamic>? ?? [];
      
      for (final chargementData in localChargements) {
        if (chargementData['firebaseId'] == null) {
          final ref = _userRef!.child('chargements').push();
          await ref.set(chargementData);
          print('Hybrid Database: Synced chargement to Firebase: ${ref.key}');
        }
      }
    } catch (e) {
      print('Hybrid Database: Error syncing chargements: $e');
    }
  }

  // Synchroniser les semis
  Future<void> _syncSemis() async {
    try {
      final localData = await _loadDataFromStorage();
      final localSemis = localData['semis'] as List<dynamic>? ?? [];
      
      for (final semisData in localSemis) {
        if (semisData['firebaseId'] == null) {
          final ref = _userRef!.child('semis').push();
          await ref.set(semisData);
          print('Hybrid Database: Synced semis to Firebase: ${ref.key}');
        }
      }
    } catch (e) {
      print('Hybrid Database: Error syncing semis: $e');
    }
  }

  // Synchroniser les variétés
  Future<void> _syncVarietes() async {
    try {
      final localData = await _loadDataFromStorage();
      final localVarietes = localData['varietes'] as List<dynamic>? ?? [];
      
      for (final varieteData in localVarietes) {
        if (varieteData['firebaseId'] == null) {
          final ref = _userRef!.child('varietes').push();
          await ref.set(varieteData);
          print('Hybrid Database: Synced variete to Firebase: ${ref.key}');
        }
      }
    } catch (e) {
      print('Hybrid Database: Error syncing varietes: $e');
    }
  }

  // Charger les données depuis localStorage
  Future<Map<String, dynamic>> _loadDataFromStorage() async {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        return jsonDecode(stored);
      }
    } catch (e) {
      print('Hybrid Database: Error loading from localStorage: $e');
    }
    return {
      'parcelles': [],
      'cellules': [],
      'chargements': [],
      'semis': [],
      'varietes': [],
    };
  }

  // Méthodes pour les parcelles
  Stream<List<Parcelle>> getParcellesStream() {
    if (_userRef != null) {
      return _userRef!.child('parcelles').onValue.map((event) {
        if (event.snapshot.value == null) return <Parcelle>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> parcelleData = Map<String, dynamic>.from(entry.value as Map);
          parcelleData['id'] = entry.key;
          return Parcelle.fromMap(parcelleData);
        }).toList();
      });
    } else {
      // Mode localStorage
      return Stream.value(_getParcellesFromStorage());
    }
  }

  Future<String> insertParcelle(Parcelle parcelle) async {
    if (_userRef != null) {
      final ref = _userRef!.child('parcelles').push();
      await ref.set(parcelle.toMap());
      return ref.key!;
    } else {
      // Mode localStorage
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      parcelle.id = int.tryParse(id) ?? 0;
      _saveParcelleToStorage(parcelle);
      return id;
    }
  }

  Future<void> updateParcelle(Parcelle parcelle) async {
    if (_userRef != null) {
      if (parcelle.id == null) throw Exception('Parcelle ID is required for update');
      await _userRef!.child('parcelles').child(parcelle.id.toString()).set(parcelle.toMap());
    } else {
      // Mode localStorage
      _saveParcelleToStorage(parcelle);
    }
  }

  Future<void> deleteParcelle(String id) async {
    if (_userRef != null) {
      await _userRef!.child('parcelles').child(id).remove();
    } else {
      // Mode localStorage
      _deleteParcelleFromStorage(id);
    }
  }

  // Méthodes pour les cellules
  Stream<List<Cellule>> getCellulesStream() {
    if (_userRef != null) {
      return _userRef!.child('cellules').onValue.map((event) {
        if (event.snapshot.value == null) return <Cellule>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> celluleData = Map<String, dynamic>.from(entry.value as Map);
          celluleData['id'] = entry.key;
          return Cellule.fromMap(celluleData);
        }).toList();
      });
    } else {
      return Stream.value(_getCellulesFromStorage());
    }
  }

  Future<String> insertCellule(Cellule cellule) async {
    if (_userRef != null) {
      final ref = _userRef!.child('cellules').push();
      await ref.set(cellule.toMap());
      return ref.key!;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      cellule.id = int.tryParse(id) ?? 0;
      _saveCelluleToStorage(cellule);
      return id;
    }
  }

  Future<void> updateCellule(Cellule cellule) async {
    if (_userRef != null) {
      if (cellule.id == null) throw Exception('Cellule ID is required for update');
      await _userRef!.child('cellules').child(cellule.id.toString()).set(cellule.toMap());
    } else {
      _saveCelluleToStorage(cellule);
    }
  }

  Future<void> deleteCellule(String id) async {
    if (_userRef != null) {
      await _userRef!.child('cellules').child(id).remove();
    } else {
      _deleteCelluleFromStorage(id);
    }
  }

  // Méthodes pour les chargements
  Stream<List<Chargement>> getChargementsStream() {
    if (_userRef != null) {
      return _userRef!.child('chargements').onValue.map((event) {
        if (event.snapshot.value == null) return <Chargement>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> chargementData = Map<String, dynamic>.from(entry.value as Map);
          chargementData['id'] = entry.key;
          return Chargement.fromMap(chargementData);
        }).toList();
      });
    } else {
      return Stream.value(_getChargementsFromStorage());
    }
  }

  Future<String> insertChargement(Chargement chargement) async {
    if (_userRef != null) {
      final ref = _userRef!.child('chargements').push();
      await ref.set(chargement.toMap());
      return ref.key!;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      chargement.id = int.tryParse(id) ?? 0;
      _saveChargementToStorage(chargement);
      return id;
    }
  }

  Future<void> updateChargement(Chargement chargement) async {
    if (_userRef != null) {
      if (chargement.id == null) throw Exception('Chargement ID is required for update');
      await _userRef!.child('chargements').child(chargement.id.toString()).set(chargement.toMap());
    } else {
      _saveChargementToStorage(chargement);
    }
  }

  Future<void> deleteChargement(String id) async {
    if (_userRef != null) {
      await _userRef!.child('chargements').child(id).remove();
    } else {
      _deleteChargementFromStorage(id);
    }
  }

  // Méthodes pour les semis
  Stream<List<Semis>> getSemisStream() {
    if (_userRef != null) {
      return _userRef!.child('semis').onValue.map((event) {
        if (event.snapshot.value == null) return <Semis>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> semisData = Map<String, dynamic>.from(entry.value as Map);
          semisData['id'] = entry.key;
          return Semis.fromMap(semisData);
        }).toList();
      });
    } else {
      return Stream.value(_getSemisFromStorage());
    }
  }

  Future<String> insertSemis(Semis semis) async {
    if (_userRef != null) {
      final ref = _userRef!.child('semis').push();
      await ref.set(semis.toMap());
      return ref.key!;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      semis.id = int.tryParse(id) ?? 0;
      _saveSemisToStorage(semis);
      return id;
    }
  }

  Future<void> updateSemis(Semis semis) async {
    if (_userRef != null) {
      if (semis.id == null) throw Exception('Semis ID is required for update');
      await _userRef!.child('semis').child(semis.id.toString()).set(semis.toMap());
    } else {
      _saveSemisToStorage(semis);
    }
  }

  Future<void> deleteSemis(String id) async {
    if (_userRef != null) {
      await _userRef!.child('semis').child(id).remove();
    } else {
      _deleteSemisFromStorage(id);
    }
  }

  // Méthodes pour les variétés
  Stream<List<Variete>> getVarietesStream() {
    if (_userRef != null) {
      return _userRef!.child('varietes').onValue.map((event) {
        if (event.snapshot.value == null) return <Variete>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> varieteData = Map<String, dynamic>.from(entry.value as Map);
          varieteData['id'] = entry.key;
          return Variete.fromMap(varieteData);
        }).toList();
      });
    } else {
      return Stream.value(_getVarietesFromStorage());
    }
  }

  Future<String> insertVariete(Variete variete) async {
    if (_userRef != null) {
      final ref = _userRef!.child('varietes').push();
      await ref.set(variete.toMap());
      return ref.key!;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      variete.id = int.tryParse(id) ?? 0;
      _saveVarieteToStorage(variete);
      return id;
    }
  }

  Future<void> updateVariete(Variete variete) async {
    if (_userRef != null) {
      if (variete.id == null) throw Exception('Variete ID is required for update');
      await _userRef!.child('varietes').child(variete.id.toString()).set(variete.toMap());
    } else {
      _saveVarieteToStorage(variete);
    }
  }

  Future<void> deleteVariete(String id) async {
    if (_userRef != null) {
      await _userRef!.child('varietes').child(id).remove();
    } else {
      _deleteVarieteFromStorage(id);
    }
  }

  // Méthodes utilitaires
  Future<void> deleteAllData() async {
    if (_userRef != null) {
      await _userRef!.remove();
    } else {
      html.window.localStorage.remove(_storageKey);
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    if (_userRef != null) {
      await _userRef!.set(data);
    } else {
      html.window.localStorage[_storageKey] = jsonEncode(data);
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    if (_userRef != null) {
      final snapshot = await _userRef!.get();
      return Map<String, dynamic>.from(snapshot.value as Map? ?? {});
    } else {
      final stored = html.window.localStorage[_storageKey];
      return stored != null ? jsonDecode(stored) : {};
    }
  }

  Future<void> updateAllChargementsPoidsNormes() async {
    // Cette méthode n'est pas nécessaire pour le service hybride
    // car les calculs sont faits automatiquement lors de l'ajout/modification
    print('updateAllChargementsPoidsNormes: Not needed for hybrid service');
  }

  // Méthodes localStorage
  List<Parcelle> _getParcellesFromStorage() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final parcelles = data['parcelles'] as List? ?? [];
        return parcelles.map((p) => Parcelle.fromMap(Map<String, dynamic>.from(p))).toList();
      }
    } catch (e) {
      print('Error loading parcelles from storage: $e');
    }
    return [];
  }

  void _saveParcelleToStorage(Parcelle parcelle) {
    try {
      final stored = html.window.localStorage[_storageKey];
      final data = stored != null ? jsonDecode(stored) : {'parcelles': []};
      final parcelles = List<Map<String, dynamic>>.from(data['parcelles'] ?? []);
      
      final existingIndex = parcelles.indexWhere((p) => p['id'] == parcelle.id);
      if (existingIndex >= 0) {
        parcelles[existingIndex] = parcelle.toMap();
      } else {
        parcelles.add(parcelle.toMap());
      }
      
      data['parcelles'] = parcelles;
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('Error saving parcelle to storage: $e');
    }
  }

  void _deleteParcelleFromStorage(String id) {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final parcelles = List<Map<String, dynamic>>.from(data['parcelles'] ?? []);
        parcelles.removeWhere((p) => p['id'].toString() == id);
        data['parcelles'] = parcelles;
        html.window.localStorage[_storageKey] = jsonEncode(data);
      }
    } catch (e) {
      print('Error deleting parcelle from storage: $e');
    }
  }

  // Méthodes similaires pour les autres entités...
  List<Cellule> _getCellulesFromStorage() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final cellules = data['cellules'] as List? ?? [];
        return cellules.map((c) => Cellule.fromMap(Map<String, dynamic>.from(c))).toList();
      }
    } catch (e) {
      print('Error loading cellules from storage: $e');
    }
    return [];
  }

  void _saveCelluleToStorage(Cellule cellule) {
    try {
      final stored = html.window.localStorage[_storageKey];
      final data = stored != null ? jsonDecode(stored) : {'cellules': []};
      final cellules = List<Map<String, dynamic>>.from(data['cellules'] ?? []);
      
      final existingIndex = cellules.indexWhere((c) => c['id'] == cellule.id);
      if (existingIndex >= 0) {
        cellules[existingIndex] = cellule.toMap();
      } else {
        cellules.add(cellule.toMap());
      }
      
      data['cellules'] = cellules;
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('Error saving cellule to storage: $e');
    }
  }

  void _deleteCelluleFromStorage(String id) {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final cellules = List<Map<String, dynamic>>.from(data['cellules'] ?? []);
        cellules.removeWhere((c) => c['id'].toString() == id);
        data['cellules'] = cellules;
        html.window.localStorage[_storageKey] = jsonEncode(data);
      }
    } catch (e) {
      print('Error deleting cellule from storage: $e');
    }
  }

  // Méthodes pour chargements, semis, variétés (similaires)
  List<Chargement> _getChargementsFromStorage() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final chargements = data['chargements'] as List? ?? [];
        return chargements.map((c) => Chargement.fromMap(Map<String, dynamic>.from(c))).toList();
      }
    } catch (e) {
      print('Error loading chargements from storage: $e');
    }
    return [];
  }

  void _saveChargementToStorage(Chargement chargement) {
    try {
      final stored = html.window.localStorage[_storageKey];
      final data = stored != null ? jsonDecode(stored) : {'chargements': []};
      final chargements = List<Map<String, dynamic>>.from(data['chargements'] ?? []);
      
      final existingIndex = chargements.indexWhere((c) => c['id'] == chargement.id);
      if (existingIndex >= 0) {
        chargements[existingIndex] = chargement.toMap();
      } else {
        chargements.add(chargement.toMap());
      }
      
      data['chargements'] = chargements;
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('Error saving chargement to storage: $e');
    }
  }

  void _deleteChargementFromStorage(String id) {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final chargements = List<Map<String, dynamic>>.from(data['chargements'] ?? []);
        chargements.removeWhere((c) => c['id'].toString() == id);
        data['chargements'] = chargements;
        html.window.localStorage[_storageKey] = jsonEncode(data);
      }
    } catch (e) {
      print('Error deleting chargement from storage: $e');
    }
  }

  List<Semis> _getSemisFromStorage() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final semis = data['semis'] as List? ?? [];
        return semis.map((s) => Semis.fromMap(Map<String, dynamic>.from(s))).toList();
      }
    } catch (e) {
      print('Error loading semis from storage: $e');
    }
    return [];
  }

  void _saveSemisToStorage(Semis semis) {
    try {
      final stored = html.window.localStorage[_storageKey];
      final data = stored != null ? jsonDecode(stored) : {'semis': []};
      final semisList = List<Map<String, dynamic>>.from(data['semis'] ?? []);
      
      final existingIndex = semisList.indexWhere((s) => s['id'] == semis.id);
      if (existingIndex >= 0) {
        semisList[existingIndex] = semis.toMap();
      } else {
        semisList.add(semis.toMap());
      }
      
      data['semis'] = semisList;
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('Error saving semis to storage: $e');
    }
  }

  void _deleteSemisFromStorage(String id) {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final semis = List<Map<String, dynamic>>.from(data['semis'] ?? []);
        semis.removeWhere((s) => s['id'].toString() == id);
        data['semis'] = semis;
        html.window.localStorage[_storageKey] = jsonEncode(data);
      }
    } catch (e) {
      print('Error deleting semis from storage: $e');
    }
  }

  List<Variete> _getVarietesFromStorage() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final varietes = data['varietes'] as List? ?? [];
        return varietes.map((v) => Variete.fromMap(Map<String, dynamic>.from(v))).toList();
      }
    } catch (e) {
      print('Error loading varietes from storage: $e');
    }
    return [];
  }

  void _saveVarieteToStorage(Variete variete) {
    try {
      final stored = html.window.localStorage[_storageKey];
      final data = stored != null ? jsonDecode(stored) : {'varietes': []};
      final varietes = List<Map<String, dynamic>>.from(data['varietes'] ?? []);
      
      final existingIndex = varietes.indexWhere((v) => v['id'] == variete.id);
      if (existingIndex >= 0) {
        varietes[existingIndex] = variete.toMap();
      } else {
        varietes.add(variete.toMap());
      }
      
      data['varietes'] = varietes;
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('Error saving variete to storage: $e');
    }
  }

  void _deleteVarieteFromStorage(String id) {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final varietes = List<Map<String, dynamic>>.from(data['varietes'] ?? []);
        varietes.removeWhere((v) => v['id'].toString() == id);
        data['varietes'] = varietes;
        html.window.localStorage[_storageKey] = jsonEncode(data);
      }
    } catch (e) {
      print('Error deleting variete from storage: $e');
    }
  }
}
