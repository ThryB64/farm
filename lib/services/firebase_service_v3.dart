import 'dart:convert';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';

class FirebaseServiceV3 {
  static final FirebaseServiceV3 _instance = FirebaseServiceV3._internal();
  factory FirebaseServiceV3() => _instance;
  FirebaseServiceV3._internal();

  late final FirebaseDatabase _database;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _userRef;
  DatabaseReference? _farmRef;
  
  // ID de la ferme partagée
  static const String _farmId = 'gaec_berard';
  
  static const String _storageKey = 'mais_tracker_data';
  bool _isInitialized = false;

  // Initialiser le service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('FirebaseService V3: Initializing...');
      
      // Forcer l'instance avec la bonne URL
      _database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://farmgaec-default-rtdb.firebaseio.com',
      );
      print('FirebaseService V3: Firebase instance created with URL: https://farmgaec-default-rtdb.firebaseio.com');

      // Persistance : seulement sur les plateformes natives
      if (!kIsWeb) {
        _database.setPersistenceEnabled(true);
        _database.setPersistenceCacheSizeBytes(10 * 1024 * 1024);
        print('FirebaseService V3: Persistence enabled for native platforms');
      } else {
        print('FirebaseService V3: Web platform - persistence handled automatically');
      }

      // Vérifier la connexion
      _database.ref('.info/connected').onValue.listen((event) {
        print('FirebaseService V3 connected: ${event.snapshot.value}');
      });

      // Authentification
      final user = _auth.currentUser;
      if (user != null) {
        _userRef = _database.ref('users/${user.uid}');
        _farmRef = _database.ref('farms/$_farmId');
        print('FirebaseService V3: Firebase initialized for existing user: ${user.uid}');
        print('FirebaseService V3: Farm reference created: /farms/$_farmId');
        
        // Ajouter l'utilisateur comme membre de la ferme
        await _addUserToFarm(user.uid);
      } else {
        // Essayer l'auth anonyme
        try {
          final userCred = await _auth.signInAnonymously();
          final newUser = userCred.user;
          if (newUser != null) {
            _userRef = _database.ref('users/${newUser.uid}');
            _farmRef = _database.ref('farms/$_farmId');
            print('FirebaseService V3: Firebase initialized for anonymous user: ${newUser.uid}');
            print('FirebaseService V3: Farm reference created: /farms/$_farmId');
            
            // Ajouter l'utilisateur comme membre de la ferme
            await _addUserToFarm(newUser.uid);
          }
        } catch (authError) {
          print('FirebaseService V3: Auth failed, using localStorage: $authError');
        }
      }
      
      // Test de connexion
      if (_farmRef != null) {
        await _testConnection();
        print('FirebaseService V3: User reference created successfully');
        print('FirebaseService V3: User path: ${_userRef!.path}');
      } else {
        print('FirebaseService V3: No user reference - will use localStorage only');
      }
      
      _isInitialized = true;
      print('✅ FirebaseService V3: Initialized successfully');
      
    } catch (e) {
      print('❌ FirebaseService V3: Firebase init failed, using localStorage: $e');
      _isInitialized = true; // Permettre l'utilisation hors ligne
    }
  }

  // Ajouter l'utilisateur comme membre de la ferme
  Future<void> _addUserToFarm(String uid) async {
    try {
      await _database.ref('farmMembers/$_farmId/$uid').set(true);
      print('FirebaseService V3: User $uid added to farm $_farmId');
    } catch (e) {
      print('FirebaseService V3: Failed to add user to farm: $e');
    }
  }

  // Test de connexion
  Future<void> _testConnection() async {
    try {
      await _database.ref('ping').set({
        'at': ServerValue.timestamp,
        'test': 'FirebaseService V3 connection test',
      });
      print('✅ FirebaseService V3: Connection test successful');
    } catch (e) {
      print('❌ FirebaseService V3: Connection test failed: $e');
    }
  }

  // Générer une clé stable déterministe pour une parcelle
  String generateStableKey(Parcelle parcelle) {
    final slug = parcelle.nom.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final surf = (parcelle.surface * 1000).round();
    return 'f_${slug}_$surf';
  }

  // Générer une clé stable pour les autres entités
  String generateStableKeyForEntity(String type, Map<String, dynamic> data) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${type}_${timestamp}';
  }

  // Méthodes pour les parcelles
  Stream<List<Parcelle>> getParcellesStream() {
    if (_farmRef != null) {
      return _farmRef!.child('parcelles').onValue.map((event) {
        if (event.snapshot.value == null) return <Parcelle>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> parcelleData = Map<String, dynamic>.from(entry.value as Map);
          parcelleData['id'] = entry.key;
          return Parcelle.fromMap(parcelleData);
        }).toList();
      });
    } else {
      return Stream.value(_getParcellesFromStorage());
    }
  }

  Future<String> insertParcelle(Parcelle parcelle) async {
    if (_farmRef != null) {
      final key = generateStableKey(parcelle);
      final ref = _farmRef!.child('parcelles').child(key);
      
      await ref.set({
        ...parcelle.toMap(),
        'id': key,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      
      print('FirebaseService V3: Parcelle inserted with stable key: $key');
      return key;
    } else {
      // Mode localStorage
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      parcelle.id = int.tryParse(id) ?? 0;
      _saveParcelleToStorage(parcelle);
      return id;
    }
  }

  Future<void> updateParcelle(Parcelle parcelle) async {
    if (_farmRef != null) {
      final key = generateStableKey(parcelle);
      await _farmRef!.child('parcelles').child(key).update({
        ...parcelle.toMap(),
        'id': key,
        'updatedAt': ServerValue.timestamp,
      });
      print('FirebaseService V3: Parcelle updated with key: $key');
    } else {
      _saveParcelleToStorage(parcelle);
    }
  }

  Future<void> deleteParcelle(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('parcelles').child(key).remove();
      print('FirebaseService V3: Parcelle deleted: $key');
    } else {
      _deleteParcelleFromStorage(key);
    }
  }

  // Méthodes pour les cellules
  Stream<List<Cellule>> getCellulesStream() {
    if (_farmRef != null) {
      return _farmRef!.child('cellules').onValue.map((event) {
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
    if (_farmRef != null) {
      final key = generateStableKeyForEntity('cellule', cellule.toMap());
      final ref = _farmRef!.child('cellules').child(key);
      await ref.set({
        ...cellule.toMap(),
        'id': key,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      return key;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      cellule.id = int.tryParse(id) ?? 0;
      _saveCelluleToStorage(cellule);
      return id;
    }
  }

  Future<void> updateCellule(Cellule cellule) async {
    if (_farmRef != null) {
      if (cellule.id == null) throw Exception('Cellule ID is required for update');
      await _farmRef!.child('cellules').child(cellule.id.toString()).update({
        ...cellule.toMap(),
        'updatedAt': ServerValue.timestamp,
      });
    } else {
      _saveCelluleToStorage(cellule);
    }
  }

  Future<void> deleteCellule(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('cellules').child(key).remove();
    } else {
      _deleteCelluleFromStorage(key);
    }
  }

  // Méthodes pour les chargements
  Stream<List<Chargement>> getChargementsStream() {
    if (_farmRef != null) {
      return _farmRef!.child('chargements').onValue.map((event) {
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
    if (_farmRef != null) {
      final key = generateStableKeyForEntity('chargement', chargement.toMap());
      final ref = _farmRef!.child('chargements').child(key);
      await ref.set({
        ...chargement.toMap(),
        'id': key,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      return key;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      chargement.id = int.tryParse(id) ?? 0;
      _saveChargementToStorage(chargement);
      return id;
    }
  }

  Future<void> updateChargement(Chargement chargement) async {
    if (_farmRef != null) {
      if (chargement.id == null) throw Exception('Chargement ID is required for update');
      await _farmRef!.child('chargements').child(chargement.id.toString()).update({
        ...chargement.toMap(),
        'updatedAt': ServerValue.timestamp,
      });
    } else {
      _saveChargementToStorage(chargement);
    }
  }

  Future<void> deleteChargement(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('chargements').child(key).remove();
    } else {
      _deleteChargementFromStorage(key);
    }
  }

  // Méthodes pour les semis
  Stream<List<Semis>> getSemisStream() {
    if (_farmRef != null) {
      return _farmRef!.child('semis').onValue.map((event) {
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
    if (_farmRef != null) {
      final key = generateStableKeyForEntity('semis', semis.toMap());
      final ref = _farmRef!.child('semis').child(key);
      await ref.set({
        ...semis.toMap(),
        'id': key,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      return key;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      semis.id = int.tryParse(id) ?? 0;
      _saveSemisToStorage(semis);
      return id;
    }
  }

  Future<void> updateSemis(Semis semis) async {
    if (_farmRef != null) {
      if (semis.id == null) throw Exception('Semis ID is required for update');
      await _farmRef!.child('semis').child(semis.id.toString()).update({
        ...semis.toMap(),
        'updatedAt': ServerValue.timestamp,
      });
    } else {
      _saveSemisToStorage(semis);
    }
  }

  Future<void> deleteSemis(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('semis').child(key).remove();
    } else {
      _deleteSemisFromStorage(key);
    }
  }

  // Méthodes pour les variétés
  Stream<List<Variete>> getVarietesStream() {
    if (_farmRef != null) {
      return _farmRef!.child('varietes').onValue.map((event) {
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
    if (_farmRef != null) {
      final key = generateStableKeyForEntity('variete', variete.toMap());
      final ref = _farmRef!.child('varietes').child(key);
      await ref.set({
        ...variete.toMap(),
        'id': key,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      return key;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      variete.id = int.tryParse(id) ?? 0;
      _saveVarieteToStorage(variete);
      return id;
    }
  }

  Future<void> updateVariete(Variete variete) async {
    if (_farmRef != null) {
      if (variete.id == null) throw Exception('Variete ID is required for update');
      await _farmRef!.child('varietes').child(variete.id.toString()).update({
        ...variete.toMap(),
        'updatedAt': ServerValue.timestamp,
      });
    } else {
      _saveVarieteToStorage(variete);
    }
  }

  Future<void> deleteVariete(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('varietes').child(key).remove();
    } else {
      _deleteVarieteFromStorage(key);
    }
  }

  // Méthodes utilitaires
  Future<void> deleteAllData() async {
    if (_farmRef != null) {
      await _userRef!.remove();
    } else {
      html.window.localStorage.remove(_storageKey);
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    if (_farmRef != null) {
      await _userRef!.set(data);
    } else {
      html.window.localStorage[_storageKey] = jsonEncode(data);
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    if (_farmRef != null) {
      final snapshot = await _userRef!.get();
      return Map<String, dynamic>.from(snapshot.value as Map? ?? {});
    } else {
      final stored = html.window.localStorage[_storageKey];
      return stored != null ? jsonDecode(stored) : {};
    }
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
