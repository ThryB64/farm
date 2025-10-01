import '../models/parcelle.dart';
import '../models/cellule.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../models/variete.dart';
import '../models/produit.dart';
import '../models/traitement.dart';
import '../models/vente.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({Key? key}) : super(key: key);

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemePageBuilder.buildScrollablePage(
      context: context,
      title: 'Import/Export',
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataOverview(),
              const SizedBox(height: AppTheme.spaceLg),
              _buildExportSection(),
              const SizedBox(height: AppTheme.spaceLg),
              _buildImportSection(),
              const SizedBox(height: AppTheme.spaceLg),
              _buildActionsSection(),
              const SizedBox(height: AppTheme.spaceLg),
              _buildDebugSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataOverview() {
    return Consumer<FirebaseProviderV4>(
      builder: (context, provider, child) {
        final parcelles = provider.parcelles;
        final cellules = provider.cellules;
        final chargements = provider.chargements;
        final semis = provider.semis;
        final varietes = provider.varietes;
        final produits = provider.produits;
        final traitements = provider.traitements;
        final ventes = provider.ventes;

        return ModernCard(
          child: Padding(
            padding: AppTheme.padding(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aperçu des données',
                  style: AppTheme.textTheme(context).titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Parcelles',
                        parcelles.length.toString(),
                        Icons.landscape,
                        AppTheme.primary(context),
                      ),
                    ),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Cellules',
                        cellules.length.toString(),
                        Icons.storage,
                        AppTheme.secondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Chargements',
                        chargements.length.toString(),
                        Icons.local_shipping,
                        AppTheme.accent(context),
                      ),
                    ),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Semis',
                        semis.length.toString(),
                        Icons.agriculture,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Variétés',
                        varietes.length.toString(),
                        Icons.eco,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Produits',
                        produits.length.toString(),
                        Icons.inventory,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Traitements',
                        traitements.length.toString(),
                        Icons.science,
                        AppTheme.primary(context),
                      ),
                    ),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Ventes',
                        ventes.length.toString(),
                        Icons.sell,
                        AppTheme.secondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: AppTheme.iconSizeL,
            color: color,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            value,
            style: AppTheme.textTheme(context).headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTheme.textTheme(context).bodySmall?.copyWith(
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return ModernCard(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export des données',
              style: AppTheme.textTheme(context).titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Exportez toutes vos données vers un fichier JSON pour sauvegarder ou partager vos informations.',
              style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                color: AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Exporter tout',
                    onPressed: () => _exportAllData(),
                    icon: Icons.download,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: ModernOutlinedButton(
                    text: 'Exporter sélectionné',
                    onPressed: () => _exportSelectedData(),
                    icon: Icons.checklist,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return ModernCard(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import des données',
              style: AppTheme.textTheme(context).titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Importez des données depuis un fichier JSON pour restaurer ou fusionner vos informations.',
              style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                color: AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Importer depuis fichier',
                    onPressed: () => _importFromFile(),
                    icon: Icons.upload,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: ModernOutlinedButton(
                    text: 'Importer depuis URL',
                    onPressed: () => _importFromUrl(),
                    icon: Icons.link,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return ModernCard(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions avancées',
              style: AppTheme.textTheme(context).titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Synchroniser avec Firebase',
                    onPressed: () => _syncWithFirebase(),
                    icon: Icons.sync,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: ModernOutlinedButton(
                    text: 'Nettoyer les données',
                    onPressed: () => _cleanData(),
                    icon: Icons.cleaning_services,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection() {
    return Consumer<FirebaseProviderV4>(
      builder: (context, provider, child) {
        return ModernCard(
          child: Padding(
            padding: AppTheme.padding(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations de debug',
                  style: AppTheme.textTheme(context).titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _buildDebugInfo(
                  context,
                  'État de connexion',
                  'Connecté',
                  Colors.green,
                ),
                _buildDebugInfo(
                  context,
                  'Dernière synchronisation',
                  'Jamais',
                  AppTheme.textSecondary(context),
                ),
                _buildDebugInfo(
                  context,
                  'Nombre de tentatives',
                  '0',
                  AppTheme.textSecondary(context),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        text: 'Forcer la synchronisation',
                        onPressed: () => _forceSync(provider),
                        icon: Icons.refresh,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      child: ModernOutlinedButton(
                        text: 'Vider le cache',
                        onPressed: () => _clearCache(provider),
                        icon: Icons.clear_all,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebugInfo(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.textTheme(context).bodyMedium?.copyWith(
              color: AppTheme.textSecondary(context),
            ),
          ),
          Text(
            value,
            style: AppTheme.textTheme(context).bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _exportAllData() {
    // TODO: Implémenter l'export de toutes les données
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export de toutes les données en cours...')),
    );
  }

  void _exportSelectedData() {
    // TODO: Implémenter l'export sélectionné
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export sélectionné en cours...')),
    );
  }

  void _importFromFile() {
    // TODO: Implémenter l'import depuis fichier
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import depuis fichier en cours...')),
    );
  }

  void _importFromUrl() {
    // TODO: Implémenter l'import depuis URL
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import depuis URL en cours...')),
    );
  }

  void _syncWithFirebase() {
    // TODO: Implémenter la synchronisation avec Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synchronisation avec Firebase en cours...')),
    );
  }

  void _cleanData() {
    // TODO: Implémenter le nettoyage des données
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nettoyage des données en cours...')),
    );
  }

  void _forceSync(FirebaseProviderV4 provider) {
    // TODO: Implémenter la synchronisation forcée
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synchronisation forcée en cours...')),
    );
  }

  void _clearCache(FirebaseProviderV4 provider) {
    // TODO: Implémenter le vidage du cache
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache vidé avec succès')),
    );
  }
}