import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../models/variete_surface.dart';
import 'debug_screen.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({Key? key}) : super(key: key);

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Import/Export'),
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              _buildDataOverview(),
              const SizedBox(height: AppTheme.spacingL),
              _buildExportSection(),
              const SizedBox(height: AppTheme.spacingL),
              _buildImportSection(),
              const SizedBox(height: AppTheme.spacingL),
              _buildActionsSection(),
              const SizedBox(height: AppTheme.spacingL),
              _buildDebugSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataOverview() {
    return ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
                    const Text(
                'État de la base de données',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
                    Consumer<FirebaseProviderV4>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            _buildDataSummary(
                              'Parcelles',
                              provider.parcelles.length,
                              Icons.landscape,
                    AppTheme.primary,
                            ),
                  const SizedBox(height: AppTheme.spacingS),
                            _buildDataSummary(
                              'Cellules',
                              provider.cellules.length,
                    Icons.grid_view,
                    AppTheme.secondary,
                            ),
                  const SizedBox(height: AppTheme.spacingS),
                            _buildDataSummary(
                              'Chargements',
                              provider.chargements.length,
                              Icons.local_shipping,
                    AppTheme.accent,
                            ),
                  const SizedBox(height: AppTheme.spacingS),
                            _buildDataSummary(
                              'Semis',
                              provider.semis.length,
                    Icons.grass,
                    AppTheme.success,
                            ),
                  const SizedBox(height: AppTheme.spacingS),
                            _buildDataSummary(
                              'Variétés',
                              provider.varietes.length,
                              Icons.eco,
                    AppTheme.info,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _buildDataSummary(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppTheme.spacingM),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.download,
                  color: AppTheme.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
                    const Text(
                'Export des données',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Téléchargez toutes vos données au format JSON pour sauvegarder ou partager.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ModernButton(
            text: 'Exporter toutes les données',
            icon: Icons.file_download,
            backgroundColor: AppTheme.success,
            onPressed: _isExporting ? null : _exportAllData,
            isLoading: _isExporting,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildImportSection() {
    return ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.upload,
                  color: AppTheme.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
                    const Text(
                'Import des données',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Importez des données depuis un fichier JSON. Attention : cela remplacera toutes les données existantes.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ModernButton(
            text: 'Importer depuis un fichier',
            icon: Icons.file_upload,
            backgroundColor: AppTheme.info,
            onPressed: _isImporting ? null : _importData,
            isLoading: _isImporting,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
      children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: AppTheme.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              const Text(
                'Actions de maintenance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Mettez à jour les calculs et synchronisez les données.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ModernButton(
            text: 'Mettre à jour les poids aux normes',
            icon: Icons.calculate,
            backgroundColor: AppTheme.warning,
            onPressed: _updatePoidsNormes,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _exportAllData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final provider = context.read<FirebaseProviderV4>();
      
      // Préparer les données à exporter avec conversion explicite des types
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'parcelles': provider.parcelles.map((p) => _convertParcelleToMap(p)).toList(),
        'cellules': provider.cellules.map((c) => _convertCelluleToMap(c)).toList(),
        'chargements': provider.chargements.map((c) => _convertChargementToMap(c)).toList(),
        'semis': provider.semis.map((s) => _convertSemisToMap(s)).toList(),
        'varietes': provider.varietes.map((v) => _convertVarieteToMap(v)).toList(),
      };

      // Convertir en JSON avec indentation
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // Créer le nom de fichier avec la date
      final now = DateTime.now();
      final fileName = 'mais_tracker_export_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      
      // Pour le web, on utilise la fonctionnalité de téléchargement
      _downloadFile(jsonString, fileName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export réussi : $fileName'),
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
            content: Text('Erreur lors de l\'export : $e'),
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

  // Méthodes de conversion avec gestion explicite des types
  Map<String, dynamic> _convertParcelleToMap(Parcelle parcelle) {
    return {
      'id': parcelle.id,
      'firebaseId': parcelle.firebaseId,
      'nom': parcelle.nom,
      'surface': parcelle.surface,
      'date_creation': parcelle.dateCreation.toIso8601String(),
      'notes': parcelle.notes,
    };
  }

  Map<String, dynamic> _convertCelluleToMap(Cellule cellule) {
    return {
      'id': cellule.id,
      'reference': cellule.reference,
      'capacite': cellule.capacite,
      'date_creation': cellule.dateCreation.toIso8601String(),
      'notes': cellule.notes,
    };
  }

  Map<String, dynamic> _convertChargementToMap(Chargement chargement) {
    return {
      'id': chargement.id,
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
    };
  }

  Map<String, dynamic> _convertSemisToMap(Semis semis) {
    return {
      'id': semis.id,
      'parcelle_id': semis.parcelleId,
      'date': semis.date.toIso8601String(),
      'varietes_surfaces': semis.varietesSurfaces.map((v) => v.toMap()).toList(),
      'notes': semis.notes,
    };
  }

  Map<String, dynamic> _convertVarieteToMap(Variete variete) {
    return {
      'id': variete.id,
      'nom': variete.nom,
      'description': variete.description,
      'date_creation': variete.dateCreation.toIso8601String(),
    };
  }

  void _downloadFile(String content, String fileName) {
    // Pour le web, on utilise la fonctionnalité de téléchargement du navigateur
    final blob = html.Blob([content], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName);
    anchor.click();
    html.Url.revokeObjectUrl(url);
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
              if (!data.containsKey('parcelles') || 
                  !data.containsKey('cellules') || 
                  !data.containsKey('chargements') || 
                  !data.containsKey('semis') || 
                  !data.containsKey('varietes')) {
                throw Exception('Format de fichier invalide');
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

  Future<void> _performImport(Map<String, dynamic> data) async {
        final provider = context.read<FirebaseProviderV4>();
    
    // 1. Vider complètement le localStorage
    await _clearLocalStorage();
    
    // 2. Supprimer toutes les données existantes de Firebase
    await provider.deleteAllData();
    
    // 3. Attendre un peu pour que la suppression soit effective
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 4. Importer les nouvelles données avec conversion explicite des types
    final parcelles = (data['parcelles'] as List)
        .map((p) => _parseParcelleFromMap(Map<String, dynamic>.from(p)))
        .toList();
    
    final cellules = (data['cellules'] as List)
        .map((c) => _parseCelluleFromMap(Map<String, dynamic>.from(c)))
        .toList();
    
    final chargements = (data['chargements'] as List)
        .map((c) => _parseChargementFromMap(Map<String, dynamic>.from(c)))
        .toList();
    
    final semis = (data['semis'] as List)
        .map((s) => _parseSemisFromMap(Map<String, dynamic>.from(s)))
        .toList();
    
    final varietes = (data['varietes'] as List)
        .map((v) => _parseVarieteFromMap(Map<String, dynamic>.from(v)))
        .toList();
    
    // Vérifier si les données sont vides
    final totalData = parcelles.length + cellules.length + chargements.length + semis.length + varietes.length;
    print('📊 Import: $totalData éléments à importer');
    print('   - Parcelles: ${parcelles.length}');
    print('   - Cellules: ${cellules.length}');
    print('   - Chargements: ${chargements.length}');
    print('   - Semis: ${semis.length}');
    print('   - Variétés: ${varietes.length}');
    
    // 5. Ajouter les données une par une
    for (final parcelle in parcelles) {
      await provider.ajouterParcelle(parcelle);
    }
    
    for (final cellule in cellules) {
      await provider.ajouterCellule(cellule);
    }
    
    for (final chargement in chargements) {
      await provider.ajouterChargement(chargement);
    }
    
    for (final semis in semis) {
      await provider.ajouterSemis(semis);
    }
    
    for (final variete in varietes) {
      await provider.ajouterVariete(variete);
    }
    
    // 6. Forcer un refresh des données
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // 7. Forcer le rechargement des données dans le provider
    await _forceDataRefresh(provider);
    
    // 8. Afficher un message approprié selon le contenu
    if (mounted) {
      String message;
      if (totalData == 0) {
        message = 'Import réussi ! Base de données vidée. Rechargement de la page...';
        
        // Pour les bases vides, forcer un rechargement complet de la page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Recharger la page après 2 secondes
        Future.delayed(const Duration(seconds: 2), () {
          html.window.location.reload();
        });
      } else {
        message = 'Import réussi ! $totalData éléments importés.';
        
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    }
  }

  // Fonction pour forcer le refresh des données
  Future<void> _forceDataRefresh(FirebaseProviderV4 provider) async {
    try {
      print('🔄 Début du refresh forcé...');
      
      // Forcer le rechargement des données depuis Firebase
      await provider.refreshAllData();
      
      // Attendre un peu pour que les listeners se mettent à jour
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Vérifier l'état des données après refresh
      print('📊 État après refresh:');
      print('   - Parcelles: ${provider.parcelles.length}');
      print('   - Cellules: ${provider.cellules.length}');
      print('   - Chargements: ${provider.chargements.length}');
      print('   - Semis: ${provider.semis.length}');
      print('   - Variétés: ${provider.varietes.length}');
      
      print('✅ Données rafraîchies avec succès');
    } catch (e) {
      print('⚠️ Erreur lors du refresh des données: $e');
    }
  }

  // Fonction pour vider le localStorage
  Future<void> _clearLocalStorage() async {
    try {
      // Vider toutes les clés liées à l'application
      html.window.localStorage.remove('parcelles');
      html.window.localStorage.remove('cellules');
      html.window.localStorage.remove('chargements');
      html.window.localStorage.remove('semis');
      html.window.localStorage.remove('varietes');
      html.window.localStorage.remove('firebase_data');
      html.window.localStorage.remove('user_data');
      
      // Vider toutes les clés qui commencent par 'firebase_'
      final keys = html.window.localStorage.keys.toList();
      for (final key in keys) {
        if (key.startsWith('firebase_') || key.startsWith('parcelle_') || 
            key.startsWith('cellule_') || key.startsWith('chargement_') ||
            key.startsWith('semis_') || key.startsWith('variete_')) {
          html.window.localStorage.remove(key);
        }
      }
      
      print('✅ LocalStorage vidé avec succès');
    } catch (e) {
      print('⚠️ Erreur lors du vidage du localStorage: $e');
    }
  }

  // Méthodes de parsing avec conversion explicite des types
  Parcelle _parseParcelleFromMap(Map<String, dynamic> map) {
    // Gérer les clés stables Firebase (ex: "f_parcelle_1_11200")
    String? firebaseId;
    int? id;
    
    if (map['id'] != null) {
      final idValue = map['id'].toString();
      if (idValue.startsWith('f_')) {
        // C'est une clé stable Firebase
        firebaseId = idValue;
        id = null; // Pas d'ID numérique pour les clés stables
      } else {
        // C'est un ID numérique
        id = int.tryParse(idValue);
      }
    }
    
    return Parcelle(
      id: id,
      firebaseId: firebaseId ?? map['firebaseId']?.toString(),
      nom: map['nom'].toString(),
      surface: double.tryParse(map['surface'].toString()) ?? 0.0,
      dateCreation: DateTime.tryParse(map['date_creation'].toString()) ?? DateTime.now(),
      notes: map['notes']?.toString(),
    );
  }

  Cellule _parseCelluleFromMap(Map<String, dynamic> map) {
    // Gérer les clés stables Firebase
    String? firebaseId;
    int? id;
    
    if (map['id'] != null) {
      final idValue = map['id'].toString();
      if (idValue.startsWith('f_')) {
        firebaseId = idValue;
        id = null;
      } else {
        id = int.tryParse(idValue);
      }
    }
    
    return Cellule(
      id: id,
      reference: map['reference'].toString(),
      dateCreation: DateTime.tryParse(map['date_creation'].toString()) ?? DateTime.now(),
      notes: map['notes']?.toString(),
    );
  }

  Chargement _parseChargementFromMap(Map<String, dynamic> map) {
    // Gérer les clés stables Firebase
    String? firebaseId;
    int? id;
    
    if (map['id'] != null) {
      final idValue = map['id'].toString();
      if (idValue.startsWith('f_')) {
        firebaseId = idValue;
        id = null;
      } else {
        id = int.tryParse(idValue);
      }
    }
    
    return Chargement(
      id: id,
      celluleId: int.tryParse(map['cellule_id'].toString()) ?? 0,
      parcelleId: int.tryParse(map['parcelle_id'].toString()) ?? 0,
      remorque: map['remorque'].toString(),
      dateChargement: DateTime.tryParse(map['date_chargement'].toString()) ?? DateTime.now(),
      poidsPlein: double.tryParse(map['poids_plein'].toString()) ?? 0.0,
      poidsVide: double.tryParse(map['poids_vide'].toString()) ?? 0.0,
      poidsNet: double.tryParse(map['poids_net'].toString()) ?? 0.0,
      poidsNormes: double.tryParse(map['poids_normes'].toString()) ?? 0.0,
      humidite: double.tryParse(map['humidite'].toString()) ?? 0.0,
      variete: map['variete'].toString(),
    );
  }

  Semis _parseSemisFromMap(Map<String, dynamic> map) {
    final varietesSurfacesData = map['varietes_surfaces'] as List? ?? [];
    final varietesSurfaces = varietesSurfacesData
        .map((v) => VarieteSurface.fromMap(Map<String, dynamic>.from(v)))
        .toList();
    
    // Gérer les clés stables Firebase
    String? firebaseId;
    int? id;
    
    if (map['id'] != null) {
      final idValue = map['id'].toString();
      if (idValue.startsWith('f_')) {
        firebaseId = idValue;
        id = null;
      } else {
        id = int.tryParse(idValue);
      }
    }
    
    return Semis(
      id: id,
      parcelleId: int.tryParse(map['parcelle_id'].toString()) ?? 0,
      date: DateTime.tryParse(map['date'].toString()) ?? DateTime.now(),
      varietesSurfaces: varietesSurfaces,
      notes: map['notes']?.toString(),
    );
  }

  Variete _parseVarieteFromMap(Map<String, dynamic> map) {
    // Gérer les clés stables Firebase
    String? firebaseId;
    int? id;
    
    if (map['id'] != null) {
      final idValue = map['id'].toString();
      if (idValue.startsWith('f_')) {
        firebaseId = idValue;
        id = null;
      } else {
        id = int.tryParse(idValue);
      }
    }
    
    return Variete(
      id: id,
      nom: map['nom'].toString(),
      description: map['description']?.toString(),
      dateCreation: DateTime.tryParse(map['date_creation'].toString()) ?? DateTime.now(),
    );
  }

  Future<void> _updatePoidsNormes() async {
    try {
      await context.read<FirebaseProviderV4>().updateAllChargementsPoidsNormes();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Poids aux normes mis à jour avec succès'),
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
            content: Text('Erreur : $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    }
  }


  Widget _buildDebugSection() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.bug_report,
                  color: AppTheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              const Text(
                'Diagnostic des données',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Analysez la cohérence des données et les problèmes de jointure.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ModernButton(
            text: 'Ouvrir l\'écran de diagnostic',
            icon: Icons.analytics,
            backgroundColor: AppTheme.error,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DebugScreen()),
            ),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
} 