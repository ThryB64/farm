import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import 'parcelles_screen.dart';
import 'cellules_screen.dart';
import 'chargements_screen.dart';
import 'semis_screen.dart';
import 'varietes_screen.dart';
import 'import_export_screen.dart';
import 'statistiques_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final parcelles = provider.parcelles;
          final chargements = provider.chargements;
          final cellules = provider.cellules;
          final semis = provider.semis;
          final varietes = provider.varietes;

          // Calculer les statistiques globales
          final surfaceTotale = parcelles.fold<double>(0, (sum, p) => sum + p.surface);
          final nombreParcelles = parcelles.length;
          final nombreChargements = chargements.length;
          // final nombreCellules = cellules.length;
          // final nombreSemis = semis.length;
          final nombreVarietes = varietes.length;

          return CustomScrollView(
            slivers: [
              // App Bar personnalisé
              SliverAppBar(
                expandedHeight: 200,
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
                                        'Bonjour ! 👋',
                                        style: AppTypography.h1Style.copyWith(
                                          color: AppColors.deepNavy,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Bienvenue dans votre ferme',
                                        style: AppTypography.bodyStyle.copyWith(
                                          color: AppColors.navy70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Avatar group
                                Row(
                                  children: [
                                    _buildAvatar('👨‍🌾'),
                                    const SizedBox(width: AppSpacing.xs),
                                    _buildAvatar('👩‍🌾'),
                                    const SizedBox(width: AppSpacing.xs),
                                    _buildAvatar('+'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImportExportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Contenu principal
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Carte de température/statistiques principales
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.thermostat,
                                color: AppColors.coral,
                                size: AppSpacing.iconSize,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Aperçu de la ferme',
                                style: AppTypography.h3Style,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'Parcelles',
                                  nombreParcelles.toString(),
                                  Icons.landscape,
                                  AppColors.coral,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'Surface',
                                  '${surfaceTotale.toStringAsFixed(1)} ha',
                                  Icons.area_chart,
                                  AppColors.salmon,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'Chargements',
                                  nombreChargements.toString(),
                                  Icons.local_shipping,
                                  AppColors.success,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'Variétés',
                                  nombreVarietes.toString(),
                                  Icons.park,
                                  AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Section "Toutes les sections"
                    Text(
                      'Toutes les sections',
                      style: AppTypography.h2Style,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Grille de navigation
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.lg,
                      mainAxisSpacing: AppSpacing.lg,
                      childAspectRatio: 1.2,
                      children: [
                        _buildNavigationCard(
                          context,
                          'Parcelles',
                          Icons.landscape,
                          AppColors.coral,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ParcellesScreen(),
                            ),
                          ),
                        ),
                        _buildNavigationCard(
                          context,
                          'Cellules',
                          Icons.grid_view,
                          AppColors.salmon,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CellulesScreen(),
                            ),
                          ),
                        ),
                        _buildNavigationCard(
                          context,
                          'Chargements',
                          Icons.local_shipping,
                          AppColors.success,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChargementsScreen(),
                            ),
                          ),
                        ),
                        _buildNavigationCard(
                          context,
                          'Semis',
                          Icons.eco,
                          AppColors.warning,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SemisScreen(),
                            ),
                          ),
                        ),
                        _buildNavigationCard(
                          context,
                          'Variétés',
                          Icons.park,
                          AppColors.danger,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VarietesScreen(),
                            ),
                          ),
                        ),
                        _buildNavigationCard(
                          context,
                          'Statistiques',
                          Icons.analytics,
                          AppColors.deepNavy,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StatistiquesScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: GlassFab(
        icon: Icons.add,
        onPressed: () {
          _showAddMenu(context);
        },
        tooltip: 'Ajouter',
      ),
    );
  }

  Widget _buildAvatar(String emoji) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.glassLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: AppSpacing.smallIconSize),
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
          style: AppTypography.h3Style.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: AppSpacing.iconSize,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.h3Style.copyWith(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusXl),
            topRight: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ajouter un élément',
                  style: AppTypography.h2Style,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: 'Parcelle',
                        icon: Icons.landscape,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ParcellesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: GlassButton(
                        text: 'Chargement',
                        icon: Icons.local_shipping,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChargementsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: 'Semis',
                        icon: Icons.eco,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SemisScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: GlassButton(
                        text: 'Variété',
                        icon: Icons.park,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VarietesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
