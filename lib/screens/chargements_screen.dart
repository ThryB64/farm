import '../models/chargement.dart';
import '../models/cellule.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import 'chargement_form_screen.dart';

class ChargementsScreen extends StatefulWidget {
  const ChargementsScreen({Key? key}) : super(key: key);

  @override
  State<ChargementsScreen> createState() => _ChargementsScreenState();
}

class _ChargementsScreenState extends State<ChargementsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int? _selectedYear;
  bool _showDebugInfo = false;

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
      title: 'Chargements',
      actions: [
        IconButton(
          onPressed: () => setState(() => _showDebugInfo = !_showDebugInfo),
          icon: Icon(_showDebugInfo ? Icons.visibility_off : Icons.bug_report),
          tooltip: _showDebugInfo ? 'Masquer debug' : 'Afficher debug',
        ),
      ],
      children: [
        Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) {
            final chargements = provider.chargements;
            final cellules = provider.cellules;
            final parcelles = provider.parcelles;
            if (chargements.isEmpty) {
              return _buildEmptyState();
            }

            // Utiliser les maps optimisées du provider
            final cellulesById = provider.cellulesById;
            final parcellesById = provider.parcellesById;

            // Grouper les chargements par année
            final Map<int, List<Chargement>> chargementsParAnnee = {};
            for (var chargement in chargements) {
              final annee = chargement.dateChargement.year;
              chargementsParAnnee.putIfAbsent(annee, () => []).add(chargement);
            }

            // Trier les années par ordre décroissant
            final List<int> annees = chargementsParAnnee.keys.toList()..sort((a, b) => b.compareTo(a));

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Filtres par année
                  _buildYearFilters(annees),
                  const SizedBox(height: AppTheme.spaceLg),
                  
                  // Liste des chargements
                  ...annees.map((annee) => _buildYearSection(
                    context,
                    annee,
                    chargementsParAnnee[annee]!,
                    cellulesById,
                    parcellesById,
                  )),
                ],
              ),
            );
          },
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChargementFormScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppThemePageBuilder.buildEmptyState(
      context: context,
      message: 'Aucun chargement enregistré\nCommencez par ajouter votre premier chargement',
      icon: Icons.local_shipping,
      actionText: 'Ajouter un chargement',
      onAction: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChargementFormScreen(),
        ),
      ),
    );
  }

  Widget _buildYearFilters(List<int> annees) {
    return Container(
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: AppTheme.createCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrer par année',
            style: AppTheme.textTheme(context).titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Wrap(
            spacing: AppTheme.spaceSm,
            children: [
              FilterChip(
                label: const Text('Toutes'),
                selected: _selectedYear == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedYear = selected ? null : _selectedYear;
                  });
                },
              ),
              ...annees.map((annee) => FilterChip(
                label: Text(annee.toString()),
                selected: _selectedYear == annee,
                onSelected: (selected) {
                  setState(() {
                    _selectedYear = selected ? annee : null;
                  });
                },
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearSection(
    BuildContext context,
    int annee,
    List<Chargement> chargements,
    Map<String, Cellule> cellulesById,
    Map<String, Parcelle> parcellesById,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Année $annee',
            style: AppTheme.textTheme(context).headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          ...chargements.map((chargement) => _buildChargementCard(
            context,
            chargement,
            cellulesById,
            parcellesById,
          )),
        ],
      ),
    );
  }

  Widget _buildChargementCard(
    BuildContext context,
    Chargement chargement,
    Map<String, Cellule> cellulesById,
    Map<String, Parcelle> parcellesById,
  ) {
    final cellule = cellulesById[chargement.celluleId];
    final parcelle = parcellesById[chargement.parcelleId];
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: ModernCard(
        child: Padding(
          padding: AppTheme.padding(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chargement #${chargement.id}',
                          style: AppTheme.textTheme(context).titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          '${chargement.dateChargement.day}/${chargement.dateChargement.month}/${chargement.dateChargement.year}',
                          style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // TODO: Implémenter l'édition
                      } else if (value == 'delete') {
                        _confirmDelete(context, chargement);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: AppTheme.spaceSm),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: AppTheme.spaceSm),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Cellule',
                      cellule?.nom ?? 'Inconnue',
                      Icons.storage,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Parcelle',
                      parcelle?.nom ?? 'Inconnue',
                      Icons.landscape,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Poids brut',
                      '${chargement.poidsNet.toStringAsFixed(1)} kg',
                      Icons.scale,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Poids net',
                      '${chargement.poidsNet.toStringAsFixed(1)} kg',
                      Icons.balance,
                    ),
                  ),
                ],
              ),
              if (_showDebugInfo) ...[
                const SizedBox(height: AppTheme.spaceMd),
                Container(
                  padding: AppTheme.padding(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Info',
                        style: AppTheme.textTheme(context).titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary(context),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        'ID: ${chargement.id}',
                        style: AppTheme.textTheme(context).bodySmall?.copyWith(
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      Text(
                        'Cellule ID: ${chargement.celluleId}',
                        style: AppTheme.textTheme(context).bodySmall?.copyWith(
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      Text(
                        'Parcelle ID: ${chargement.parcelleId}',
                        style: AppTheme.textTheme(context).bodySmall?.copyWith(
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppTheme.iconSizeS,
          color: AppTheme.textSecondary(context),
        ),
        const SizedBox(width: AppTheme.spaceXs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.textTheme(context).bodySmall?.copyWith(
                  color: AppTheme.textSecondary(context),
                ),
              ),
              Text(
                value,
                style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Chargement chargement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le chargement #${chargement.id} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la suppression
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}