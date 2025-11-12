import 'dart:convert';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/parcelle.dart';
import '../models/variete.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/vente.dart';
import '../models/traitement.dart';
import '../models/produit.dart';
import '../utils/firebase_normalize.dart';

class FirebaseServiceV4 {
  static final FirebaseServiceV4 _instance = FirebaseServiceV4._internal();
  factory FirebaseServiceV4() => _instance;
  FirebaseServiceV4._internal();
  
  static bool _isGloballyInitialized = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? _farmRef;
  
  // ID de la ferme (déterminé automatiquement selon l'utilisateur)
  String? _farmId;
  String? _currentUserId;
  static const String _storageKey = 'mais_tracker_data_v4';
  bool _isInitialized = false;

  // Réinitialiser le service (pour changement d'utilisateur)
  void reset() {
    _isInitialized = false;
    _farmId = null;
    _farmRef = null;
    _currentUserId = null;
    print('FirebaseService V4: Reset for new user');
  }

  // Initialiser le service
  Future<void> initialize() async {
    final user = _auth.currentUser;
    
    // Si l'utilisateur a changé, réinitialiser
    if (_currentUserId != null && _currentUserId != user?.uid) {
      print('FirebaseService V4: User changed, resetting...');
      reset();
    }
    
    if (_isInitialized) return;
    
    try {
      print('FirebaseService V4: Initializing...');
      
      // Vérifier l'initialisation globale pour éviter les doublons
      if (_isGloballyInitialized) {
        print('FirebaseService V4: Already globally initialized, skipping...');
        _isInitialized = true;
        return;
      }
      
      // Initialiser App Check
      await _initializeAppCheck();
      
      // Utiliser le singleton Firebase Database
      final database = await FirebaseDatabase.instance;
      print('FirebaseService V4: Using singleton database instance');

      // Vérifier l'authentification
      final user = _auth.currentUser;
      if (user != null) {
        try {
          // Récupérer la ferme assignée à cet utilisateur
          _farmId = await _getUserFarm(user.uid);
          
          if (_farmId == null) {
            print('FirebaseService V4: No farm assigned to user ${user.uid}');
            throw Exception('Aucune ferme assignée à cet utilisateur');
          }
          
          // Utiliser farms/{farmId} comme chemin (ex: farms/agricorn_demo)
          _farmRef = database.ref('farms/$_farmId');
          await _addUserToFarm(user.uid, _farmId!);
          _currentUserId = user.uid;
          print('FirebaseService V4: User authenticated: ${user.uid}, Farm: $_farmId');
        } catch (e) {
          print('FirebaseService V4: Auth setup failed: $e');
          // Continuer en mode hors ligne
        }
      } else {
        print('FirebaseService V4: No authenticated user - using local storage only');
        _currentUserId = null;
        // En mode hors ligne, on utilise seulement le localStorage
      }
      
      print('✅ FirebaseService V4: Initialized successfully');
      _isInitialized = true;
      _isGloballyInitialized = true;
      
    } catch (e) {
      print('❌ FirebaseService V4: Init failed: $e');
      _isInitialized = true;
    }
  }

