import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/firebase_provider_v4.dart';
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
    ).animate(
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

      if (confirmed != true) return;

      print('HomeScreen: user pressed logout');

      // 1) Déconnexion d'abord
      await SecurityService().signOut();

      // 2) Nettoyage des ressources liées à l'auth (streams, caches)
      await context.read<FirebaseProviderV4>().disposeAuthBoundResources();

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

    // Éviter l'affichage "fantôme" si le provider n'est pas prêt
    if (!provider.ready) {
      return const SplashScreen();
    }

    // Palette locale (terre + crème)
    const bgCream = Color(0xFFFAF7F2);
    const bgRadial1 = Color(0xFFFFF2DE);
    const bgRadial2 = Color(0xFFE8F5ED);
    const inkTitle = Color(0xFF1B2B34);
    const inkMuted = Color(0xFF5C6B73);
    const chipBg = Color(0xFFEFEAE2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('GAEC de la BARADE'),
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.0),
        foregroundColor: inkTitle,
        centerTitle: false,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signingOut ? null : _signOut,
            tooltip: _signingOut ? 'Déconnexion en cours...' : 'Déconnexion',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: bgCream,
        ),
        child: Stack(
          children: [
            // Halos radiaux doux
            Positioned(
              top: -120,
              left: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    radius: 0.85,
                    colors: [bgRadial1, Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -40,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    radius: 0.9,
                    colors: [bgRadial2, Colors.transparent],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Consumer<FirebaseProviderV4>(
                builder: (context, provider, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spacingM,
                          AppTheme.spacingL,
                          AppTheme.spacingM,
                          AppTheme.spacingL,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(inkTitle, inkMuted, chipBg),
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
          ],
        ),
      ),
    );
  }

  // HEADER — visuel “hero” doux, avec chip d’accès stats
  Widget _buildHeader(Color inkTitle, Color inkMuted, Color chipBg) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container
              (
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: AppTheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAEC de la BARADE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: inkTitle,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gestion des récoltes de maïs',
                      style: TextStyle(
                        fontSize: 15,
                        color: inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Raccourci Stats en haut à droite, version “pill”
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatistiquesScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF7F1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFD9EDE1)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.analytics, color: AppTheme.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Statistiques',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
      _selectedYear = anneesDisponibles.isNotEmpty
          ? anneesDisponibles.first
          : DateTime.now().year;
    }

    // Calculs
    final chargementsAnnee =
        chargements.where((c) => c.dateChargement.year == _selectedYear).toList();

    final parcellesRecoltees = <String>{};
    for (var chargement in chargementsAnnee) {
      parcellesRecoltees.add(chargement.parcelleId);
    }

    double surfaceRecoltee = 0.0;
    for (var parcelle in parcelles) {
      final parcelleId = parcelle.firebaseId ?? parcelle.id.toString();
      if (parcellesRecoltees.contains(parcelleId)) {
        surfaceRecoltee += parcelle.surface;
      }
    }

    final poidsTotalNormeAnnee =
        chargementsAnnee.fold<double>(0, (sum, c) => sum + c.poidsNormes);
    final rendementMoyenNorme =
        surfaceRecoltee > 0 ? poidsTotalNormeAnnee / (surfaceRecoltee * 1000) : 0.0;

    // Carte stats : ombre via parent Container + ClipRRect, pas de paramètre 'elevation'
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: GradientCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF9F9F7)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child:
                          const Icon(Icons.analytics, color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    const Text(
                      'Aperçu général',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingL),

                // Sélecteur d'année en style "pill"
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.primary, size: 18),
                    const SizedBox(width: AppTheme.spacingS),
                    const Text(
                      'Année :',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFF3F2EF),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(color: Color(0xFFE4E1DC)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(color: Color(0xFFE4E1DC)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                                color: AppTheme.primary.withOpacity(0.6)),
                          ),
                        ),
                        items: () {
                          final annees = provider.chargements
                              .map((c) => c.dateChargement.year)
                              .toSet()
                              .toList();
                          annees.sort((a, b) => b.compareTo(a));
                          return annees
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  ))
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

                const SizedBox(height: AppTheme.spacingL),

                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Surface récoltée',
                        value: '${surfaceRecoltee.toStringAsFixed(1)} ha',
                        icon: Icons.landscape,
                        color: const Color(0xFF1F8A48),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: StatCard(
                        title: 'Rendement $_selectedYear',
                        value: '${rendementMoyenNorme.toStringAsFixed(1)} T/ha',
                        icon: Icons.trending_up,
                        color: const Color(0xFF156036),
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
                        color: const Color(0xFFF4A737),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: StatCard(
                        title: 'Parcelles',
                        value: '${parcelles.length}',
                        icon: Icons.grid_view,
                        color: const Color(0xFF2EB67D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MENU — look sobre, texte sombre lisible
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEAE2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 22),
            ),
            const SizedBox(width: AppTheme.spacingM),
            const Text(
              'Menu principal',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.1,
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
              color: const Color(0xFF1F8A48),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParcellesScreen()),
              ),
            ),
            MenuCard(
              title: 'Cellules',
              subtitle: 'Stockage des grains',
              icon: Icons.grid_view,
              color: const Color(0xFF156036),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CellulesScreen()),
              ),
            ),
            MenuCard(
              title: 'Chargements',
              subtitle: 'Récoltes et transport',
              icon: Icons.local_shipping,
              color: const Color(0xFFF4A737),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChargementsScreen()),
              ),
            ),
            MenuCard(
              title: 'Semis',
              subtitle: 'Plantations',
              icon: Icons.grass,
              color: const Color(0xFF2EB67D),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SemisScreen()),
              ),
            ),
            MenuCard(
              title: 'Ventes',
              subtitle: 'Suivi des ventes',
              icon: Icons.shopping_cart,
              color: const Color(0xFF2EB67D),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VentesScreen()),
              ),
            ),
            MenuCard(
              title: 'Traitements',
              subtitle: 'Produits phytosanitaires',
              icon: Icons.science,
              color: const Color(0xFFB88413),
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

  // ACTIONS — boutons “pill” inversés
  Widget _buildQuickActions(FirebaseProviderV4 provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEAE2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(Icons.flash_on, color: AppTheme.textPrimary, size: 22),
            ),
            const SizedBox(width: AppTheme.spacingM),
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.1,
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
                backgroundColor: const Color(0xFF1B2B34),
                textColor: Colors.white,
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
                borderColor: const Color(0xFF1B2B34),
                textColor: const Color(0xFF1B2B34),
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
