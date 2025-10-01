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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../providers/theme_provider.dart';
import '../services/security_service.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import 'parcelles_screen.dart';
import 'cellules_screen.dart';
import 'chargements_screen.dart';
import 'semis_screen.dart';
import 'ventes_screen.dart';
import 'traitements_screen.dart';
import 'statistiques_screen.dart';
import 'import_export_screen.dart';
import 'exports_pdf_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int? _selectedYear;
  bool _signingOut = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  Future<void> _signOut() async {
    if (_signingOut) return;
    _signingOut = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Déconnexion'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      print('HomeScreen: user pressed logout');
      // 1) Déconnexion d'abord
      await SecurityService().signOut();
      // 2) Nettoyage des ressources liées à l'auth (streams, caches)
      await context
          .read<FirebaseProviderV4>()
          .disposeAuthBoundResources();
      // 3) NE PAS NAVIGUER — AuthGate rendra SecureLoginScreen tout seul
      print('HomeScreen: logout flow done');
    } catch (e) {
      print('HomeScreen: Sign out error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de déconnexion: $e')),
        );
      }
    } finally {
      _signingOut = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FirebaseProviderV4>(context);
    final themeProvider = context.watch<ThemeProvider>();
    // Éviter l'affichage "fantôme" si le provider n'est pas prêt
    if (!provider.ready) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('GAEC de la BARADE'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signingOut ? null : _signOut,
            tooltip:
                _signingOut ? 'Déconnexion en cours...' : 'Déconnexion',
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.appBackground(context),
        child: SafeArea(
          child: Consumer<FirebaseProviderV4>(
            builder: (context, provider, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: AppTheme.spaceLg),
                      _buildStatsSection(context, provider),
                      const SizedBox(height: AppTheme.spaceLg),
                      _buildMenuSection(context),
                      const SizedBox(height: AppTheme.spaceLg),
                      _buildQuickActions(context, provider),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return AppTheme.sectionHeader(
      context,
      "Bonsoir Thierry",
      subtitle: "Prêt pour une saison parfaite ?",
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle dark/light mode
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return GestureDetector(
                onTap: () {
                  themeProvider.toggleTheme();
                },
                child: AppTheme.glowIcon(
                  context,
                  themeProvider.isDarkMode ? Icons.brightness_6 : Icons.brightness_4,
                  color: AppTheme.cornGold,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          // Logo lumineux
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StatistiquesScreen(),
              ),
            ),
            child: AppTheme.glowIcon(context, Icons.agriculture, color: AppTheme.leafLight),
          ),
        ],
      ),
    );
  }
  Widget _buildStatsSection(BuildContext context, FirebaseProviderV4 provider) {
    final themeProvider = context.watch<ThemeProvider>();
    final parcelles = provider.parcelles;
    final chargements = provider.chargements;
    // Initialiser l'année sélectionnée si pas encore fait
    if (_selectedYear == null) {
      final anneesDisponibles = chargements
          .map((c) => c.dateChargement.year)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
      _selectedYear = anneesDisponibles.isNotEmpty
          ? anneesDisponibles.first
          : DateTime.now().year;
    }
    // Calculer les stats pour l'année sélectionnée
    final chargementsAnnee = chargements
        .where((c) => c.dateChargement.year == _selectedYear)
        .toList();
    // Parcelles récoltées cette année
    final parcellesRecoltees = <String>{};
    for (final chargement in chargementsAnnee) {
      parcellesRecoltees.add(chargement.parcelleId);
    }
    // Surface récoltée
    double surfaceRecoltee = 0.0;
    for (final parcelle in parcelles) {
      final parcelleId = parcelle.firebaseId ?? parcelle.id.toString();
      if (parcellesRecoltees.contains(parcelleId)) {
        surfaceRecoltee += parcelle.surface;
      }
    }
    final poidsTotalNormeAnnee = chargementsAnnee.fold<double>(
      0,
      (sum, c) => sum + c.poidsNormes,
    );
    final rendementMoyenNorme = surfaceRecoltee > 0
        ? poidsTotalNormeAnnee / (surfaceRecoltee * 1000)
        : 0.0;
    return AppTheme.glass(
      context,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x22F6C65B), // Or maïs transparent
          Color(0x112E7D32), // Vert feuille transparent
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppTheme.padding(AppTheme.spacingS),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFE082), // Or maïs clair
                      Color(0xFFF6C65B), // Or maïs
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cornGold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Text(
                'Aperçu général',
                style: AppTheme.textTheme(context).titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),
          // Sélecteur d'année
          Row(
            children: [
              AppTheme.glowIcon(context, Icons.calendar_today, color: AppTheme.primary(context)),
              const SizedBox(width: AppTheme.spaceSm),
              Text(
                'Année:',
                style: AppTheme.textTheme(context).bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: AppTheme.inputDecoration(context),
                  items: () {
                    final annees = chargements
                        .map((c) => c.dateChargement.year)
                        .toSet()
                        .toList();
                    annees.sort((a, b) => b.compareTo(a));
                    return annees
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ),
                        )
                        .toList();
                  }(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Surface récoltée',
                  value: '${surfaceRecoltee.toStringAsFixed(1)} ha',
                  icon: Icons.landscape,
                  color: AppTheme.primary(context),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: _StatCard(
                  title: 'Rendement $_selectedYear',
                  value: '${rendementMoyenNorme.toStringAsFixed(1)} T/ha',
                  icon: Icons.trending_up,
                  color: AppTheme.secondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Poids total $_selectedYear',
                  value: '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(1)} T',
                  icon: Icons.scale,
                  color: AppTheme.accent(context),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: _StatCard(
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
  Widget _buildMenuSection(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppTheme.padding(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.textPrimary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                Icons.menu,
                color: AppTheme.textPrimary(context),
                size: AppTheme.iconSizeM,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Text(
              'Menu principal',
              style: AppTheme.textTheme(context).titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceLg),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spaceMd,
          mainAxisSpacing: AppTheme.spaceMd,
          childAspectRatio: 1.2,
          children: [
            _MenuCard(
              title: 'Parcelles',
              subtitle: 'Gestion des parcelles',
              icon: Icons.landscape,
              color: AppTheme.primary(context),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParcellesScreen(),
                ),
              ),
            ),
            _MenuCard(
              title: 'Cellules',
              subtitle: 'Stockage des grains',
              icon: Icons.grid_view,
              color: AppTheme.secondary(context),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CellulesScreen(),
                ),
              ),
            ),
            _MenuCard(
              title: 'Chargements',
              subtitle: 'Récoltes et transport',
              icon: Icons.local_shipping,
              color: AppTheme.accent(context),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChargementsScreen(),
                ),
              ),
            ),
            _MenuCard(
              title: 'Semis',
              subtitle: 'Plantations',
              icon: Icons.grass,
              color: AppTheme.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SemisScreen(),
                ),
              ),
            ),
            _MenuCard(
              title: 'Ventes',
              subtitle: 'Suivi des ventes',
              icon: Icons.shopping_cart,
              color: AppTheme.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VentesScreen(),
                ),
              ),
            ),
            _MenuCard(
              title: 'Traitements',
              subtitle: 'Produits phytosanitaires',
              icon: Icons.science,
              color: AppTheme.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TraitementsScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildQuickActions(BuildContext context, FirebaseProviderV4 provider) {
    final themeProvider = context.watch<ThemeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: AppTheme.padding(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.textPrimary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                Icons.flash_on,
                color: AppTheme.textPrimary(context),
                size: AppTheme.iconSizeM,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Text(
              'Actions rapides',
              style: AppTheme.textTheme(context).titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceLg),
        Row(
          children: [
            Expanded(
              child: _ModernButton(
                text: 'Import/Export',
                icon: Icons.import_export,
                backgroundColor: AppTheme.surface(context),
                textColor: AppTheme.cornGold,
                borderColor: AppTheme.cornGold,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImportExportScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _ModernButton(
                text: 'Exports PDF',
                icon: Icons.picture_as_pdf,
                backgroundColor: AppTheme.surface(context),
                textColor: AppTheme.cornGold,
                borderColor: AppTheme.cornGold,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExportsPdfScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.glass(
      context,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: AppTheme.iconSizeM),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              value,
              style: AppTheme.textTheme(context).titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppTheme.glass(
        context,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: AppTheme.iconSizeL),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                title,
                style: AppTheme.textTheme(context).titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                subtitle,
                style: AppTheme.textTheme(context).bodySmall?.copyWith(
                  color: AppTheme.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _ModernButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(text, style: TextStyle(color: textColor)),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg,
          vertical: AppTheme.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: borderColor != null ? BorderSide(color: borderColor!, width: 1) : BorderSide.none,
        ),
      ),
    );
  }
}

class _ModernOutlinedButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _ModernOutlinedButton({
    required this.text,
    required this.icon,
    required this.borderColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(text, style: TextStyle(color: textColor)),
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg,
          vertical: AppTheme.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}
