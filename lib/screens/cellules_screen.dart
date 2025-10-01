import '../models/cellule.dart';
import '../models/chargement.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../providers/theme_provider.dart';
import 'cellule_form_screen.dart';
import 'cellule_details_screen.dart';
import 'fermer_cellule_screen.dart';

class CellulesScreen extends StatefulWidget {
  const CellulesScreen({Key? key}) : super(key: key);

  @override
  State<CellulesScreen> createState() => _CellulesScreenState();
}

class _CellulesScreenState extends State<CellulesScreen> with TickerProviderStateMixin {
  int? _selectedYear;
  final Map<String, AnimationController> _animationControllers = {};

  @override
  void dispose() {
    // Nettoyer les contrôleurs d'animation
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemePageBuilder.buildScrollablePage(
      context: context,
      title: 'Cellules',
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CelluleFormScreen()),
        ),
        backgroundColor: AppTheme.primary(context),
        child: Icon(Icons.add, color: AppTheme.onPrimary(context)),
      ),
      children: [
        Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) {
            final cellules = provider.cellules;
            final chargements = provider.chargements;
            
            if (cellules.isEmpty) {
              return AppThemePageBuilder.buildEmptyState(
                context: context,
                message: 'Aucune cellule enregistrée\nCommencez par ajouter votre première cellule',
                icon: Icons.warehouse,
                actionText: 'Ajouter une cellule',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CelluleFormScreen()),
                ),
              );
            }

            // Grouper les cellules par année de création
            final Map<int, List<Cellule>> cellulesParAnnee = {};
            for (var cellule in cellules) {
              final annee = cellule.dateCreation.year;
              if (!cellulesParAnnee.containsKey(annee)) {
                cellulesParAnnee[annee] = [];
              }
              cellulesParAnnee[annee]!.add(cellule);
            }

            // Trier les années par ordre décroissant
            final List<int> annees = cellulesParAnnee.keys.toList()..sort((a, b) => b.compareTo(a));

            // Trier les cellules par date décroissante dans chaque année
            cellulesParAnnee.forEach((annee, cellules) {
              cellules.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
            });

            // Si aucune année n'est sélectionnée, sélectionner la plus récente
            if (_selectedYear == null && annees.isNotEmpty) {
              _selectedYear = annees.first;
            } else if (_selectedYear == null) {
              _selectedYear = DateTime.now().year;
            }

            // Calculer les statistiques de l'année sélectionnée
            final chargementsAnnee = _selectedYear != null ? chargements.where(
              (c) => c.dateChargement.year == _selectedYear &&
                     cellulesParAnnee[_selectedYear]!.any((cell) => (cell.firebaseId ?? cell.id.toString()) == c.celluleId)
            ).toList() : [];

            final poidsTotalNormeAnnee = chargementsAnnee.fold<double>(
              0,
              (sum, c) => sum + c.poidsNormes,
            );

            final poidsTotalNetAnnee = chargementsAnnee.fold<double>(
              0,
              (sum, c) => sum + c.poidsNet,
            );

            return Column(
              children: [
                // Filtres et statistiques
                AppThemePageBuilder.buildContentSection(
                  context: context,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: AppTheme.createInputDecoration(
                          context,
                          labelText: 'Année',
                          prefixIcon: Icons.calendar_today,
                        ),
                        items: annees.map((year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Poids Net',
                              '${(poidsTotalNetAnnee / 1000).toStringAsFixed(1)} T',
                              Icons.scale,
                              AppTheme.primary(context),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: _buildStatCard(
                              'Poids Normé',
                              '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(1)} T',
                              Icons.trending_up,
                              AppTheme.secondary(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                
                // Liste des cellules
                AppThemePageBuilder.buildItemList(
                  context: context,
                  items: cellulesParAnnee[_selectedYear]?.map((cellule) => _buildCelluleCard(cellule, provider)).toList() ?? [],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            value,
            style: AppTheme.textTheme(context).titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
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

  Widget _buildCelluleCard(Cellule cellule, FirebaseProviderV4 provider) {
    final celluleId = cellule.firebaseId ?? cellule.id.toString();
    final chargementsCellule = provider.chargements
        .where((c) => c.celluleId == celluleId)
        .toList();

    // Calculer le taux de remplissage
    final capaciteMax = 1000.0; // Capacité maximale en kg
    final poidsActuel = chargementsCellule.fold<double>(0, (sum, c) => sum + c.poidsNet);
    final tauxRemplissage = (poidsActuel / capaciteMax * 100).clamp(0, 100);

    return ModernCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CelluleDetailsScreen(cellule: cellule),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppTheme.padding(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.primary(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Icon(
                  Icons.warehouse,
                  color: AppTheme.primary(context),
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cellule.nom,
                      style: AppTheme.textTheme(context).titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      'Référence: ${cellule.reference}',
                      style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                    Text(
                      'Créée le ${_formatDate(cellule.dateCreation)}',
                      style: AppTheme.textTheme(context).bodySmall?.copyWith(
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedLock(cellule),
                  const SizedBox(width: AppTheme.spaceSm),
                  IconButton(
                    icon: Icon(Icons.info, color: AppTheme.primary(context), size: AppTheme.iconSizeM),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CelluleDetailsScreen(cellule: cellule),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          
          if (chargementsCellule.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceSm),
            LinearProgressIndicator(
              value: tauxRemplissage / 100,
              backgroundColor: AppTheme.primary(context).withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                tauxRemplissage > 90
                    ? AppTheme.error
                    : tauxRemplissage > 70
                        ? AppTheme.warning
                        : AppTheme.success,
              ),
              minHeight: AppTheme.spaceSm,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remplissage: ${tauxRemplissage.toStringAsFixed(1)}%',
                  style: AppTheme.textTheme(context).bodySmall?.copyWith(
                    color: AppTheme.textSecondary(context),
                  ),
                ),
                Text(
                  '${chargementsCellule.length} chargement(s)',
                  style: AppTheme.textTheme(context).bodySmall?.copyWith(
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Widget animé pour le cadenas
  Widget _buildAnimatedLock(Cellule cellule) {
    final celluleId = cellule.firebaseId ?? cellule.id.toString();
    
    // Créer le contrôleur d'animation s'il n'existe pas
    if (!_animationControllers.containsKey(celluleId)) {
      _animationControllers[celluleId] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      
      // Définir l'état initial basé sur l'état de la cellule
      if (cellule.fermee) {
        _animationControllers[celluleId]!.value = 1.0;
      }
    }
    
    final animation = _animationControllers[celluleId]!;
    
    return GestureDetector(
      onTap: () => _toggleCelluleState(cellule),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (animation.value * 0.1),
            child: Icon(
              cellule.fermee ? Icons.lock : Icons.lock_open,
              color: cellule.fermee ? AppTheme.error : AppTheme.success,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  // Méthode pour basculer l'état de la cellule
  void _toggleCelluleState(Cellule cellule) async {
    final celluleId = cellule.firebaseId ?? cellule.id.toString();
    final controller = _animationControllers[celluleId];
    
    if (controller == null) return;
    
    if (cellule.fermee) {
      // Ouvrir la cellule directement
      await controller.reverse();
      final updatedCellule = Cellule(
        id: cellule.id,
        firebaseId: cellule.firebaseId,
        reference: cellule.reference,
        dateCreation: cellule.dateCreation,
        notes: cellule.notes,
        nom: cellule.nom,
        fermee: false,
        quantiteGaz: null,
        prixGaz: null,
      );
      context.read<FirebaseProviderV4>().modifierCellule(updatedCellule);
    } else {
      // Fermer la cellule via l'écran de fermeture
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FermerCelluleScreen(cellule: cellule),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}