import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/parcelle.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_chip.dart';
import 'parcelle_form_screen.dart';
import 'parcelle_details_screen.dart';

class ParcellesScreen extends StatefulWidget {
  const ParcellesScreen({Key? key}) : super(key: key);

  @override
  State<ParcellesScreen> createState() => _ParcellesScreenState();
}

class _ParcellesScreenState extends State<ParcellesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Toutes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final parcelles = provider.parcelles;
          final filteredParcelles = _filterParcelles(parcelles);

          return CustomScrollView(
            slivers: [
              // App Bar personnalisé
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.sand,
                foregroundColor: AppColors.deepNavy,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.sand, AppColors.sand],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Parcelles',
                                        style: AppTypography.h1Style.copyWith(
                                          color: AppColors.deepNavy,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '${parcelles.length} parcelles • ${_calculateTotalSurface(parcelles).toStringAsFixed(1)} ha',
                                        style: AppTypography.bodyStyle.copyWith(
                                          color: AppColors.navy70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GlassButton(
                                  text: 'Ajouter',
                                  icon: Icons.add,
                                  isPrimary: true,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ParcelleFormScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Barre de recherche et filtres
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Barre de recherche
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Rechercher une parcelle...',
                            hintStyle: AppTypography.bodyStyle.copyWith(
                              color: AppColors.navy50,
                            ),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.navy50,
                              size: AppSpacing.iconSize,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: AppColors.navy50,
                                      size: AppSpacing.iconSize,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Filtres
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Toutes', _selectedFilter == 'Toutes'),
                            const SizedBox(width: AppSpacing.sm),
                            _buildFilterChip('Petites (< 2 ha)', _selectedFilter == 'Petites'),
                            const SizedBox(width: AppSpacing.sm),
                            _buildFilterChip('Moyennes (2-5 ha)', _selectedFilter == 'Moyennes'),
                            const SizedBox(width: AppSpacing.sm),
                            _buildFilterChip('Grandes (> 5 ha)', _selectedFilter == 'Grandes'),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),

              // Liste des parcelles
              if (filteredParcelles.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final parcelle = filteredParcelles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: _buildParcelleCard(context, parcelle, provider),
                        );
                      },
                      childCount: filteredParcelles.length,
                    ),
                  ),
                ),

              // Espacement en bas
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GlassChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
    );
  }

  Widget _buildParcelleCard(BuildContext context, Parcelle parcelle, FirebaseProviderV3 provider) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParcelleDetailsScreen(parcelle: parcelle),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parcelle.nom,
                      style: AppTypography.h3Style.copyWith(
                        color: AppColors.deepNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Code: ${parcelle.code} • Année: ${parcelle.annee}',
                      style: AppTypography.captionStyle.copyWith(
                        color: AppColors.navy70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '${parcelle.surface.toStringAsFixed(1)} ha',
                  style: AppTypography.captionStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Informations détaillées
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.landscape,
                  'Surface',
                  '${parcelle.surface.toStringAsFixed(1)} ha',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today,
                  'Année',
                  parcelle.annee.toString(),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.tag,
                  'Code',
                  parcelle.code,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Actions
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  text: 'Modifier',
                  icon: Icons.edit,
                  isSecondary: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParcelleFormScreen(parcelle: parcelle),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: GlassButton(
                  text: 'Supprimer',
                  icon: Icons.delete,
                  isTertiary: true,
                  onPressed: () {
                    _showDeleteDialog(context, parcelle, provider);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: AppSpacing.smallIconSize,
              color: AppColors.navy70,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.captionStyle.copyWith(
                color: AppColors.navy70,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.bodyStyle.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.glassLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Icon(
              Icons.landscape,
              size: 60,
              color: AppColors.navy50,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Aucune parcelle trouvée',
            style: AppTypography.h2Style.copyWith(
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucune parcelle ne correspond à votre recherche'
                : 'Commencez par ajouter votre première parcelle',
            style: AppTypography.bodyStyle.copyWith(
              color: AppColors.navy70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassButton(
            text: 'Ajouter une parcelle',
            icon: Icons.add,
            isPrimary: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParcelleFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Parcelle> _filterParcelles(List<Parcelle> parcelles) {
    var filtered = parcelles.where((parcelle) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!parcelle.nom.toLowerCase().contains(query) &&
            !parcelle.code.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtre par taille
      switch (_selectedFilter) {
        case 'Petites':
          return parcelle.surface < 2.0;
        case 'Moyennes':
          return parcelle.surface >= 2.0 && parcelle.surface <= 5.0;
        case 'Grandes':
          return parcelle.surface > 5.0;
        default:
          return true;
      }
    }).toList();

    // Trier par nom
    filtered.sort((a, b) => a.nom.compareTo(b.nom));
    return filtered;
  }

  double _calculateTotalSurface(List<Parcelle> parcelles) {
    return parcelles.fold<double>(0, (sum, parcelle) => sum + parcelle.surface);
  }

  void _showDeleteDialog(BuildContext context, Parcelle parcelle, FirebaseProviderV3 provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sand,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Supprimer la parcelle',
          style: AppTypography.h3Style.copyWith(
            color: AppColors.deepNavy,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la parcelle "${parcelle.nom}" ?\n\nCette action est irréversible.',
          style: AppTypography.bodyStyle.copyWith(
            color: AppColors.navy70,
          ),
        ),
        actions: [
          GlassButton(
            text: 'Annuler',
            isTertiary: true,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          GlassButton(
            text: 'Supprimer',
            isPrimary: true,
            onPressed: () {
              provider.supprimerParcelle(parcelle.id.toString());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Parcelle "${parcelle.nom}" supprimée'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