  // Initialiser App Check
  Future<void> _initializeAppCheck() async {
    try {
      if (kIsWeb) {
        // App Check pour Web avec reCAPTCHA v3 (désactivé temporairement)
        // await FirebaseAppCheck.instance.activate(
        //   webRecaptchaSiteKey: '6LfXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
        // );
        print('FirebaseService V4: App Check skipped for Web (to be configured)');
      } else {
        // App Check pour mobile (optionnel)
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug, // En production, utiliser playIntegrity
          appleProvider: AppleProvider.debug, // En production, utiliser appAttest
        );
        print('FirebaseService V4: App Check activated for Mobile');
      }
    } catch (e) {
      print('FirebaseService V4: App Check activation failed: $e');
      // Continuer même si App Check échoue
    }
  }

  // Récupérer la ferme assignée à un utilisateur (chercher dans farms/{farmId}/allowedUsers/{uid})
  Future<String?> _getUserFarm(String uid) async {
    try {
      final database = await FirebaseDatabase.instance;
      
      // Parcourir toutes les fermes pour trouver celle où l'utilisateur est dans allowedUsers
      final farmsSnapshot = await database.ref('farms').get();
      
      if (farmsSnapshot.exists && farmsSnapshot.value != null) {
        final farms = farmsSnapshot.value as Map;
        
        for (final entry in farms.entries) {
          final farmId = entry.key as String;
          final farmData = entry.value as Map?;
          
          if (farmData != null) {
            // Vérifier si allowedUsers existe et contient cet utilisateur
            final allowedUsers = farmData['allowedUsers'] as Map?;
            if (allowedUsers != null && allowedUsers.containsKey(uid)) {
              print('FirebaseService V4: User $uid found in farm $farmId');
              return farmId;
            }
          }
        }
      }
      
      print('FirebaseService V4: No farm assigned to user $uid');
      return null;
    } catch (e) {
      print('FirebaseService V4: Failed to get user farm: $e');
      return null;
    }
  }

  // Ajouter l'utilisateur dans allowedUsers de la ferme
  Future<void> _addUserToFarm(String uid, String farmId) async {
    try {
      final database = await FirebaseDatabase.instance;
      
      // Ajouter l'utilisateur dans farms/{farmId}/allowedUsers/{uid}
      await database.ref('farms/$farmId/allowedUsers/$uid').set(true);
      print('FirebaseService V4: User $uid added to farm $farmId/allowedUsers');
    } catch (e) {
      print('FirebaseService V4: Failed to add user to farm: $e');
    }
  }

  // ===== GÉNÉRATION DE CLÉS STANDARDISÉES =====
  
  String generateParcelleKey(Parcelle parcelle) {
    final nom = parcelle.nom.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final surface = (parcelle.surface * 100).round();
    return 'parcelle_${nom}_${surface}';
  }

  String generateCelluleKey(Cellule cellule) {
    return 'cellule_${cellule.reference}';
  }

  String generateChargementKey(Chargement chargement) {
    final date = chargement.dateChargement.toIso8601String().split('T')[0];
    final remorque = chargement.remorque.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final poidsPlein = chargement.poidsPlein.toString();
    final poidsVide = chargement.poidsVide.toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'chargement_${date}_${remorque}_${poidsPlein}_${poidsVide}_$timestamp';
  }

  String generateSemisKey(Semis semis) {
    final date = semis.date.toIso8601String().split('T')[0];
    return 'semis_${semis.parcelleId}_${date}';
  }

  String generateVarieteKey(Variete variete) {
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
      final key = generateParcelleKey(parcelle);
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
      final key = parcelle.firebaseId ?? generateParcelleKey(parcelle);
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
      final key = generateCelluleKey(cellule);
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
      final key = cellule.firebaseId ?? generateCelluleKey(cellule);
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
      final key = generateChargementKey(chargement);
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
      final key = chargement.firebaseId ?? generateChargementKey(chargement);
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
      final key = generateSemisKey(semis);
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
      final key = semis.firebaseId ?? generateSemisKey(semis);
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
          
          print('🔍 Service: Chargement variété ${entry.key}');
          print('🔍 Service: Données reçues: $varieteData');
          
          final variete = Variete.fromMap(varieteData);
          print('🔍 Service: Variété parsée: ${variete.nom}, Prix: ${variete.prixParAnnee}');
          
          return variete;
        }).toList();
      });
    } else {
      return Stream.value(_getVarietesFromStorage());
    }
  }

  Future<String> insertVariete(Variete variete) async {
    if (_farmRef != null) {
      final key = generateVarieteKey(variete);
      final varieteMap = variete.toMap();
      
      print('🔍 Service: Création variété $key');
      print('🔍 Service: Données à sauvegarder: $varieteMap');
      
      await _farmRef!.child('varietes').child(key).set({
        ...varieteMap,
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
      
      print('✅ Service: Variété créée avec succès');
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
      final key = variete.firebaseId ?? generateVarieteKey(variete);
      final varieteMap = variete.toMap();
      
      print('🔍 Service: Mise à jour variété $key');
      print('🔍 Service: Données à sauvegarder: $varieteMap');
      
      // Forcer la sauvegarde de tous les champs, y compris prixParAnnee
      await _farmRef!.child('varietes').child(key).set({
        ...varieteMap,
        'firebaseId': key,
        'updatedAt': ServerValue.timestamp,
      });
      
      print('✅ Service: Variété mise à jour avec succès');
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

  // ===== MÉTHODES POUR LES VENTES =====

  String generateVenteKey(Vente vente) {
    final date = vente.date.toIso8601String().split('T')[0];
    final ticket = vente.numeroTicket.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'v_${date}_${ticket}';
  }

  Stream<List<Vente>> getVentesStream() {
    if (_farmRef != null) {
      return _farmRef!.child('ventes').onValue.map((event) {
        if (event.snapshot.value == null) return <Vente>[];
        final data = event.snapshot.value as Map;
        return data.entries.map((entry) {
          final venteData = Map<String, dynamic>.from(entry.value as Map);
          venteData['firebaseId'] = entry.key;
          return Vente.fromMap(venteData);
        }).toList();
      });
    } else {
      return Stream.value(_getVentesFromStorage());
    }
  }

  Future<String> insertVente(Vente vente) async {
    if (_farmRef != null) {
      final key = generateVenteKey(vente);
      await _farmRef!.child('ventes').child(key).set({
        ...vente.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
      print('FirebaseService V4: Vente inserted: $key');
      return key;
    } else {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      vente.id = int.tryParse(id) ?? 0;
      _saveVenteToStorage(vente);
      return id;
    }
  }

  Future<void> updateVente(Vente vente) async {
    if (_farmRef != null) {
      final key = vente.firebaseId ?? generateVenteKey(vente);
      await _farmRef!.child('ventes').child(key).update({
        ...vente.toMap(),
        'firebaseId': key,
        'updatedAt': ServerValue.timestamp,
      });
    } else {
      _saveVenteToStorage(vente);
    }
  }

  Future<void> deleteVente(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('ventes').child(key).remove();
    } else {
      _deleteVenteFromStorage(key);
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
  
  List<Vente> _getVentesFromStorage() => [];
  void _saveVenteToStorage(Vente vente) {}
  void _deleteVenteFromStorage(String key) {}

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

  // ===== MÉTHODES POUR LES TRAITEMENTS =====
  
  Future<String> ajouterTraitement(Traitement traitement) async {
    if (_farmRef != null) {
      final ref = _farmRef!.child('traitements').push();
      final key = ref.key!;
      await ref.set(traitement.toMap());
      // Sauvegarder aussi en local pour la persistance
      _saveTraitementToStorage(traitement.copyWith(firebaseId: key));
      return key;
    } else {
      final key = 't_${DateTime.now().millisecondsSinceEpoch}';
      _saveTraitementToStorage(traitement.copyWith(firebaseId: key));
      return key;
    }
  }

  Future<void> modifierTraitement(Traitement traitement) async {
    final key = traitement.firebaseId ?? traitement.id.toString();
    if (_farmRef != null) {
      await _farmRef!.child('traitements').child(key).set(traitement.toMap());
      // Sauvegarder aussi en local pour la persistance
      _saveTraitementToStorage(traitement);
    } else {
      _saveTraitementToStorage(traitement);
    }
  }

  Future<void> supprimerTraitement(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('traitements').child(key).remove();
      // Supprimer aussi du stockage local
      _deleteTraitementFromStorage(key);
    } else {
      _deleteTraitementFromStorage(key);
    }
  }

  Stream<List<Traitement>> getTraitementsStream() {
    if (_farmRef != null) {
      return _farmRef!.child('traitements').onValue.map((event) {
        if (event.snapshot.value == null) return <Traitement>[];
        try {
          // Normalisation robuste via JSON round-trip
          final root = normalizeLoose(event.snapshot.value);
          print('FirebaseService V4: Received ${root.length} traitements from Firebase');
          print('FirebaseService V4: Traitements keys: ${root.keys.toList()}');
          
          return root.entries.map((e) {
            try {
              final map = normalizeLoose(e.value);
              final traitement = Traitement.fromMap(map);
              // Assigner la clé Firebase comme firebaseId
              return traitement.copyWith(firebaseId: e.key);
            } catch (error) {
              print('Error parsing traitement ${e.key}: $error');
              return null;
            }
          }).where((t) => t != null).cast<Traitement>().toList();
        } catch (error) {
          print('Error parsing traitements: $error');
          return <Traitement>[];
        }
      });
    } else {
      return Stream.value(_getTraitementsFromStorage());
    }
  }

  // ===== MÉTHODES POUR LES PRODUITS =====
  
  Future<String> ajouterProduit(Produit produit) async {
    if (_farmRef != null) {
      final ref = _farmRef!.child('produits').push();
      await ref.set(produit.toMap());
      return ref.key!;
    } else {
      final key = 'p_${DateTime.now().millisecondsSinceEpoch}';
      _saveProduitToStorage(produit.copyWith(firebaseId: key));
      return key;
    }
  }

  Future<void> modifierProduit(Produit produit) async {
    final key = produit.firebaseId ?? produit.id.toString();
    if (_farmRef != null) {
      await _farmRef!.child('produits').child(key).set(produit.toMap());
    } else {
      _saveProduitToStorage(produit);
    }
  }

  Future<void> supprimerProduit(String key) async {
    if (_farmRef != null) {
      await _farmRef!.child('produits').child(key).remove();
    } else {
      _deleteProduitFromStorage(key);
    }
  }

  Stream<List<Produit>> getProduitsStream() {
    if (_farmRef != null) {
      return _farmRef!.child('produits').onValue.map((event) {
        if (event.snapshot.value == null) return <Produit>[];
        try {
          // Normalisation robuste via JSON round-trip
          final root = normalizeLoose(event.snapshot.value);
          
          return root.entries.map((e) {
            try {
              final map = normalizeLoose(e.value);
              final produit = Produit.fromMap(map);
              // Assigner la clé Firebase comme firebaseId
              return produit.copyWith(firebaseId: e.key);
            } catch (error) {
              print('Error parsing produit ${e.key}: $error');
              return null;
            }
          }).where((p) => p != null).cast<Produit>().toList();
        } catch (error) {
          print('Error parsing produits: $error');
          return <Produit>[];
        }
      });
    } else {
      return Stream.value(_getProduitsFromStorage());
    }
  }

  // ===== MÉTHODES DE STOCKAGE LOCAL =====
  
  List<Traitement> _getTraitementsFromStorage() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final traitementsData = data['traitements'] as Map<String, dynamic>? ?? {};
        return traitementsData.values.map((t) => Traitement.fromMap(t)).toList();
      }
    } catch (e) {
      print('Error loading traitements from storage: $e');
    }
    return [];
  }
  
  void _saveTraitementToStorage(Traitement traitement) {
    try {
      final stored = html.window.localStorage[_storageKey];
      final data = stored != null ? jsonDecode(stored) : <String, dynamic>{};
      data['traitements'] ??= <String, dynamic>{};
      data['traitements'][traitement.firebaseId!] = traitement.toMap();
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('Error saving traitement to storage: $e');
    }
  }
  
  void _deleteTraitementFromStorage(String key) {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        data['traitements']?.remove(key);
        html.window.localStorage[_storageKey] = jsonEncode(data);
      }
    } catch (e) {
      print('Error deleting traitement from storage: $e');
    }
  }
  
  List<Produit> _getProduitsFromStorage() {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        final produitsData = data['produits'] as Map<String, dynamic>? ?? {};
        return produitsData.values.map((p) => Produit.fromMap(p)).toList();
      }
    } catch (e) {
      print('Error loading produits from storage: $e');
    }
    return [];
  }
  
  void _saveProduitToStorage(Produit produit) {
    try {
      final stored = html.window.localStorage[_storageKey];
      final data = stored != null ? jsonDecode(stored) : <String, dynamic>{};
      data['produits'] ??= <String, dynamic>{};
      data['produits'][produit.firebaseId!] = produit.toMap();
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('Error saving produit to storage: $e');
    }
  }
  
  void _deleteProduitFromStorage(String key) {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        final data = jsonDecode(stored);
        data['produits']?.remove(key);
        html.window.localStorage[_storageKey] = jsonEncode(data);
      }
    } catch (e) {
      print('Error deleting produit from storage: $e');
    }
  }

  // Nettoyer les listeners
  Future<void> disposeListeners() async {
    try {
      print('FirebaseService V4: Disposing listeners...');
      
      // Pour l'instant, on ne fait que logger
      // Les listeners seront automatiquement nettoyés lors de la déconnexion
      
      print('✅ FirebaseService V4: Listeners disposed successfully');
    } catch (e) {
      print('❌ FirebaseService V4: Error disposing listeners: $e');
    }
  }

  // Vider le cache localStorage
  Future<void> clearLocalStorage() async {
    try {
      if (kIsWeb) {
        html.window.localStorage.remove(_storageKey);
        print('✅ FirebaseService V4: LocalStorage cleared');
      }
    } catch (e) {
      print('❌ FirebaseService V4: Error clearing localStorage: $e');
    }
  }

  // Forcer le refresh des données en réinitialisant les références
  Future<void> forceRefresh() async {
    try {
      print('🔄 FirebaseService V4: Forcing refresh...');
      
      // Réinitialiser l'état
      _isInitialized = false;
      _isGloballyInitialized = false;
      
      // Vider le cache localStorage
      await clearLocalStorage();
      
      // Réinitialiser les références
      _farmRef = null;
      _farmId = null;
      
      // Réinitialiser complètement
      await initialize();
      
      print('✅ FirebaseService V4: Refresh completed');
    } catch (e) {
      print('❌ FirebaseService V4: Error during refresh: $e');
      rethrow;
    }
  }

  // Diagnostic: obtenir des informations sur l'état actuel
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    try {
      final user = _auth.currentUser;
      final database = await FirebaseDatabase.instance;
      
      // Trouver la ferme de l'utilisateur en cherchant dans farms/{farmId}/allowedUsers/{uid}
      String? userFarmId;
      if (user != null) {
        final farmsSnapshot = await database.ref('farms').get();
        if (farmsSnapshot.exists && farmsSnapshot.value != null) {
          final farms = farmsSnapshot.value as Map;
          for (final entry in farms.entries) {
            final farmId = entry.key as String;
            final farmData = entry.value as Map?;
            if (farmData != null) {
              final allowedUsers = farmData['allowedUsers'] as Map?;
              if (allowedUsers != null && allowedUsers.containsKey(user.uid)) {
                userFarmId = farmId;
                break;
              }
            }
          }
        }
      }
      
      // Vérifier si la ferme existe dans farms/{farmId}
      bool farmExists = false;
      int? dataCount = 0;
      if (userFarmId != null) {
        final farmSnapshot = await database.ref('farms/$userFarmId').get();
        farmExists = farmSnapshot.exists;
        if (farmExists && farmSnapshot.value != null) {
          final farmData = farmSnapshot.value as Map?;
          if (farmData != null) {
            dataCount = farmData.length;
          }
        }
      }
      
      // Vérifier le localStorage
      String? localStorageData;
      if (kIsWeb) {
        localStorageData = html.window.localStorage[_storageKey];
      }
      
      return {
        'user': user?.uid ?? 'null',
        'userEmail': user?.email ?? 'null',
        'farmId': _farmId ?? 'null',
        'userFarmId': userFarmId ?? 'null',
        'farmExists': farmExists,
        'farmDataCount': dataCount,
        'isInitialized': _isInitialized,
        'hasLocalStorage': localStorageData != null,
        'localStorageSize': localStorageData?.length ?? 0,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
