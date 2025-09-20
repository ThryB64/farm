import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../services/firebase_service_v3.dart';
import '../utils/poids_utils.dart';

class FirebaseProviderV3 with ChangeNotifier {
  final FirebaseServiceV3 _firebaseService = FirebaseServiceV3();
  
  // État de l'application
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  
  // Données avec Maps pour éviter les doublons
  final Map<String, Parcelle> _parcellesMap = {};
  final Map<String, Cellule> _cellulesMap = {};
  final Map<String, Chargement> _chargementsMap = {};
  final Map<String, Semis> _semisMap = {};
  final Map<String, Variete> _varietesMap = {};
  
  // Streams pour la synchronisation temps réel
  StreamSubscription<List<Parcelle>>? _parcellesSubscription;
  StreamSubscription<List<Cellule>>? _cellulesSubscription;
  StreamSubscription<List<Chargement>>? _chargementsSubscription;
  StreamSubscription<List<Semis>>? _semisSubscription;
  StreamSubscription<List<Variete>>? _varietesSubscription;

  // Getters
  List<Parcelle> get parcelles => _parcellesMap.values.toList(growable: false);
  List<Cellule> get cellules => _cellulesMap.values.toList(growable: false);
  List<Chargement> get chargements => _chargementsMap.values.toList(growable: false);
  List<Semis> get semis => _semisMap.values.toList(growable: false);
  List<Variete> get varietes => _varietesMap.values.toList(growable: false);
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialiser le provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('FirebaseProvider V3: Initializing...');
      
      // Initialiser le service Firebase
      await _firebaseService.initialize();
      
      // Configurer les listeners temps réel
      await _setupRealtimeListeners();
      
