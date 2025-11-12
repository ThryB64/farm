import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_service_v4.dart';
import '../models/parcelle.dart';
import '../models/variete.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/vente.dart';
import '../models/traitement.dart';
import '../models/produit.dart';
import '../models/produit_traitement.dart';
import '../models/variete_surface.dart';
import '../utils/poids_utils.dart';
import '../utils/cout_utils.dart';

class FirebaseProviderV4 extends ChangeNotifier {
  final FirebaseServiceV4 _service = FirebaseServiceV4();
  
  // Maps locales pour le cache
  final Map<String, Parcelle> _parcellesMap = {};
  final Map<String, Cellule> _cellulesMap = {};
  final Map<String, Chargement> _chargementsMap = {};
  final Map<String, Semis> _semisMap = {};
  final Map<String, Variete> _varietesMap = {};
  final Map<String, Vente> _ventesMap = {};
  final Map<String, Traitement> _traitementsMap = {};
  final Map<String, Produit> _produitsMap = {};
  
  // Streams pour les données
  Stream<List<Parcelle>>? _parcellesStream;
  Stream<List<Cellule>>? _cellulesStream;
  Stream<List<Chargement>>? _chargementsStream;
  Stream<List<Semis>>? _semisStream;
  Stream<List<Variete>>? _varietesStream;
  Stream<List<Vente>>? _ventesStream;
  Stream<List<Traitement>>? _traitementsStream;
  Stream<List<Produit>>? _produitsStream;
  
  // StreamSubscriptions pour les annuler
  StreamSubscription<List<Parcelle>>? _parcellesSub;
  StreamSubscription<List<Cellule>>? _cellulesSub;
  StreamSubscription<List<Chargement>>? _chargementsSub;
  StreamSubscription<List<Semis>>? _semisSub;
  StreamSubscription<List<Variete>>? _varietesSub;
  StreamSubscription<List<Vente>>? _ventesSub;
  StreamSubscription<List<Traitement>>? _traitementsSub;
  StreamSubscription<List<Produit>>? _produitsSub;
  
  // Getters pour l'accès aux données
  List<Parcelle> get parcelles => _parcellesMap.values.toList();
  List<Cellule> get cellules => _cellulesMap.values.toList();
  List<Chargement> get chargements => _chargementsMap.values.toList();
  List<Semis> get semis => _semisMap.values.toList();
  List<Variete> get varietes => _varietesMap.values.toList();
  List<Vente> get ventes => _ventesMap.values.toList();
  List<Traitement> get traitements => _traitementsMap.values.toList();
  List<Produit> get produits => _produitsMap.values.toList();
  
  // Maps pour les relations (optimisation des jointures) - String keys
  Map<String, Parcelle> get parcellesById => {
    for (final p in parcelles) 
      if (p.firebaseId != null) p.firebaseId!: p
      else if (p.id != null) p.id.toString(): p
  };
  
  Map<String, Cellule> get cellulesById => {
    for (final c in cellules) 
      if (c.firebaseId != null) c.firebaseId!: c
      else if (c.id != null) c.id.toString(): c
  };
  
  Map<String, Variete> get varietesById => {
    for (final v in varietes) 
      if (v.firebaseId != null) v.firebaseId!: v
      else if (v.id != null) v.id.toString(): v
  };
  
