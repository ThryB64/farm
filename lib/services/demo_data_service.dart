import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../models/vente.dart';
import '../models/traitement.dart';
import '../models/produit.dart';
import '../models/variete_surface.dart';
import '../models/produit_traitement.dart';
import 'firebase_service_v4.dart';

/// Service pour générer des données de démonstration
class DemoDataService {
  final FirebaseServiceV4 _firebaseService = FirebaseServiceV4();
  
  /// Génère et insère toutes les données de démonstration
  Future<void> generateDemoData() async {
    print('DemoDataService: Génération des données de démonstration...');
    
    try {
      // 1. Créer des variétés
      final varietes = await _createVarietes();
      
      // 2. Créer des parcelles
      final parcelles = await _createParcelles();
      
      // 3. Créer des cellules
      final cellules = await _createCellules();
      
      // 4. Créer des semis
      await _createSemis(parcelles, varietes);
      
      // 5. Créer des chargements
      await _createChargements(parcelles, cellules, varietes);
      
      // 6. Créer des produits
      final produits = await _createProduits();
      
      // 7. Créer des traitements
      await _createTraitements(parcelles, produits);
      
      // 8. Créer des ventes
      await _createVentes(varietes);
      
      print('✅ DemoDataService: Données de démonstration créées avec succès');
    } catch (e) {
      print('❌ DemoDataService: Erreur lors de la génération: $e');
      rethrow;
    }
  }
  
  Future<List<Variete>> _createVarietes() async {
    final varietes = [
      Variete(
        nom: 'DK 391',
        dateCreation: DateTime(2023, 1, 1),
        prixParAnnee: {
          2023: 280.0,
          2024: 285.0,
        },
      ),
      Variete(
        nom: 'Pioneer P1234',
        dateCreation: DateTime(2023, 1, 1),
        prixParAnnee: {
          2023: 275.0,
          2024: 280.0,
        },
      ),
      Variete(
        nom: 'LG 30.222',
        dateCreation: DateTime(2023, 1, 1),
        prixParAnnee: {
          2023: 270.0,
          2024: 275.0,
        },
      ),
    ];
    
    final createdVarietes = <Variete>[];
    for (final variete in varietes) {
      final key = await _firebaseService.insertVariete(variete);
      final varieteWithId = Variete(
        id: variete.id,
        firebaseId: key,
        nom: variete.nom,
        description: variete.description,
        dateCreation: variete.dateCreation,
        prixParAnnee: variete.prixParAnnee,
      );
      createdVarietes.add(varieteWithId);
    }
    
    return createdVarietes;
  }
  
  Future<List<Parcelle>> _createParcelles() async {
    final parcelles = [
      Parcelle(
        nom: 'Parcelle Nord',
        surface: 12.5,
        notes: 'Parcelle principale - Sol argileux',
        dateCreation: DateTime(2024, 1, 15),
      ),
      Parcelle(
        nom: 'Parcelle Sud',
        surface: 8.3,
        notes: 'Parcelle secondaire - Bon ensoleillement',
        dateCreation: DateTime(2024, 1, 20),
      ),
      Parcelle(
        nom: 'Parcelle Est',
        surface: 15.2,
        notes: 'Grande parcelle - Irrigation disponible',
        dateCreation: DateTime(2024, 2, 1),
      ),
    ];
    
    final createdParcelles = <Parcelle>[];
    for (final parcelle in parcelles) {
      final key = await _firebaseService.insertParcelle(parcelle);
      final parcelleWithId = Parcelle(
        id: parcelle.id,
        firebaseId: key,
        nom: parcelle.nom,
        surface: parcelle.surface,
        dateCreation: parcelle.dateCreation,
        notes: parcelle.notes,
      );
      createdParcelles.add(parcelleWithId);
    }
    
    return createdParcelles;
  }
  
  Future<List<Cellule>> _createCellules() async {
    final cellules = [
      Cellule(
        reference: 'C001',
        nom: 'Cellule Principale',
        dateCreation: DateTime(2024, 1, 10),
        notes: 'Cellule de stockage principale - Capacité 500T',
        fermee: false,
      ),
      Cellule(
        reference: 'C002',
        nom: 'Cellule Secondaire',
        dateCreation: DateTime(2024, 1, 12),
        notes: 'Cellule de stockage secondaire - Capacité 300T',
        fermee: false,
      ),
      Cellule(
        reference: 'C003',
        nom: 'Cellule Est',
        dateCreation: DateTime(2024, 1, 15),
        notes: 'Cellule de stockage Est - Capacité 400T',
        fermee: true,
      ),
    ];
    
    final createdCellules = <Cellule>[];
    for (final cellule in cellules) {
      final key = await _firebaseService.insertCellule(cellule);
      final celluleWithId = Cellule(
        id: cellule.id,
        firebaseId: key,
        reference: cellule.reference,
        dateCreation: cellule.dateCreation,
        notes: cellule.notes,
        nom: cellule.nom,
        fermee: cellule.fermee,
        quantiteGaz: cellule.quantiteGaz,
        prixGaz: cellule.prixGaz,
      );
      createdCellules.add(celluleWithId);
    }
    
    return createdCellules;
  }
  
