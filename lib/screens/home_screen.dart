import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../theme/app_theme.dart';
import '../widgets/app_layout.dart';
import 'parcelles_screen.dart';
import 'cellules_screen.dart';
import 'chargements_screen.dart';
import 'varietes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Accueil',
      child: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: AppTheme.spacingXL),
                _buildKPISection(provider),
                const SizedBox(height: AppTheme.spacingXL),
                _buildMenuSection(),
                const SizedBox(height: AppTheme.spacingXL),
                _buildRecentActivitySection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Text(
      'Bonjour, Thierry 👋',
      style: AppTheme.h1,
    );
  }

  Widget _buildKPISection(FirebaseProviderV3 provider) {
    final parcelles = provider.parcelles;
    final chargements = provider.chargements;
    
    // Calculer les statistiques
    final surfaceTotale = parcelles.fold<double>(0, (sum, p) => sum + p.surface);
    final derniereAnnee = DateTime.now().year;
    final chargementsAnnee = chargements.where((c) => c.dateChargement.year == derniereAnnee).toList();
    final poidsTotalNormeAnnee = chargementsAnnee.fold<double>(0, (sum, c) => sum + c.poidsNormes);
    final rendementMoyenNorme = surfaceTotale > 0 ? poidsTotalNormeAnnee / (surfaceTotale * 1000) : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 1.2,
          children: [
            AppTheme.buildKPICard(
              label: 'Surface totale',
              value: '${surfaceTotale.toStringAsFixed(1)} ha',
              icon: Icons.landscape,
              iconColor: AppTheme.success,
            ),
            AppTheme.buildKPICard(
              label: 'Rendement moyen',
              value: '${rendementMoyenNorme.toStringAsFixed(1)} T/ha',
              icon: Icons.trending_up,
              iconColor: AppTheme.textMain,
            ),
            AppTheme.buildKPICard(
              label: 'Poids total $derniereAnnee',
              value: '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(1)} T',
              icon: Icons.scale,
              iconColor: AppTheme.accent,
            ),
            AppTheme.buildKPICard(
              label: 'Parcelles',
              value: '${parcelles.length}',
              icon: Icons.grid_view,
              iconColor: AppTheme.success,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1200;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 2 : 1,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 2.5,
          children: [
            AppTheme.buildMenuCard(
              title: 'Parcelles',
              subtitle: 'Gérer vos parcelles et cultures',
              icon: Icons.landscape,
              iconColor: AppTheme.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParcellesScreen()),
              ),
            ),
            AppTheme.buildMenuCard(
              title: 'Cellules',
              subtitle: 'Stockage et gestion des grains',
              icon: Icons.grid_view,
              iconColor: AppTheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CellulesScreen()),
              ),
            ),
            AppTheme.buildMenuCard(
              title: 'Chargements',
              subtitle: 'Récoltes et transport',
              icon: Icons.local_shipping,
              iconColor: AppTheme.accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChargementsScreen()),
              ),
            ),
            AppTheme.buildMenuCard(
              title: 'Variétés',
              subtitle: 'Types de maïs et semences',
              icon: Icons.eco,
              iconColor: AppTheme.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VarietesScreen()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivitySection(FirebaseProviderV3 provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activité récente',
          style: AppTheme.h2,
        ),
        const SizedBox(height: AppTheme.spacingL),
        _buildActivityList(provider),
      ],
    );
  }

  Widget _buildActivityList(FirebaseProviderV3 provider) {
    final activities = <Widget>[];
    
    // Ajouter les dernières parcelles créées
    final recentParcelles = provider.parcelles.take(3).toList();
    for (final parcelle in recentParcelles) {
      activities.add(_buildActivityItem(
        icon: Icons.landscape,
        title: 'Nouvelle parcelle créée',
        subtitle: parcelle.nom,
        date: parcelle.dateCreation,
        iconColor: AppTheme.success,
      ));
    }
    
    // Ajouter les derniers chargements
    final recentChargements = provider.chargements.take(2).toList();
    for (final chargement in recentChargements) {
      activities.add(_buildActivityItem(
        icon: Icons.local_shipping,
        title: 'Chargement enregistré',
        subtitle: '${(chargement.poidsNormes / 1000).toStringAsFixed(1)} T',
        date: chargement.dateChargement,
        iconColor: AppTheme.accent,
      ));
    }
    
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(
              Icons.timeline,
              size: 48,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Aucune activité récente',
              style: AppTheme.h3.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Vos actions apparaîtront ici',
              style: AppTheme.body.copyWith(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: activities.take(5).toList(),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required DateTime date,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.body),
                const SizedBox(height: AppTheme.spacingS),
                Text(subtitle, style: AppTheme.meta),
              ],
            ),
          ),
          Text(
            _formatDate(date),
            style: AppTheme.meta,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}