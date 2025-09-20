import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../utils/poids_utils.dart';

class SimpleRealtimeDatabase {
  static const String _storageKey = 'mais_tracker_realtime';
  
  // Cache en mémoire pour les performances
  final Map<String, List<Map<String, dynamic>>> _cache = {
    'parcelles': [],
    'cellules': [],
    'chargements': [],
    'semis': [],
    'varietes': [],
  };
  
  // Stream pour les changements en temps réel
  final StreamController<Map<String, dynamic>> _changeController = StreamController.broadcast();
  bool _isInitialized = false;

  Stream<Map<String, dynamic>> get changes => _changeController.stream;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await _loadFromStorage();
      _isInitialized = true;
      print('✅ SimpleRealtimeDatabase initialized');
    } catch (e) {
      print('❌ Error initializing database: $e');
      _isInitialized = true; // Continue même en cas d'erreur
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null && stored.isNotEmpty) {
        final data = jsonDecode(stored) as Map<String, dynamic>;
        
        for (String key in _cache.keys) {
          if (data.containsKey(key)) {
            _cache[key] = List<Map<String, dynamic>>.from(data[key]);
          }
        }
        
        print('✅ Data loaded from storage: ${_cache.values.map((v) => v.length).join(', ')} items');
      }
    } catch (e) {
      print('❌ Error loading from storage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final data = Map<String, dynamic>.from(_cache);
      html.window.localStorage[_storageKey] = jsonEncode(data);
    } catch (e) {
      print('❌ Error saving to storage: $e');
    }
  }

  void _notifyChange(String type, {Map<String, dynamic>? data, dynamic id}) {
    _changeController.add({
      'type': type,
      'data': data,
      'id': id,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Méthodes pour les parcelles
  Future<List<Parcelle>> getParcelles() async {
    await _ensureInitialized();
    return _cache['parcelles']!.map((map) => Parcelle.fromMap(map)).toList();
  }

  Future<int> insertParcelle(Parcelle parcelle) async {
    await _ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch;
    parcelle.id = id;
    
    final data = parcelle.toMap();
    _cache['parcelles']!.add(data);
    await _saveToStorage();
    
    _notifyChange('parcelle_added', data: data);
    return id;
  }

  Future<void> updateParcelle(Parcelle parcelle) async {
    await _ensureInitialized();
    final data = parcelle.toMap();
    final index = _cache['parcelles']!.indexWhere((p) => p['id'] == parcelle.id);
    
    if (index != -1) {
      _cache['parcelles']![index] = data;
      await _saveToStorage();
      _notifyChange('parcelle_updated', data: data);
    }
  }

  Future<void> deleteParcelle(int id) async {
    await _ensureInitialized();
    _cache['parcelles']!.removeWhere((p) => p['id'] == id);
    await _saveToStorage();
    _notifyChange('parcelle_deleted', id: id);
  }

  // Méthodes pour les cellules
  Future<List<Cellule>> getCellules() async {
    await _ensureInitialized();
    return _cache['cellules']!.map((map) => Cellule.fromMap(map)).toList();
  }

  Future<int> insertCellule(Cellule cellule) async {
    await _ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch;
    cellule.id = id;
    
    final data = cellule.toMap();
    _cache['cellules']!.add(data);
    await _saveToStorage();
    
    _notifyChange('cellule_added', data: data);
    return id;
  }

  Future<void> updateCellule(Cellule cellule) async {
    await _ensureInitialized();
    final data = cellule.toMap();
    final index = _cache['cellules']!.indexWhere((c) => c['id'] == cellule.id);
    
    if (index != -1) {
      _cache['cellules']![index] = data;
      await _saveToStorage();
      _notifyChange('cellule_updated', data: data);
    }
  }

  Future<void> deleteCellule(int id) async {
    await _ensureInitialized();
    _cache['cellules']!.removeWhere((c) => c['id'] == id);
    await _saveToStorage();
    _notifyChange('cellule_deleted', id: id);
  }

  // Méthodes pour les chargements
  Future<List<Chargement>> getChargements() async {
    await _ensureInitialized();
    return _cache['chargements']!.map((map) => Chargement.fromMap(map)).toList();
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
    _cache['chargements']!.add(data);
    await _saveToStorage();
    
    _notifyChange('chargement_added', data: data);
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
    final index = _cache['chargements']!.indexWhere((c) => c['id'] == chargement.id);
    
    if (index != -1) {
      _cache['chargements']![index] = data;
      await _saveToStorage();
      _notifyChange('chargement_updated', data: data);
    }
  }

  Future<void> deleteChargement(int id) async {
    await _ensureInitialized();
    _cache['chargements']!.removeWhere((c) => c['id'] == id);
    await _saveToStorage();
    _notifyChange('chargement_deleted', id: id);
  }

  Future<void> updateAllChargementsPoidsNormes() async {
    await _ensureInitialized();
    final chargements = _cache['chargements']!;
    
    for (var chargement in chargements) {
      final double poidsPlein = double.tryParse(chargement['poids_plein'].toString()) ?? 0.0;
      final double poidsVide = double.tryParse(chargement['poids_vide'].toString()) ?? 0.0;
      final double humidite = double.tryParse(chargement['humidite'].toString()) ?? 0.0;
      
      final double poidsNet = PoidsUtils.calculPoidsNet(poidsPlein, poidsVide);
      final double poidsNormes = PoidsUtils.calculPoidsNormes(poidsNet, humidite);
      
      chargement['poids_net'] = poidsNet;
      chargement['poids_normes'] = poidsNormes;
    }
    
    await _saveToStorage();
    _notifyChange('chargements_updated');
  }

  // Méthodes pour les semis
  Future<List<Semis>> getSemis() async {
    await _ensureInitialized();
    return _cache['semis']!.map((map) => Semis.fromMap(map)).toList();
  }

  Future<int> insertSemis(Semis semis) async {
    await _ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch;
    semis.id = id;
    
    final data = semis.toMap();
    _cache['semis']!.add(data);
    await _saveToStorage();
    
    _notifyChange('semis_added', data: data);
    return id;
  }

  Future<void> updateSemis(Semis semis) async {
    await _ensureInitialized();
    final data = semis.toMap();
    final index = _cache['semis']!.indexWhere((s) => s['id'] == semis.id);
    
    if (index != -1) {
      _cache['semis']![index] = data;
      await _saveToStorage();
      _notifyChange('semis_updated', data: data);
    }
  }

  Future<void> deleteSemis(int id) async {
    await _ensureInitialized();
    _cache['semis']!.removeWhere((s) => s['id'] == id);
    await _saveToStorage();
    _notifyChange('semis_deleted', id: id);
  }

  // Méthodes pour les variétés
  Future<List<Variete>> getVarietes() async {
    await _ensureInitialized();
    return _cache['varietes']!.map((map) => Variete.fromMap(map)).toList();
  }

  Future<int> insertVariete(Variete variete) async {
    await _ensureInitialized();
    final id = DateTime.now().millisecondsSinceEpoch;
    variete.id = id;
    
    final data = variete.toMap();
    _cache['varietes']!.add(data);
    await _saveToStorage();
    
    _notifyChange('variete_added', data: data);
    return id;
  }

  Future<void> updateVariete(Variete variete) async {
    await _ensureInitialized();
    final data = variete.toMap();
    final index = _cache['varietes']!.indexWhere((v) => v['id'] == variete.id);
    
    if (index != -1) {
      _cache['varietes']![index] = data;
      await _saveToStorage();
      _notifyChange('variete_updated', data: data);
    }
  }

  Future<void> deleteVariete(int id) async {
    await _ensureInitialized();
    _cache['varietes']!.removeWhere((v) => v['id'] == id);
    await _saveToStorage();
    _notifyChange('variete_deleted', id: id);
  }

  // Méthodes utilitaires
  Future<void> deleteAllData() async {
    await _ensureInitialized();
    
    for (String key in _cache.keys) {
      _cache[key] = [];
    }
    
    await _saveToStorage();
    _notifyChange('all_data_deleted');
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await _ensureInitialized();
    
    for (String key in _cache.keys) {
      if (data.containsKey(key)) {
        _cache[key] = List<Map<String, dynamic>>.from(data[key]);
      }
    }
    
    await _saveToStorage();
    _notifyChange('data_imported');
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
  }
}
