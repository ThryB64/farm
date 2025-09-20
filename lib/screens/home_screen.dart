import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/firebase_provider_v3.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import '../widgets/stat_card.dart';
import 'parcelles_screen.dart';
import 'cellules_screen.dart';
import 'chargements_screen.dart';
import 'semis_screen.dart';
import 'varietes_screen.dart';
import 'import_export_screen.dart';
import 'statistiques_screen.dart';
import 'export_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // Les statistiques sont maintenant calculées en temps réel dans le Consumer
    // Plus besoin de charger les stats séparément
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GAEC de la BARADE',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.sand,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.sand, AppColors.sand],
            ),
          ),
        ),
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final parcelles = provider.parcelles;
          final chargements = provider.chargements;

          // Calculer les statistiques globales
          final surfaceTotale = parcelles.fold<double>(
            0,
            (sum, p) => sum + p.surface,
          );

          // Obtenir l'année la plus récente avec des chargements
          final derniereAnnee = chargements.isEmpty 
              ? DateTime.now().year 
              : chargements
                  .map((c) => c.dateChargement.year)
                  .reduce((a, b) => a > b ? a : b);

          final chargementsDerniereAnnee = chargements.where(
            (c) => c.dateChargement.year == derniereAnnee
          ).toList();

          // Calculer le poids total normé de l'année
          final poidsTotalNormeAnnee = chargementsDerniereAnnee.fold<double>(
            0,
            (sum, c) => sum + c.poidsNormes,
          );

          // Calculer le rendement moyen normé (en T/ha)
          final rendementMoyenNorme = surfaceTotale > 0
              ? (poidsTotalNormeAnnee / 1000) / surfaceTotale
              : 0.0;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.sand, AppColors.sand],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Carte de statistiques rapides
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Glass(
                      padding: const EdgeInsets.all(20),
                      radius: AppRadius.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primary,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: const Icon(
                                  Icons.analytics,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Aperçu',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    StatCard(
                                      label: 'Surface totale',
                                      value: '${surfaceTotale.toStringAsFixed(2)} ha',
                                      icon: Icons.landscape,
                                      color: AppColors.coral,
                                    ),
                                    const SizedBox(width: 12),
                                    StatCard(
                                      label: 'Rendement $derniereAnnee',
                                      value: '${rendementMoyenNorme.toStringAsFixed(3)} T/ha',
                                      icon: Icons.trending_up,
                                      color: AppColors.salmon,
                                    ),
                                    const SizedBox(width: 12),
                                    StatCard(
                                      label: 'Poids total $derniereAnnee',
                                      value: '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(2)} T',
                                      icon: Icons.scale,
                                      color: AppColors.navy,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Menu principal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Menu principal',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            MenuCard(
                              title: 'Parcelles',
                              icon: Icons.landscape,
                              color: AppColors.coral,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ParcellesScreen(),
                                ),
                              ),
                            ),
                            MenuCard(
                              title: 'Cellules',
                              icon: Icons.grid_view,
                              color: AppColors.salmon,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CellulesScreen(),
                                ),
                              ),
                            ),
                            MenuCard(
                              title: 'Chargements',
                              icon: Icons.local_shipping,
                              color: AppColors.navy,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChargementsScreen(),
                                ),
                              ),
                            ),
                            MenuCard(
                              title: 'Semis',
                              icon: Icons.grass,
                              color: const Color(0xFF8B4513),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SemisScreen(),
                                ),
                              ),
                            ),
                            MenuCard(
                              title: 'Variétés',
                              icon: Icons.eco,
                              color: const Color(0xFF90EE90),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VarietesScreen(),
                                ),
                              ),
                            ),
                            MenuCard(
                              title: 'Statistiques',
                              icon: Icons.bar_chart,
                              color: const Color(0xFF9370DB),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StatistiquesScreen(),
                                ),
                              ),
                            ),
                            MenuCard(
                              title: 'Import/Export',
                              icon: Icons.import_export,
                              color: const Color(0xFF008080),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ImportExportScreen(),
                                ),
                              ),
                            ),
                            MenuCard(
                              title: 'Export PDF',
                              icon: Icons.picture_as_pdf,
                              color: const Color(0xFFDC143C),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ExportScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}