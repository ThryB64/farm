import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
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
      // Vérifier l'accès à la ferme
      final hasAccess = await BackupService.instance.hasFarmAccess();
      if (!hasAccess) {
        throw Exception('Accès à la ferme non autorisé');
      }

      // Exporter les données depuis Firebase
      final exportData = await BackupService.instance.exportFarmData();
      
      // Convertir en JSON avec indentation
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Créer le nom de fichier avec la date
      final now = DateTime.now();
      final fileName = 'farmgaec-backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      
      // Télécharger le fichier
      _downloadFile(jsonString, fileName);
      
      // Optionnel : sauvegarder dans Firebase Storage
      try {
        await BackupService.instance.saveBackupToStorage(exportData);
        print('BackupService: Backup also saved to Firebase Storage');
      } catch (e) {
        print('BackupService: Failed to save to Storage (non-critical): $e');
      }
      
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
      // Vérifier l'accès à la ferme
      final hasAccess = await BackupService.instance.hasFarmAccess();
      if (!hasAccess) {
        throw Exception('Accès à la ferme non autorisé');
      }

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
              
              // Afficher une confirmation avant l'import
              final confirmed = await _showImportConfirmation();
              if (!confirmed) return;
              
              // Importer les données via BackupService
              await _performFirebaseImport(jsonString);
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

  /// Importe les données via BackupService
  Future<void> _performFirebaseImport(String jsonString) async {
    try {
      print('ImportExportScreen: Starting Firebase import');
      
      // Importer les données (mode remplacement total)
      await BackupService.instance.importFromJsonString(jsonString, wipeBefore: true);
      
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