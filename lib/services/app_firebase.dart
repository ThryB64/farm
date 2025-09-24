import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Singleton centralisé pour Firebase
/// Garantit qu'une seule instance d'Auth et DB est utilisée partout
class AppFirebase {
  // Toujours la même app (celle que tu initialises dans main())
  static final FirebaseApp app = Firebase.app(); // default app

  // Une seule instance d'Auth utilisée PARTOUT
  static final FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);

  // Une seule instance de DB utilisée PARTOUT
  static final FirebaseDatabase db = FirebaseDatabase.instanceFor(app: app);
  
  /// Vérifier que l'instance est correcte
  static void debugInfo() {
    print('AppFirebase: app name = ${app.name}');
    print('AppFirebase: auth instance = ${auth.hashCode}');
    print('AppFirebase: db instance = ${db.hashCode}');
    print('AppFirebase: current user = ${auth.currentUser?.uid ?? 'null'}');
  }
}
