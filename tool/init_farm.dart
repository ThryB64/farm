import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../lib/firebase_options.dart' as firebase_options;

/// Script pour initialiser la ferme agricorn_demo dans Firebase
/// 
/// Usage: dart run tool/init_farm.dart
/// 
/// Ce script crée:
/// - La structure vide de la ferme agricorn_demo
/// - Le mapping utilisateur -> ferme (à compléter manuellement)
/// 
/// Après exécution, vous devrez:
/// 1. Créer un utilisateur dans Firebase Authentication
/// 2. Ajouter userFarms/{uid}/farmId = "agricorn_demo" dans Firebase Database
/// 3. Ajouter farmMembers/agricorn_demo/{uid} = true dans Firebase Database
/// 4. Ajouter allowedUsers/{uid} = true dans Firebase Database

Future<void> main() async {
  print('🚀 Initialisation de la ferme agricorn_demo...\n');
  
  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: firebase_options.DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé\n');
    
    final database = FirebaseDatabase.instance;
    final db = database.ref();
    
    const String farmId = 'agricorn_demo';
    
    // Créer la structure vide de la ferme
    print('📦 Création de la structure de la ferme $farmId...');
    
    final farmRef = db.child('farms/$farmId');
    
    // Vérifier si la ferme existe déjà
    final snapshot = await farmRef.get();
    if (snapshot.exists) {
      print('⚠️  La ferme $farmId existe déjà. Suppression...');
      await farmRef.remove();
      print('✅ Ferme supprimée\n');
    }
    
    // Créer la structure vide
    await farmRef.set({
      'parcelles': {},
      'cellules': {},
      'chargements': {},
      'semis': {},
      'varietes': {},
      'traitements': {},
      'ventes': {},
      'produits': {},
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'name': 'AgriCorn Demo',
    });
    
    print('✅ Structure de la ferme $farmId créée avec succès\n');
    
    // Afficher les instructions pour l'utilisateur
    print('📋 PROCHAINES ÉTAPES:\n');
    print('1. Créez un utilisateur dans Firebase Authentication');
    print('2. Dans Firebase Realtime Database, ajoutez:');
    print('   - userFarms/{uid}/farmId = "$farmId"');
    print('   - farmMembers/$farmId/{uid} = true');
    print('   - allowedUsers/{uid} = true');
    print('\n3. L\'utilisateur pourra alors se connecter et accéder uniquement à cette ferme.\n');
    
    print('✅ Initialisation terminée!\n');
    
    exit(0);
  } catch (e, stackTrace) {
    print('❌ Erreur lors de l\'initialisation: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

