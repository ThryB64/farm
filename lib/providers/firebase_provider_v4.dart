import 'package:flutter/material.dart';
import '../services/firebase_service_v4.dart';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';

class FirebaseProviderV4 extends ChangeNotifier {
  final FirebaseServiceV4 _service = FirebaseServiceV4();
  
  // Maps locales pour le cache
  final Map<String, Parcelle> _parcellesMap = {};
  final Map<String, Cellule> _cellulesMap = {};
  final Map<String, Chargement> _chargementsMap = {};
  final Map<String, Semis> _semisMap = {};
  final Map<String, Variete> _varietesMap = {};
  
  // Streams pour les données
  Stream<List<Parcelle>>? _parcellesStream;
  Stream<List<Cellule>>? _cellulesStream;
  Stream<List<Chargement>>? _chargementsStream;
  Stream<List<Semis>>? _semisStream;
  Stream<List<Variete>>? _varietesStream;
  
  // Getters pour l'accès aux données
  List<Parcelle> get parcelles => _parcellesMap.values.toList();
  List<Cellule> get cellules => _cellulesMap.values.toList();
  List<Chargement> get chargements => _chargementsMap.values.toList();
  List<Semis> get semis => _semisMap.values.toList();
  List<Variete> get varietes => _varietesMap.values.toList();
  
  // Maps pour les relations (optimisation des jointures)
  Map<int, Parcelle> get parcellesById => {
    for (final p in parcelles) if (p.id != null) p.id!: p
  };
  
  Map<int, Cellule> get cellulesById => {
    for (final c in cellules) if (c.id != null) c.id!: c
  };
  
  Map<int, Variete> get varietesById => {
    for (final v in varietes) if (v.id != null) v.id!: v
  };
  
  String? _error;
  String? get error => _error;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Initialiser le provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('FirebaseProvider V4: Initializing...');
      
      await _service.initialize();
      
      // Configurer les streams
      _parcellesStream = _service.getParcellesStream();
      _cellulesStream = _service.getCellulesStream();
      _chargementsStream = _service.getChargementsStream();
      _semisStream = _service.getSemisStream();
      _varietesStream = _service.getVarietesStream();
      
      // Écouter les changements
      _parcellesStream?.listen(_onParcellesChanged);
      _cellulesStream?.listen(_onCellulesChanged);
      _chargementsStream?.listen(_onChargementsChanged);
      _semisStream?.listen(_onSemisChanged);
      _varietesStream?.listen(_onVarietesChanged);
      
