import 'package:flutter/foundation.dart';
import '../core/app_firebase.dart';
import '../services/firebase_service_v4.dart';

class FirebaseProvider with ChangeNotifier {
  String? _uid;
  bool _ready = false;
  FirebaseServiceV4? _service;

  bool get ready => _ready;
  String? get uid => _uid;

  // Données
  final List<dynamic> parcelles = [];
  final List<dynamic> cellules = [];
  final List<dynamic> chargements = [];
  final List<dynamic> semis = [];
  final List<dynamic> varietes = [];
  final List<dynamic> ventes = [];
  final List<dynamic> traitements = [];
  final List<dynamic> produits = [];

  Future<void> ensureInitializedFor(String uid) async {
    if (_ready && _uid == uid) {
      print('FirebaseProvider: Already initialized for $uid, skipping');
      return;
    }
    
    print('FirebaseProvider: Initializing for user: $uid');
    
    // Initialiser le service si nécessaire
    if (_service == null) {
      _service = FirebaseServiceV4();
      await _service!.initialize();
    }
    
    // Configurer les listeners RTDB pour cet utilisateur
    await _setupListeners();
    
    _uid = uid;
    _ready = true;
    notifyListeners();
    print('FirebaseProvider: Initialization completed for user: $uid');
  }

  Future<void> disposeAuthBoundResources() async {
    if (!_ready && _uid == null) {
      print('FirebaseProvider: Already disposed, skipping');
      return;
    }
    
    print('FirebaseProvider: Disposing auth bound resources');
    
    // Annuler tous les listeners RTDB
    if (_service != null) {
      await _service!.disposeListeners();
    }
    
    _uid = null;
    _ready = false;
    _clearAllSilently();
    notifyListeners();
    print('FirebaseProvider: Auth bound resources disposed');
  }

  void _clearAllSilently() {
    print('FirebaseProvider: Clearing all data silently');
    parcelles.clear();
    cellules.clear();
    chargements.clear();
    semis.clear();
    varietes.clear();
    ventes.clear();
    traitements.clear();
    produits.clear();
    print('FirebaseProvider: All data cleared silently');
  }

  Future<void> _setupListeners() async {
    // TODO: Configurer les listeners RTDB spécifiques
    // Utiliser AppFirebase.db pour les listeners
    print('FirebaseProvider: Setting up RTDB listeners');
  }
}
