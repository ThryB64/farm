import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_database_singleton.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  static BackupService get instance => _instance;

  final FirebaseDatabase _database = FirebaseDatabaseSingleton.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUid => _auth.currentUser?.uid ?? '';
  String get _farmId => 'gaec_berard'; // ID de la ferme

  // ===== EXPORT =====

  /// Exporte toutes les données de la ferme depuis Firebase
  Future<Map<String, dynamic>> exportFarmData() async {
    try {
      print('BackupService: Starting export for farm $_farmId');
      
      final farmRef = _database.ref('farms/$_farmId');
      final snapshot = await farmRef.get();
      
      if (!snapshot.exists) {
        throw Exception('Farm $_farmId not found');
      }

      final farmData = snapshot.value as Map<dynamic, dynamic>;
      
      // Construire l'export complet avec métadonnées
      final exportData = {
        '_meta': {
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
          'farmId': _farmId,
          'exportedBy': _currentUid,
        },
        'data': _convertFirebaseData(farmData),
      };

      print('BackupService: Export completed - ${farmData.length} sections');
      return exportData;
    } catch (e) {
      print('BackupService: Export failed: $e');
      rethrow;
    }
  }

  /// Convertit les données Firebase en format export
  Map<String, dynamic> _convertFirebaseData(Map<dynamic, dynamic> farmData) {
    final result = <String, dynamic>{};
    
    // Sections à exporter
    final sections = [
      'parcelles', 'cellules', 'chargements', 'semis', 'varietes',
      'ventes', 'traitements', 'produits'
    ];
    
    for (final section in sections) {
      if (farmData.containsKey(section)) {
        result[section] = farmData[section];
      } else {
        result[section] = {};
      }
    }
    
    return result;
  }

  /// Sauvegarde l'export dans Firebase Storage
  Future<String> saveBackupToStorage(Map<String, dynamic> exportData) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final path = 'backups/$_currentUid/$fileName';
      
      final ref = _storage.ref(path);
      await ref.putString(jsonString);
      
      final downloadUrl = await ref.getDownloadURL();
      print('BackupService: Backup saved to Storage: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('BackupService: Failed to save backup to Storage: $e');
      rethrow;
    }
  }

  // ===== IMPORT =====

  /// Importe des données depuis un JSON
  Future<void> importFromJsonString(String jsonString, {bool wipeBefore = false}) async {
    try {
      print('BackupService: Starting import (wipeBefore: $wipeBefore)');
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Vérifier la structure
      if (!data.containsKey('_meta') || !data.containsKey('data')) {
        throw Exception('Invalid backup format - missing _meta or data');
      }
      
      final meta = data['_meta'] as Map<String, dynamic>;
      final farmData = data['data'] as Map<String, dynamic>;
      
      print('BackupService: Importing backup from ${meta['exportDate']}');
      
      // Préparer les données pour Firebase
      final updates = <String, dynamic>{};
      
      if (wipeBefore) {
        // Mode remplacement : vider d'abord
        print('BackupService: Wiping existing data before import');
        updates['farms/$_farmId'] = null;
      }
      
      // Ajouter les nouvelles données
      for (final section in farmData.keys) {
        updates['farms/$_farmId/$section'] = farmData[section];
      }
      
      // Appliquer l'import de manière atomique
      await _database.ref().update(updates);
      
      print('BackupService: Import completed successfully');
    } catch (e) {
      print('BackupService: Import failed: $e');
      rethrow;
    }
  }

  /// Charge un backup depuis Firebase Storage
  Future<Map<String, dynamic>> loadBackupFromStorage(String backupUrl) async {
    try {
      final ref = _storage.refFromURL(backupUrl);
      final jsonString = await ref.getData();
      
      if (jsonString == null) {
        throw Exception('Backup file not found');
      }
      
      return jsonDecode(utf8.decode(jsonString)) as Map<String, dynamic>;
    } catch (e) {
      print('BackupService: Failed to load backup from Storage: $e');
      rethrow;
    }
  }

  /// Liste les backups disponibles pour l'utilisateur
  Future<List<Map<String, dynamic>>> listUserBackups() async {
    try {
      final listRef = _storage.ref('backups/$_currentUid');
      final result = await listRef.listAll();
      
      final backups = <Map<String, dynamic>>[];
      
      for (final item in result.items) {
        final metadata = await item.getMetadata();
        backups.add({
          'name': item.name,
          'path': item.fullPath,
          'size': metadata.size,
          'created': metadata.timeCreated,
          'updated': metadata.updated,
        });
      }
      
      // Trier par date de création (plus récent en premier)
      backups.sort((a, b) => (b['created'] as DateTime).compareTo(a['created'] as DateTime));
      
      return backups;
    } catch (e) {
      print('BackupService: Failed to list backups: $e');
      return [];
    }
  }

  /// Supprime un backup
  Future<void> deleteBackup(String backupPath) async {
    try {
      final ref = _storage.ref(backupPath);
      await ref.delete();
      print('BackupService: Backup deleted: $backupPath');
    } catch (e) {
      print('BackupService: Failed to delete backup: $e');
      rethrow;
    }
  }

  // ===== UTILITAIRES =====

  /// Vérifie si l'utilisateur a accès à la ferme
  Future<bool> hasFarmAccess() async {
    try {
      final userFarmsRef = _database.ref('userFarms/$_currentUid');
      final snapshot = await userFarmsRef.get();
      
      if (!snapshot.exists) return false;
      
      final userFarmId = snapshot.value as String;
      return userFarmId == _farmId;
    } catch (e) {
      print('BackupService: Failed to check farm access: $e');
      return false;
    }
  }

  /// Force le refresh des données locales
  Future<void> refreshLocalData() async {
    try {
      // Cette méthode sera appelée par le provider pour forcer un refresh
      print('BackupService: Refreshing local data...');
      // Le provider gérera le refresh via ses streams
    } catch (e) {
      print('BackupService: Failed to refresh local data: $e');
    }
  }
}
