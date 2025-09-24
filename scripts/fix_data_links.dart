#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart fix_data_links.dart <input_file> <output_file>');
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
    print('🔧 RÉPARATION DES LIENS DE DONNÉES');
    print('==================================');
    
    final content = inputFile.readAsStringSync();
    final data = jsonDecode(content) as Map<String, dynamic>;
    
    // Créer des maps pour la correspondance des IDs
    final Map<String, String> parcelleIdMap = {};
    final Map<String, String> celluleIdMap = {};
    
    // 1. Traiter les parcelles
    final parcelles = data['parcelles'] as List;
    print('📊 Traitement de ${parcelles.length} parcelles...');
    
    for (final parcelle in parcelles) {
      final p = parcelle as Map<String, dynamic>;
      final id = p['id']?.toString() ?? '';
      final firebaseId = p['firebaseId']?.toString() ?? id;
      
      // Normaliser l'ID
      final normalizedId = firebaseId.isNotEmpty ? firebaseId : id;
      parcelleIdMap[id] = normalizedId;
      parcelleIdMap[firebaseId] = normalizedId;
      
      // Mettre à jour l'objet
      p['id'] = normalizedId;
      p['firebaseId'] = normalizedId;
    }
    
    // 2. Traiter les cellules
    final cellules = data['cellules'] as List;
    print('🏠 Traitement de ${cellules.length} cellules...');
    
    for (final cellule in cellules) {
      final c = cellule as Map<String, dynamic>;
      final id = c['id']?.toString() ?? '';
      final firebaseId = c['firebaseId']?.toString() ?? id;
      
      // Normaliser l'ID
      final normalizedId = firebaseId.isNotEmpty ? firebaseId : id;
      celluleIdMap[id] = normalizedId;
      celluleIdMap[firebaseId] = normalizedId;
      
      // Mettre à jour l'objet
      c['id'] = normalizedId;
      c['firebaseId'] = normalizedId;
    }
    
    // 3. Traiter les chargements
    final chargements = data['chargements'] as List;
    print('📦 Traitement de ${chargements.length} chargements...');
    
    int liensRepares = 0;
    for (final chargement in chargements) {
      final c = chargement as Map<String, dynamic>;
      
      // Réparer les liens de cellule
      final celluleId = c['celluleId']?.toString() ?? c['cellule_id']?.toString() ?? '';
      if (celluleId.isNotEmpty && celluleIdMap.containsKey(celluleId)) {
        final normalizedCelluleId = celluleIdMap[celluleId]!;
        c['celluleId'] = normalizedCelluleId;
        c['cellule_id'] = normalizedCelluleId;
        liensRepares++;
      }
      
      // Réparer les liens de parcelle
      final parcelleId = c['parcelleId']?.toString() ?? c['parcelle_id']?.toString() ?? '';
      if (parcelleId.isNotEmpty && parcelleIdMap.containsKey(parcelleId)) {
        final normalizedParcelleId = parcelleIdMap[parcelleId]!;
        c['parcelleId'] = normalizedParcelleId;
        c['parcelle_id'] = normalizedParcelleId;
        liensRepares++;
      }
    }
    
    // 4. Traiter les semis
    final semis = data['semis'] as List;
    print('🌱 Traitement de ${semis.length} semis...');
    
    for (final semisItem in semis) {
      final s = semisItem as Map<String, dynamic>;
      
      // Réparer les liens de parcelle
      final parcelleId = s['parcelleId']?.toString() ?? s['parcelle_id']?.toString() ?? '';
      if (parcelleId.isNotEmpty && parcelleIdMap.containsKey(parcelleId)) {
        final normalizedParcelleId = parcelleIdMap[parcelleId]!;
        s['parcelleId'] = normalizedParcelleId;
        s['parcelle_id'] = normalizedParcelleId;
      }
    }
    
    // 5. Traiter les ventes
    final ventes = data['ventes'] as List? ?? [];
    print('💰 Traitement de ${ventes.length} ventes...');
    
    for (final vente in ventes) {
      final v = vente as Map<String, dynamic>;
      
      // Réparer les liens de parcelle
      final parcelleId = v['parcelleId']?.toString() ?? v['parcelle_id']?.toString() ?? '';
      if (parcelleId.isNotEmpty && parcelleIdMap.containsKey(parcelleId)) {
        final normalizedParcelleId = parcelleIdMap[parcelleId]!;
        v['parcelleId'] = normalizedParcelleId;
        v['parcelle_id'] = normalizedParcelleId;
      }
    }
    
    // 6. Traiter les traitements
    final traitements = data['traitements'] as List? ?? [];
    print('🧪 Traitement de ${traitements.length} traitements...');
    
    for (final traitement in traitements) {
      final t = traitement as Map<String, dynamic>;
      
      // Réparer les liens de parcelle
      final parcelleId = t['parcelleId']?.toString() ?? t['parcelle_id']?.toString() ?? '';
      if (parcelleId.isNotEmpty && parcelleIdMap.containsKey(parcelleId)) {
        final normalizedParcelleId = parcelleIdMap[parcelleId]!;
        t['parcelleId'] = normalizedParcelleId;
        t['parcelle_id'] = normalizedParcelleId;
      }
    }
    
    // 7. Sauvegarder le fichier réparé
    final outputFile = File(outputPath);
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    outputFile.writeAsStringSync(jsonString);
    
    print('\n✅ RÉPARATION TERMINÉE');
    print('======================');
    print('Liens réparés: $liensRepares');
    print('Fichier de sortie: $outputPath');
    print('Taille: ${(outputFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB');
    
    print('\n🎯 PROCHAINES ÉTAPES');
    print('====================');
    print('1. Importer le fichier réparé dans votre application');
    print('2. Vérifier que tous les liens fonctionnent correctement');
    print('3. Tester l\'affichage des données liées');
    
  } catch (e) {
    print('❌ Erreur lors de la réparation: $e');
    exit(1);
  }
}
