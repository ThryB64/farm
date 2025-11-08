import 'package:firebase_database/firebase_database.dart';

/// Service pour initialiser la ferme de démonstration (structure vide)
class DemoFarmInitializer {
  final DatabaseReference _demoFarmRef;
  
  DemoFarmInitializer() : _demoFarmRef = FirebaseDatabase.instance.ref('farms/agricorn_demo');
  
  /// Initialise la structure de la ferme de démonstration (vide)
  Future<void> initializeDemoFarm() async {
    print('DemoFarmInitializer: Début de l\'initialisation de la ferme de démo...');
    
    try {
      // Vérifier si la ferme existe déjà
      final snapshot = await _demoFarmRef.get();
      if (snapshot.exists && snapshot.value != null) {
        print('DemoFarmInitializer: La ferme de démo existe déjà. Ignoré.');
        return;
      }
      
      // Créer la structure vide de la ferme
      await _demoFarmRef.set({
        'parcelles': {},
        'cellules': {},
        'chargements': {},
        'semis': {},
        'varietes': {},
        'ventes': {},
        'traitements': {},
        'produits': {},
        'createdAt': ServerValue.timestamp,
      });
      
      print('✅ DemoFarmInitializer: Ferme de démonstration créée (vide)');
    } catch (e) {
      print('❌ DemoFarmInitializer: Erreur lors de l\'initialisation: $e');
      rethrow;
    }
  }
}
