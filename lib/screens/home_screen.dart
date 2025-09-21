import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import 'parcelles_screen.dart';
import 'cellules_screen.dart';
import 'chargements_screen.dart';
import 'semis_screen.dart';
import 'varietes_screen.dart';
import 'ventes_screen.dart';
import 'statistiques_screen.dart';
import 'import_export_screen.dart';
import 'export_screen.dart';
import 'export_ventes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              AppTheme.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<FirebaseProviderV4>(
            builder: (context, provider, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppTheme.spacingL),
                        _buildStatsSection(provider),
                        const SizedBox(height: AppTheme.spacingL),
                        _buildMenuSection(),
                        const SizedBox(height: AppTheme.spacingL),
                        _buildQuickActions(provider),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: const Icon(
                Icons.agriculture,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GAEC de la BARADE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gestion des récoltes de maïs',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(FirebaseProviderV4 provider) {
    final parcelles = provider.parcelles;
    final chargements = provider.chargements;
    
    // Calculer les statistiques
    final surfaceTotale = parcelles.fold<double>(0, (sum, p) => sum + p.surface);
    final derniereAnnee = DateTime.now().year;
    final chargementsAnnee = chargements.where((c) => c.dateChargement.year == derniereAnnee).toList();
    final poidsTotalNormeAnnee = chargementsAnnee.fold<double>(0, (sum, c) => sum + c.poidsNormes);
    final rendementMoyenNorme = surfaceTotale > 0 ? poidsTotalNormeAnnee / (surfaceTotale * 1000) : 0.0;

    return GradientCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Color(0xFFF8F9FA)],
      ),
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
                'Aperçu général',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Surface totale',
                  value: '${surfaceTotale.toStringAsFixed(1)} ha',
                  icon: Icons.landscape,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: StatCard(
                  title: 'Rendement $derniereAnnee',
                  value: '${rendementMoyenNorme.toStringAsFixed(1)} T/ha',
                  icon: Icons.trending_up,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Poids total $derniereAnnee',
                  value: '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(1)} T',
                  icon: Icons.scale,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: StatCard(
                  title: 'Parcelles',
                  value: '${parcelles.length}',
                  icon: Icons.grid_view,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            const Text(
              'Menu principal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 1.2,
          children: [
            MenuCard(
              title: 'Parcelles',
              subtitle: 'Gestion des parcelles',
              icon: Icons.landscape,
              color: AppTheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParcellesScreen()),
              ),
            ),
            MenuCard(
              title: 'Cellules',
              subtitle: 'Stockage des grains',
              icon: Icons.grid_view,
              color: AppTheme.secondary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CellulesScreen()),
              ),
            ),
            MenuCard(
              title: 'Chargements',
              subtitle: 'Récoltes et transport',
              icon: Icons.local_shipping,
              color: AppTheme.accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChargementsScreen()),
              ),
            ),
            MenuCard(
              title: 'Semis',
              subtitle: 'Plantations',
              icon: Icons.grass,
              color: AppTheme.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SemisScreen()),
              ),
            ),
            MenuCard(
              title: 'Variétés',
              subtitle: 'Types de maïs',
              icon: Icons.eco,
              color: AppTheme.info,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VarietesScreen()),
              ),
            ),
            MenuCard(
              title: 'Ventes',
              subtitle: 'Suivi des ventes',
              icon: Icons.shopping_cart,
              color: AppTheme.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VentesScreen()),
              ),
            ),
            MenuCard(
              title: 'Statistiques',
              subtitle: 'Analyses et graphiques',
              icon: Icons.bar_chart,
              color: AppTheme.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatistiquesScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(FirebaseProviderV4 provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingL),
        Row(
          children: [
            Expanded(
              child: ModernButton(
                text: 'Import/Export',
                icon: Icons.import_export,
                backgroundColor: Colors.white,
                textColor: AppTheme.primary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImportExportScreen()),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: ModernOutlinedButton(
                text: 'Export PDF',
                icon: Icons.picture_as_pdf,
                borderColor: Colors.white,
                textColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportScreen()),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: ModernOutlinedButton(
                text: 'Export Ventes PDF',
                icon: Icons.sell,
                borderColor: Colors.white,
                textColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportVentesScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}