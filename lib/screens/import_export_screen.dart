import '../models/variete_surface.dart';
import '../models/produit_traitement.dart';
import '../models/produit.dart';
import '../models/traitement.dart';
import '../models/vente.dart';
import '../models/semis.dart';
import '../models/chargement.dart';
import '../models/cellule.dart';
import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/firebase_provider_v4.dart';
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
      backgroundColor: AppTheme.surface(context),
      appBar: AppBar(
        title: const Text('Import/Export'),
        backgroundColor: AppTheme.accent(context),
        foregroundColor: AppTheme.onPrimary(context),
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              _buildDataOverview(),
              SizedBox(height: AppTheme.spacingL),
              _buildExportSection(),
              SizedBox(height: AppTheme.spacingL),
              _buildImportSection(),
              SizedBox(height: AppTheme.spacingL),
              _buildActionsSection(),
              SizedBox(height: AppTheme.spacingL),
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
                padding: AppTheme.padding(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.primary(context).withOpacity(0.1),
                  borderRadius: AppTheme.radius(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.analytics,
                  color: AppTheme.primary(context),
                  size: AppTheme.iconSizeM,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
                    Text(
                'État de la base de données',
                      style: AppTheme.textTheme(context).titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
            ],
          ),
          SizedBox(height: AppTheme.spacingL),
                    Consumer<FirebaseProviderV4>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            _buildDataSummary(
                              'Parcelles',
                              provider.parcelles.length,
                              Icons.landscape,
                    AppTheme.primary(context),
                            ),
                  const SizedBox(height: AppTheme.spacingS),
                            _buildDataSummary(
                              'Cellules',
                              provider.cellules.length,
                    Icons.grid_view,
                    AppTheme.secondary(context),
                            ),
                  const SizedBox(height: AppTheme.spacingS),
                            _buildDataSummary(
                              'Chargements',
                              provider.chargements.length,
                              Icons.local_shipping,
                    AppTheme.accent(context),
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
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.radius(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppTheme.iconSizeM),
          SizedBox(width: AppTheme.spacingM),
          Text(
            label,
            style: AppTheme.textTheme(context).titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppTheme.radius(AppTheme.radiusSmall),
            ),
            child: Text(
              count.toString(),
              style: AppTheme.textTheme(context).titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.onPrimary(context),
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
                padding: AppTheme.padding(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: AppTheme.radius(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.download,
                  color: AppTheme.success,
                  size: AppTheme.iconSizeM,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
                    Text(
                'Export des données',
                      style: AppTheme.textTheme(context).titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'Téléchargez toutes vos données au format JSON pour sauvegarder ou partager.',
            style: AppTheme.textTheme(context).bodyMedium?.copyWith(
              color: AppTheme.textSecondary(context),
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
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
                padding: AppTheme.padding(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: AppTheme.radius(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.upload,
                  color: AppTheme.info,
                  size: AppTheme.iconSizeM,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
                    Text(
                'Import des données',
                      style: AppTheme.textTheme(context).titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'Importez des données depuis un fichier JSON. Attention : cela remplacera toutes les données existantes.',
            style: AppTheme.textTheme(context).bodyMedium?.copyWith(
              color: AppTheme.textSecondary(context),
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
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
                padding: AppTheme.padding(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: AppTheme.radius(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.refresh,
                  color: AppTheme.warning,
                  size: AppTheme.iconSizeM,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Text(
                'Actions de maintenance',
                style: AppTheme.textTheme(context).titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingM),
        Text(
            'Mettez à jour les calculs et synchronisez les données.',
            style: AppTheme.textTheme(context).bodyMedium?.copyWith(
              color: AppTheme.textSecondary(context),
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
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
      // Export exact via API REST Firebase (identique console)
      await _exportExactJsonAndDownload();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Export réussi - JSON identique à la console Firebase'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
              borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
  // ===== API REST FIREBASE (IDENTIQUE CONSOLE) =====
  // 1) Utiliser le farmId par défaut (pas de récupération via API)
  Future<String> _resolveFarmId() async {
    // Utiliser directement le farmId par défaut
    return 'gaec_berard';
  }
  // 3) EXPORT — téléchargement direct depuis Firebase (sans reconstruction)
  Future<void> _exportExactJsonAndDownload() async {
    try {
      print('🔄 Téléchargement direct depuis Firebase...');
      
      final farmId = await _resolveFarmId();
      final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
      
      // URL REST directe vers Firebase (URL fixe)
      final url = 'https://farmgaec-default-rtdb.firebaseio.com/farms/$farmId.json?auth=$idToken&format=export&print=pretty';
      
      print('📡 URL REST: $url');
      
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        throw Exception('Téléchargement échoué: ${res.statusCode} ${res.body}');
      }
      // Télécharger le JSON brut (identique console)
      final now = DateTime.now();
      final fileName = 'firebase_export_${farmId}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';
      
      final blob = html.Blob([res.body], 'application/json');
      final href = html.Url.createObjectUrlFromBlob(blob);
      final a = html.AnchorElement(href: href)
        ..download = fileName
        ..click();
      html.Url.revokeObjectUrl(href);
      
      print('✅ Téléchargement terminé: $fileName');
    } catch (e) {
      print('❌ Erreur téléchargement: $e');
      rethrow;
    }
  }
  // 4) IMPORT — remplacement direct dans Firebase (sans reconstruction)
  Future<void> _importExactJsonReplace(String jsonString) async {
    try {
      print('🔄 Remplacement direct dans Firebase...');
      
      final farmId = await _resolveFarmId();
      final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
      
      // URL REST directe vers Firebase (URL fixe)
      final url = 'https://farmgaec-default-rtdb.firebaseio.com/farms/$farmId.json?auth=$idToken';
      
      print('📡 URL REST: $url');
      
      final res = await http.put(
        Uri.parse(url),
        headers: {'content-type': 'application/json'},
        body: jsonString, // JSON brut tel quel
      );
      
      if (res.statusCode >= 400) {
        throw Exception('Remplacement échoué: ${res.statusCode} ${res.body}');
      }
      
      print('✅ Remplacement terminé');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Import réussi - Base de données remplacée directement'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.radius(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur remplacement: $e');
      rethrow;
    }
  }
  // ===== ANCIENNES MÉTHODES (SUPPRIMÉES - REMPLACÉES PAR API REST) =====
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
              
              // Afficher une confirmation avant l'import
              final confirmed = await _showImportConfirmation();
              if (!confirmed) return;
              
              // Import direct du JSON Firebase (sans validation de structure)
              await _importExactJsonReplace(jsonString);
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
              borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
          borderRadius: AppTheme.radius(AppTheme.radiusLarge),
        ),
        content: const Text(
          'Cette action va remplacer directement la base de données Firebase. Toutes les données existantes seront perdues. Êtes-vous sûr de vouloir continuer ?',
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
  // ===== ANCIENNES MÉTHODES D'IMPORT (SUPPRIMÉES - REMPLACÉES PAR API REST) =====
  // Fonction pour forcer le refresh des données
  // Méthode utilitaire pour récupérer une valeur parmi plusieurs clés possibles
  T? _pick<T>(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key) && map[key] != null) {
        return map[key] as T?;
      }
    }
    return null;
  }
  Future<void> _forceDataRefresh(FirebaseProviderV4 provider) async {
    try {
      print('🔄 Début du refresh forcé...');
      
      // Forcer le rechargement des données depuis Firebase
      // L'initialisation est gérée par AuthGate
      
      // Attendre un peu pour que les listeners se mettent à jour
      await Future.delayed(const Duration(milliseconds: 1000));
      
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
      celluleId: _pick(map, ['celluleId', 'cellule_id', 'cellule', 'celluleRef'])?.toString() ?? '',
      parcelleId: _pick(map, ['parcelleId', 'parcelle_id', 'parcelle', 'parcelleRef'])?.toString() ?? '',
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
      parcelleId: map['parcelle_id']?.toString() ?? '',
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
              borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
              borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
                padding: AppTheme.padding(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: AppTheme.radius(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.bug_report,
                  color: AppTheme.error,
                  size: AppTheme.iconSizeM,
                ),
              ),
              SizedBox(width: AppTheme.spacingM),
              Text(
                'Diagnostic des données',
                style: AppTheme.textTheme(context).titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            'Analysez la cohérence des données et les problèmes de jointure.',
            style: AppTheme.textTheme(context).bodyMedium?.copyWith(
              color: AppTheme.textSecondary(context),
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
        ],
      ),
    );
  }
  // Méthodes de parsing pour les nouvelles entités
  dynamic _parseVenteFromMap(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'firebaseId': map['firebaseId'],
      'date': DateTime.tryParse(map['date'].toString()) ?? DateTime.now(),
      'numeroTicket': map['numeroTicket']?.toString() ?? '',
      'client': map['client']?.toString() ?? '',
      'immatriculationRemorque': map['immatriculationRemorque']?.toString() ?? '',
      'cmr': map['cmr']?.toString() ?? '',
      'poidsVide': double.tryParse(map['poidsVide'].toString()) ?? 0.0,
      'poidsPlein': double.tryParse(map['poidsPlein'].toString()) ?? 0.0,
      'poidsNet': double.tryParse(map['poidsNet'].toString()),
      'ecartPoidsNet': double.tryParse(map['ecartPoidsNet'].toString()),
      'payer': map['payer'] == true,
      'prix': double.tryParse(map['prix'].toString()),
      'annee': int.tryParse(map['annee'].toString()) ?? DateTime.now().year,
      'terminee': map['terminee'] == true,
    };
  }
  dynamic _parseTraitementFromMap(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'firebaseId': map['firebaseId'],
      'parcelleId': map['parcelleId']?.toString() ?? '',
      'date': DateTime.fromMillisecondsSinceEpoch(map['date'] ?? DateTime.now().millisecondsSinceEpoch),
      'annee': int.tryParse(map['annee'].toString()) ?? DateTime.now().year,
      'notes': map['notes']?.toString(),
      'produits': (map['produits'] as List?)?.map((p) => _parseProduitTraitementFromMap(Map<String, dynamic>.from(p))).toList() ?? [],
      'coutTotal': double.tryParse(map['coutTotal'].toString()) ?? 0.0,
    };
  }
  dynamic _parseProduitTraitementFromMap(Map<String, dynamic> map) {
    return {
      'produitId': map['produitId']?.toString() ?? '',
      'nomProduit': map['nomProduit']?.toString() ?? '',
      'quantite': double.tryParse(map['quantite'].toString()) ?? 0.0,
      'mesure': map['mesure']?.toString() ?? '',
      'prixUnitaire': double.tryParse(map['prixUnitaire'].toString()) ?? 0.0,
      'coutTotal': double.tryParse(map['coutTotal'].toString()) ?? 0.0,
      'date': DateTime.fromMillisecondsSinceEpoch(map['date'] ?? DateTime.now().millisecondsSinceEpoch),
    };
  }
  dynamic _parseProduitFromMap(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'firebaseId': map['firebaseId'],
      'nom': map['nom']?.toString(),
      'mesure': map['mesure']?.toString(),
      'notes': map['notes']?.toString(),
      'prixParAnnee': Map<String, dynamic>.from(map['prixParAnnee'] ?? {}),
    };
  }
} 