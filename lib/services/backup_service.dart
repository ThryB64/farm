import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html show AnchorElement, Blob, Url; // Web-only
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class BackupService {
  BackupService._();
  static final instance = BackupService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance;

  /// Récupère le farmId (adapte à ton schéma)
  Future<String> _resolveFarmId(String uid) async {
    final snap = await _db.ref('userFarms/$uid').get();
    if (!snap.exists || snap.value == null) {
      throw Exception('FarmId introuvable pour $uid');
    }
    return snap.value.toString();
  }

  /// Sections métier à exporter/importer
  static const sections = <String>[
    'parcelles',
    'cellules',
    'chargements',
    'semis',
    'varietes',
    'ventes',
    'traitements',
    'produits',
  ];

  /// ----- EXPORT -----

  /// Lit tout l'arbre et renvoie une String JSON
  Future<String> exportToJsonString({String? farmId}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non connecté');

    final resolvedFarmId = farmId ?? await _resolveFarmId(uid);
    final rootPath = 'farms/$resolvedFarmId';

    final data = <String, dynamic>{};
    for (final s in sections) {
      final snap = await _db.ref('$rootPath/$s').get();
      data[s] = snap.exists ? snap.value : null; // null si section vide
    }

    final payload = {
      '_meta': {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'uid': uid,
        'farmId': resolvedFarmId,
      },
      'data': data,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Upload du JSON dans Firebase Storage (désactivé pour simplifier)
  Future<String> exportToFirebaseStorage({String? farmId}) async {
    throw Exception('Firebase Storage non configuré - utilisez exportAndDownloadJson()');
  }

  /// Téléchargement local (Web) du JSON
  Future<void> exportAndDownloadJson({String? farmId}) async {
    final json = await exportToJsonString(farmId: farmId);
    final bytes = Uint8List.fromList(utf8.encode(json));
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final a = html.AnchorElement(href: url)
      ..download = 'backup_${DateTime.now().toIso8601String()}.json'
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// ----- IMPORT -----

  /// Valide rapidement la structure du backup
  void _validateBackup(Map<String, dynamic> payload) {
    if (!payload.containsKey('_meta') || !payload.containsKey('data')) {
      throw Exception('Backup invalide: champs _meta/data manquants.');
    }
    if (payload['data'] is! Map) {
      throw Exception('Backup invalide: data doit être un objet.');
    }
  }

  /// Applique l'import par multi-path update (atomique).
  /// [wipeBefore] : si true, on efface chaque section avant d'écrire
  Future<void> importFromJsonString(
    String json, {
    bool wipeBefore = false,
    String? farmId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Utilisateur non connecté');

    final Map<String, dynamic> payload = jsonDecode(json);
    _validateBackup(payload);

    final resolvedFarmId = farmId ?? await _resolveFarmId(uid);
    final rootPath = 'farms/$resolvedFarmId';
    final Map<String, dynamic> data = Map<String, dynamic>.from(payload['data'] ?? {});

    // Optionnel : nettoyer avant d'écrire
    if (wipeBefore) {
      final futures = <Future>[];
      for (final s in sections) {
        futures.add(_db.ref('$rootPath/$s').remove());
      }
      await Future.wait(futures);
    }

    // Construire un multi-location update (écriture atomique)
    final updates = <String, dynamic>{};
    for (final s in sections) {
      if (data.containsKey(s)) {
        updates['$rootPath/$s'] = data[s]; // peut être null (section vide)
      }
    }

    if (updates.isEmpty) {
      throw Exception('Aucune section à importer.');
    }

    await _db.ref().update(updates);
  }

  /// Import depuis Firebase Storage (désactivé pour simplifier)
  Future<void> importFromFirebaseStoragePath(
    String storagePath, {
    bool wipeBefore = false,
    String? farmId,
  }) async {
    throw Exception('Firebase Storage non configuré - utilisez importFromJsonString()');
  }
}
