import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../services/simple_realtime_database.dart';
import '../utils/poids_utils.dart';

class SimpleRealtimeProvider with ChangeNotifier {
  final SimpleRealtimeDatabase _db;
  List<Parcelle> _parcelles = [];
  List<Cellule> _cellules = [];
  List<Chargement> _chargements = [];
  List<Semis> _semis = [];
  List<Variete> _varietes = [];
  bool _isInitialized = false;
  StreamSubscription? _changeSubscription;

  SimpleRealtimeProvider() : _db = SimpleRealtimeDatabase() {
    _init();
  }

  static final SimpleRealtimeProvider instance = SimpleRealtimeProvider._();
  SimpleRealtimeProvider._() : _db = SimpleRealtimeDatabase() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _db.init();
      await _loadData();
      _isInitialized = true;
      
      // Écouter les changements en temps réel
      _changeSubscription = _db.changes.listen((change) {
        _handleRealtimeChange(change);
      });
      
      print('✅ SimpleRealtimeProvider initialized');
    } catch (e) {
      print('❌ Error initializing SimpleRealtimeProvider: $e');
    }
  }

  void _handleRealtimeChange(Map<String, dynamic> change) {
    final type = change['type'] as String;
    final data = change['data'];
    final id = change['id'];

    switch (type) {
      case 'parcelle_added':
        _parcelles.add(Parcelle.fromMap(Map<String, dynamic>.from(data)));
        break;
      case 'parcelle_updated':
        final index = _parcelles.indexWhere((p) => p.id == data['id']);
        if (index != -1) {
          _parcelles[index] = Parcelle.fromMap(Map<String, dynamic>.from(data));
        }
        break;
      case 'parcelle_deleted':
        _parcelles.removeWhere((p) => p.id == id);
        break;
        
      case 'cellule_added':
        _cellules.add(Cellule.fromMap(Map<String, dynamic>.from(data)));
        break;
      case 'cellule_updated':
        final index = _cellules.indexWhere((c) => c.id == data['id']);
        if (index != -1) {
          _cellules[index] = Cellule.fromMap(Map<String, dynamic>.from(data));
        }
        break;
      case 'cellule_deleted':
        _cellules.removeWhere((c) => c.id == id);
        break;
        
      case 'chargement_added':
        _chargements.add(Chargement.fromMap(Map<String, dynamic>.from(data)));
        break;
      case 'chargement_updated':
        final index = _chargements.indexWhere((c) => c.id == data['id']);
        if (index != -1) {
          _chargements[index] = Chargement.fromMap(Map<String, dynamic>.from(data));
        }
        break;
      case 'chargement_deleted':
        _chargements.removeWhere((c) => c.id == id);
        break;
        
      case 'semis_added':
        _semis.add(Semis.fromMap(Map<String, dynamic>.from(data)));
        break;
      case 'semis_updated':
        final index = _semis.indexWhere((s) => s.id == data['id']);
        if (index != -1) {
          _semis[index] = Semis.fromMap(Map<String, dynamic>.from(data));
        }
        break;
      case 'semis_deleted':
        _semis.removeWhere((s) => s.id == id);
        break;
        
      case 'variete_added':
        _varietes.add(Variete.fromMap(Map<String, dynamic>.from(data)));
        break;
      case 'variete_updated':
        final index = _varietes.indexWhere((v) => v.id == data['id']);
        if (index != -1) {
          _varietes[index] = Variete.fromMap(Map<String, dynamic>.from(data));
        }
        break;
      case 'variete_deleted':
        _varietes.removeWhere((v) => v.id == id);
        break;
        
      case 'chargements_updated':
        _loadChargements();
        break;
        
      case 'all_data_deleted':
      case 'data_imported':
        _loadData();
        break;
    }
    
    // Notifier les listeners en temps réel
    notifyListeners();
  }

  Future<void> _loadData() async {
    try {
      _parcelles = await _db.getParcelles();
      _cellules = await _db.getCellules();
      _chargements = await _db.getChargements();
      _semis = await _db.getSemis();
      _varietes = await _db.getVarietes();
      
      print('✅ Data loaded: ${_parcelles.length} parcelles, ${_cellules.length} cellules, ${_chargements.length} chargements, ${_semis.length} semis, ${_varietes.length} varietes');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading data: $e');
    }
  }

  Future<void> _loadChargements() async {
    try {
      _chargements = await _db.getChargements();
    } catch (e) {
      print('❌ Error loading chargements: $e');
    }
  }

  // Getters
  List<Parcelle> get parcelles => _parcelles;
  List<Cellule> get cellules => _cellules;
  List<Chargement> get chargements => _chargements;
  List<Semis> get semis => _semis;
  List<Variete> get varietes => _varietes;
  bool get isInitialized => _isInitialized;

  // Statistiques en temps réel
  Future<Map<String, dynamic>> getStats() async {
    try {
      final surfaceTotale = _parcelles.fold<double>(0, (sum, p) => sum + p.surface);
      
      final derniereAnnee = _chargements.isEmpty
          ? DateTime.now().year
          : _chargements
              .map((c) => c.dateChargement.year)
              .reduce((a, b) => a > b ? a : b);

      final chargementsDerniereAnnee = _chargements.where(
        (c) => c.dateChargement.year == derniereAnnee
      ).toList();

      final poidsTotalNormeAnnee = chargementsDerniereAnnee.fold<double>(
        0,
        (sum, c) => sum + c.poidsNormes,
      );

      final rendementMoyenNorme = surfaceTotale > 0
          ? (poidsTotalNormeAnnee / 1000) / surfaceTotale
          : 0.0;

      return {
        'surfaceTotale': surfaceTotale,
        'derniereAnnee': derniereAnnee,
        'poidsTotalNormeAnnee': poidsTotalNormeAnnee,
        'rendementMoyenNorme': rendementMoyenNorme,
        'totalParcelles': _parcelles.length,
        'totalCellules': _cellules.length,
        'totalChargements': _chargements.length,
        'totalSemis': _semis.length,
        'totalVarietes': _varietes.length,
      };
    } catch (e) {
      print('❌ Error calculating stats: $e');
      return {};
    }
  }

  // Méthodes pour les parcelles
  Future<void> ajouterParcelle(Parcelle parcelle) async {
    try {
      await _db.insertParcelle(parcelle);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error adding parcelle: $e');
      rethrow;
    }
  }

  Future<void> modifierParcelle(Parcelle parcelle) async {
    try {
      await _db.updateParcelle(parcelle);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error updating parcelle: $e');
      rethrow;
    }
  }

  Future<void> supprimerParcelle(int id) async {
    try {
      await _db.deleteParcelle(id);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error deleting parcelle: $e');
      rethrow;
    }
  }

  // Méthodes pour les cellules
  Future<void> ajouterCellule(Cellule cellule) async {
    try {
      await _db.insertCellule(cellule);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error adding cellule: $e');
      rethrow;
    }
  }

  Future<void> modifierCellule(Cellule cellule) async {
    try {
      await _db.updateCellule(cellule);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error updating cellule: $e');
      rethrow;
    }
  }

  Future<void> supprimerCellule(int id) async {
    try {
      await _db.deleteCellule(id);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error deleting cellule: $e');
      rethrow;
    }
  }

  // Méthodes pour les chargements
  Future<void> ajouterChargement(Chargement chargement) async {
    try {
      // Validation
      if (!PoidsUtils.estPoidsValide(chargement.poidsPlein)) {
        throw Exception('Le poids plein doit être positif');
      }
      if (!PoidsUtils.estPoidsValide(chargement.poidsVide)) {
        throw Exception('Le poids vide doit être positif');
      }
      if (!PoidsUtils.estHumiditeValide(chargement.humidite)) {
        throw Exception('L\'humidité doit être comprise entre 0 et 100%');
      }

      // Calculer le poids net et le poids aux normes
      chargement.poidsNet = PoidsUtils.calculPoidsNet(
        chargement.poidsPlein,
        chargement.poidsVide,
      );
      chargement.poidsNormes = PoidsUtils.calculPoidsNormes(
        chargement.poidsNet,
        chargement.humidite,
      );

      await _db.insertChargement(chargement);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error adding chargement: $e');
      rethrow;
    }
  }

  Future<void> modifierChargement(Chargement chargement) async {
    try {
      // Validation
      if (!PoidsUtils.estPoidsValide(chargement.poidsPlein)) {
        throw Exception('Le poids plein doit être positif');
      }
      if (!PoidsUtils.estPoidsValide(chargement.poidsVide)) {
        throw Exception('Le poids vide doit être positif');
      }
      if (!PoidsUtils.estHumiditeValide(chargement.humidite)) {
        throw Exception('L\'humidité doit être comprise entre 0 et 100%');
      }

      // Calculer le poids net et le poids aux normes
      chargement.poidsNet = PoidsUtils.calculPoidsNet(
        chargement.poidsPlein,
        chargement.poidsVide,
      );
      chargement.poidsNormes = PoidsUtils.calculPoidsNormes(
        chargement.poidsNet,
        chargement.humidite,
      );

      await _db.updateChargement(chargement);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error updating chargement: $e');
      rethrow;
    }
  }

  Future<void> supprimerChargement(int id) async {
    try {
      await _db.deleteChargement(id);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error deleting chargement: $e');
      rethrow;
    }
  }

  // Méthodes pour les semis
  Future<void> ajouterSemis(Semis semis) async {
    try {
      await _db.insertSemis(semis);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error adding semis: $e');
      rethrow;
    }
  }

  Future<void> modifierSemis(Semis semis) async {
    try {
      await _db.updateSemis(semis);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error updating semis: $e');
      rethrow;
    }
  }

  Future<void> supprimerSemis(int id) async {
    try {
      await _db.deleteSemis(id);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error deleting semis: $e');
      rethrow;
    }
  }

  // Méthodes pour les variétés
  Future<void> ajouterVariete(Variete variete) async {
    try {
      await _db.insertVariete(variete);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error adding variete: $e');
      rethrow;
    }
  }

  Future<void> modifierVariete(Variete variete) async {
    try {
      await _db.updateVariete(variete);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error updating variete: $e');
      rethrow;
    }
  }

  Future<void> supprimerVariete(int id) async {
    try {
      await _db.deleteVariete(id);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error deleting variete: $e');
      rethrow;
    }
  }

  // Méthodes utilitaires
  Future<void> updateAllChargementsPoidsNormes() async {
    try {
      await _db.updateAllChargementsPoidsNormes();
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error updating poids normes: $e');
      rethrow;
    }
  }

  Future<void> deleteAllData() async {
    try {
      await _db.deleteAllData();
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error deleting all data: $e');
      rethrow;
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      await _db.importData(data);
      // Le changement sera géré automatiquement par le listener
    } catch (e) {
      print('❌ Error importing data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      return await _db.exportData();
    } catch (e) {
      print('❌ Error exporting data: $e');
      return {};
    }
  }

  Variete? getVarieteForParcelle(int? parcelleId) {
    if (parcelleId == null) return null;

    final semis = _semis.where((s) => s.parcelleId == parcelleId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

    if (semis.isEmpty) return null;

    final dernierSemis = semis.first;
    return _varietes.firstWhere(
      (v) => v.nom == dernierSemis.varietes.first,
      orElse: () => Variete(
        nom: 'Inconnue',
        dateCreation: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _changeSubscription?.cancel();
    _db.dispose();
    super.dispose();
  }
}
