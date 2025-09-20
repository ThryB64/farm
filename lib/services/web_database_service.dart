import 'dart:convert';
import 'dart:html' as html;
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../utils/poids_utils.dart';

class WebDatabaseService {
  static const String _storageKey = 'mais_tracker_data';
  
  Map<String, dynamic> _data = {
    'parcelles': [],
    'cellules': [],
    'chargements': [],
    'semis': [],
    'varietes': [],
  };

  Future<void> _loadData() async {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
        _data = jsonDecode(stored);
      }
    } catch (e) {
      print('Error loading data from localStorage: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      html.window.localStorage[_storageKey] = jsonEncode(_data);
    } catch (e) {
      print('Error saving data to localStorage: $e');
    }
  }

  // Méthodes pour les parcelles
  Future<List<Parcelle>> getParcelles() async {
    await _loadData();
    final List<dynamic> maps = _data['parcelles'] ?? [];
    return maps.map((map) => Parcelle.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertParcelle(Parcelle parcelle) async {
    await _loadData();
    final id = DateTime.now().millisecondsSinceEpoch;
    parcelle.id = id;
    _data['parcelles'].add(parcelle.toMap());
    await _saveData();
    return id;
  }

  Future<void> updateParcelle(Parcelle parcelle) async {
    await _loadData();
    final index = _data['parcelles'].indexWhere((p) => p['id'] == parcelle.id);
    if (index != -1) {
      _data['parcelles'][index] = parcelle.toMap();
      await _saveData();
    }
  }

  Future<void> deleteParcelle(int id) async {
    await _loadData();
    _data['parcelles'].removeWhere((p) => p['id'] == id);
    await _saveData();
  }

  // Méthodes pour les cellules
  Future<List<Cellule>> getCellules() async {
    await _loadData();
    final List<dynamic> maps = _data['cellules'] ?? [];
    return maps.map((map) => Cellule.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertCellule(Cellule cellule) async {
    await _loadData();
    final id = DateTime.now().millisecondsSinceEpoch;
    cellule.id = id;
    _data['cellules'].add(cellule.toMap());
    await _saveData();
    return id;
  }

  Future<void> updateCellule(Cellule cellule) async {
    await _loadData();
    final index = _data['cellules'].indexWhere((c) => c['id'] == cellule.id);
    if (index != -1) {
      _data['cellules'][index] = cellule.toMap();
      await _saveData();
    }
  }

  Future<void> deleteCellule(int id) async {
    await _loadData();
    _data['cellules'].removeWhere((c) => c['id'] == id);
    await _saveData();
  }

  // Méthodes pour les chargements
  Future<List<Chargement>> getChargements() async {
    await _loadData();
    final List<dynamic> maps = _data['chargements'] ?? [];
    return maps.map((map) => Chargement.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertChargement(Chargement chargement) async {
    await _loadData();
    
    // Vérifier que la cellule existe
    final celluleExists = _data['cellules'].any((c) => c['id'] == chargement.celluleId);
    if (!celluleExists) {
      throw Exception('La cellule n\'existe pas');
    }

    // Vérifier que la parcelle existe
    final parcelleExists = _data['parcelles'].any((p) => p['id'] == chargement.parcelleId);
    if (!parcelleExists) {
      throw Exception('La parcelle n\'existe pas');
    }

    // Vérifier que le poids plein est supérieur au poids vide
    if (chargement.poidsPlein <= chargement.poidsVide) {
      throw Exception('Le poids plein doit être supérieur au poids vide');
    }

    // Vérifier que l'humidité est valide
    if (chargement.humidite < 0 || chargement.humidite > 100) {
      throw Exception('L\'humidité doit être comprise entre 0 et 100%');
    }

    final id = DateTime.now().millisecondsSinceEpoch;
    chargement.id = id;
    _data['chargements'].add(chargement.toMap());
    await _saveData();
    return id;
  }

  Future<void> updateChargement(Chargement chargement) async {
    await _loadData();
    
    // Vérifier que le chargement existe
    final index = _data['chargements'].indexWhere((c) => c['id'] == chargement.id);
    if (index == -1) {
      throw Exception('Le chargement n\'existe pas');
    }

    // Vérifier que la cellule existe
    final celluleExists = _data['cellules'].any((c) => c['id'] == chargement.celluleId);
    if (!celluleExists) {
      throw Exception('La cellule n\'existe pas');
    }

    // Vérifier que la parcelle existe
    final parcelleExists = _data['parcelles'].any((p) => p['id'] == chargement.parcelleId);
    if (!parcelleExists) {
      throw Exception('La parcelle n\'existe pas');
    }

    // Vérifier que le poids plein est supérieur au poids vide
    if (chargement.poidsPlein <= chargement.poidsVide) {
      throw Exception('Le poids plein doit être supérieur au poids vide');
    }

    // Vérifier que l'humidité est valide
    if (chargement.humidite < 0 || chargement.humidite > 100) {
      throw Exception('L\'humidité doit être comprise entre 0 et 100%');
    }

    _data['chargements'][index] = chargement.toMap();
    await _saveData();
  }

  Future<void> deleteChargement(int id) async {
    await _loadData();
    _data['chargements'].removeWhere((c) => c['id'] == id);
    await _saveData();
  }

  Future<void> updateAllChargementsPoidsNormes() async {
    await _loadData();
    final List<dynamic> chargements = _data['chargements'] ?? [];
    
    for (var chargement in chargements) {
      final double poidsPlein = double.tryParse(chargement['poids_plein'].toString()) ?? 0.0;
      final double poidsVide = double.tryParse(chargement['poids_vide'].toString()) ?? 0.0;
      final double humidite = double.tryParse(chargement['humidite'].toString()) ?? 0.0;
      
      final double poidsNet = PoidsUtils.calculPoidsNet(poidsPlein, poidsVide);
      final double poidsNormes = PoidsUtils.calculPoidsNormes(poidsNet, humidite);
      
      chargement['poids_net'] = poidsNet;
      chargement['poids_normes'] = poidsNormes;
    }
    
    await _saveData();
  }

  // Méthodes pour les semis
  Future<List<Semis>> getSemis() async {
    await _loadData();
    final List<dynamic> maps = _data['semis'] ?? [];
    return maps.map((map) => Semis.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertSemis(Semis semis) async {
    await _loadData();
    final id = DateTime.now().millisecondsSinceEpoch;
    semis.id = id;
    _data['semis'].add(semis.toMap());
    await _saveData();
    return id;
  }

  Future<void> updateSemis(Semis semis) async {
    await _loadData();
    final index = _data['semis'].indexWhere((s) => s['id'] == semis.id);
    if (index != -1) {
      _data['semis'][index] = semis.toMap();
      await _saveData();
    }
  }

  Future<void> deleteSemis(int id) async {
    await _loadData();
    _data['semis'].removeWhere((s) => s['id'] == id);
    await _saveData();
  }

  // Méthodes pour les variétés
  Future<List<Variete>> getVarietes() async {
    await _loadData();
    final List<dynamic> maps = _data['varietes'] ?? [];
    return maps.map((map) => Variete.fromMap(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertVariete(Variete variete) async {
    await _loadData();
    final id = DateTime.now().millisecondsSinceEpoch;
    variete.id = id;
    _data['varietes'].add(variete.toMap());
    await _saveData();
    return id;
  }

  Future<void> updateVariete(Variete variete) async {
    await _loadData();
    final index = _data['varietes'].indexWhere((v) => v['id'] == variete.id);
    if (index != -1) {
      _data['varietes'][index] = variete.toMap();
      await _saveData();
    }
  }

  Future<void> deleteVariete(int id) async {
    await _loadData();
    _data['varietes'].removeWhere((v) => v['id'] == id);
    await _saveData();
  }

  Future<void> deleteAllData() async {
    _data = {
      'parcelles': [],
      'cellules': [],
      'chargements': [],
      'semis': [],
      'varietes': [],
    };
    await _saveData();
  }

  Future<void> importData(Map<String, dynamic> data) async {
    _data = {
      'parcelles': data['parcelles'] ?? [],
      'cellules': data['cellules'] ?? [],
      'chargements': data['chargements'] ?? [],
      'semis': data['semis'] ?? [],
      'varietes': data['varietes'] ?? [],
    };
    await _saveData();
  }
}
