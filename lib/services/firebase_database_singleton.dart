import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Singleton global pour Firebase Database
/// Évite l'initialisation multiple de Firebase Database
class FirebaseDatabaseSingleton {
  static FirebaseDatabase? _instance;
  static bool _isInitialized = false;
  
  /// Obtient l'instance unique de Firebase Database
  static FirebaseDatabase get instance {
    if (_instance == null) {
      throw Exception('FirebaseDatabase not initialized. Call initialize() first.');
    }
    return _instance!;
  }
  
  /// Initialise Firebase Database une seule fois
  static Future<FirebaseDatabase> initialize() async {
    if (_isInitialized && _instance != null) {
      print('FirebaseDatabaseSingleton: Using existing instance');
      return _instance!;
    }
    
    try {
      print('FirebaseDatabaseSingleton: Initializing Firebase Database...');
      
      // Vérifier si Firebase est déjà initialisé
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase not initialized. Call Firebase.initializeApp() first.');
      }
      
      // Créer l'instance Firebase Database
      _instance = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://farmgaec-default-rtdb.firebaseio.com',
      );
      
      // Configurer la persistance pour les plateformes natives
      if (!kIsWeb) {
        try {
          _instance!.setPersistenceEnabled(true);
          _instance!.setPersistenceCacheSizeBytes(10 * 1024 * 1024);
          print('FirebaseDatabaseSingleton: Persistence enabled');
        } catch (e) {
          print('FirebaseDatabaseSingleton: Persistence already configured: $e');
        }
      }
      
      _isInitialized = true;
      print('✅ FirebaseDatabaseSingleton: Initialized successfully');
      return _instance!;
      
    } catch (e) {
      print('❌ FirebaseDatabaseSingleton: Initialization failed: $e');
      
      // Fallback vers l'instance par défaut
      try {
        _instance = FirebaseDatabase.instance;
        _isInitialized = true;
        print('FirebaseDatabaseSingleton: Using default instance as fallback');
        return _instance!;
      } catch (fallbackError) {
        print('❌ FirebaseDatabaseSingleton: Fallback also failed: $fallbackError');
        rethrow;
      }
    }
  }
  
  /// Vérifie si Firebase Database est initialisé
  static bool get isInitialized => _isInitialized && _instance != null;
  
  /// Réinitialise le singleton (pour les tests)
  static void reset() {
    _instance = null;
    _isInitialized = false;
    print('FirebaseDatabaseSingleton: Reset');
  }
}
