import 'package:firebase_database/firebase_database.dart';
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

/// Service pour initialiser la ferme de démonstration avec des données de présentation
class DemoFarmInitializer {
  final DatabaseReference _demoFarmRef;
  
  DemoFarmInitializer() : _demoFarmRef = FirebaseDatabase.instance.ref('farms/agricorn_demo');
  
  /// Initialise toutes les données de démonstration
  Future<void> initializeDemoFarm() async {
    print('DemoFarmInitializer: Début de l\'initialisation de la ferme de démo...');
    
    try {
      // Vérifier si la ferme existe déjà
      final snapshot = await _demoFarmRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map;
        if (data.containsKey('parcelles') && (data['parcelles'] as Map).isNotEmpty) {
          print('DemoFarmInitializer: La ferme de démo contient déjà des données. Ignoré.');
          return;
        }
      }
      
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
      await _createVentes();
      
      print('✅ DemoFarmInitializer: Ferme de démonstration initialisée avec succès');
    } catch (e) {
      print('❌ DemoFarmInitializer: Erreur lors de l\'initialisation: $e');
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
      final key = 'variete_${variete.nom.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
      await _demoFarmRef.child('varietes').child(key).set({
        ...variete.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
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
      final key = 'parcelle_${parcelle.nom.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${(parcelle.surface * 100).round()}';
      await _demoFarmRef.child('parcelles').child(key).set({
        ...parcelle.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
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
      final key = 'cellule_${cellule.reference}';
      await _demoFarmRef.child('cellules').child(key).set({
        ...cellule.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
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
      final date = semisItem.date.toIso8601String().split('T')[0];
      final key = 'semis_${semisItem.parcelleId}_$date';
      await _demoFarmRef.child('semis').child(key).set({
        ...semisItem.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
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
      final date = chargement.dateChargement.toIso8601String().split('T')[0];
      final remorque = chargement.remorque.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final key = 'chargement_${date}_${remorque}_${chargement.poidsPlein}_${chargement.poidsVide}_$timestamp';
      await _demoFarmRef.child('chargements').child(key).set({
        ...chargement.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
    }
  }
  
  Future<List<Produit>> _createProduits() async {
    final produits = [
      Produit(
        nom: 'Herbicide Sélectif',
        mesure: 'L',
        prixParAnnee: {
          2024: 45.0,
        },
        notes: 'Herbicide pour traitement précoce',
      ),
      Produit(
        nom: 'Fongicide Systémique',
        mesure: 'L',
        prixParAnnee: {
          2024: 52.0,
        },
        notes: 'Fongicide pour protection des cultures',
      ),
      Produit(
        nom: 'Insecticide Large Spectre',
        mesure: 'L',
        prixParAnnee: {
          2024: 38.0,
        },
        notes: 'Insecticide polyvalent',
      ),
    ];
    
    final createdProduits = <Produit>[];
    for (final produit in produits) {
      final ref = _demoFarmRef.child('produits').push();
      final key = ref.key!;
      await ref.set({
        ...produit.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
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
            nomProduit: produits[0].nom,
            quantite: 2.5,
            mesure: 'L',
            prixUnitaire: produits[0].getPrixPourAnnee(2024),
            coutTotal: 2.5 * produits[0].getPrixPourAnnee(2024),
            date: DateTime(2024, 5, 10),
          ),
        ],
        coutTotal: 2.5 * produits[0].getPrixPourAnnee(2024),
      ),
      Traitement(
        parcelleId: parcelles[1].firebaseId ?? parcelles[1].id.toString(),
        annee: 2024,
        date: DateTime(2024, 6, 15),
        produits: [
          ProduitTraitement(
            produitId: produits[1].firebaseId ?? produits[1].id.toString(),
            nomProduit: produits[1].nom,
            quantite: 1.8,
            mesure: 'L',
            prixUnitaire: produits[1].getPrixPourAnnee(2024),
            coutTotal: 1.8 * produits[1].getPrixPourAnnee(2024),
            date: DateTime(2024, 6, 15),
          ),
        ],
        coutTotal: 1.8 * produits[1].getPrixPourAnnee(2024),
      ),
    ];
    
    for (final traitement in traitements) {
      final ref = _demoFarmRef.child('traitements').push();
      await ref.set({
        ...traitement.toMap(),
        'firebaseId': ref.key,
        'createdAt': ServerValue.timestamp,
      });
    }
  }
  
  Future<void> _createVentes() async {
    final ventes = [
      Vente(
        numeroTicket: 'TKT-2024-001',
        client: 'Coopérative Agricole Sud',
        date: DateTime(2024, 10, 5),
        annee: 2024,
        immatriculationRemorque: 'AB-123-CD',
        cmr: 'CMR-001',
        poidsVide: 5000.0,
        poidsPlein: 20000.0,
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
        immatriculationRemorque: 'EF-456-GH',
        cmr: 'CMR-002',
        poidsVide: 5000.0,
        poidsPlein: 17000.0,
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
        immatriculationRemorque: 'IJ-789-KL',
        cmr: 'CMR-003',
        poidsVide: 5000.0,
        poidsPlein: 23000.0,
        poidsNet: 18000.0,
        prix: 5400.0,
        payer: true,
        terminee: true,
      ),
    ];
    
    for (final vente in ventes) {
      final date = vente.date.toIso8601String().split('T')[0];
      final ticket = vente.numeroTicket.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final key = 'v_${date}_$ticket';
      await _demoFarmRef.child('ventes').child(key).set({
        ...vente.toMap(),
        'firebaseId': key,
        'createdAt': ServerValue.timestamp,
      });
    }
  }
}

