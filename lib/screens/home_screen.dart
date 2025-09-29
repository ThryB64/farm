import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../services/security_service.dart';
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

/// ====== Palette agricole & tokens ======
class _UX {
  // Teintes "agricoles"
  static const Color leaf = Color(0xFF1F8A48);   // feuille
  static const Color meadow = Color(0xFF5CAF7A); // prairie
  static const Color wheat = Color(0xFFF3E7D3);  // blé clair
  static const Color cream = Color(0xFFFFF9F2);  // crème
  static const Color clay  = Color(0xFFC69C7B);  // terre cuite
  static const Color soil  = Color(0xFF8B6B5C);  // terre
  static const Color ink   = Color(0xFF163227);  // bleu-vert profond (texte)

  static const double rLg = 28;
  static const double rMd = 20;
  static const double rSm = 14;

  static const List<BoxShadow> floatShadow = [
    BoxShadow(color: Colors.black12, blurRadius: 28, offset: Offset(0, 14)),
  ];

  /// Dégradé “verre” doux
  static LinearGradient glassGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(.55),
      Colors.white.withOpacity(.28),
    ],
  );

  /// Dégradé des boutons pilules
  static const LinearGradient pillGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leaf, Color(0xFFE6B980)], // vert -> or doux
  );

  /// Fond doux avec blobs
  static const LinearGradient bgGrad = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [
      cream,        // haut gauche
      Color(0xFFF6EFE7),
      Color(0xFFE9F5EE), // une pointe de vert pour l’ambiance agricole
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
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int? _selectedYear;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Text(
          'GAEC de la BARADE',
          style: TextStyle(color: _UX.ink, fontWeight: FontWeight.w800, fontSize: 22),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _Pill.icon(
              icon: Icons.logout,
              label: 'Logout',
              onTap: _signingOut ? null : _signOut,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fond dégradé + blobs lumineux
          const DecoratedBox(decoration: BoxDecoration(gradient: _UX.bgGrad)),
          const _BackgroundBlobs(),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
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
        ],
      ),
    );
  }

  // ----- HEADER (verre liquide + reflet latéral) -----
  Widget _buildHeader() {
    return _LiquidGlass(
      padding: const EdgeInsets.all(18),
      radius: _UX.rLg,
      tint: _UX.clay.withOpacity(.06),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _UX.leaf.withOpacity(.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: const Icon(Icons.agriculture, color: _UX.leaf, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GAEC de la BARADE',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _UX.ink)),
                    SizedBox(height: 4),
                    Text('Gestion des récoltes de maïs',
                        style: TextStyle(fontSize: 14, color: Color(0xFF51635B))),
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatistiquesScreen())),
            ),
          ),
        ],
      ),
    );
  }

  // ----- STATS (cartes verre + sélecteur pilule) -----
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

    final poidsTotalNormeAnnee = yearLoads.fold<double>(0, (sum, c) => sum + c.poidsNormes);
    final rendementMoyenNorme =
        surfaceRecoltee > 0 ? poidsTotalNormeAnnee / (surfaceRecoltee * 1000) : 0.0;

    return _LiquidGlass(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      radius: _UX.rLg,
      tint: _UX.wheat.withOpacity(.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.insights, color: _UX.leaf, size: 22),
            SizedBox(width: 10),
            Text('Aperçu général',
                style: TextStyle(color: _UX.ink, fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 16),

          // Sélecteur d’année style pilule/verre
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: _UX.ink),
              const SizedBox(width: 8),
              const Text('Année', style: TextStyle(color: _UX.ink, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Expanded(
                child: _LiquidGlass(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      icon: const Icon(Icons.expand_more, color: _UX.ink),
                      isExpanded: true,
                      items: () {
                        final years = chargements.map((c) => c.dateChargement.year).toSet().toList()
                          ..sort((a, b) => b - a);
                        return years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList();
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
                child: _StatGlass(
                  title: 'Surface récoltée',
                  value: '${surfaceRecoltee.toStringAsFixed(1)} ha',
                  icon: Icons.landscape,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatGlass(
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
                child: _StatGlass(
                  title: 'Poids total $_selectedYear',
                  value: '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(1)} T',
                  icon: Icons.scale,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatGlass(
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

  // ----- MENU (tuiles verre) -----
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
        child: _LiquidGlass(
          radius: _UX.rMd,
          padding: const EdgeInsets.all(16),
          tint: _UX.clay.withOpacity(.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _UX.leaf.withOpacity(.10),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _UX.floatShadow,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: _UX.leaf, size: 26),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _UX.ink)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF5E6B64))),
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

  // ----- ACTIONS RAPIDES -----
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
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportExportScreen())),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _Pill.bigOutline(
                icon: Icons.picture_as_pdf,
                label: 'Exports PDF',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportsPdfScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ====== Fond avec “blobs” lumineux pour l’effet maquette ======
class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80, left: -60,
            child: _GlowBlob(size: 220, color: _UX.wheat.withOpacity(.6)),
          ),
          Positioned(
            bottom: -60, right: -40,
            child: _GlowBlob(size: 200, color: _UX.clay.withOpacity(.35)),
          ),
          Positioned(
            top: 140, right: -50,
            child: _GlowBlob(size: 160, color: _UX.meadow.withOpacity(.22)),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowBlob({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: size * .8, spreadRadius: size * .3)],
      ),
    );
  }
}

/// ====== Verre liquide réutilisable (blur + bordure + reflets) ======
class _LiquidGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? tint;

  const _LiquidGlass({
    Key? key,
    required this.child,
    this.padding,
    this.radius = _UX.rLg,
    this.tint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          // flou de l’arrière-plan
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22)),
          // couche verre + légère teinte
          Container(
            decoration: BoxDecoration(
              gradient: _UX.glassGrad,
              color: (tint ?? Colors.transparent),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withOpacity(.35), width: 1),
              boxShadow: _UX.floatShadow,
            ),
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
          // Reflet haut gauche
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(.25),
                      Colors.white.withOpacity(.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.7],
                  ),
                ),
              ),
            ),
          ),
          // Ombre interne bas droit (profondeur du verre)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [
                      Colors.black.withOpacity(.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== Carte Stat en verre ======
class _StatGlass extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatGlass({Key? key, required this.title, required this.value, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _LiquidGlass(
      radius: _UX.rMd,
      padding: const EdgeInsets.all(16),
      tint: _UX.wheat.withOpacity(.06),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _UX.leaf.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _UX.leaf),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF54665D), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _UX.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== Boutons pilules (plein / contour) ======
class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool outline;
  final bool big;

  const _Pill.icon({Key? key, required this.icon, required this.label, required this.onTap})
      : outline = false, big = false, super(key: key);

  const _Pill.big({Key? key, required this.icon, required this.label, required this.onTap})
      : outline = false, big = true, super(key: key);

  const _Pill.bigOutline({Key? key, required this.icon, required this.label, required this.onTap})
      : outline = true, big = true, super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: outline ? _UX.leaf : Colors.white, size: big ? 22 : 18),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(color: outline ? _UX.leaf : Colors.white, fontWeight: FontWeight.w800)),
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
            border: Border.all(color: _UX.leaf.withOpacity(.35), width: 1.6),
            color: Colors.white.withOpacity(.85),
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
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(32)),
          gradient: _UX.pillGrad,
        ),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({Key? key, required this.icon, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _UX.leaf.withOpacity(.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _UX.leaf, size: 22),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, color: _UX.ink, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