  Future<void> _createSemis(List<Parcelle> parcelles, List<Variete> varietes) async {
    if (parcelles.isEmpty || varietes.isEmpty) return;
    
    final semis = [
      Semis(
        parcelleId: parcelles[0].firebaseId ?? parcelles[0].id.toString(),
        date: DateTime(2024, 4, 15),
        varietesSurfaces: [
          VarieteSurface(
            nom: varietes[0].nom,
            surface: 12.5,
          ),
        ],
      ),
      Semis(
        parcelleId: parcelles[1].firebaseId ?? parcelles[1].id.toString(),
        date: DateTime(2024, 4, 20),
        varietesSurfaces: [
          VarieteSurface(
            nom: varietes[1].nom,
            surface: 8.3,
          ),
        ],
      ),
      Semis(
        parcelleId: parcelles[2].firebaseId ?? parcelles[2].id.toString(),
        date: DateTime(2024, 4, 25),
        varietesSurfaces: [
          VarieteSurface(
            nom: varietes[2].nom,
            surface: 15.2,
          ),
        ],
      ),
    ];
    
    for (final semisItem in semis) {
      await _firebaseService.insertSemis(semisItem);
    }
  }
  
  Future<void> _createChargements(
    List<Parcelle> parcelles,
    List<Cellule> cellules,
    List<Variete> varietes,
  ) async {
    if (parcelles.isEmpty || cellules.isEmpty || varietes.isEmpty) return;
    
    final chargements = [
      Chargement(
        celluleId: cellules[0].firebaseId ?? cellules[0].id.toString(),
        parcelleId: parcelles[0].firebaseId ?? parcelles[0].id.toString(),
        remorque: 'REM-001',
        dateChargement: DateTime(2024, 9, 15),
        poidsPlein: 25000.0,
        poidsVide: 5000.0,
        poidsNet: 20000.0,
        poidsNormes: 18500.0,
        humidite: 18.5,
        variete: varietes[0].nom,
      ),
      Chargement(
        celluleId: cellules[0].firebaseId ?? cellules[0].id.toString(),
        parcelleId: parcelles[1].firebaseId ?? parcelles[1].id.toString(),
        remorque: 'REM-002',
        dateChargement: DateTime(2024, 9, 18),
        poidsPlein: 24000.0,
        poidsVide: 5000.0,
        poidsNet: 19000.0,
        poidsNormes: 17600.0,
        humidite: 17.8,
        variete: varietes[1].nom,
      ),
      Chargement(
        celluleId: cellules[1].firebaseId ?? cellules[1].id.toString(),
        parcelleId: parcelles[2].firebaseId ?? parcelles[2].id.toString(),
        remorque: 'REM-003',
        dateChargement: DateTime(2024, 9, 22),
        poidsPlein: 26000.0,
        poidsVide: 5000.0,
        poidsNet: 21000.0,
        poidsNormes: 19500.0,
        humidite: 19.2,
        variete: varietes[2].nom,
      ),
    ];
    
    for (final chargement in chargements) {
      await _firebaseService.insertChargement(chargement);
    }
  }
  
  Future<List<Produit>> _createProduits() async {
    final produits = [
      Produit(
        nom: 'Herbicide Sélectif',
        type: 'Herbicide',
        dateCreation: DateTime(2024, 1, 1),
      ),
      Produit(
        nom: 'Fongicide Systémique',
        type: 'Fongicide',
        dateCreation: DateTime(2024, 1, 1),
      ),
      Produit(
        nom: 'Insecticide Large Spectre',
        type: 'Insecticide',
        dateCreation: DateTime(2024, 1, 1),
      ),
    ];
    
    final createdProduits = <Produit>[];
    for (final produit in produits) {
      final key = await _firebaseService.ajouterProduit(produit);
      createdProduits.add(produit.copyWith(firebaseId: key));
    }
    
    return createdProduits;
  }
  
  Future<void> _createTraitements(
    List<Parcelle> parcelles,
    List<Produit> produits,
  ) async {
    if (parcelles.isEmpty || produits.isEmpty) return;
    
    final traitements = [
      Traitement(
        parcelleId: parcelles[0].firebaseId ?? parcelles[0].id.toString(),
        annee: 2024,
        date: DateTime(2024, 5, 10),
        produits: [
          ProduitTraitement(
            produitId: produits[0].firebaseId ?? produits[0].id.toString(),
            quantite: 2.5,
            unite: 'L',
          ),
        ],
        coutTotal: 125.0,
      ),
      Traitement(
        parcelleId: parcelles[1].firebaseId ?? parcelles[1].id.toString(),
        annee: 2024,
        date: DateTime(2024, 6, 15),
        produits: [
          ProduitTraitement(
            produitId: produits[1].firebaseId ?? produits[1].id.toString(),
            quantite: 1.8,
            unite: 'L',
          ),
        ],
        coutTotal: 95.0,
      ),
    ];
    
    for (final traitement in traitements) {
      await _firebaseService.ajouterTraitement(traitement);
    }
  }
  
  Future<void> _createVentes(List<Variete> varietes) async {
    if (varietes.isEmpty) return;
    
    final ventes = [
      Vente(
        numeroTicket: 'TKT-2024-001',
        client: 'Coopérative Agricole Sud',
        date: DateTime(2024, 10, 5),
        annee: 2024,
        poidsNet: 15000.0,
        prix: 4200.0,
        payer: true,
        terminee: true,
      ),
      Vente(
        numeroTicket: 'TKT-2024-002',
        client: 'Négociant Maïs Premium',
        date: DateTime(2024, 10, 12),
        annee: 2024,
        poidsNet: 12000.0,
        prix: 3600.0,
        payer: false,
        terminee: false,
      ),
      Vente(
        numeroTicket: 'TKT-2024-003',
        client: 'Coopérative Agricole Sud',
        date: DateTime(2024, 10, 20),
        annee: 2024,
        poidsNet: 18000.0,
        prix: 5400.0,
        payer: true,
        terminee: true,
      ),
    ];
    
    for (final vente in ventes) {
      await _firebaseService.insertVente(vente);
    }
  }
}

