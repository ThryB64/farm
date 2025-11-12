import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Script pour associer un utilisateur à une ferme dans Firebase
/// 
/// Usage: dart run tool/associer_utilisateur_ferme.dart <UID_UTILISATEUR> [FARM_ID]
/// 
/// Exemple:
///   dart run tool/associer_utilisateur_ferme.dart C6PPci3ca3TarM6SDMqli7mk2uh1
///   dart run tool/associer_utilisateur_ferme.dart C6PPci3ca3TarM6SDMqli7mk2uh1 agricorn_demo

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Erreur: UID utilisateur requis');
    print('\nUsage: dart run tool/associer_utilisateur_ferme.dart <UID_UTILISATEUR> [FARM_ID]');
    print('\nExemple:');
    print('  dart run tool/associer_utilisateur_ferme.dart C6PPci3ca3TarM6SDMqli7mk2uh1');
    print('  dart run tool/associer_utilisateur_ferme.dart C6PPci3ca3TarM6SDMqli7mk2uh1 agricorn_demo');
    exit(1);
  }

  final String uid = args[0];
  final String farmId = args.length > 1 ? args[1] : 'agricorn_demo';

  print('🔗 Association de l\'utilisateur à la ferme...\n');
  print('UID: $uid');
  print('Farm ID: $farmId\n');

  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBCXUTiXNwvqsHMvct9917i0LbXg8Rej9A',
        appId: '1:616599452364:web:2523a247431044dcb8e069',
        messagingSenderId: '616599452364',
        projectId: 'farmgaec',
        authDomain: 'farmgaec.firebaseapp.com',
        storageBucket: 'farmgaec.firebasestorage.app',
        measurementId: 'G-L2B24EG6TJ',
        databaseURL: 'https://farmgaec-default-rtdb.firebaseio.com',
      ),
    );
    print('✅ Firebase initialisé\n');

    final database = FirebaseDatabase.instance;
    final db = database.ref();

    // 1. Vérifier si la ferme existe, sinon la créer
    print('📦 Vérification de la ferme $farmId...');
    final farmRef = db.child('farms/$farmId');
    final farmSnapshot = await farmRef.get();
    
    if (!farmSnapshot.exists) {
      print('⚠️  La ferme $farmId n\'existe pas. Création...');
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
        'name': 'Ferme $farmId',
      });
      print('✅ Ferme $farmId créée\n');
    } else {
      print('✅ Ferme $farmId existe déjà\n');
    }

    // 2. Associer l'utilisateur à la ferme
    print('🔗 Association utilisateur -> ferme...');
    await db.child('userFarms/$uid').set({
      'farmId': farmId,
      'assignedAt': DateTime.now().millisecondsSinceEpoch,
    });
    print('✅ userFarms/$uid/farmId = $farmId\n');

    // 3. Ajouter l'utilisateur comme membre de la ferme (nouvelle structure)
    print('👥 Ajout de l\'utilisateur comme membre de la ferme...');
    
    // Récupérer l'email de l'utilisateur depuis Authentication
    // Note: Pour un script standalone, on ne peut pas récupérer l'email automatiquement
    // Il faudra le passer en paramètre ou le récupérer depuis Firebase Auth
    final userEmail = args.length > 2 ? args[2] : 'user@example.com';
    
    await db.child('farms/$farmId/membres/$uid').set({
      'email': userEmail,
      'role': 'member',
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
    print('✅ farms/$farmId/membres/$uid créé\n');

    // 4. Vérification finale
    print('🔍 Vérification finale...');
    final userFarmCheck = await db.child('userFarms/$uid/farmId').get();
    final farmMemberCheck = await db.child('farms/$farmId/membres/$uid').get();

    if (userFarmCheck.exists && farmMemberCheck.exists) {
      print('✅ Toutes les associations sont correctes!\n');
      print('📋 Résumé:');
      print('   - Utilisateur $uid');
      print('   - Email: $userEmail');
      print('   - Associé à la ferme: $farmId');
      print('   - Membre de la ferme: ✅\n');
      print('🎉 L\'utilisateur peut maintenant se connecter et accéder aux données de la ferme!\n');
    } else {
      print('⚠️  Certaines associations n\'ont pas été créées correctement');
      exit(1);
    }

    exit(0);
  } catch (e, stackTrace) {
    print('❌ Erreur lors de l\'association: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

