import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../services/hybrid_database_service.dart';
import '../utils/poids_utils.dart';

class FirebaseProvider with ChangeNotifier {
  final HybridDatabaseService _databaseService = HybridDatabaseService();
  
  List<Parcelle> _parcelles = [];
  List<Cellule> _cellules = [];
  List<Chargement> _chargements = [];
  List<Semis> _semis = [];
  List<Variete> _varietes = [];
  
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // Streams pour la synchronisation temps réel
  StreamSubscription<List<Parcelle>>? _parcellesSubscription;
  StreamSubscription<List<Cellule>>? _cellulesSubscription;
  StreamSubscription<List<Chargement>>? _chargementsSubscription;
  StreamSubscription<List<Semis>>? _semisSubscription;
  StreamSubscription<List<Variete>>? _varietesSubscription;

  // Getters
  List<Parcelle> get parcelles => _parcelles;
  List<Cellule> get cellules => _cellules;
  List<Chargement> get chargements => _chargements;
  List<Semis> get semis => _semis;
  List<Variete> get varietes => _varietes;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialiser Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier si l'utilisateur est déjà connecté
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Connexion anonyme seulement si pas déjà connecté
        await FirebaseAuth.instance.signInAnonymously();
        print('Firebase Auth: Anonymous sign-in successful');
      } else {
        print('Firebase Auth: User already signed in: ${currentUser.uid}');
      }
      
      await _databaseService.initialize();
      await _setupRealtimeListeners();
      _isInitialized = true;
      print('Firebase Provider initialized successfully');
    } catch (e) {
      _error = 'Erreur d\'initialisation Firebase: $e';
      print('Firebase Provider initialization error: $e');
      // Continuer même en cas d'erreur d'auth pour permettre l'utilisation hors ligne
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Configurer les listeners temps réel
  Future<void> _setupRealtimeListeners() async {
    // Parcelles
    _parcellesSubscription = _databaseService.getParcellesStream().listen(
      (parcelles) {
        _parcelles = parcelles;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Erreur parcelles: $error';
        notifyListeners();
      },
    );

    // Cellules
    _cellulesSubscription = _databaseService.getCellulesStream().listen(
      (cellules) {
        _cellules = cellules;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Erreur cellules: $error';
        notifyListeners();
      },
    );

    // Chargements
    _chargementsSubscription = _databaseService.getChargementsStream().listen(
      (chargements) {
        _chargements = chargements;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Erreur chargements: $error';
        notifyListeners();
      },
    );

    // Semis
    _semisSubscription = _databaseService.getSemisStream().listen(
      (semis) {
        _semis = semis;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Erreur semis: $error';
        notifyListeners();
      },
    );

    // Variétés
    _varietesSubscription = _databaseService.getVarietesStream().listen(
      (varietes) {
        _varietes = varietes;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Erreur variétés: $error';
        notifyListeners();
      },
    );
  }

  // Statistiques
  Future<Map<String, dynamic>> getStats() async {
    try {
      // Calculer la surface totale
      final surfaceTotale = _parcelles.fold<double>(
        0,
        (sum, p) => sum + p.surface,
      );

      // Obtenir l'année la plus récente avec des chargements
      final derniereAnnee = _chargements.isEmpty
          ? DateTime.now().year
          : _chargements
              .map((c) => c.dateChargement.year)
              .reduce((a, b) => a > b ? a : b);

      final chargementsDerniereAnnee = _chargements.where(
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
      final firebaseId = await _databaseService.insertParcelle(parcelle);
      // Stocker l'ID Firebase comme string
      parcelle.firebaseId = firebaseId;
      // Générer un ID local pour la compatibilité
      parcelle.id = DateTime.now().millisecondsSinceEpoch;
      print('Parcelle ajoutée avec ID Firebase: $firebaseId (ID local: ${parcelle.id})');
    } catch (e) {
      _error = 'Erreur ajout parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierParcelle(Parcelle parcelle) async {
    try {
      await _databaseService.updateParcelle(parcelle);
    } catch (e) {
      _error = 'Erreur modification parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerParcelle(int id) async {
    try {
      await _databaseService.deleteParcelle(id.toString());
    } catch (e) {
      _error = 'Erreur suppression parcelle: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes pour les cellules
  Future<void> ajouterCellule(Cellule cellule) async {
    try {
      final id = await _databaseService.insertCellule(cellule);
      cellule.id = int.tryParse(id) ?? 0;
      print('Cellule ajoutée avec ID: ${cellule.id}');
    } catch (e) {
      _error = 'Erreur ajout cellule: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierCellule(Cellule cellule) async {
    try {
      await _databaseService.updateCellule(cellule);
    } catch (e) {
      _error = 'Erreur modification cellule: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerCellule(int id) async {
    try {
      await _databaseService.deleteCellule(id.toString());
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

      final id = await _databaseService.insertChargement(chargement);
      chargement.id = int.tryParse(id) ?? 0;
      print('Chargement ajouté avec ID: ${chargement.id}');
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

        await _databaseService.updateChargement(chargement);
      }
    } catch (e) {
      _error = 'Erreur modification chargement: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerChargement(int id) async {
    try {
      await _databaseService.deleteChargement(id.toString());
    } catch (e) {
      _error = 'Erreur suppression chargement: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes pour les semis
  Future<void> ajouterSemis(Semis semis) async {
    try {
      final id = await _databaseService.insertSemis(semis);
      semis.id = int.tryParse(id) ?? 0;
      print('Semis ajouté avec ID: ${semis.id}');
    } catch (e) {
      _error = 'Erreur ajout semis: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierSemis(Semis semis) async {
    try {
      await _databaseService.updateSemis(semis);
    } catch (e) {
      _error = 'Erreur modification semis: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerSemis(int id) async {
    try {
      await _databaseService.deleteSemis(id.toString());
    } catch (e) {
      _error = 'Erreur suppression semis: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes pour les variétés
  Future<void> ajouterVariete(Variete variete) async {
    try {
      final id = await _databaseService.insertVariete(variete);
      variete.id = int.tryParse(id) ?? 0;
      print('Variété ajoutée avec ID: ${variete.id}');
    } catch (e) {
      _error = 'Erreur ajout variété: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> modifierVariete(Variete variete) async {
    try {
      await _databaseService.updateVariete(variete);
    } catch (e) {
      _error = 'Erreur modification variété: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> supprimerVariete(int id) async {
    try {
      await _databaseService.deleteVariete(id.toString());
    } catch (e) {
      _error = 'Erreur suppression variété: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Méthodes utilitaires
  Future<void> deleteAllData() async {
    try {
      await _databaseService.deleteAllData();
    } catch (e) {
      _error = 'Erreur suppression données: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      await _databaseService.importData(data);
    } catch (e) {
      _error = 'Erreur import données: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      return await _databaseService.exportData();
    } catch (e) {
      _error = 'Erreur export données: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAllChargementsPoidsNormes() async {
    try {
      await _databaseService.updateAllChargementsPoidsNormes();
    } catch (e) {
      _error = 'Erreur mise à jour poids normes: $e';
      notifyListeners();
      rethrow;
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

  // Nettoyer les ressources
  @override
  void dispose() {
    _parcellesSubscription?.cancel();
    _cellulesSubscription?.cancel();
    _chargementsSubscription?.cancel();
    _semisSubscription?.cancel();
    _varietesSubscription?.cancel();
    super.dispose();
  }
}
