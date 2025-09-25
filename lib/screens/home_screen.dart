import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../services/security_service.dart';
import '../services/app_firebase.dart';
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
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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

  Future<void> _signOut() async {
    if (_signingOut) return;
    _signingOut = true;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
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

    if (confirmed == true) {
      try {
        print('HomeScreen: user pressed logout');
        
        // 1) Déconnexion Firebase (même instance que l'AuthGate)
        await SecurityService().signOut();
        
        // 2) Nettoyage côté data (annule listeners + vide caches)
        final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
        await provider.disposeAuthBoundResources();
        
        // 3) Attendre (très) brièvement l'event user=null ; sinon fallback navigation
        try {
          await AppFirebase.auth
              .userChanges()
              .firstWhere((u) => u == null)
              .timeout(const Duration(milliseconds: 400));
          print('HomeScreen: Auth event received, AuthGate will handle navigation');
        } catch (_) {
          // Fallback: on force le retour sous l'AuthGate / vers login
          print('HomeScreen: Auth event timeout, using fallback navigation');
          if (mounted) {
            // Revenir à la racine si l'AuthGate est la home de ton MaterialApp
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        }
        
        print('HomeScreen: logout flow done');
      } catch (e) {
        print('HomeScreen: Sign out error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de déconnexion: $e')),
          );
        }
      }
    }
    
    _signingOut = false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FirebaseProviderV4>(context);
    
    // Éviter l'affichage "fantôme" si le provider n'est pas prêt
    if (!provider.ready) {
      return const SplashScreen();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('GAEC de la BARADE'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
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
    return Stack(
      children: [
        Column(
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
        ),
        // Logo en haut à droite
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatistiquesScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(FirebaseProviderV4 provider) {
    final parcelles = provider.parcelles;
    final chargements = provider.chargements;
    
    // Initialiser l'année sélectionnée si pas encore fait
    if (_selectedYear == null) {
      final anneesDisponibles = chargements
          .map((c) => c.dateChargement.year)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
      _selectedYear = anneesDisponibles.isNotEmpty ? anneesDisponibles.first : DateTime.now().year;
    }
    
    // Calculer les statistiques pour l'année sélectionnée
    final chargementsAnnee = chargements.where((c) => c.dateChargement.year == _selectedYear).toList();
    
    // Trouver les parcelles qui ont été récoltées cette année
    final parcellesRecoltees = <String>{};
    for (var chargement in chargementsAnnee) {
      parcellesRecoltees.add(chargement.parcelleId);
    }
    
    // Calculer la surface des parcelles récoltées
    double surfaceRecoltee = 0.0;
    for (var parcelle in parcelles) {
      final parcelleId = parcelle.firebaseId ?? parcelle.id.toString();
      if (parcellesRecoltees.contains(parcelleId)) {
        surfaceRecoltee += parcelle.surface;
      }
    }
    
    final poidsTotalNormeAnnee = chargementsAnnee.fold<double>(0, (sum, c) => sum + c.poidsNormes);
    final rendementMoyenNorme = surfaceRecoltee > 0 ? poidsTotalNormeAnnee / (surfaceRecoltee * 1000) : 0.0;

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
          
          // Sélecteur d'année
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingS),
              const Text(
                'Année:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: () {
                    final annees = chargements
                        .map((c) => c.dateChargement.year)
                        .toSet()
                        .toList();
                    annees.sort((a, b) => b.compareTo(a));
                    return annees.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList();
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
          
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Surface récoltée',
                  value: '${surfaceRecoltee.toStringAsFixed(1)} ha',
                  icon: Icons.landscape,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: StatCard(
                  title: 'Rendement $_selectedYear',
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
                  title: 'Poids total $_selectedYear',
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
              title: 'Traitements',
              subtitle: 'Produits phytosanitaires',
              icon: Icons.science,
              color: AppTheme.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TraitementsScreen()),
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
                text: 'Exports PDF',
                icon: Icons.picture_as_pdf,
                borderColor: Colors.white,
                textColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportsPdfScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}