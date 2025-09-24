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
    final deviceId = ensureDeviceId();

    // Connexion Firebase Auth
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // Vérifier si l'utilisateur est dans la whitelist
    if (!await isUserAllowed(uid)) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'user-not-allowed',
        message: 'Votre compte n\'est pas autorisé à accéder à cette application.',
      );
    }

    // Vérifier/gérer la liaison d'appareil
    await _handleDeviceBinding(uid, deviceId);

    return credential;
  }

  /// Gère la liaison d'appareil unique
  Future<void> _handleDeviceBinding(String uid, String deviceId) async {
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
      print('Device bound for user $uid: $deviceId');
    } else {
      // Vérifier si c'est le même appareil
      final boundDeviceId = snapshot.value as String;
      if (boundDeviceId != deviceId) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'device-mismatch',
          message: 'Ce compte est déjà lié à un autre appareil. Contactez l\'administrateur pour réinitialiser.',
        );
      }
      print('Device verified for user $uid: $deviceId');
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
    await _auth.signOut();
    // Optionnel : nettoyer le device ID local
    // html.window.localStorage.remove(_deviceIdKey);
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
  
  /// Configure un listener pour les changements d'authentification
  void setupAuthListener(VoidCallback onAuthChange) {
    _auth.authStateChanges().listen((user) {
      onAuthChange();
    });
  }
}

enum SecurityStatus {
  notAuthenticated,
  notAllowed,
  authenticated,
}
