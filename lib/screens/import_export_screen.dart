import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../models/variete_surface.dart';
import '../models/vente.dart';
import '../models/traitement.dart';
import '../models/produit.dart';
import '../models/produit_traitement.dart';
import 'debug_screen.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({Key? key}) : super(key: key);

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import / Export'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary,
              AppTheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section Export
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.upload, color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Export des données',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Exporter toutes les données de la ferme depuis Firebase',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ModernButton(
                        text: 'Exporter vers fichier',
                        onPressed: _isExporting ? null : _exportAllData,
                        isLoading: _isExporting,
                        icon: Icons.download,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Section Import
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.download, color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Import des données',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Importer des données depuis un fichier JSON',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ModernButton(
                        text: 'Importer depuis un fichier',
                        onPressed: _isImporting ? null : _importData,
                        isLoading: _isImporting,
                        icon: Icons.upload,
                        backgroundColor: AppTheme.warning,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Section Debug
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bug_report, color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Outils de débogage',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Accéder aux outils de débogage et diagnostic',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ModernButton(
                        text: 'Ouvrir Debug',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DebugScreen(),
                            ),
                          );
                        },
                        icon: Icons.settings,
                        backgroundColor: AppTheme.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportAllData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Utiliser l'export Firebase natif
      final firebaseData = await _getFirebaseExport();
      
      // Convertir en JSON avec indentation
      final jsonString = const JsonEncoder.withIndent('  ').convert(firebaseData);
      
      // Créer le nom de fichier avec la date
      final now = DateTime.now();
      final fileName = 'farmgaec-backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      
      // Télécharger le fichier
      _downloadFile(jsonString, fileName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export Firebase réussi : $fileName'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export Firebase : $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
    });

    try {
      // Pour le web, on utilise un input file
      final input = html.FileUploadInputElement()
        ..accept = '.json'
        ..click();
      
      input.onChange.listen((e) async {
        final file = input.files?.first;
        if (file != null) {
          final reader = html.FileReader();
          reader.onLoadEnd.listen((e) async {
            try {
              final jsonString = reader.result as String;
              final data = jsonDecode(jsonString) as Map<String, dynamic>;
              
              // Valider la structure des données
              if (!data.containsKey('_meta') || !data.containsKey('data')) {
                throw Exception('Format de fichier invalide - structure Firebase requise');
              }
              
              // Afficher une confirmation avant l'import
              final confirmed = await _showImportConfirmation();
              if (!confirmed) return;
              
              // Importer les données
              await _performImport(data);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de l\'import : $e'),
                    backgroundColor: AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                );
              }
            }
          });
          reader.readAsText(file);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'import : $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  Future<bool> _showImportConfirmation() async {
    return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'import'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        content: const Text(
          'Cette action va remplacer toutes les données existantes. Êtes-vous sûr de vouloir continuer ?',
          ),
          actions: [
          ModernTextButton(
            text: 'Annuler',
            onPressed: () => Navigator.pop(context, false),
          ),
          ModernButton(
            text: 'Confirmer',
            backgroundColor: AppTheme.error,
            onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
    ) ?? false;
  }

  // Récupérer l'export Firebase natif
  Future<Map<String, dynamic>> _getFirebaseExport() async {
    try {
      // Utiliser le provider pour récupérer toutes les données
      final provider = context.read<FirebaseProviderV4>();
      
      // Récupérer toutes les données depuis le provider
      final parcelles = provider.parcelles;
      final cellules = provider.cellules;
      final chargements = provider.chargements;
      final semis = provider.semis;
      final varietes = provider.varietes;
      final ventes = provider.ventes;
      final traitements = provider.traitements;
      final produits = provider.produits;
      
      // Construire la structure Firebase
      final firebaseData = {
        '_meta': {
          'exportDate': DateTime.now().toIso8601String(),
          'version': '1.0',
          'farmId': 'gaec_berard',
          'exportedBy': 'current_user',
        },
        'data': {
          'parcelles': _buildFirebaseParcelles(parcelles),
          'cellules': _buildFirebaseCellules(cellules),
          'chargements': _buildFirebaseChargements(chargements),
          'semis': _buildFirebaseSemis(semis),
          'varietes': _buildFirebaseVarietes(varietes),
          'ventes': _buildFirebaseVentes(ventes),
          'traitements': _buildFirebaseTraitements(traitements),
          'produits': _buildFirebaseProduits(produits),
        }
      };
      
      return firebaseData;
    } catch (e) {
      print('Erreur lors de la récupération des données Firebase: $e');
      rethrow;
    }
  }

  // Construire la structure Firebase pour les parcelles
  Map<String, dynamic> _buildFirebaseParcelles(List<Parcelle> parcelles) {
    final Map<String, dynamic> result = {};
    for (final parcelle in parcelles) {
      final key = parcelle.firebaseId ?? 'parcelle_${parcelle.nom.toLowerCase().replaceAll(' ', '_')}_${(parcelle.surface * 1000).round()}';
      result[key] = {
        'firebaseId': key,
        'nom': parcelle.nom,
        'surface': parcelle.surface,
        'date_creation': parcelle.dateCreation.toIso8601String(),
        'notes': parcelle.notes,
        'createdAt': parcelle.dateCreation.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
    }
    return result;
  }

  // Construire la structure Firebase pour les cellules
  Map<String, dynamic> _buildFirebaseCellules(List<Cellule> cellules) {
    final Map<String, dynamic> result = {};
    for (final cellule in cellules) {
      final key = cellule.firebaseId ?? 'cellule_${cellule.reference}';
      result[key] = {
        'firebaseId': key,
        'reference': cellule.reference,
        'capacite': cellule.capacite,
        'date_creation': cellule.dateCreation.toIso8601String(),
        'notes': cellule.notes,
        'nom': cellule.nom,
        'fermee': cellule.fermee,
        'createdAt': cellule.dateCreation.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
    }
    return result;
  }

  // Construire la structure Firebase pour les chargements
  Map<String, dynamic> _buildFirebaseChargements(List<Chargement> chargements) {
    final Map<String, dynamic> result = {};
    for (final chargement in chargements) {
      final key = chargement.firebaseId ?? 'chargement_${chargement.dateChargement.year}-${chargement.dateChargement.month.toString().padLeft(2, '0')}-${chargement.dateChargement.day.toString().padLeft(2, '0')}_${chargement.remorque}';
      result[key] = {
        'firebaseId': key,
        'cellule_id': chargement.celluleId,
        'parcelle_id': chargement.parcelleId,
        'remorque': chargement.remorque,
        'date_chargement': chargement.dateChargement.toIso8601String(),
        'poids_plein': chargement.poidsPlein,
        'poids_vide': chargement.poidsVide,
        'poids_net': chargement.poidsNet,
        'poids_normes': chargement.poidsNormes,
        'humidite': chargement.humidite,
        'variete': chargement.variete,
        'createdAt': chargement.dateChargement.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
    }
    return result;
  }

  // Construire la structure Firebase pour les semis
  Map<String, dynamic> _buildFirebaseSemis(List<Semis> semis) {
    final Map<String, dynamic> result = {};
    for (final s in semis) {
      final key = s.firebaseId ?? 'semis_${s.parcelleId}_${s.date.year}-${s.date.month.toString().padLeft(2, '0')}-${s.date.day.toString().padLeft(2, '0')}';
      result[key] = {
        'firebaseId': key,
        'parcelle_id': s.parcelleId,
        'date': s.date.toIso8601String(),
        'varietes_surfaces': s.varietesSurfaces.map((v) => v.toMap()).toList(),
        'notes': s.notes,
        'createdAt': s.date.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
    }
    return result;
  }

  // Construire la structure Firebase pour les variétés
  Map<String, dynamic> _buildFirebaseVarietes(List<Variete> varietes) {
    final Map<String, dynamic> result = {};
    for (final variete in varietes) {
      final key = variete.firebaseId ?? 'variete_${variete.nom.toLowerCase().replaceAll(' ', '_')}';
      result[key] = {
        'firebaseId': key,
        'nom': variete.nom,
        'description': variete.description,
        'date_creation': variete.dateCreation.toIso8601String(),
        'createdAt': variete.dateCreation.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
    }
    return result;
  }

  // Construire la structure Firebase pour les ventes
  Map<String, dynamic> _buildFirebaseVentes(List<Vente> ventes) {
    final Map<String, dynamic> result = {};
    for (final vente in ventes) {
      final key = vente.firebaseId ?? 'vente_${vente.numeroTicket}_${vente.date.year}-${vente.date.month.toString().padLeft(2, '0')}-${vente.date.day.toString().padLeft(2, '0')}';
      result[key] = {
        'firebaseId': key,
        'date': vente.date.millisecondsSinceEpoch,
        'annee': vente.annee,
        'numeroTicket': vente.numeroTicket,
        'client': vente.client,
        'immatriculationRemorque': vente.immatriculationRemorque,
        'cmr': vente.cmr,
        'poidsVide': vente.poidsVide,
        'poidsPlein': vente.poidsPlein,
        'poidsNet': vente.poidsNet,
        'ecartPoidsNet': vente.ecartPoidsNet,
        'payer': vente.payer,
        'prix': vente.prix,
        'terminee': vente.terminee,
        'createdAt': vente.date.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
    }
    return result;
  }

  // Construire la structure Firebase pour les traitements
  Map<String, dynamic> _buildFirebaseTraitements(List<Traitement> traitements) {
    final Map<String, dynamic> result = {};
    for (final traitement in traitements) {
      final key = traitement.firebaseId ?? 'traitement_${traitement.parcelleId}_${traitement.date.year}-${traitement.date.month.toString().padLeft(2, '0')}-${traitement.date.day.toString().padLeft(2, '0')}';
      result[key] = {
        'firebaseId': key,
        'parcelleId': traitement.parcelleId,
        'date': traitement.date.millisecondsSinceEpoch,
        'annee': traitement.annee,
        'notes': traitement.notes,
        'produits': traitement.produits.map((p) => p.toMap()).toList(),
        'coutTotal': traitement.coutTotal,
        'createdAt': traitement.date.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
    }
    return result;
  }

  // Construire la structure Firebase pour les produits
  Map<String, dynamic> _buildFirebaseProduits(List<Produit> produits) {
    final Map<String, dynamic> result = {};
    for (final produit in produits) {
      final key = produit.firebaseId ?? 'produit_${produit.nom.toLowerCase().replaceAll(' ', '_')}';
      result[key] = {
        'firebaseId': key,
        'nom': produit.nom,
        'mesure': produit.mesure,
        'notes': produit.notes,
        'prixParAnnee': produit.prixParAnnee.map((k, v) => MapEntry(k.toString(), v)),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
    }
    return result;
  }

  /// Importe les données via BackupService
  Future<void> _performImport(Map<String, dynamic> data) async {
    try {
      print('ImportExportScreen: Starting Firebase import');
      
      // Importer les données (mode remplacement total)
      await BackupService.instance.importFromJsonString(jsonEncode(data), wipeBefore: true);
      
      // Forcer le refresh des données locales
      final provider = context.read<FirebaseProviderV4>();
      await provider.refreshAllData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Import Firebase réussi ! Données restaurées.'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
      
      print('ImportExportScreen: Firebase import completed successfully');
    } catch (e) {
      print('ImportExportScreen: Firebase import failed: $e');
      rethrow;
    }
  }

  void _downloadFile(String content, String fileName) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }
}