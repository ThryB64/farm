import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

/// Helper pour configurer la base de données de test
class TestDatabaseHelper {
  static Database? _database;
  
  /// Initialise la base de données de test
  static Future<void> initializeTestDatabase() async {
    // Initialiser sqflite_common_ffi pour les tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // Créer un répertoire temporaire pour la base de données de test
    final tempDir = Directory.systemTemp;
    final dbPath = path.join(tempDir.path, 'test_mais_tracker.db');
    
    // Supprimer la base de données existante si elle existe
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    
    _database = await openDatabase(
      dbPath,
      version: 8,
      onCreate: _createTestDatabase,
    );
  }
  
  /// Crée les tables de test
  static Future<void> _createTestDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE parcelles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        surface REAL NOT NULL,
        date_creation TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cellules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference TEXT NOT NULL,
        capacite REAL NOT NULL,
        date_creation TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE chargements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cellule_id INTEGER NOT NULL,
        parcelle_id INTEGER NOT NULL,
        remorque TEXT NOT NULL,
        date_chargement TEXT NOT NULL,
        poids_plein REAL NOT NULL,
        poids_vide REAL NOT NULL,
        poids_net REAL NOT NULL,
        poids_normes REAL NOT NULL,
        humidite REAL NOT NULL,
        variete TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (cellule_id) REFERENCES cellules (id),
        FOREIGN KEY (parcelle_id) REFERENCES parcelles (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE semis(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parcelle_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        varietes_surfaces TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (parcelle_id) REFERENCES parcelles (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE varietes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        description TEXT,
        date_creation TEXT NOT NULL
      )
    ''');
  }
  
  /// Retourne l'instance de la base de données de test
  static Database? get database => _database;
  
  /// Ferme la base de données de test
  static Future<void> closeTestDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  /// Nettoie la base de données de test
  static Future<void> cleanTestDatabase() async {
    if (_database != null) {
      await _database!.transaction((txn) async {
        await txn.rawDelete('DELETE FROM chargements');
        await txn.rawDelete('DELETE FROM semis');
        await txn.rawDelete('DELETE FROM parcelles');
        await txn.rawDelete('DELETE FROM cellules');
        await txn.rawDelete('DELETE FROM varietes');
      });
    }
  }
}
