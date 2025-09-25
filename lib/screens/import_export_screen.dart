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
        title: const Text('Import/Export'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // État de la base de données
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'État de la base',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<FirebaseProviderV4>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            _buildDataSummary(
                              'Parcelles',
                              provider.parcelles.length,
                              Icons.landscape,
                              Colors.green,
                            ),
                            const SizedBox(height: 8),
                            _buildDataSummary(
                              'Cellules',
                              provider.cellules.length,
                              Icons.warehouse,
                              Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            _buildDataSummary(
                              'Chargements',
                              provider.chargements.length,
                              Icons.local_shipping,
                              Colors.orange,
                            ),
                            const SizedBox(height: 8),
                            _buildDataSummary(
                              'Semis',
                              provider.semis.length,
                              Icons.agriculture,
                              Colors.brown,
                            ),
                            const SizedBox(height: 8),
                            _buildDataSummary(
                              'Variétés',
                              provider.varietes.length,
                              Icons.eco,
                              Colors.purple,
                            ),
                            const SizedBox(height: 8),
                            _buildDataSummary(
                              'Ventes',
                              provider.ventes.length,
                              Icons.shopping_cart,
                              Colors.red,
                            ),
                            const SizedBox(height: 8),
                            _buildDataSummary(
                              'Traitements',
                              provider.traitements.length,
                              Icons.medical_services,
                              Colors.teal,
                            ),
                            const SizedBox(height: 8),
                            _buildDataSummary(
                              'Produits',
                              provider.produits.length,
                              Icons.inventory,
                              Colors.indigo,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await provider.updateAllChargementsPoidsNormes();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Poids aux normes mis à jour avec succès'),
                                        duration: Duration(seconds: 5),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    // Forcer le rafraîchissement de l'interface
                                    provider.notifyListeners();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur lors de la mise à jour: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Mettre à jour les poids aux normes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Export complet
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export complet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Exporte toutes les données de la base dans un fichier JSON',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportData,
                      icon: _isExporting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                      label: Text(_isExporting ? 'Export en cours...' : 'Exporter la base'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Import complet
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import complet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Importe toutes les données depuis un fichier JSON',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isImporting ? null : _importData,
                      icon: _isImporting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload),
                      label: Text(_isImporting ? 'Import en cours...' : 'Importer la base'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Outils de débogage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Outils de débogage',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Accéder aux outils de débogage et diagnostic',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DebugScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Ouvrir Debug'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSummary(String title, int count, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          '$title : $count',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Future<void> _exportData() async {
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
      final fileName = 'mais_tracker_db_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      
      // Télécharger le fichier
      _downloadFile(jsonString, fileName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Base de données exportée : $fileName'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: Colors.red,
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
              
              // Vérifier la structure des données
              if (!_validateDataStructure(data)) {
                throw Exception('Format de fichier invalide. Veuillez utiliser un fichier exporté depuis l\'application.');
              }
              
              // Afficher un résumé des données à importer
              final summary = await _showImportSummary(data);
              if (summary != null) {
                await _performImport(summary);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de l\'import: $e'),
                    backgroundColor: Colors.red,
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
            content: Text('Erreur lors de l\'import: $e'),
            backgroundColor: Colors.red,
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

  Future<Map<String, dynamic>?> _showImportSummary(Map<String, dynamic> data) async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Résumé des données à importer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version du fichier: ${data['version'] ?? '1.0'}'),
            const SizedBox(height: 8),
            Text('Parcelles : ${data['parcelles']?.length ?? 0}'),
            Text('Cellules : ${data['cellules']?.length ?? 0}'),
            Text('Chargements : ${data['chargements']?.length ?? 0}'),
            Text('Semis : ${data['semis']?.length ?? 0}'),
            Text('Variétés : ${data['varietes']?.length ?? 0}'),
            Text('Ventes : ${data['ventes']?.length ?? 0}'),
            Text('Traitements : ${data['traitements']?.length ?? 0}'),
            Text('Produits : ${data['produits']?.length ?? 0}'),
            const SizedBox(height: 16),
            const Text(
              'Les données existantes seront remplacées. '
              'Voulez-vous continuer ?',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, data),
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }

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
          const SnackBar(
            content: Text('Base de données importée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      print('ImportExportScreen: Firebase import completed successfully');
    } catch (e) {
      print('ImportExportScreen: Firebase import failed: $e');
      rethrow;
    }
  }

  bool _validateDataStructure(Map<String, dynamic> data) {
    return data.containsKey('parcelles') &&
           data.containsKey('cellules') &&
           data.containsKey('chargements') &&
           data.containsKey('semis') &&
           data.containsKey('varietes') &&
           data['parcelles'] is List &&
           data['cellules'] is List &&
           data['chargements'] is List &&
           data['semis'] is List &&
           data['varietes'] is List;
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
        'version': '2.0', // Version mise à jour pour inclure toutes les données
        'parcelles': parcelles.map((p) => _convertParcelleToMap(p)).toList(),
        'cellules': cellules.map((c) => _convertCelluleToMap(c)).toList(),
        'chargements': chargements.map((c) => _convertChargementToMap(c)).toList(),
        'semis': semis.map((s) => _convertSemisToMap(s)).toList(),
        'varietes': varietes.map((v) => _convertVarieteToMap(v)).toList(),
        'ventes': ventes.map((v) => _convertVenteToMap(v)).toList(),
        'traitements': traitements.map((t) => _convertTraitementToMap(t)).toList(),
        'produits': produits.map((p) => _convertProduitToMap(p)).toList(),
      };
      
      return firebaseData;
    } catch (e) {
      print('Erreur lors de la récupération des données Firebase: $e');
      rethrow;
    }
  }

  // Méthodes de conversion avec gestion explicite des types
  Map<String, dynamic> _convertParcelleToMap(Parcelle parcelle) {
    return {
      'id': parcelle.id,
      'firebaseId': parcelle.firebaseId,
      'nom': parcelle.nom,
      'surface': parcelle.surface,
      'dateCreation': parcelle.dateCreation.toIso8601String(),
      'notes': parcelle.notes,
    };
  }

  Map<String, dynamic> _convertCelluleToMap(Cellule cellule) {
    return {
      'id': cellule.id,
      'firebaseId': cellule.firebaseId,
      'reference': cellule.reference,
      'capacite': cellule.capacite,
      'dateCreation': cellule.dateCreation.toIso8601String(),
      'notes': cellule.notes,
      'nom': cellule.nom,
      'fermee': cellule.fermee,
    };
  }

  Map<String, dynamic> _convertChargementToMap(Chargement chargement) {
    return {
      'id': chargement.id,
      'firebaseId': chargement.firebaseId,
      'celluleId': chargement.celluleId,
      'parcelleId': chargement.parcelleId,
      'remorque': chargement.remorque,
      'dateChargement': chargement.dateChargement.toIso8601String(),
      'poidsPlein': chargement.poidsPlein,
      'poidsVide': chargement.poidsVide,
      'poidsNet': chargement.poidsNet,
      'poidsNormes': chargement.poidsNormes,
      'humidite': chargement.humidite,
      'variete': chargement.variete,
    };
  }

  Map<String, dynamic> _convertSemisToMap(Semis semis) {
    return {
      'id': semis.id,
      'firebaseId': semis.firebaseId,
      'parcelleId': semis.parcelleId,
      'date': semis.date.toIso8601String(),
      'varietesSurfaces': semis.varietesSurfaces.map((v) => v.toMap()).toList(),
      'notes': semis.notes,
    };
  }

  Map<String, dynamic> _convertVarieteToMap(Variete variete) {
    return {
      'id': variete.id,
      'firebaseId': variete.firebaseId,
      'nom': variete.nom,
      'description': variete.description,
      'dateCreation': variete.dateCreation.toIso8601String(),
    };
  }

  Map<String, dynamic> _convertVenteToMap(Vente vente) {
    return {
      'id': vente.id,
      'firebaseId': vente.firebaseId,
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
    };
  }

  Map<String, dynamic> _convertTraitementToMap(Traitement traitement) {
    return {
      'id': traitement.id,
      'firebaseId': traitement.firebaseId,
      'parcelleId': traitement.parcelleId,
      'date': traitement.date.millisecondsSinceEpoch,
      'annee': traitement.annee,
      'notes': traitement.notes,
      'produits': traitement.produits.map((p) => p.toMap()).toList(),
      'coutTotal': traitement.coutTotal,
    };
  }

  Map<String, dynamic> _convertProduitToMap(Produit produit) {
    return {
      'id': produit.id,
      'firebaseId': produit.firebaseId,
      'nom': produit.nom,
      'mesure': produit.mesure,
      'notes': produit.notes,
      'prixParAnnee': produit.prixParAnnee.map((k, v) => MapEntry(k.toString(), v)),
    };
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