import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../utils/poids_utils.dart';

class OptimizedWebDatabase {
  static const String _dbName = 'mais_tracker_optimized';
  static const int _dbVersion = 1;
  
  html.IdbFactory? _idbFactory;
  html.IdbDatabase? _database;
  final StreamController<Map<String, dynamic>> _changeController = StreamController.broadcast();
  
  // Cache en mémoire pour les performances
  final Map<String, List<dynamic>> _cache = {};
  bool _isInitialized = false;

  // Stream pour les changements en temps réel
  Stream<Map<String, dynamic>> get changes => _changeController.stream;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _idbFactory = html.window.indexedDB;
      _database = await _idbFactory!.open(
        _dbName,
        version: _dbVersion,
        onUpgradeNeeded: _onUpgrade,
      );
      
      await _loadCache();
      _isInitialized = true;
      print('✅ OptimizedWebDatabase initialized');
    } catch (e) {
      print('❌ Error initializing database: $e');
      // Fallback vers localStorage si IndexedDB échoue
      await _initLocalStorageFallback();
    }
  }

  Future<void> _initLocalStorageFallback() async {
    print('🔄 Using localStorage fallback');
    _isInitialized = true;
  }

  Future<void> _onUpgrade(html.IdbVersionChangeEvent e) async {
    final db = e.target as html.IdbDatabase;
    
    // Créer les stores (tables)
    if (!db.objectStoreNames.contains('parcelles')) {
      db.createObjectStore('parcelles', keyPath: 'id', autoIncrement: true);
    }
    if (!db.objectStoreNames.contains('cellules')) {
      db.createObjectStore('cellules', keyPath: 'id', autoIncrement: true);
    }
    if (!db.objectStoreNames.contains('chargements')) {
      db.createObjectStore('chargements', keyPath: 'id', autoIncrement: true);
    }
    if (!db.objectStoreNames.contains('semis')) {
      db.createObjectStore('semis', keyPath: 'id', autoIncrement: true);
    }
    if (!db.objectStoreNames.contains('varietes')) {
      db.createObjectStore('varietes', keyPath: 'id', autoIncrement: true);
    }
    
    print('✅ Database stores created');
  }

  Future<void> _loadCache() async {
    if (_database == null) return;
    
    try {
      _cache['parcelles'] = await _getAllFromStore('parcelles');
      _cache['cellules'] = await _getAllFromStore('cellules');
      _cache['chargements'] = await _getAllFromStore('chargements');
      _cache['semis'] = await _getAllFromStore('semis');
      _cache['varietes'] = await _getAllFromStore('varietes');
      
      print('✅ Cache loaded: ${_cache.values.map((v) => v.length).join(', ')} items');
    } catch (e) {
      print('❌ Error loading cache: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getAllFromStore(String storeName) async {
    if (_database == null) return [];
    
    try {
      final transaction = _database!.transaction([storeName], 'readonly');
      final store = transaction.objectStore(storeName);
      final request = store.getAll();
      final result = await request.future;
      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error reading from $storeName: $e');
      return [];
    }
  }

  Future<void> _saveToStore(String storeName, Map<String, dynamic> data) async {
    if (_database == null) {
      // Fallback vers localStorage
      await _saveToLocalStorage(storeName, data);
      return;
    }
    
    try {
      final transaction = _database!.transaction([storeName], 'readwrite');
      final store = transaction.objectStore(storeName);
      await store.put(data).future;
    } catch (e) {
      print('❌ Error saving to $storeName: $e');
      await _saveToLocalStorage(storeName, data);
    }
  }

  Future<void> _deleteFromStore(String storeName, dynamic id) async {
    if (_database == null) {
      await _deleteFromLocalStorage(storeName, id);
      return;
    }
    
    try {
      final transaction = _database!.transaction([storeName], 'readwrite');
      final store = transaction.objectStore(storeName);
      await store.delete(id).future;
    } catch (e) {
      print('❌ Error deleting from $storeName: $e');
      await _deleteFromLocalStorage(storeName, id);
    }
  }

  // Fallback localStorage methods
  Future<void> _saveToLocalStorage(String storeName, Map<String, dynamic> data) async {
    final key = 'mais_tracker_$storeName';
    final existing = _cache[storeName] ?? [];
    final index = existing.indexWhere((item) => item['id'] == data['id']);
    
    if (index != -1) {
      existing[index] = data;
    } else {
      existing.add(data);
    }
    
    _cache[storeName] = existing;
    html.window.localStorage[key] = jsonEncode(existing);
  }

  Future<void> _deleteFromLocalStorage(String storeName, dynamic id) async {
    final key = 'mais_tracker_$storeName';
    final existing = _cache[storeName] ?? [];
    existing.removeWhere((item) => item['id'] == id);
    
    _cache[storeName] = existing;
    html.window.localStorage[key] = jsonEncode(existing);
  }

  // Méthodes publiques avec cache et temps réel
  Future<List<Parcelle>> getParcelles() async {
    await _ensureInitialized();
    final data = _cache['parcelles'] ?? [];
    return data.map((map) => Parcelle.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertParcelle(Parcelle parcelle) async {
    await _ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch;
    parcelle.id = id;
    
    final data = parcelle.toMap();
    await _saveToStore('parcelles', data);
    
    // Mettre à jour le cache
    _cache['parcelles'] = _cache['parcelles'] ?? [];
    _cache['parcelles'].add(data);
    
    // Notifier le changement
    _changeController.add({'type': 'parcelle_added', 'data': data});
    
    return id;
  }

  Future<void> updateParcelle(Parcelle parcelle) async {
    await _ensureInitialized();
    final data = parcelle.toMap();
    await _saveToStore('parcelles', data);
    
    // Mettre à jour le cache
    final index = (_cache['parcelles'] ?? []).indexWhere((p) => p['id'] == parcelle.id);
    if (index != -1) {
      _cache['parcelles'][index] = data;
    }
    
    // Notifier le changement
    _changeController.add({'type': 'parcelle_updated', 'data': data});
  }

  Future<void> deleteParcelle(int id) async {
    await _ensureInitialized();
    await _deleteFromStore('parcelles', id);
    
    // Mettre à jour le cache
    _cache['parcelles'] = (_cache['parcelles'] ?? []).where((p) => p['id'] != id).toList();
    
    // Notifier le changement
    _changeController.add({'type': 'parcelle_deleted', 'id': id});
  }

  // Méthodes pour les cellules
  Future<List<Cellule>> getCellules() async {
    await _ensureInitialized();
    final data = _cache['cellules'] ?? [];
    return data.map((map) => Cellule.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertCellule(Cellule cellule) async {
    await _ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch;
    cellule.id = id;
    
    final data = cellule.toMap();
    await _saveToStore('cellules', data);
    
    _cache['cellules'] = _cache['cellules'] ?? [];
    _cache['cellules'].add(data);
    
    _changeController.add({'type': 'cellule_added', 'data': data});
    return id;
  }

  Future<void> updateCellule(Cellule cellule) async {
    await _ensureInitialized();
    final data = cellule.toMap();
    await _saveToStore('cellules', data);
    
    final index = (_cache['cellules'] ?? []).indexWhere((c) => c['id'] == cellule.id);
    if (index != -1) {
      _cache['cellules'][index] = data;
    }
    
    _changeController.add({'type': 'cellule_updated', 'data': data});
  }

  Future<void> deleteCellule(int id) async {
    await _ensureInitialized();
    await _deleteFromStore('cellules', id);
    
    _cache['cellules'] = (_cache['cellules'] ?? []).where((c) => c['id'] != id).toList();
    
    _changeController.add({'type': 'cellule_deleted', 'id': id});
  }

  // Méthodes pour les chargements
  Future<List<Chargement>> getChargements() async {
    await _ensureInitialized();
    final data = _cache['chargements'] ?? [];
    return data.map((map) => Chargement.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertChargement(Chargement chargement) async {
    await _ensureInitialized();
    
    // Validation
    if (chargement.poidsPlein <= chargement.poidsVide) {
      throw Exception('Le poids plein doit être supérieur au poids vide');
    }
    if (chargement.humidite < 0 || chargement.humidite > 100) {
      throw Exception('L\'humidité doit être comprise entre 0 et 100%');
    }
    
    final id = DateTime.now().millisecondsSinceEpoch;
    chargement.id = id;
    
    final data = chargement.toMap();
    await _saveToStore('chargements', data);
    
    _cache['chargements'] = _cache['chargements'] ?? [];
    _cache['chargements'].add(data);
    
    _changeController.add({'type': 'chargement_added', 'data': data});
    return id;
  }

  Future<void> updateChargement(Chargement chargement) async {
    await _ensureInitialized();
    
    if (chargement.poidsPlein <= chargement.poidsVide) {
      throw Exception('Le poids plein doit être supérieur au poids vide');
    }
    if (chargement.humidite < 0 || chargement.humidite > 100) {
      throw Exception('L\'humidité doit être comprise entre 0 et 100%');
    }
    
    final data = chargement.toMap();
    await _saveToStore('chargements', data);
    
    final index = (_cache['chargements'] ?? []).indexWhere((c) => c['id'] == chargement.id);
    if (index != -1) {
      _cache['chargements'][index] = data;
    }
    
    _changeController.add({'type': 'chargement_updated', 'data': data});
  }

  Future<void> deleteChargement(int id) async {
    await _ensureInitialized();
    await _deleteFromStore('chargements', id);
    
    _cache['chargements'] = (_cache['chargements'] ?? []).where((c) => c['id'] != id).toList();
    
    _changeController.add({'type': 'chargement_deleted', 'id': id});
  }

  Future<void> updateAllChargementsPoidsNormes() async {
    await _ensureInitialized();
    final chargements = _cache['chargements'] ?? [];
    
    for (var chargement in chargements) {
      final double poidsPlein = double.tryParse(chargement['poids_plein'].toString()) ?? 0.0;
      final double poidsVide = double.tryParse(chargement['poids_vide'].toString()) ?? 0.0;
      final double humidite = double.tryParse(chargement['humidite'].toString()) ?? 0.0;
      
      final double poidsNet = PoidsUtils.calculPoidsNet(poidsPlein, poidsVide);
      final double poidsNormes = PoidsUtils.calculPoidsNormes(poidsNet, humidite);
      
      chargement['poids_net'] = poidsNet;
      chargement['poids_normes'] = poidsNormes;
      
      await _saveToStore('chargements', chargement);
    }
    
    _changeController.add({'type': 'chargements_updated'});
  }

  // Méthodes pour les semis
  Future<List<Semis>> getSemis() async {
    await _ensureInitialized();
    final data = _cache['semis'] ?? [];
    return data.map((map) => Semis.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertSemis(Semis semis) async {
    await _ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch;
    semis.id = id;
    
    final data = semis.toMap();
    await _saveToStore('semis', data);
    
    _cache['semis'] = _cache['semis'] ?? [];
    _cache['semis'].add(data);
    
    _changeController.add({'type': 'semis_added', 'data': data});
    return id;
  }

  Future<void> updateSemis(Semis semis) async {
    await _ensureInitialized();
    final data = semis.toMap();
    await _saveToStore('semis', data);
    
    final index = (_cache['semis'] ?? []).indexWhere((s) => s['id'] == semis.id);
    if (index != -1) {
      _cache['semis'][index] = data;
    }
    
    _changeController.add({'type': 'semis_updated', 'data': data});
  }

  Future<void> deleteSemis(int id) async {
    await _ensureInitialized();
    await _deleteFromStore('semis', id);
    
    _cache['semis'] = (_cache['semis'] ?? []).where((s) => s['id'] != id).toList();
    
    _changeController.add({'type': 'semis_deleted', 'id': id});
  }

  // Méthodes pour les variétés
  Future<List<Variete>> getVarietes() async {
    await _ensureInitialized();
    final data = _cache['varietes'] ?? [];
    return data.map((map) => Variete.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertVariete(Variete variete) async {
    await _ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch;
    variete.id = id;
    
    final data = variete.toMap();
    await _saveToStore('varietes', data);
    
    _cache['varietes'] = _cache['varietes'] ?? [];
    _cache['varietes'].add(data);
    
    _changeController.add({'type': 'variete_added', 'data': data});
    return id;
  }

  Future<void> updateVariete(Variete variete) async {
    await _ensureInitialized();
    final data = variete.toMap();
    await _saveToStore('varietes', data);
    
    final index = (_cache['varietes'] ?? []).indexWhere((v) => v['id'] == variete.id);
    if (index != -1) {
      _cache['varietes'][index] = data;
    }
    
    _changeController.add({'type': 'variete_updated', 'data': data});
  }

  Future<void> deleteVariete(int id) async {
    await _ensureInitialized();
    await _deleteFromStore('varietes', id);
    
    _cache['varietes'] = (_cache['varietes'] ?? []).where((v) => v['id'] != id).toList();
    
    _changeController.add({'type': 'variete_deleted', 'id': id});
  }

  // Méthodes utilitaires
  Future<void> deleteAllData() async {
    await _ensureInitialized();
    
    for (String storeName in ['parcelles', 'cellules', 'chargements', 'semis', 'varietes']) {
      if (_database != null) {
        final transaction = _database!.transaction([storeName], 'readwrite');
        final store = transaction.objectStore(storeName);
        await store.clear().future;
      } else {
        html.window.localStorage.remove('mais_tracker_$storeName');
      }
      _cache[storeName] = [];
    }
    
    _changeController.add({'type': 'all_data_deleted'});
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    for (String storeName in ['parcelles', 'cellules', 'chargements', 'semis', 'varietes']) {
      final items = data[storeName] ?? [];
      _cache[storeName] = List<Map<String, dynamic>>.from(items);
      
      if (_database != null) {
        final transaction = _database!.transaction([storeName], 'readwrite');
        final store = transaction.objectStore(storeName);
        await store.clear().future;
        
        for (var item in items) {
          await store.put(item).future;
        }
      } else {
        html.window.localStorage['mais_tracker_$storeName'] = jsonEncode(items);
      }
    }
    
    _changeController.add({'type': 'data_imported'});
  }

  Future<Map<String, dynamic>> exportData() async {
    await _ensureInitialized();
    return Map<String, dynamic>.from(_cache);
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  void dispose() {
    _changeController.close();
    _database?.close();
  }
}