      _isInitialized = true;
      print('✅ FirebaseProvider V3: Initialized successfully');
      
    } catch (e) {
      _error = 'Erreur d\'initialisation: $e';
      print('❌ FirebaseProvider V3: Initialization failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Configurer les listeners temps réel
  Future<void> _setupRealtimeListeners() async {
    try {
      // Listener pour les parcelles
      _parcellesSubscription = _firebaseService.getParcellesStream().listen(
        (parcelles) {
          _parcellesMap.clear();
          for (final parcelle in parcelles) {
            final key = _firebaseService.generateStableKey(parcelle);
            _parcellesMap[key] = parcelle;
          }
          notifyListeners();
          print('FirebaseProvider V3: Updated ${parcelles.length} parcelles');
        },
        onError: (error) {
          _error = 'Erreur de synchronisation parcelles: $error';
          notifyListeners();
          print('❌ FirebaseProvider V3: Parcelles stream error: $error');
        },
      );

      // Listener pour les cellules
      _cellulesSubscription = _firebaseService.getCellulesStream().listen(
        (cellules) {
          _cellulesMap.clear();
          for (final cellule in cellules) {
            final key = cellule.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            _cellulesMap[key] = cellule;
          }
          notifyListeners();
          print('FirebaseProvider V3: Updated ${cellules.length} cellules');
        },
        onError: (error) {
          _error = 'Erreur de synchronisation cellules: $error';
          notifyListeners();
          print('❌ FirebaseProvider V3: Cellules stream error: $error');
        },
      );

      // Listener pour les chargements
      _chargementsSubscription = _firebaseService.getChargementsStream().listen(
        (chargements) {
          _chargementsMap.clear();
          for (final chargement in chargements) {
            final key = chargement.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            _chargementsMap[key] = chargement;
          }
          notifyListeners();
          print('FirebaseProvider V3: Updated ${chargements.length} chargements');
        },
        onError: (error) {
          _error = 'Erreur de synchronisation chargements: $error';
          notifyListeners();
          print('❌ FirebaseProvider V3: Chargements stream error: $error');
        },
      );

      // Listener pour les semis
      _semisSubscription = _firebaseService.getSemisStream().listen(
        (semis) {
          _semisMap.clear();
          for (final semisItem in semis) {
            final key = semisItem.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            _semisMap[key] = semisItem;
          }
          notifyListeners();
          print('FirebaseProvider V3: Updated ${semis.length} semis');
        },
        onError: (error) {
          _error = 'Erreur de synchronisation semis: $error';
          notifyListeners();
          print('❌ FirebaseProvider V3: Semis stream error: $error');
        },
      );

      // Listener pour les variétés
      _varietesSubscription = _firebaseService.getVarietesStream().listen(
        (varietes) {
          _varietesMap.clear();
          for (final variete in varietes) {
            final key = variete.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
            _varietesMap[key] = variete;
          }
          notifyListeners();
          print('FirebaseProvider V3: Updated ${varietes.length} varietes');
        },
        onError: (error) {
          _error = 'Erreur de synchronisation variétés: $error';
          notifyListeners();
          print('❌ FirebaseProvider V3: Varietes stream error: $error');
        },
      );
      
      print('✅ FirebaseProvider V3: Realtime listeners configured');
      
    } catch (e) {
      _error = 'Erreur de configuration des listeners: $e';
      print('❌ FirebaseProvider V3: Error setting up listeners: $e');
    }
  }

  // Statistiques
  Future<Map<String, dynamic>> getStats() async {
    try {
      // Calculer la surface totale
      final surfaceTotale = _parcellesMap.values.fold<double>(
        0,
        (sum, p) => sum + p.surface,
      );

      // Obtenir l'année la plus récente avec des chargements
      final derniereAnnee = _chargementsMap.values.isEmpty
          ? DateTime.now().year
          : _chargementsMap.values
              .map((c) => c.dateChargement.year)
              .reduce((a, b) => a > b ? a : b);

      final chargementsDerniereAnnee = _chargementsMap.values.where(
        (c) => c.dateChargement.year == derniereAnnee
      ).toList();

      // Calculer le poids total normé de l'année
      final poidsTotalNormeAnnee = chargementsDerniereAnnee.fold<double>(
        0,
        (sum, c) => sum + c.poidsNormes,
      );

      // Calculer le rendement moyen normé (en T/ha)
      final rendementMoyenNorme = surfaceTotale > 0
          ? (poidsTotalNormeAnnee / 1000) / surfaceTotale
          : 0.0;

      return {
        'surfaceTotale': surfaceTotale,
        'derniereAnnee': derniereAnnee,
        'poidsTotalNormeAnnee': poidsTotalNormeAnnee,
        'rendementMoyenNorme': rendementMoyenNorme,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      rethrow;
    }
  }

  // Méthodes pour les parcelles
  Future<void> ajouterParcelle(Parcelle parcelle) async {
    try {
      print('FirebaseProvider V3: Adding parcelle: ${parcelle.nom}');
      
      final key = await _firebaseService.insertParcelle(parcelle);
      parcelle.id = int.tryParse(key) ?? 0;
      
      // Mise à jour optimiste locale
      _parcellesMap[key] = parcelle;
      notifyListeners();
      
      print('✅ FirebaseProvider V3: Parcelle added with key: $key');
      
    } catch (e) {
      _error = 'Erreur ajout parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierParcelle(Parcelle parcelle) async {
    try {
      print('FirebaseProvider V3: Updating parcelle: ${parcelle.nom}');
      
      await _firebaseService.updateParcelle(parcelle);
      
      // Mise à jour optimiste locale
      final key = _firebaseService.generateStableKey(parcelle);
      _parcellesMap[key] = parcelle;
      notifyListeners();
      
      print('✅ FirebaseProvider V3: Parcelle updated');
      
    } catch (e) {
      _error = 'Erreur modification parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerParcelle(String key) async {
    try {
      print('FirebaseProvider V3: Deleting parcelle: $key');
      
      await _firebaseService.deleteParcelle(key);
      
      // Suppression optimiste locale
      _parcellesMap.remove(key);
      notifyListeners();
      
      print('✅ FirebaseProvider V3: Parcelle deleted: $key');
      
    } catch (e) {
      _error = 'Erreur suppression parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes pour les cellules
  Future<void> ajouterCellule(Cellule cellule) async {
    try {
      print('FirebaseProvider V3: Adding cellule: ${cellule.id}');
      
      final key = await _firebaseService.insertCellule(cellule);
      cellule.id = int.tryParse(key) ?? 0;
      
      // Mise à jour optimiste locale
      _cellulesMap[key] = cellule;
      notifyListeners();
      
      print('✅ FirebaseProvider V3: Cellule added with key: $key');
      
    } catch (e) {
      _error = 'Erreur ajout cellule: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierCellule(Cellule cellule) async {
    try {
      await _firebaseService.updateCellule(cellule);
      
      // Mise à jour optimiste locale
      final key = cellule.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      _cellulesMap[key] = cellule;
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur modification cellule: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerCellule(String key) async {
    try {
      await _firebaseService.deleteCellule(key);
      
      // Suppression optimiste locale
      _cellulesMap.remove(key);
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur suppression cellule: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes pour les chargements
  Future<void> ajouterChargement(Chargement chargement) async {
    try {
      // Valider les données
      if (!PoidsUtils.estPoidsValide(chargement.poidsPlein)) {
        throw Exception('Le poids plein doit être positif');
      }
      if (!PoidsUtils.estPoidsValide(chargement.poidsVide)) {
        throw Exception('Le poids vide doit être positif');
      }
      if (!PoidsUtils.estHumiditeValide(chargement.humidite)) {
        throw Exception('L\'humidité doit être comprise entre 0 et 100%');
      }

      // Calculer le poids net
      chargement.poidsNet = PoidsUtils.calculPoidsNet(
        chargement.poidsPlein,
        chargement.poidsVide,
      );

      // Calculer le poids aux normes
      chargement.poidsNormes = PoidsUtils.calculPoidsNormes(
        chargement.poidsNet,
        chargement.humidite,
      );

      final key = await _firebaseService.insertChargement(chargement);
      chargement.id = int.tryParse(key) ?? 0;
      
      // Mise à jour optimiste locale
      _chargementsMap[key] = chargement;
      notifyListeners();
      
      print('✅ FirebaseProvider V3: Chargement added with key: $key');
      
    } catch (e) {
      _error = 'Erreur ajout chargement: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierChargement(Chargement chargement) async {
    try {
      if (chargement.id != null) {
        // Valider les données
        if (!PoidsUtils.estPoidsValide(chargement.poidsPlein)) {
          throw Exception('Le poids plein doit être positif');
        }
        if (!PoidsUtils.estPoidsValide(chargement.poidsVide)) {
          throw Exception('Le poids vide doit être positif');
        }
        if (!PoidsUtils.estHumiditeValide(chargement.humidite)) {
          throw Exception('L\'humidité doit être comprise entre 0 et 100%');
        }

        // Calculer le poids net
        chargement.poidsNet = PoidsUtils.calculPoidsNet(
          chargement.poidsPlein,
          chargement.poidsVide,
        );

        // Calculer le poids aux normes
        chargement.poidsNormes = PoidsUtils.calculPoidsNormes(
          chargement.poidsNet,
          chargement.humidite,
        );

        await _firebaseService.updateChargement(chargement);
        
        // Mise à jour optimiste locale
        final key = chargement.id.toString();
        _chargementsMap[key] = chargement;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur modification chargement: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerChargement(String key) async {
    try {
      await _firebaseService.deleteChargement(key);
      
      // Suppression optimiste locale
      _chargementsMap.remove(key);
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur suppression chargement: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes pour les semis
  Future<void> ajouterSemis(Semis semis) async {
    try {
      final key = await _firebaseService.insertSemis(semis);
      semis.id = int.tryParse(key) ?? 0;
      
      // Mise à jour optimiste locale
      _semisMap[key] = semis;
      notifyListeners();
      
      print('✅ FirebaseProvider V3: Semis added with key: $key');
      
    } catch (e) {
      _error = 'Erreur ajout semis: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierSemis(Semis semis) async {
    try {
      await _firebaseService.updateSemis(semis);
      
      // Mise à jour optimiste locale
      final key = semis.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      _semisMap[key] = semis;
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur modification semis: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerSemis(String key) async {
    try {
      await _firebaseService.deleteSemis(key);
      
      // Suppression optimiste locale
      _semisMap.remove(key);
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur suppression semis: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes pour les variétés
  Future<void> ajouterVariete(Variete variete) async {
    try {
      final key = await _firebaseService.insertVariete(variete);
      variete.id = int.tryParse(key) ?? 0;
      
      // Mise à jour optimiste locale
      _varietesMap[key] = variete;
      notifyListeners();
      
      print('✅ FirebaseProvider V3: Variete added with key: $key');
      
    } catch (e) {
      _error = 'Erreur ajout variété: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierVariete(Variete variete) async {
    try {
      await _firebaseService.updateVariete(variete);
      
      // Mise à jour optimiste locale
      final key = variete.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
      _varietesMap[key] = variete;
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur modification variété: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerVariete(String key) async {
    try {
      await _firebaseService.deleteVariete(key);
      
      // Suppression optimiste locale
      _varietesMap.remove(key);
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur suppression variété: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes utilitaires
  Future<void> deleteAllData() async {
    try {
      await _firebaseService.deleteAllData();
      
      // Nettoyage local
      _parcellesMap.clear();
      _cellulesMap.clear();
      _chargementsMap.clear();
      _semisMap.clear();
      _varietesMap.clear();
      notifyListeners();
      
    } catch (e) {
      _error = 'Erreur suppression données: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      await _firebaseService.importData(data);
    } catch (e) {
      _error = 'Erreur import données: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      return await _firebaseService.exportData();
    } catch (e) {
      _error = 'Erreur export données: $e';
      notifyListeners();
      rethrow;
    }
  }

  Variete? getVarieteForParcelle(int? parcelleId) {
    if (parcelleId == null) return null;

    final semis = _semisMap.values.where((s) => s.parcelleId == parcelleId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

    if (semis.isEmpty) return null;

    final dernierSemis = semis.first;
    return _varietesMap.values.firstWhere(
      (v) => v.nom == dernierSemis.varietes.first,
      orElse: () => Variete(
        nom: 'Inconnue',
        dateCreation: DateTime.now(),
      ),
    );
  }

  // Méthode pour mettre à jour tous les poids aux normes
  Future<void> updateAllChargementsPoidsNormes() async {
    try {
      print('FirebaseProvider V3: Updating all chargements poids normes...');
      // Cette méthode n'est pas nécessaire pour le provider V3
      // car les calculs sont faits automatiquement lors de l'ajout/modification
      print('✅ FirebaseProvider V3: Poids normes already calculated automatically');
    } catch (e) {
      _error = 'Erreur mise à jour poids normes: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Nettoyer les ressources
  @override
  // Forcer le refresh de toutes les données
  Future<void> refreshAllData() async {
    try {
      print('🔄 FirebaseProviderV3: Forcing data refresh...');
      
      // Vider les maps locales
      _parcellesMap.clear();
      _cellulesMap.clear();
      _chargementsMap.clear();
      _semisMap.clear();
      _varietesMap.clear();
      
      // Notifier les listeners que les données ont changé
      notifyListeners();
      
      // Attendre un peu pour que les streams se mettent à jour
      await Future.delayed(const Duration(milliseconds: 200));
      
      print('✅ FirebaseProviderV3: Data refresh completed');
    } catch (e) {
      print('❌ FirebaseProviderV3: Error during data refresh: $e');
      _error = 'Erreur lors du refresh des données: $e';
      notifyListeners();
    }
  }

  void dispose() {
    _parcellesSubscription?.cancel();
    _cellulesSubscription?.cancel();
    _chargementsSubscription?.cancel();
    _semisSubscription?.cancel();
    _varietesSubscription?.cancel();
    super.dispose();
  }
}
