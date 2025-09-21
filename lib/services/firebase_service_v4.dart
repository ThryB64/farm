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

class FirebaseServiceV4 {
  static final FirebaseServiceV4 _instance = FirebaseServiceV4._internal();
  factory FirebaseServiceV4() => _instance;
  FirebaseServiceV4._internal();

  late final FirebaseDatabase _database;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _farmRef;
  
  // ID de la ferme partagée
  static const String _farmId = 'gaec_berard';
  static const String _storageKey = 'mais_tracker_data_v4';
  bool _isInitialized = false;

  // Initialiser le service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('FirebaseService V4: Initializing...');
      
      _database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://farmgaec-default-rtdb.firebaseio.com',
      );
      print('FirebaseService V4: Firebase instance created');

      // Persistance pour les plateformes natives
      if (!kIsWeb) {
        _database.setPersistenceEnabled(true);
        _database.setPersistenceCacheSizeBytes(10 * 1024 * 1024);
      }

      // Authentification
      final user = _auth.currentUser;
      if (user == null) {
        await _auth.signInAnonymously();
      }
      
      _farmRef = _database.ref('farms/$_farmId');
      await _addUserToFarm(_auth.currentUser!.uid);
      
      print('✅ FirebaseService V4: Initialized successfully');
      _isInitialized = true;
      
    } catch (e) {
      print('❌ FirebaseService V4: Init failed: $e');
      _isInitialized = true;
    }
  }

  // Ajouter l'utilisateur comme membre de la ferme
  Future<void> _addUserToFarm(String uid) async {
    try {
      await _database.ref('farmMembers/$_farmId/$uid').set(true);
      print('FirebaseService V4: User $uid added to farm $_farmId');
    } catch (e) {
      print('FirebaseService V4: Failed to add user to farm: $e');
    }
  }

  // ===== GÉNÉRATION DE CLÉS STANDARDISÉES =====
  
  String _generateParcelleKey(Parcelle parcelle) {
    final nom = parcelle.nom.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final surface = (parcelle.surface * 100).round();
    return 'parcelle_${nom}_${surface}';
  }

  String _generateCelluleKey(Cellule cellule) {
    return 'cellule_${cellule.reference}';
  }

  String _generateChargementKey(Chargement chargement) {
    final date = chargement.dateChargement.toIso8601String().split('T')[0];
    final remorque = chargement.remorque.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    return 'chargement_${date}_${remorque}';
  }

  String _generateSemisKey(Semis semis) {
    final date = semis.date.toIso8601String().split('T')[0];
    return 'semis_${semis.parcelleId}_${date}';
  }

  String _generateVarieteKey(Variete variete) {
    final nom = variete.nom.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    return 'variete_$nom';
  }

  // ===== MÉTHODES POUR PARCELLES =====
  
  Stream<List<Parcelle>> getParcellesStream() {
    if (_farmRef != null) {
      return _farmRef!.child('parcelles').onValue.map((event) {
        if (event.snapshot.value == null) return <Parcelle>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> parcelleData = Map<String, dynamic>.from(entry.value as Map);
          parcelleData['firebaseId'] = entry.key;
          return Parcelle.fromMap(parcelleData);
        }).toList();
      });
    } else {
      return Stream.value(_getParcellesFromStorage());
    }
  }

  Future<String> insertParcelle(Parcelle parcelle) async {
    if (_farmRef != null) {
      final key = _generateParcelleKey(parcelle);
      await _farmRef!.child('parcelles').child(key).set({
        ...parcelle.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
      print('FirebaseService V4: Parcelle inserted: $key');
      return key;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      parcelle.id = int.tryParse(id) ?? 0;
      _saveParcelleToStorage(parcelle);
      return id;
    }
  }

  Future<void> updateParcelle(Parcelle parcelle) async {
    if (_farmRef != null) {
      final key = parcelle.firebaseId ?? _generateParcelleKey(parcelle);
      await _farmRef!.child('parcelles').child(key).update({
        ...parcelle.toMap(),
        'firebaseId': key,
        'updatedAt': ServerValue.timestamp,
      });
    } else {
      _saveParcelleToStorage(parcelle);
    }
  }

  Future<void> deleteParcelle(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('parcelles').child(key).remove();
    } else {
      _deleteParcelleFromStorage(key);
    }
  }

  // ===== MÉTHODES POUR CELLULES =====
  
  Stream<List<Cellule>> getCellulesStream() {
    if (_farmRef != null) {
      return _farmRef!.child('cellules').onValue.map((event) {
        if (event.snapshot.value == null) return <Cellule>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> celluleData = Map<String, dynamic>.from(entry.value as Map);
          celluleData['firebaseId'] = entry.key;
          return Cellule.fromMap(celluleData);
        }).toList();
      });
    } else {
      return Stream.value(_getCellulesFromStorage());
    }
  }

  Future<String> insertCellule(Cellule cellule) async {
    if (_farmRef != null) {
      final key = _generateCelluleKey(cellule);
      await _farmRef!.child('cellules').child(key).set({
        ...cellule.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
      print('FirebaseService V4: Cellule inserted: $key');
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
      final key = cellule.firebaseId ?? _generateCelluleKey(cellule);
      await _farmRef!.child('cellules').child(key).update({
        ...cellule.toMap(),
        'firebaseId': key,
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

  // ===== MÉTHODES POUR CHARGEMENTS =====
  
  Stream<List<Chargement>> getChargementsStream() {
    if (_farmRef != null) {
      return _farmRef!.child('chargements').onValue.map((event) {
        if (event.snapshot.value == null) return <Chargement>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> chargementData = Map<String, dynamic>.from(entry.value as Map);
          chargementData['firebaseId'] = entry.key;
          return Chargement.fromMap(chargementData);
        }).toList();
      });
    } else {
      return Stream.value(_getChargementsFromStorage());
    }
  }

  Future<String> insertChargement(Chargement chargement) async {
    if (_farmRef != null) {
      final key = _generateChargementKey(chargement);
      await _farmRef!.child('chargements').child(key).set({
        ...chargement.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
      print('FirebaseService V4: Chargement inserted: $key');
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
      final key = chargement.firebaseId ?? _generateChargementKey(chargement);
      await _farmRef!.child('chargements').child(key).update({
        ...chargement.toMap(),
        'firebaseId': key,
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

  // ===== MÉTHODES POUR SEMIS =====
  
  Stream<List<Semis>> getSemisStream() {
    if (_farmRef != null) {
      return _farmRef!.child('semis').onValue.map((event) {
        if (event.snapshot.value == null) return <Semis>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> semisData = Map<String, dynamic>.from(entry.value as Map);
          semisData['firebaseId'] = entry.key;
          return Semis.fromMap(semisData);
        }).toList();
      });
    } else {
      return Stream.value(_getSemisFromStorage());
    }
  }

  Future<String> insertSemis(Semis semis) async {
    if (_farmRef != null) {
      final key = _generateSemisKey(semis);
      await _farmRef!.child('semis').child(key).set({
        ...semis.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
      print('FirebaseService V4: Semis inserted: $key');
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
      final key = semis.firebaseId ?? _generateSemisKey(semis);
      await _farmRef!.child('semis').child(key).update({
        ...semis.toMap(),
        'firebaseId': key,
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

  // ===== MÉTHODES POUR VARIÉTÉS =====
  
  Stream<List<Variete>> getVarietesStream() {
    if (_farmRef != null) {
      return _farmRef!.child('varietes').onValue.map((event) {
        if (event.snapshot.value == null) return <Variete>[];
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        return data.entries.map((entry) {
          final Map<String, dynamic> varieteData = Map<String, dynamic>.from(entry.value as Map);
          varieteData['firebaseId'] = entry.key;
          return Variete.fromMap(varieteData);
        }).toList();
      });
    } else {
      return Stream.value(_getVarietesFromStorage());
    }
  }

  Future<String> insertVariete(Variete variete) async {
    if (_farmRef != null) {
      final key = _generateVarieteKey(variete);
      await _farmRef!.child('varietes').child(key).set({
        ...variete.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
      print('FirebaseService V4: Variete inserted: $key');
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
      final key = variete.firebaseId ?? _generateVarieteKey(variete);
      await _farmRef!.child('varietes').child(key).update({
        ...variete.toMap(),
        'firebaseId': key,
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

  // ===== MÉTHODES DE STOCKAGE LOCAL =====
  
  List<Parcelle> _getParcellesFromStorage() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final parcelles = (data['parcelles'] as List?) ?? [];
        return parcelles.map((p) => Parcelle.fromMap(p)).toList();
      }
    } catch (e) {
      print('Error loading parcelles from storage: $e');
    }
    return [];
  }

  void _saveParcelleToStorage(Parcelle parcelle) {
    try {
      final stored = html.window.localStorage[_storageKey];
      final data = stored != null ? jsonDecode(stored) : {};
      final parcelles = (data['parcelles'] as List?) ?? [];
      parcelles.add(parcelle.toMap());
      data['parcelles'] = parcelles;
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('Error saving parcelle to storage: $e');
    }
  }

  void _deleteParcelleFromStorage(String key) {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final parcelles = (data['parcelles'] as List?) ?? [];
        parcelles.removeWhere((p) => p['firebaseId'] == key);
        data['parcelles'] = parcelles;
        html.window.localStorage[_storageKey] = jsonEncode(data);
      }
    } catch (e) {
      print('Error deleting parcelle from storage: $e');
    }
  }

  // Méthodes similaires pour les autres entités...
  List<Cellule> _getCellulesFromStorage() => [];
  void _saveCelluleToStorage(Cellule cellule) {}
  void _deleteCelluleFromStorage(String key) {}
  
  List<Chargement> _getChargementsFromStorage() => [];
  void _saveChargementToStorage(Chargement chargement) {}
  void _deleteChargementFromStorage(String key) {}
  
  List<Semis> _getSemisFromStorage() => [];
  void _saveSemisToStorage(Semis semis) {}
  void _deleteSemisFromStorage(String key) {}
  
  List<Variete> _getVarietesFromStorage() => [];
  void _saveVarieteToStorage(Variete variete) {}
  void _deleteVarieteFromStorage(String key) {}

  // ===== MÉTHODES D'IMPORT/EXPORT =====
  
  Future<void> deleteAllData() async {
    if (_farmRef != null) {
      await _farmRef!.remove();
      print('FirebaseService V4: All farm data deleted');
    } else {
      html.window.localStorage.remove(_storageKey);
      print('FirebaseService V4: Local storage cleared');
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    if (_farmRef != null) {
      await _farmRef!.set(data);
    } else {
      html.window.localStorage[_storageKey] = jsonEncode(data);
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    if (_farmRef != null) {
      final snapshot = await _farmRef!.get();
      return Map<String, dynamic>.from(snapshot.value as Map? ?? {});
    } else {
      final stored = html.window.localStorage[_storageKey];
      return stored != null ? jsonDecode(stored) : {};
    }
  }
}
