import '../models/semis.dart';
import '../models/parcelle.dart';
import '../models/variete.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import 'semis_form_screen.dart';
import 'varietes_screen.dart';

class SemisScreen extends StatefulWidget {
  const SemisScreen({Key? key}) : super(key: key);

  @override
  State<SemisScreen> createState() => _SemisScreenState();
}

class _SemisScreenState extends State<SemisScreen> with TickerProviderStateMixin {
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
      title: 'Semis',
      actions: [
        IconButton(
          icon: const Icon(Icons.eco),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VarietesScreen()),
          ),
          tooltip: 'Gérer les variétés',
        ),
      ],
      children: [
        Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) {
            final semis = provider.semis;
            final parcelles = provider.parcelles;
            final varietes = provider.varietes;
            if (semis.isEmpty) {
              return _buildEmptyState();
            }

            // Utiliser les maps optimisées du provider
            final parcellesById = provider.parcellesById;
            final varietesById = provider.varietesById;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: semis.map((semis) => _buildSemisCard(
                  context,
                  semis,
                  parcellesById,
                  varietesById,
                )).toList(),
              ),
            );
          },
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SemisFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau semis'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppThemePageBuilder.buildEmptyState(
      context: context,
      message: 'Aucun semis enregistré\nCommencez par ajouter votre premier semis',
      icon: Icons.agriculture,
      actionText: 'Ajouter un semis',
      onAction: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SemisFormScreen(),
        ),
      ),
    );
  }

  Widget _buildSemisCard(
    BuildContext context,
    Semis semis,
    Map<String, Parcelle> parcellesById,
    Map<String, Variete> varietesById,
  ) {
    final parcelle = parcellesById[semis.parcelleId];
    final variete = varietesById[semis.id.toString()];

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
                          'Semis #${semis.id}',
                          style: AppTheme.textTheme(context).titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          '${semis.date.day}/${semis.date.month}/${semis.date.year}',
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
                        _confirmDelete(context, semis);
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
                      'Parcelle',
                      parcelle?.nom ?? 'Inconnue',
                      Icons.landscape,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Variété',
                      variete?.nom ?? 'Inconnue',
                      Icons.eco,
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
                      'Surface',
                      '1.0 ha',
                      Icons.area_chart,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoRow(
                      context,
                      'Densité',
                      '80000 graines/ha',
                      Icons.grid_view,
                    ),
                  ),
                ],
              ),
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
                      'Observations',
                      style: AppTheme.textTheme(context).titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary(context),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      'Semis effectué avec succès',
                      style: AppTheme.textTheme(context).bodySmall?.copyWith(
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
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

  void _confirmDelete(BuildContext context, Semis semis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le semis #${semis.id} ?'),
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