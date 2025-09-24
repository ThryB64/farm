#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart fix_current_database.dart <input_file> <output_file>');
    exit(1);
  }

  final inputPath = args[0];
  final outputPath = args[1];
  
  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    print('❌ Fichier d\'entrée non trouvé: $inputPath');
    exit(1);
  }

  try {
    print('🔧 CORRECTION DE LA BASE DE DONNÉES ACTUELLE');
    print('============================================');
    
    final content = inputFile.readAsStringSync();
    final data = jsonDecode(content) as Map<String, dynamic>;
    
    // 1. Analyser les parcelles
    final parcelles = data['parcelles'] as List;
    print('📊 Parcelles trouvées: ${parcelles.length}');
    
    // Créer un map des parcelles pour la correspondance
    final Map<String, String> parcelleIdMap = {};
    for (final parcelle in parcelles) {
      final p = parcelle as Map<String, dynamic>;
      final firebaseId = p['firebaseId']?.toString() ?? '';
      if (firebaseId.isNotEmpty) {
        parcelleIdMap[firebaseId] = firebaseId;
      }
    }
    
    // 2. Analyser les cellules
    final cellules = data['cellules'] as List;
    print('🏠 Cellules trouvées: ${cellules.length}');
    
    // Créer un map des cellules pour la correspondance
    final Map<String, String> celluleIdMap = {};
    for (final cellule in cellules) {
      final c = cellule as Map<String, dynamic>;
      final firebaseId = c['firebaseId']?.toString() ?? '';
      if (firebaseId.isNotEmpty) {
        celluleIdMap[firebaseId] = firebaseId;
      }
    }
    
    // 3. Corriger les chargements
    final chargements = data['chargements'] as List;
    print('📦 Chargements trouvés: ${chargements.length}');
    
    int liensCorriges = 0;
    for (final chargement in chargements) {
      final c = chargement as Map<String, dynamic>;
      
      // Corriger les liens de cellule
      final celluleId = c['cellule_id']?.toString() ?? '';
      if (celluleId.isNotEmpty) {
        c['celluleId'] = celluleId;
        liensCorriges++;
      }
      
      // Corriger les liens de parcelle
      final parcelleId = c['parcelle_id']?.toString() ?? '';
      if (parcelleId.isNotEmpty) {
        c['parcelleId'] = parcelleId;
        liensCorriges++;
      }
    }
    
    // 4. Corriger les semis
    final semis = data['semis'] as List? ?? [];
    print('🌱 Semis trouvés: ${semis.length}');
    
    for (final semisItem in semis) {
      final s = semisItem as Map<String, dynamic>;
      
      // Corriger les liens de parcelle
      final parcelleId = s['parcelle_id']?.toString() ?? '';
      if (parcelleId.isNotEmpty) {
        s['parcelleId'] = parcelleId;
        liensCorriges++;
      }
    }
    
    // 5. Corriger les ventes
    final ventes = data['ventes'] as List? ?? [];
    print('💰 Ventes trouvées: ${ventes.length}');
    
    for (final vente in ventes) {
      final v = vente as Map<String, dynamic>;
      
      // Corriger les liens de parcelle
      final parcelleId = v['parcelle_id']?.toString() ?? '';
      if (parcelleId.isNotEmpty) {
        v['parcelleId'] = parcelleId;
        liensCorriges++;
      }
    }
    
    // 6. Corriger les traitements
    final traitements = data['traitements'] as List? ?? [];
    print('🧪 Traitements trouvés: ${traitements.length}');
    
    for (final traitement in traitements) {
      final t = traitement as Map<String, dynamic>;
      
      // Corriger les liens de parcelle
      final parcelleId = t['parcelle_id']?.toString() ?? '';
      if (parcelleId.isNotEmpty) {
        t['parcelleId'] = parcelleId;
        liensCorriges++;
      }
    }
    
    // 7. Vérifier l'intégrité des liens
    print('\n🔍 VÉRIFICATION DE L\'INTÉGRITÉ DES LIENS');
    print('==========================================');
    
    int liensValides = 0;
    int liensInvalides = 0;
    
    for (final chargement in chargements) {
      final c = chargement as Map<String, dynamic>;
      final celluleId = c['celluleId']?.toString() ?? c['cellule_id']?.toString() ?? '';
      final parcelleId = c['parcelleId']?.toString() ?? c['parcelle_id']?.toString() ?? '';
      
      final celluleExiste = celluleIdMap.containsKey(celluleId);
      final parcelleExiste = parcelleIdMap.containsKey(parcelleId);
      
      if (celluleExiste && parcelleExiste) {
        liensValides++;
      } else {
        liensInvalides++;
        print('❌ Lien invalide: CelluleId=$celluleId, ParcelleId=$parcelleId');
      }
    }
    
    // 8. Sauvegarder le fichier corrigé
    final outputFile = File(outputPath);
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    outputFile.writeAsStringSync(jsonString);
    
    print('\n✅ CORRECTION TERMINÉE');
    print('======================');
    print('Liens corrigés: $liensCorriges');
    print('Liens valides: $liensValides');
    print('Liens invalides: $liensInvalides');
    print('Fichier de sortie: $outputPath');
    print('Taille: ${(outputFile.lengthSync() / 1024).toStringAsFixed(2)} KB');
    
    if (liensInvalides > 0) {
      print('\n⚠️  ATTENTION: $liensInvalides liens invalides détectés');
      print('Vérifiez que les IDs des cellules et parcelles correspondent');
    } else {
      print('\n🎉 Tous les liens sont valides !');
    }
    
    print('\n🎯 PROCHAINES ÉTAPES');
    print('====================');
    print('1. Importer le fichier corrigé dans votre application');
    print('2. Vérifier que tous les liens fonctionnent correctement');
    print('3. Tester l\'affichage des données liées');
    
  } catch (e) {
    print('❌ Erreur lors de la correction: $e');
    exit(1);
  }
}
