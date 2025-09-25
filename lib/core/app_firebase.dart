import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Source de vérité unique pour Firebase
/// Utilise exclusivement l'instance par défaut [DEFAULT]
class AppFirebase {
  static FirebaseApp get app => Firebase.app(); // [DEFAULT]
  static FirebaseAuth get auth => FirebaseAuth.instanceFor(app: app);
  static FirebaseDatabase get db => FirebaseDatabase.instanceFor(app: app);
}
