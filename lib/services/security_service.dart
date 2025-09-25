import 'dart:async';
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'firebase_database_singleton.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Clé pour le device ID dans localStorage
  static const String _deviceIdKey = 'mais_tracker_device_id';

  /// Génère ou récupère l'ID de l'appareil depuis localStorage
  String ensureDeviceId() {
    var deviceId = html.window.localStorage[_deviceIdKey];
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      html.window.localStorage[_deviceIdKey] = deviceId;
    }
    return deviceId;
  }

  /// Vérifie si l'utilisateur est dans la whitelist
  Future<bool> isUserAllowed(String uid) async {
    try {
      // Initialiser la base de données si nécessaire
      final database = await FirebaseDatabaseSingleton.initialize();
      final snapshot = await database.ref('allowedUsers/$uid').get();
      return snapshot.exists && snapshot.value == true;
    } catch (e) {
      print('Error checking user whitelist: $e');
      return false;
    }
  }

  /// Connexion avec vérification d'appareil unique
  Future<UserCredential> signInOncePerDevice(String email, String password) async {
    try {
      print('SecurityService: Starting sign in for $email');
      final deviceId = ensureDeviceId();

      // Connexion Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Erreur lors de la connexion.',
        );
      }

      final uid = credential.user!.uid;
      print('SecurityService: User authenticated with UID: $uid');

      // Vérifier si l'utilisateur est dans la whitelist
      final isAllowed = await isUserAllowed(uid);
      if (!isAllowed) {
        print('SecurityService: User $uid not in whitelist');
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-not-allowed',
          message: 'Votre compte n\'est pas autorisé à accéder à cette application.',
        );
      }

      // Vérifier/gérer la liaison d'appareil
      await _handleDeviceBinding(uid, deviceId);

      print('SecurityService: Sign in successful for $email');
      return credential;
    } catch (e) {
      print('SecurityService: Sign in error: $e');
      rethrow;
    }
  }

  /// Gère la liaison d'appareil unique
  Future<void> _handleDeviceBinding(String uid, String deviceId) async {
    try {
      print('SecurityService: Handling device binding for $uid');
      final database = await FirebaseDatabaseSingleton.initialize();
      final db = database.ref();
      final deviceRef = db.child('userDevices/$uid/primaryDeviceId');
      final snapshot = await deviceRef.get();

      if (!snapshot.exists) {
        // Premier appareil - autoriser et enregistrer
        await db.child('userDevices/$uid').update({
          'primaryDeviceId': deviceId,
          'boundAt': ServerValue.timestamp,
          'email': _auth.currentUser?.email,
        });
        print('SecurityService: Device bound for user $uid: $deviceId');
      } else {
        // Vérifier si c'est le même appareil
        final boundDeviceId = snapshot.value as String?;
        if (boundDeviceId != null && boundDeviceId != deviceId) {
          print('SecurityService: Device mismatch for user $uid');
          print('SecurityService: Bound device: $boundDeviceId, Current device: $deviceId');
          
          // Option 1: Permettre la réinitialisation automatique (activé temporairement)
          print('SecurityService: Auto-resetting device binding for $uid');
          await db.child('userDevices/$uid').update({
            'primaryDeviceId': deviceId,
            'boundAt': ServerValue.timestamp,
            'email': _auth.currentUser?.email,
            'previousDeviceId': boundDeviceId,
          });
          print('SecurityService: Device binding reset for user $uid');
          
          // Option 2: Bloquer la connexion (désactivé temporairement)
          // await _auth.signOut();
          // throw FirebaseAuthException(
          //   code: 'device-mismatch',
          //   message: 'Ce compte est déjà lié à un autre appareil. Contactez l\'administrateur pour réinitialiser.',
          // );
        }
        print('SecurityService: Device verified for user $uid: $deviceId');
      }
    } catch (e) {
      print('SecurityService: Device binding error: $e');
      rethrow;
    }
  }

  /// Vérifie si l'utilisateur actuel est autorisé
  Future<bool> isCurrentUserAllowed() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return await isUserAllowed(user.uid);
  }

  /// Déconnexion sécurisée
  Future<void> signOut() async {
    try {
      print('SecurityService: Signing out...');
      await _auth.signOut();
      
      // Ne PAS supprimer le device ID pour éviter les "device-mismatch" à la reconnexion
      // html.window.localStorage.remove(_deviceIdKey);
      
      // Nettoyer les données de l'application
      html.window.localStorage.remove('parcelles');
      html.window.localStorage.remove('cellules');
      html.window.localStorage.remove('chargements');
      html.window.localStorage.remove('semis');
      html.window.localStorage.remove('varietes');
      html.window.localStorage.remove('ventes');
      html.window.localStorage.remove('traitements');
      html.window.localStorage.remove('produits');
      
      print('SecurityService: Sign out completed');
    } catch (e) {
      print('SecurityService: Sign out error: $e');
      rethrow;
    }
  }

  /// Vérifie l'état de sécurité complet
  Future<SecurityStatus> checkSecurityStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      return SecurityStatus.notAuthenticated;
    }

    if (!await isUserAllowed(user.uid)) {
      return SecurityStatus.notAllowed;
    }

    return SecurityStatus.authenticated;
  }

  /// Obtient les informations de l'appareil lié
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final database = await FirebaseDatabaseSingleton.initialize();
      final snapshot = await database.ref('userDevices/${user.uid}').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      print('Error getting device info: $e');
    }
    return null;
  }
  
  // Note: AuthGate gère directement authStateChanges() - pas besoin de listener ici
  
  /// Réinitialise la liaison d'appareil pour l'utilisateur actuel
  Future<void> resetDeviceBinding() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Aucun utilisateur connecté');
      }
      
      print('SecurityService: Resetting device binding for ${user.uid}');
      final database = await FirebaseDatabaseSingleton.initialize();
      final db = database.ref();
      
      // Supprimer l'ancienne liaison
      await db.child('userDevices/${user.uid}').remove();
      
      // Créer une nouvelle liaison avec le nouvel appareil
      final deviceId = ensureDeviceId();
      await db.child('userDevices/${user.uid}').update({
        'primaryDeviceId': deviceId,
        'boundAt': ServerValue.timestamp,
        'email': user.email,
        'resetAt': ServerValue.timestamp,
      });
      
      print('SecurityService: Device binding reset successful for ${user.uid}');
    } catch (e) {
      print('SecurityService: Device binding reset error: $e');
      rethrow;
    }
  }
}

enum SecurityStatus {
  notAuthenticated,
  notAllowed,
  authenticated,
}