  String? _error;
  String? get error => _error;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Méthode privée pour l'initialisation interne (utilisée par initializeForUser)
  Future<void> _initialize() async {
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
      _ventesStream = _service.getVentesStream();
      _traitementsStream = _service.getTraitementsStream();
      _produitsStream = _service.getProduitsStream();
      
      // Écouter les changements
      _parcellesSub = _parcellesStream?.listen(_onParcellesChanged);
      _cellulesSub = _cellulesStream?.listen(_onCellulesChanged);
      _chargementsSub = _chargementsStream?.listen(_onChargementsChanged);
      _semisSub = _semisStream?.listen(_onSemisChanged);
      _varietesSub = _varietesStream?.listen(_onVarietesChanged);
      _ventesSub = _ventesStream?.listen(_onVentesChanged);
      _traitementsSub = _traitementsStream?.listen(_onTraitementsChanged);
      _produitsSub = _produitsStream?.listen(_onProduitsChanged);
      
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
  
  void _onVentesChanged(List<Vente> ventes) {
    _ventesMap.clear();
    for (final vente in ventes) {
      if (vente.firebaseId != null) {
        _ventesMap[vente.firebaseId!] = vente;
      }
    }
    print('FirebaseProvider V4: Updated ${ventes.length} ventes');
    notifyListeners();
  }
  
  void _onTraitementsChanged(List<Traitement> traitements) {
    _traitementsMap.clear();
    for (final traitement in traitements) {
      if (traitement.firebaseId != null) {
        _traitementsMap[traitement.firebaseId!] = traitement;
      }
    }
    print('FirebaseProvider V4: Updated ${traitements.length} traitements');
    // Log des clés pour debug
    print('Traitements keys: ${_traitementsMap.keys.toList()}');
    notifyListeners();
  }
  
  void _onProduitsChanged(List<Produit> produits) {
    _produitsMap.clear();
    for (final produit in produits) {
      if (produit.firebaseId != null) {
        _produitsMap[produit.firebaseId!] = produit;
      }
    }
    print('FirebaseProvider V4: Updated ${produits.length} produits');
    notifyListeners();
  }
  
  // ===== MÉTHODES POUR PARCELLES =====
  
  Future<String> ajouterParcelle(Parcelle parcelle) async {
    try {
      final key = await _service.insertParcelle(parcelle);
      
      // Mise à jour optimiste locale
      parcelle.firebaseId = key;
      _parcellesMap[key] = parcelle;
      notifyListeners();
      
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
      
      // Mise à jour optimiste locale
      final key = parcelle.firebaseId ?? _service.generateParcelleKey(parcelle);
      _parcellesMap[key] = parcelle;
      notifyListeners();
      
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
      
      // Suppression optimiste locale
      _parcellesMap.remove(key);
      notifyListeners();
      
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
      
      // Mise à jour optimiste locale
      cellule.firebaseId = key;
      _cellulesMap[key] = cellule;
      notifyListeners();
      
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
      
      // Mise à jour optimiste locale
      final key = cellule.firebaseId ?? _service.generateCelluleKey(cellule);
      _cellulesMap[key] = cellule;
      notifyListeners();
      
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
      
      // Suppression optimiste locale
      _cellulesMap.remove(key);
      notifyListeners();
      
      print('FirebaseProvider V4: Cellule deleted: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression de la cellule: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fermerCellule(String key) async {
    try {
      final cellule = _cellulesMap[key];
      if (cellule != null) {
        final celluleFermee = Cellule(
          id: cellule.id,
          firebaseId: cellule.firebaseId,
          reference: cellule.reference,
          dateCreation: cellule.dateCreation,
          notes: cellule.notes,
          nom: cellule.nom,
          fermee: true,
        );
        await _service.updateCellule(celluleFermee);
        _cellulesMap[key] = celluleFermee;
        notifyListeners();
        print('FirebaseProvider V4: Cellule fermée: $key');
      }
    } catch (e) {
      _error = 'Erreur lors de la fermeture de la cellule: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> ouvrirCellule(String key) async {
    try {
      final cellule = _cellulesMap[key];
      if (cellule != null) {
        final celluleOuverte = Cellule(
          id: cellule.id,
          firebaseId: cellule.firebaseId,
          reference: cellule.reference,
          dateCreation: cellule.dateCreation,
          notes: cellule.notes,
          nom: cellule.nom,
          fermee: false,
        );
        await _service.updateCellule(celluleOuverte);
        _cellulesMap[key] = celluleOuverte;
        notifyListeners();
        print('FirebaseProvider V4: Cellule ouverte: $key');
      }
    } catch (e) {
      _error = 'Erreur lors de l\'ouverture de la cellule: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // ===== MÉTHODES POUR CHARGEMENTS =====
  
  Future<String> ajouterChargement(Chargement chargement) async {
    try {
      final key = await _service.insertChargement(chargement);
      
      // Mise à jour optimiste locale
      chargement.firebaseId = key;
      _chargementsMap[key] = chargement;
      notifyListeners();
      
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
      
      // Mise à jour optimiste locale
      final key = chargement.firebaseId ?? _service.generateChargementKey(chargement);
      _chargementsMap[key] = chargement;
      notifyListeners();
      
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
      
      // Suppression optimiste locale
      _chargementsMap.remove(key);
      notifyListeners();
      
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
      
      // Mise à jour optimiste locale
      semis.firebaseId = key;
      _semisMap[key] = semis;
      notifyListeners();
      
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
      
      // Mise à jour optimiste locale
      final key = semis.firebaseId ?? _service.generateSemisKey(semis);
      _semisMap[key] = semis;
      notifyListeners();
      
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
      
      // Suppression optimiste locale
      _semisMap.remove(key);
      notifyListeners();
      
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
      
      // Mise à jour optimiste locale
      variete.firebaseId = key;
      _varietesMap[key] = variete;
      notifyListeners();
      
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
      
      // Mise à jour optimiste locale
      final key = variete.firebaseId ?? _service.generateVarieteKey(variete);
      _varietesMap[key] = variete;
      notifyListeners();
      
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
      
      // Suppression optimiste locale
      _varietesMap.remove(key);
      notifyListeners();
      
      print('FirebaseProvider V4: Variete deleted: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression de la variété: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // ===== MÉTHODES POUR LES VENTES =====
  
  Future<String> ajouterVente(Vente vente) async {
    try {
      final key = await _service.insertVente(vente);
      
      // Mise à jour optimiste locale
      vente.firebaseId = key;
      _ventesMap[key] = vente;
      notifyListeners();
      
      print('FirebaseProvider V4: Vente added with key: $key');
      return key;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la vente: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> modifierVente(Vente vente) async {
    try {
      await _service.updateVente(vente);
      
      // Mise à jour optimiste locale
      final key = vente.firebaseId ?? _service.generateVenteKey(vente);
      _ventesMap[key] = vente;
      notifyListeners();
      
      print('FirebaseProvider V4: Vente updated');
    } catch (e) {
      _error = 'Erreur lors de la modification de la vente: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> supprimerVente(String key) async {
    try {
      await _service.deleteVente(key);
      
      // Suppression optimiste locale
      _ventesMap.remove(key);
      notifyListeners();
      
      print('FirebaseProvider V4: Vente deleted: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression de la vente: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  // Méthodes utilitaires pour les ventes
  List<Vente> get ventesEnCours => ventes.where((v) => !v.terminee).toList();
  List<Vente> get ventesTerminees => ventes.where((v) => v.terminee).toList();
  
  // Ventes par année
  List<Vente> getVentesParAnnee(int annee) => ventes.where((v) => v.annee == annee).toList();
  List<Vente> getVentesEnCoursParAnnee(int annee) => ventes.where((v) => v.annee == annee && !v.terminee).toList();
  List<Vente> getVentesTermineesParAnnee(int annee) => ventes.where((v) => v.annee == annee && v.terminee).toList();
  
  // Calculer le stock restant par année
  double getStockRestantParAnnee(int annee) {
    // Calculer le total des chargements pour cette année (maïs entré)
    final totalChargements = chargements
        .where((c) => c.dateChargement.year == annee)
        .fold<double>(0, (sum, c) => sum + c.poidsNormes);
    
    // Calculer le total des ventes terminées pour cette année (maïs sorti)
    final totalVentes = getVentesTermineesParAnnee(annee)
        .fold<double>(0, (sum, v) => sum + (v.poidsNet ?? 0));
    
    return totalChargements - totalVentes;
  }
  
  // Calculer le chiffre d'affaires par année
  double getChiffreAffairesParAnnee(int annee) {
    return getVentesTermineesParAnnee(annee)
        .fold<double>(0, (sum, v) => sum + (v.prix ?? 0));
  }
  
  // Calculer le stock restant global (toutes années confondues)
  double get stockRestant {
    // Calculer le total des chargements (maïs entré)
    final totalChargements = chargements.fold<double>(0, (sum, c) => sum + c.poidsNormes);
    
    // Calculer le total des ventes terminées (maïs sorti)
    final totalVentes = ventesTerminees.fold<double>(0, (sum, v) => sum + (v.poidsNet ?? 0));
    
    return totalChargements - totalVentes;
  }
  
  // Obtenir les années disponibles
  List<int> get anneesDisponibles {
    final annees = <int>{};
    for (final vente in ventes) {
      annees.add(vente.annee);
    }
    for (final chargement in chargements) {
      annees.add(chargement.dateChargement.year);
    }
    return annees.toList()..sort((a, b) => b.compareTo(a)); // Années récentes en premier
  }
  
  // ===== MÉTHODES D'IMPORT/EXPORT =====
  
  Future<void> deleteAllData() async {
    try {
      await _service.deleteAllData();
      
      // Nettoyage local
      _parcellesMap.clear();
      _cellulesMap.clear();
      _chargementsMap.clear();
      _semisMap.clear();
      _varietesMap.clear();
      notifyListeners();
      
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
  
  // Méthode pour recalculer tous les poids aux normes
  Future<void> updateAllChargementsPoidsNormes() async {
    print('FirebaseProvider V4: Recalcul des poids aux normes...');
    
    try {
      // Parcourir tous les chargements et recalculer les poids aux normes
      for (final chargement in _chargementsMap.values) {
        if (chargement.poidsNet > 0 && chargement.humidite > 0) {
          // Créer un nouveau chargement avec le poids aux normes recalculé
          final nouveauChargement = Chargement(
            id: chargement.id,
            firebaseId: chargement.firebaseId,
            celluleId: chargement.celluleId,
            parcelleId: chargement.parcelleId,
            remorque: chargement.remorque,
            dateChargement: chargement.dateChargement,
            poidsPlein: chargement.poidsPlein,
            poidsVide: chargement.poidsVide,
            poidsNet: chargement.poidsNet,
            poidsNormes: 0, // Sera recalculé automatiquement
            humidite: chargement.humidite,
            variete: chargement.variete,
          );
          
          // Mettre à jour dans Firebase
          if (chargement.firebaseId != null) {
            await _service.updateChargement(nouveauChargement);
          }
        }
      }
      
      print('✅ Poids aux normes recalculés avec succès');
    } catch (e) {
      print('❌ Erreur lors du recalcul des poids aux normes: $e');
      rethrow;
    }
  }

  // Méthode pour recalculer TOUTES les variables calculées dans l'application
  Future<void> recalculAllCalculatedValues() async {
    print('🔄 FirebaseProvider V4: Recalcul de toutes les variables calculées...');
    
    int countChargements = 0;
    int countVentes = 0;
    int countSemis = 0;
    int countTraitements = 0;
    int countProduitsTraitement = 0;
    
    try {
      // ===== 1. CHARGEMENTS : Recalculer poidsNet et poidsNormes =====
      print('📦 Recalcul des chargements (poidsNet, poidsNormes)...');
      // Créer une copie de la liste pour éviter les modifications concurrentes
      final chargementsList = _chargementsMap.values.toList();
      for (final chargement in chargementsList) {
        // Recalculer poidsNet = poidsPlein - poidsVide
        final poidsNetCalcule = PoidsUtils.calculPoidsNet(chargement.poidsPlein, chargement.poidsVide);
        
        // Recalculer poidsNormes si humidite > 0
        double poidsNormesCalcule = 0;
        if (chargement.humidite > 0 && poidsNetCalcule > 0) {
          poidsNormesCalcule = PoidsUtils.calculPoidsNormes(poidsNetCalcule, chargement.humidite);
        }
        
        // Créer un nouveau chargement avec les valeurs recalculées
        final nouveauChargement = Chargement(
          id: chargement.id,
          firebaseId: chargement.firebaseId,
          celluleId: chargement.celluleId,
          parcelleId: chargement.parcelleId,
          remorque: chargement.remorque,
          dateChargement: chargement.dateChargement,
          poidsPlein: chargement.poidsPlein,
          poidsVide: chargement.poidsVide,
          poidsNet: poidsNetCalcule,
          poidsNormes: poidsNormesCalcule,
          humidite: chargement.humidite,
          variete: chargement.variete,
        );
        
        // Mettre à jour dans Firebase
        if (chargement.firebaseId != null) {
          await _service.updateChargement(nouveauChargement);
          countChargements++;
        }
      }
      print('✅ $countChargements chargements recalculés');
      
      // ===== 2. VENTES : Recalculer ecartPoidsNet =====
      print('💰 Recalcul des ventes (ecartPoidsNet)...');
      // Créer une copie de la liste pour éviter les modifications concurrentes
      final ventesList = _ventesMap.values.toList();
      for (final vente in ventesList) {
        // Calculer le poids net à partir de poidsPlein - poidsVide
        final poidsNetCalcule = vente.poidsPlein - vente.poidsVide;
        
        // Calculer l'écart si poidsNet est saisi
        double? ecartCalcule;
        if (vente.poidsNet != null) {
          ecartCalcule = poidsNetCalcule - vente.poidsNet!;
        }
        
        // Créer une nouvelle vente avec l'écart recalculé
        final nouvelleVente = vente.copyWith(
          ecartPoidsNet: ecartCalcule,
        );
        
        // Mettre à jour dans Firebase
        if (vente.firebaseId != null) {
          await _service.updateVente(nouvelleVente);
          countVentes++;
        }
      }
      print('✅ $countVentes ventes recalculées');
      
      // ===== 3. SEMIS : Recalculer prixSemis =====
      print('🌱 Recalcul des semis (prixSemis)...');
      // Créer une copie de la liste pour éviter les modifications concurrentes
      final semisList = _semisMap.values.toList();
      for (final semis in semisList) {
        double totalPrix = 0.0;
        final annee = semis.date.year;
        
        // Pour chaque varieteSurface, calculer le coût
        for (final varieteSurface in semis.varietesSurfaces) {
          // Trouver la variété
          final variete = getVarieteById(varieteSurface.varieteId);
          
          if (variete != null && variete.prixParAnnee.containsKey(annee)) {
            final prixDose = variete.prixParAnnee[annee]!;
            // Calculer le coût total pour cette variété : cout/ha × surface
            final coutParHectare = CoutUtils.calculerCoutSemisParHectare(prixDose, semis.densiteMais);
            final coutTotal = CoutUtils.calculerCoutTotalSemis(prixDose, semis.densiteMais, varieteSurface.surface);
            totalPrix += coutTotal;
          }
        }
        
        // Créer un nouveau semis avec le prix recalculé
        final nouveauSemis = Semis(
          id: semis.id,
          firebaseId: semis.firebaseId,
          parcelleId: semis.parcelleId,
          date: semis.date,
          varietesSurfaces: semis.varietesSurfaces,
          notes: semis.notes,
          densiteMais: semis.densiteMais,
          prixSemis: totalPrix,
        );
        
        // Mettre à jour dans Firebase
        if (semis.firebaseId != null) {
          await _service.updateSemis(nouveauSemis);
          countSemis++;
        }
      }
      print('✅ $countSemis semis recalculés');
      
      // ===== 4. TRAITEMENTS : Recalculer coutTotal pour chaque ProduitTraitement et Traitement =====
      print('💊 Recalcul des traitements (coutTotal produits et traitements)...');
      // Créer une copie de la liste pour éviter les modifications concurrentes
      final traitementsList = _traitementsMap.values.toList();
      for (final traitement in traitementsList) {
        final parcelle = getParcelleById(traitement.parcelleId);
        if (parcelle == null) continue;
        
        // Recalculer coutTotal pour chaque ProduitTraitement
        final produitsRecalcules = traitement.produits.map((produit) {
          // coutTotal = quantite * prixUnitaire (coût par hectare)
          final coutTotal = produit.quantite * produit.prixUnitaire;
          
          return ProduitTraitement(
            produitId: produit.produitId,
            nomProduit: produit.nomProduit,
            quantite: produit.quantite,
            mesure: produit.mesure,
            prixUnitaire: produit.prixUnitaire,
            coutTotal: coutTotal,
            date: produit.date,
          );
        }).toList();
        
        countProduitsTraitement += produitsRecalcules.length;
        
        // Recalculer coutTotal du traitement = somme des (coutTotal produit × surface parcelle)
        final coutTotalTraitement = produitsRecalcules.fold<double>(
          0.0,
          (sum, produit) => sum + (produit.coutTotal * parcelle.surface),
        );
        
        // Créer un nouveau traitement avec les coûts recalculés
        final nouveauTraitement = Traitement(
          id: traitement.id,
          firebaseId: traitement.firebaseId,
          parcelleId: traitement.parcelleId,
          date: traitement.date,
          annee: traitement.annee,
          notes: traitement.notes,
          produits: produitsRecalcules,
          coutTotal: coutTotalTraitement,
        );
        
        // Mettre à jour dans Firebase
        if (traitement.firebaseId != null) {
          await _service.modifierTraitement(nouveauTraitement);
          countTraitements++;
        }
      }
      print('✅ $countTraitements traitements recalculés ($countProduitsTraitement produits)');
      
      // Résumé
      print('✅ Recalcul terminé :');
      print('   - $countChargements chargements');
      print('   - $countVentes ventes');
      print('   - $countSemis semis');
      print('   - $countTraitements traitements ($countProduitsTraitement produits)');
      
      // Notifier les listeners pour mettre à jour l'UI
      notifyListeners();
      
    } catch (e) {
      print('❌ Erreur lors du recalcul des variables calculées: $e');
      rethrow;
    }
  }
  
  // ===== MÉTHODES UTILITAIRES POUR LES RELATIONS =====
  
  // Obtenir une variété par ID (String)
  Variete? getVarieteById(String? id) {
    if (id == null || id.isEmpty) return null;
    return varietesById[id];
  }
  
  // Obtenir une parcelle par ID (String)
  Parcelle? getParcelleById(String? id) {
    if (id == null || id.isEmpty) return null;
    return parcellesById[id];
  }
  
  // Obtenir une cellule par ID (String)
  Cellule? getCelluleById(String? id) {
    if (id == null || id.isEmpty) return null;
    return cellulesById[id];
  }
  
  // Obtenir la variété principale d'une parcelle (pour compatibilité)
  Variete? getVarieteForParcelle(String? parcelleId) {
    if (parcelleId == null || parcelleId.isEmpty) return null;
    
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
  
  // Obtenir les chargements d'une parcelle (String ID)
  List<Chargement> getChargementsForParcelle(String? parcelleId) {
    if (parcelleId == null || parcelleId.isEmpty) return [];
    return chargements.where((c) => c.parcelleId == parcelleId).toList();
  }
  
  // Obtenir les chargements d'une cellule (String ID)
  List<Chargement> getChargementsForCellule(String? celluleId) {
    if (celluleId == null || celluleId.isEmpty) return [];
    return chargements.where((c) => c.celluleId == celluleId).toList();
  }
  
  // Obtenir les semis d'une parcelle (String ID)
  List<Semis> getSemisForParcelle(String? parcelleId) {
    if (parcelleId == null || parcelleId.isEmpty) return [];
    return semis.where((s) => s.parcelleId == parcelleId).toList();
  }
  
  // Méthode de diagnostic pour vérifier les jointures
  Map<String, int> debugJoins() {
    int ok = 0, missCell = 0, missParc = 0;
    
    for (final ch in chargements) {
      final cellule = getCelluleById(ch.celluleId);
      final parcelle = getParcelleById(ch.parcelleId);
      
      if (cellule == null) missCell++;
      if (parcelle == null) missParc++;
      if (cellule != null && parcelle != null) ok++;
    }
    
    return {
      'ok': ok,
      'missCell': missCell,
      'missParc': missParc,
      'total': chargements.length,
    };
  }

  // ===== MÉTHODES POUR LES TRAITEMENTS =====
  
  // Ajouter un traitement
  Future<void> ajouterTraitement(Traitement traitement) async {
    try {
      final key = await _service.ajouterTraitement(traitement);
      final traitementAvecKey = traitement.copyWith(firebaseId: key);
      _traitementsMap[key] = traitementAvecKey;
      notifyListeners();
      print('FirebaseProvider V4: Traitement ajouté: $key');
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du traitement: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Modifier un traitement
  Future<void> modifierTraitement(Traitement traitement) async {
    try {
      final key = traitement.firebaseId ?? traitement.id.toString();
      await _service.modifierTraitement(traitement);
      _traitementsMap[key] = traitement;
      notifyListeners();
      print('FirebaseProvider V4: Traitement modifié: $key');
    } catch (e) {
      _error = 'Erreur lors de la modification du traitement: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Supprimer un traitement
  Future<void> supprimerTraitement(String key) async {
    try {
      await _service.supprimerTraitement(key);
      _traitementsMap.remove(key);
      notifyListeners();
      print('FirebaseProvider V4: Traitement supprimé: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression du traitement: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ===== MÉTHODES POUR LES PRODUITS =====
  
  // Ajouter un produit
  Future<void> ajouterProduit(Produit produit) async {
    try {
      final key = await _service.ajouterProduit(produit);
      final produitAvecKey = produit.copyWith(firebaseId: key);
      _produitsMap[key] = produitAvecKey;
      notifyListeners();
      print('FirebaseProvider V4: Produit ajouté: $key');
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du produit: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Modifier un produit
  Future<void> modifierProduit(Produit produit) async {
    try {
      final key = produit.firebaseId ?? produit.id.toString();
      await _service.modifierProduit(produit);
      _produitsMap[key] = produit;
      notifyListeners();
      print('FirebaseProvider V4: Produit modifié: $key');
    } catch (e) {
      _error = 'Erreur lors de la modification du produit: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Supprimer un produit
  Future<void> supprimerProduit(String key) async {
    try {
      await _service.supprimerProduit(key);
      _produitsMap.remove(key);
      notifyListeners();
      print('FirebaseProvider V4: Produit supprimé: $key');
    } catch (e) {
      _error = 'Erreur lors de la suppression du produit: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Obtenir un produit par ID
  Produit? getProduitById(String? produitId) {
    if (produitId == null || produitId.isEmpty) return null;
    return _produitsMap[produitId];
  }

  // Obtenir les traitements d'une parcelle
  List<Traitement> getTraitementsForParcelle(String? parcelleId) {
    if (parcelleId == null || parcelleId.isEmpty) return [];
    return traitements.where((t) => t.parcelleId == parcelleId).toList();
  }

  // Obtenir les traitements d'une année
  List<Traitement> getTraitementsForAnnee(int annee) {
    return traitements.where((t) => t.annee == annee).toList();
  }
  
  String? _initedUid;
  bool _ready = false;
  
  // Getter pour vérifier si le provider est prêt
  bool get ready => _ready;

  // Initialiser pour un utilisateur spécifique (API unique)
  Future<void> initializeForUser(String uid) async {
    if (_ready && _initedUid == uid && _isInitialized) return;
    
    print('FirebaseProvider V4: Initializing for user: $uid');
    
    try {
      // Utiliser la méthode privée d'initialisation
      await _initialize();
      
      _initedUid = uid;
      _ready = true;
      _error = null;
      notifyListeners();
      print('✅ FirebaseProvider V4: Initialization completed for user: $uid');
      
    } catch (e) {
      _error = 'Erreur d\'initialisation: $e';
      print('❌ FirebaseProvider V4: Initialization failed for user $uid: $e');
      notifyListeners();
    }
  }

  // Nettoyer les ressources liées à l'authentification
  Future<void> disposeAuthBoundResources() async {
    print('FirebaseProvider V4: Disposing auth bound resources');
    
    // Annuler tous les StreamSubscriptions
    await _parcellesSub?.cancel();
    await _cellulesSub?.cancel();
    await _chargementsSub?.cancel();
    await _semisSub?.cancel();
    await _varietesSub?.cancel();
    await _ventesSub?.cancel();
    await _traitementsSub?.cancel();
    await _produitsSub?.cancel();
    
    _parcellesSub = _cellulesSub = _chargementsSub = _semisSub =
    _varietesSub = _ventesSub = _traitementsSub = _produitsSub = null;
    
    await _service.disposeListeners();
    _initedUid = null;
    _ready = false;
    _isInitialized = false;   // IMPORTANT : remettre à false
    _clearAllInternal(); // Méthode interne sans notifyListeners
    notifyListeners(); // Un seul notify à la fin
    print('FirebaseProvider V4: Auth bound resources disposed');
  }

  // Vider toutes les données (version interne sans notify)
  void _clearAllInternal() {
    print('FirebaseProvider V4: Clearing all data');
    _parcellesMap.clear();
    _cellulesMap.clear();
    _chargementsMap.clear();
    _semisMap.clear();
    _varietesMap.clear();
    _ventesMap.clear();
    _traitementsMap.clear();
    _produitsMap.clear();
    print('FirebaseProvider V4: All data cleared');
  }

  // Vider toutes les données (version publique avec notify)
  void clearAll() {
    _clearAllInternal();
    notifyListeners();
  }

  // Forcer la mise à jour après la connexion (legacy)
  Future<void> refreshAfterAuth() async {
    try {
      print('FirebaseProvider V4: Refreshing after authentication...');
      
      // Réinitialiser le service pour prendre en compte la nouvelle authentification
      await _service.initialize();
      
      // Attendre un peu pour que les données se chargent
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Notifier les listeners
      notifyListeners();
      
      print('FirebaseProvider V4: Refresh completed');
    } catch (e) {
      print('FirebaseProvider V4: Refresh failed: $e');
    }
  }

  // Forcer un refresh complet des données
  Future<void> forceRefresh() async {
    try {
      print('🔄 FirebaseProvider V4: Forcing complete refresh...');
      
      // Annuler les subscriptions actuelles
      await _parcellesSub?.cancel();
      await _cellulesSub?.cancel();
      await _chargementsSub?.cancel();
      await _semisSub?.cancel();
      await _varietesSub?.cancel();
      await _ventesSub?.cancel();
      await _traitementsSub?.cancel();
      await _produitsSub?.cancel();
      
      // Vider les maps locales
      _clearAllInternal();
      
      // Réinitialiser le service
      _isInitialized = false;
      await _service.forceRefresh();
      
      // Réinitialiser les streams
      await _initialize();
      
      print('✅ FirebaseProvider V4: Complete refresh done');
    } catch (e) {
      _error = 'Erreur lors du refresh: $e';
      print('❌ FirebaseProvider V4: Refresh failed: $e');
      notifyListeners();
      rethrow;
    }
  }

  // Obtenir des informations de diagnostic
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    return await _service.getDiagnosticInfo();
  }

  @override
  void dispose() {
    // Annuler tous les StreamSubscriptions
    _parcellesSub?.cancel();
    _cellulesSub?.cancel();
    _chargementsSub?.cancel();
    _semisSub?.cancel();
    _varietesSub?.cancel();
    _ventesSub?.cancel();
    _traitementsSub?.cancel();
    _produitsSub?.cancel();
    
    // Nettoyer les streams
    _parcellesStream = null;
    _cellulesStream = null;
    _chargementsStream = null;
    _semisStream = null;
    _varietesStream = null;
    _ventesStream = null;
    _traitementsStream = null;
    _produitsStream = null;
    super.dispose();
  }
}
