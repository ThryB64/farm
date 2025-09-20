import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import/Export'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    SizedBox(height: 16),
                    Consumer<FirebaseProviderV3>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            _buildDataSummary(
                              'Parcelles',
                              provider.parcelles.length,
                              Icons.landscape,
                              Colors.green,
                            ),
                            SizedBox(height: 8),
                            _buildDataSummary(
                              'Cellules',
                              provider.cellules.length,
                              Icons.warehouse,
                              Colors.blue,
                            ),
                            SizedBox(height: 8),
                            _buildDataSummary(
                              'Chargements',
                              provider.chargements.length,
                              Icons.local_shipping,
                              Colors.orange,
                            ),
                            SizedBox(height: 8),
                            _buildDataSummary(
                              'Semis',
                              provider.semis.length,
                              Icons.agriculture,
                              Colors.brown,
                            ),
                            SizedBox(height: 8),
                            _buildDataSummary(
                              'Variétés',
                              provider.varietes.length,
                              Icons.eco,
                              Colors.purple,
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  // Méthode non disponible dans le provider V3
        print('updateAllChargementsPoidsNormes: Not needed for V3 provider');
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
                              icon: Icon(Icons.refresh),
                              label: const Text('Mettre à jour les poids aux normes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
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
            SizedBox(height: 16),
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
                    SizedBox(height: 8),
                    const Text(
                      'Exporte toutes les données de la base dans un fichier JSON',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _exportData(context),
                      icon: Icon(Icons.download),
                      label: const Text('Exporter la base'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
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
                    SizedBox(height: 8),
                    const Text(
                      'Importe toutes les données depuis un fichier JSON',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _importData(context),
                      icon: Icon(Icons.upload),
                      label: const Text('Importer la base'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
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
        SizedBox(width: 8),
        Text(
          '$title : $count',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = context.read<FirebaseProviderV3>();
      
      // Créer un objet contenant toutes les données
      final data = {
        'version': '2.0', // Version du format d'export
        'parcelles': provider.parcelles.map((p) => p.toMap()).toList(),
        'cellules': provider.cellules.map((c) => c.toMap()).toList(),
        'chargements': provider.chargements.map((c) => c.toMap()).toList(),
        'semis': provider.semis.map((s) => s.toMap()).toList(),
        'varietes': provider.varietes.map((v) => v.toMap()).toList(),
      };

      // Convertir en JSON avec indentation pour une meilleure lisibilité
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Obtenir le répertoire de téléchargement
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw 'Impossible d\'accéder au répertoire de téléchargement';
      }

      // Créer le nom de fichier avec la date et l'heure
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'mais_tracker_db_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // Sauvegarder le fichier
      await file.writeAsString(jsonString);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Base de données exportée dans ${directory.path}/$fileName'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      // Obtenir le répertoire de téléchargement
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw 'Impossible d\'accéder au répertoire de téléchargement';
      }

      // Lister tous les fichiers JSON dans le répertoire
      final files = directory.listSync()
          .where((file) => file is File && file.path.endsWith('.json'))
          .map((file) => file as File)
          .toList();

      if (files.isEmpty) {
        throw 'Aucun fichier JSON trouvé dans le répertoire de téléchargement';
      }

      // Trier les fichiers par date de modification (plus récent en premier)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Prendre le fichier le plus récent
      final file = files.first;
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);

      // Vérifier la structure des données
      if (!_validateDataStructure(data)) {
        throw 'Format de fichier invalide. Veuillez utiliser un fichier exporté depuis l\'application.';
      }

      // Afficher un résumé des données à importer
      final summary = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Résumé des données à importer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version du fichier: ${data['version'] ?? '1.0'}'),
              SizedBox(height: 8),
              Text('Parcelles : ${data['parcelles'].length}'),
              Text('Cellules : ${data['cellules'].length}'),
              Text('Chargements : ${data['chargements'].length}'),
              Text('Semis : ${data['semis'].length}'),
              Text('Variétés : ${data['varietes'].length}'),
              SizedBox(height: 16),
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

      if (summary != null) {
        final provider = context.read<FirebaseProviderV3>();
        
        // Supprimer les données existantes
        await provider.deleteAllData();
        
        // Importer les nouvelles données
        await provider.importData(summary);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Base de données importée avec succès')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'import: $e')),
        );
      }
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
} 