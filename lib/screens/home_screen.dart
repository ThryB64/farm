import 'dart:ui'; // pour ImageFilter (blur)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../services/security_service.dart';
// On ne touche pas au reste de ton archi ni aux écrans :
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

/// ----- Palette & Tokens inspirés des maquettes -----
class _UX {
  static const Color bgPeach = Color(0xFFF6E8DF); // #F6E8DF
  static const Color peach = Color(0xFFFEAE96);   // #FEAE96
  static const Color coral = Color(0xFFFE979C);   // #FE979C
  static const Color navy = Color(0xFF013237);    // #013237

  static const double rLg = 28;
  static const double rMd = 20;
  static const double rSm = 14;

  static const double sS = 10;
  static const double sM = 14;
  static const double sL = 20;
  static const double sXL = 28;

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 10)),
  ];

  static const LinearGradient pillGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [peach, coral],
  );

  static const LinearGradient cardGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF9F6F4)],
  );

  static const LinearGradient bgGrad = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [
      Color(0xFFFFF7F1),
      Color(0xFFFCEFE7),
      Color(0xFFF6E8DF),
    ],
  );
}

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
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
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
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Déconnexion')),
          ],
        ),
      );
      if (confirmed != true) return;
      await SecurityService().signOut();
      await context.read<FirebaseProviderV4>().disposeAuthBoundResources();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de déconnexion: $e')));
      }
    } finally {
      _signingOut = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FirebaseProviderV4>(context);
    if (!provider.ready) return const SplashScreen();

    return Scaffold(
      // AppBar “flottant”, transparent, avec titre fin + bouton logout en pilule
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text(
          'GAEC de la BARADE',
          style: TextStyle(
            color: _UX.navy,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _Pill.icon(
              icon: Icons.logout,
              label: 'Logout',
              onTap: _signingOut ? null : _signOut,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _UX.bgGrad),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 22),
                    _buildStatsSection(provider),
                    const SizedBox(height: 22),
                    _buildMenuSection(),
                    const SizedBox(height: 22),
                    _buildQuickActions(provider),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----- HEADER : “verre dépoli” + actions -----
  Widget _buildHeader() {
    return _Glass(
      padding: const EdgeInsets.all(18),
      radius: _UX.rLg,
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _UX.navy.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: const Icon(Icons.agriculture, color: _UX.navy, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GAEC de la BARADE',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _UX.navy)),
                    SizedBox(height: 4),
                    Text('Gestion des récoltes de maïs',
                        style: TextStyle(fontSize: 14, color: Color(0xFF5E6B6D))),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: _Pill.icon(
              icon: Icons.analytics_outlined,
              label: 'Stats',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatistiquesScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- STATS : cartes “neumorph” + sélecteur année arrondi -----
  Widget _buildStatsSection(FirebaseProviderV4 provider) {
    final parcelles = provider.parcelles;
    final chargements = provider.chargements;

    if (_selectedYear == null) {
      final years = chargements.map((c) => c.dateChargement.year).toSet().toList()..sort((a, b) => b - a);
      _selectedYear = years.isNotEmpty ? years.first : DateTime.now().year;
    }

    final yearLoads = chargements.where((c) => c.dateChargement.year == _selectedYear).toList();

    final parcellesRecoltees = <String>{};
    for (final ch in yearLoads) {
      parcellesRecoltees.add(ch.parcelleId);
    }

    double surfaceRecoltee = 0.0;
    for (final p in parcelles) {
      final id = p.firebaseId ?? p.id.toString();
      if (parcellesRecoltees.contains(id)) surfaceRecoltee += p.surface;
    }

    final poidsTotalNormeAnnee =
        yearLoads.fold<double>(0, (sum, c) => sum + c.poidsNormes);
    final rendementMoyenNorme =
        surfaceRecoltee > 0 ? poidsTotalNormeAnnee / (surfaceRecoltee * 1000) : 0.0;

    return _Glass(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      radius: _UX.rLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.insights, color: _UX.navy, size: 22),
            SizedBox(width: 10),
            Text('Aperçu général',
                style: TextStyle(color: _UX.navy, fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 16),

          // Sélecteur d’année en pilule
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: _UX.navy),
              const SizedBox(width: 8),
              const Text('Année',
                  style: TextStyle(color: _UX.navy, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF5F2F0)],
                    ),
                    boxShadow: _UX.softShadow,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      icon: const Icon(Icons.expand_more, color: _UX.navy),
                      isExpanded: true,
                      items: () {
                        final years = chargements.map((c) => c.dateChargement.year).toSet().toList()
                          ..sort((a, b) => b - a);
                        return years
                            .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                            .toList();
                      }(),
                      onChanged: (v) => setState(() => _selectedYear = v),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _NeoCard(
                  title: 'Surface récoltée',
                  value: '${surfaceRecoltee.toStringAsFixed(1)} ha',
                  icon: Icons.landscape,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _NeoCard(
                  title: 'Rendement $_selectedYear',
                  value: '${rendementMoyenNorme.toStringAsFixed(1)} T/ha',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _NeoCard(
                  title: 'Poids total $_selectedYear',
                  value: '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(1)} T',
                  icon: Icons.scale,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _NeoCard(
                  title: 'Parcelles',
                  value: '${parcelles.length}',
                  icon: Icons.grid_view_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- MENU : tuiles 2 colonnes, visuel doux -----
  Widget _buildMenuSection() {
    Widget tile({
      required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_UX.rMd),
        child: _Glass(
          radius: _UX.rMd,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFDFCFB), Color(0xFFF6EFEA)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _UX.softShadow,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: _UX.navy, size: 26),
              ),
              const Spacer(),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: _UX.navy)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF6F7A7C))),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.menu_rounded, title: 'Menu principal'),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.14,
          children: [
            tile(
              title: 'Parcelles',
              subtitle: 'Gestion des parcelles',
              icon: Icons.landscape,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcellesScreen())),
            ),
            tile(
              title: 'Cellules',
              subtitle: 'Stockage des grains',
              icon: Icons.grid_view_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CellulesScreen())),
            ),
            tile(
              title: 'Chargements',
              subtitle: 'Récoltes et transport',
              icon: Icons.local_shipping,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChargementsScreen())),
            ),
            tile(
              title: 'Semis',
              subtitle: 'Plantations',
              icon: Icons.grass,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemisScreen())),
            ),
            tile(
              title: 'Ventes',
              subtitle: 'Suivi des ventes',
              icon: Icons.shopping_cart,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VentesScreen())),
            ),
            tile(
              title: 'Traitements',
              subtitle: 'Produits phytosanitaires',
              icon: Icons.science,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TraitementsScreen())),
            ),
          ],
        ),
      ],
    );
  }

  // ----- ACTIONS RAPIDES : deux boutons pilules -----
  Widget _buildQuickActions(FirebaseProviderV4 provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.flash_on_rounded, title: 'Actions rapides'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Pill.big(
                icon: Icons.import_export,
                label: 'Import / Export',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImportExportScreen()),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _Pill.bigOutline(
                icon: Icons.picture_as_pdf,
                label: 'Exports PDF',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExportsPdfScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ====== Petits widgets de style (glass, neo, pills) ======

class _Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const _Glass({
    Key? key,
    required this.child,
    this.padding,
    this.radius = _UX.rLg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: _UX.cardGrad,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: _UX.softShadow,
          ),
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

class _NeoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _NeoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF7F4F2)]),
        borderRadius: BorderRadius.circular(_UX.rMd),
        boxShadow: _UX.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _UX.navy.withOpacity(.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _UX.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6F7A7C), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _UX.navy)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool outline;
  final bool big;

  const _Pill.icon({required this.icon, required this.label, required this.onTap, Key? key})
      : outline = false,
        big = false,
        super(key: key);

  const _Pill.big({required this.icon, required this.label, required this.onTap, Key? key})
      : outline = false,
        big = true,
        super(key: key);

  const _Pill.bigOutline({required this.icon, required this.label, required this.onTap, Key? key})
      : outline = true,
        big = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: outline ? _UX.navy : Colors.white, size: big ? 22 : 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: outline ? _UX.navy : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    if (outline) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: big ? 16 : 12, vertical: big ? 14 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _UX.navy.withOpacity(.2), width: 1.4),
            color: Colors.white.withOpacity(.8),
          ),
          child: child,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: big ? 16 : 12, vertical: big ? 14 : 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: _UX.pillGrad,
          boxShadow: _UX.softShadow,
        ),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _UX.navy.withOpacity(.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _UX.navy, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: _UX.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