      _isInitialized = true;
      _error = null;
      print('✅ FirebaseProvider V4: Initialized successfully');
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur d\'initialisation: $e';
      print('❌ FirebaseProvider V4: Initialization failed: $e');
      notifyListeners();
    }
  }
  
  // Callbacks pour les changements de données
  void _onParcellesChanged(List<Parcelle> parcelles) {
    _parcellesMap.clear();
    for (final parcelle in parcelles) {
      if (parcelle.firebaseId != null) {
        _parcellesMap[parcelle.firebaseId!] = parcelle;
      }
    }
    print('FirebaseProvider V4: Updated ${parcelles.length} parcelles');
    notifyListeners();
  }
  
  void _onCellulesChanged(List<Cellule> cellules) {
    _cellulesMap.clear();
    for (final cellule in cellules) {
      if (cellule.firebaseId != null) {
        _cellulesMap[cellule.firebaseId!] = cellule;
      }
    }
    print('FirebaseProvider V4: Updated ${cellules.length} cellules');
    notifyListeners();
  }
  
  void _onChargementsChanged(List<Chargement> chargements) {
    _chargementsMap.clear();
    for (final chargement in chargements) {
      if (chargement.firebaseId != null) {
        _chargementsMap[chargement.firebaseId!] = chargement;
      }
    }
    print('FirebaseProvider V4: Updated ${chargements.length} chargements');
    notifyListeners();
  }
  
  void _onSemisChanged(List<Semis> semis) {
    _semisMap.clear();
    for (final semisItem in semis) {
      if (semisItem.firebaseId != null) {
        _semisMap[semisItem.firebaseId!] = semisItem;
      }
    }
    print('FirebaseProvider V4: Updated ${semis.length} semis');
    notifyListeners();
  }
  
  void _onVarietesChanged(List<Variete> varietes) {
    _varietesMap.clear();
    for (final variete in varietes) {
      if (variete.firebaseId != null) {
        _varietesMap[variete.firebaseId!] = variete;
      }
    }
    print('FirebaseProvider V4: Updated ${varietes.length} varietes');
    notifyListeners();
  }
  
  // ===== MÉTHODES POUR PARCELLES =====
  
  Future<String> ajouterParcelle(Parcelle parcelle) async {
    try {
      final key = await _service.insertParcelle(parcelle);
      print('FirebaseProvider V4: Parcelle added with key: $key');
      return key;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> modifierParcelle(Parcelle parcelle) async {
    try {
      await _service.updateParcelle(parcelle);
      print('FirebaseProvider V4: Parcelle updated');
    } catch (e) {
      _error = 'Erreur lors de la modification de la parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> supprimerParcelle(String key) async {
    try {
      await _service.deleteParcelle(key);
      print('FirebaseProvider V4: Parcelle deleted: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression de la parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // ===== MÉTHODES POUR CELLULES =====
  
  Future<String> ajouterCellule(Cellule cellule) async {
    try {
      final key = await _service.insertCellule(cellule);
      print('FirebaseProvider V4: Cellule added with key: $key');
      return key;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la cellule: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> modifierCellule(Cellule cellule) async {
    try {
      await _service.updateCellule(cellule);
      print('FirebaseProvider V4: Cellule updated');
    } catch (e) {
      _error = 'Erreur lors de la modification de la cellule: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> supprimerCellule(String key) async {
    try {
      await _service.deleteCellule(key);
      print('FirebaseProvider V4: Cellule deleted: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression de la cellule: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // ===== MÉTHODES POUR CHARGEMENTS =====
  
  Future<String> ajouterChargement(Chargement chargement) async {
    try {
      final key = await _service.insertChargement(chargement);
      print('FirebaseProvider V4: Chargement added with key: $key');
      return key;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du chargement: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> modifierChargement(Chargement chargement) async {
    try {
      await _service.updateChargement(chargement);
      print('FirebaseProvider V4: Chargement updated');
    } catch (e) {
      _error = 'Erreur lors de la modification du chargement: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> supprimerChargement(String key) async {
    try {
      await _service.deleteChargement(key);
      print('FirebaseProvider V4: Chargement deleted: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression du chargement: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // ===== MÉTHODES POUR SEMIS =====
  
  Future<String> ajouterSemis(Semis semis) async {
    try {
      final key = await _service.insertSemis(semis);
      print('FirebaseProvider V4: Semis added with key: $key');
      return key;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du semis: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> modifierSemis(Semis semis) async {
    try {
      await _service.updateSemis(semis);
      print('FirebaseProvider V4: Semis updated');
    } catch (e) {
      _error = 'Erreur lors de la modification du semis: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> supprimerSemis(String key) async {
    try {
      await _service.deleteSemis(key);
      print('FirebaseProvider V4: Semis deleted: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression du semis: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // ===== MÉTHODES POUR VARIÉTÉS =====
  
  Future<String> ajouterVariete(Variete variete) async {
    try {
      final key = await _service.insertVariete(variete);
      print('FirebaseProvider V4: Variete added with key: $key');
      return key;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la variété: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> modifierVariete(Variete variete) async {
    try {
      await _service.updateVariete(variete);
      print('FirebaseProvider V4: Variete updated');
    } catch (e) {
      _error = 'Erreur lors de la modification de la variété: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> supprimerVariete(String key) async {
    try {
      await _service.deleteVariete(key);
      print('FirebaseProvider V4: Variete deleted: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression de la variété: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // ===== MÉTHODES D'IMPORT/EXPORT =====
  
  Future<void> deleteAllData() async {
    try {
      await _service.deleteAllData();
      print('FirebaseProvider V4: All data deleted');
    } catch (e) {
      _error = 'Erreur lors de la suppression des données: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> importData(Map<String, dynamic> data) async {
    try {
      await _service.importData(data);
      print('FirebaseProvider V4: Data imported');
    } catch (e) {
      _error = 'Erreur lors de l\'import des données: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> exportData() async {
    try {
      final data = await _service.exportData();
      print('FirebaseProvider V4: Data exported');
      return data;
    } catch (e) {
      _error = 'Erreur lors de l\'export des données: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // ===== MÉTHODES UTILITAIRES =====
  
  Future<void> refreshAllData() async {
    try {
      print('🔄 FirebaseProvider V4: Forcing data refresh...');
      
      // Vider les maps locales
      _parcellesMap.clear();
      _cellulesMap.clear();
      _chargementsMap.clear();
      _semisMap.clear();
      _varietesMap.clear();
      
      // Notifier les listeners
      notifyListeners();
      
      print('✅ FirebaseProvider V4: Data refresh completed');
    } catch (e) {
      print('❌ FirebaseProvider V4: Error during data refresh: $e');
      _error = 'Erreur lors du refresh des données: $e';
      notifyListeners();
    }
  }
  
  // Méthode de compatibilité (pour les calculs automatiques)
  Future<void> updateAllChargementsPoidsNormes() async {
    print('FirebaseProvider V4: updateAllChargementsPoidsNormes - not needed for V4 (calculations are automatic)');
  }
  
  // ===== MÉTHODES UTILITAIRES POUR LES RELATIONS =====
  
  // Obtenir une variété par ID
  Variete? getVarieteById(int? id) {
    if (id == null) return null;
    return varietesById[id];
  }
  
  // Obtenir une parcelle par ID
  Parcelle? getParcelleById(int? id) {
    if (id == null) return null;
    return parcellesById[id];
  }
  
  // Obtenir une cellule par ID
  Cellule? getCelluleById(int? id) {
    if (id == null) return null;
    return cellulesById[id];
  }
  
  // Obtenir la variété principale d'une parcelle (pour compatibilité)
  Variete? getVarieteForParcelle(int? parcelleId) {
    if (parcelleId == null) return null;
    
    // Chercher dans les semis de cette parcelle
    final semisForParcelle = semis.where((s) => s.parcelleId == parcelleId).toList();
    if (semisForParcelle.isNotEmpty) {
      final firstSemis = semisForParcelle.first;
      if (firstSemis.varietesSurfaces.isNotEmpty) {
        final varieteName = firstSemis.varietesSurfaces.first.nom;
        return varietes.firstWhere(
          (v) => v.nom == varieteName,
          orElse: () => Variete(nom: varieteName, dateCreation: DateTime.now()),
        );
      }
    }
    
    return null;
  }
  
  // Obtenir les chargements d'une parcelle
  List<Chargement> getChargementsForParcelle(int? parcelleId) {
    if (parcelleId == null) return [];
    return chargements.where((c) => c.parcelleId == parcelleId).toList();
  }
  
  // Obtenir les chargements d'une cellule
  List<Chargement> getChargementsForCellule(int? celluleId) {
    if (celluleId == null) return [];
    return chargements.where((c) => c.celluleId == celluleId).toList();
  }
  
  // Obtenir les semis d'une parcelle
  List<Semis> getSemisForParcelle(int? parcelleId) {
    if (parcelleId == null) return [];
    return semis.where((s) => s.parcelleId == parcelleId).toList();
  }
}
