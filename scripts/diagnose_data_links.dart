#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart diagnose_data_links.dart <path_to_json_file>');
    exit(1);
  }

  final filePath = args[0];
  final file = File(filePath);
  
  if (!file.existsSync()) {
    print('❌ Fichier non trouvé: $filePath');
    exit(1);
  }

  try {
    final content = file.readAsStringSync();
    final data = jsonDecode(content) as Map<String, dynamic>;
    
    print('🔍 DIAGNOSTIC DES LIENS DE DONNÉES');
    print('=====================================');
    
    // Analyser les parcelles
    final parcelles = data['parcelles'] as List? ?? [];
    print('\n📊 PARCELLES (${parcelles.length})');
    for (int i = 0; i < parcelles.length && i < 5; i++) {
      final p = parcelles[i] as Map<String, dynamic>;
      print('  ${i + 1}. ID: ${p['id']}, FirebaseId: ${p['firebaseId']}, Nom: ${p['nom']}');
    }
    
    // Analyser les cellules
    final cellules = data['cellules'] as List? ?? [];
    print('\n🏠 CELLULES (${cellules.length})');
    for (int i = 0; i < cellules.length && i < 5; i++) {
      final c = cellules[i] as Map<String, dynamic>;
      print('  ${i + 1}. ID: ${c['id']}, FirebaseId: ${c['firebaseId']}, Ref: ${c['reference']}');
    }
    
    // Analyser les chargements et leurs liens
    final chargements = data['chargements'] as List? ?? [];
    print('\n📦 CHARGEMENTS (${chargements.length})');
    
    int liensCorrects = 0;
    int liensIncorrects = 0;
    Set<String> cellulesUtilisees = {};
    Set<String> parcellesUtilisees = {};
    
    for (int i = 0; i < chargements.length && i < 10; i++) {
      final c = chargements[i] as Map<String, dynamic>;
      final celluleId = c['celluleId'] ?? c['cellule_id'] ?? '';
      final parcelleId = c['parcelleId'] ?? c['parcelle_id'] ?? '';
      
      print('  ${i + 1}. Chargement: ${c['id']}');
      print('     - CelluleId: $celluleId');
      print('     - ParcelleId: $parcelleId');
      
      // Vérifier si les liens existent
      final celluleExiste = cellules.any((cell) => 
        (cell['id'] == celluleId) || (cell['firebaseId'] == celluleId));
      final parcelleExiste = parcelles.any((parc) => 
        (parc['id'] == parcelleId) || (parc['firebaseId'] == parcelleId));
      
      if (celluleExiste && parcelleExiste) {
        liensCorrects++;
        cellulesUtilisees.add(celluleId);
        parcellesUtilisees.add(parcelleId);
        print('     ✅ Liens corrects');
      } else {
        liensIncorrects++;
        print('     ❌ Liens incorrects');
        if (!celluleExiste) print('       - Cellule non trouvée');
        if (!parcelleExiste) print('       - Parcelle non trouvée');
      }
    }
    
    print('\n📈 RÉSUMÉ DES LIENS');
    print('==================');
    print('Liens corrects: $liensCorrects');
    print('Liens incorrects: $liensIncorrects');
    print('Cellules utilisées: ${cellulesUtilisees.length}');
    print('Parcelles utilisées: ${parcellesUtilisees.length}');
    
    // Vérifier les formats de clés
    print('\n🔑 ANALYSE DES FORMATS DE CLÉS');
    print('==============================');
    
    if (chargements.isNotEmpty) {
      final premierChargement = chargements.first as Map<String, dynamic>;
      final cles = premierChargement.keys.toList();
      
      bool aCelluleId = cles.contains('celluleId');
      bool aCellule_id = cles.contains('cellule_id');
      bool aParcelleId = cles.contains('parcelleId');
      bool aParcelle_id = cles.contains('parcelle_id');
      
      print('Format camelCase (celluleId/parcelleId): ${aCelluleId && aParcelleId}');
      print('Format snake_case (cellule_id/parcelle_id): ${aCellule_id && aParcelle_id}');
      print('Format mixte: ${(aCelluleId || aCellule_id) && (aParcelleId || aParcelle_id)}');
      
      if (aCelluleId && aParcelleId) {
        print('✅ Format moderne (camelCase) détecté');
      } else if (aCellule_id && aParcelle_id) {
        print('⚠️  Format ancien (snake_case) détecté');
      } else {
        print('❌ Format incohérent détecté');
      }
    }
    
    print('\n🎯 RECOMMANDATIONS');
    print('==================');
    if (liensIncorrects > 0) {
      print('❌ Des liens sont cassés. Vérifiez que:');
      print('   1. Les IDs des cellules et parcelles correspondent');
      print('   2. Les formats de clés sont cohérents');
      print('   3. L\'ordre d\'importation est correct (parcelles → cellules → chargements)');
    } else {
      print('✅ Tous les liens semblent corrects !');
    }
    
  } catch (e) {
    print('❌ Erreur lors de l\'analyse: $e');
    exit(1);
  }
}
