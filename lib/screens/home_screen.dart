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

/// ===================== THEME AGRI LIQUID GLASS =====================
class _AG {
  // Couleurs agricoles
  static const Color leaf     = Color(0xFF1F8A48);
  static const Color leafDark = Color(0xFF156A37);
  static const Color meadow   = Color(0xFF9ED6B5);
  static const Color wheat    = Color(0xFFF2E7D9);
  static const Color sand     = Color(0xFFF7F1E9);
  static const Color clay     = Color(0xFFC9A07A);
  static const Color soil     = Color(0xFF8E6B57);
  static const Color ink      = Color(0xFF172A23);

  // Rayons
  static const double rXXL = 32;
  static const double rXL  = 26;
  static const double rL   = 20;
  static const double rM   = 16;
  static const double rS   = 12;

  // Ombres
  static const List<BoxShadow> shadowFloat = [
    BoxShadow(color: Colors.black12, blurRadius: 28, offset: Offset(0, 14)),
  ];

  // Fond doux
  static const LinearGradient bg = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [sand, Color(0xFFEFF6F1), Color(0xFFFFF7EF)],
  );

  // Dégradé pilule
  static const LinearGradient pill = LinearGradient(
    colors: [leaf, clay],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// ================ ECRAN ==================
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int? _selectedYear;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    _signingOut = true;
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Déconnexion')),
          ],
        ),
      );
      if (ok != true) return;
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
        elevation: 0, backgroundColor: Colors.transparent, scrolledUnderElevation: 0, centerTitle: true,
        title: const Text('GAEC de la BARADE',
            style: TextStyle(color: _AG.ink, fontWeight: FontWeight.w900, letterSpacing: .2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _Pill.icon(icon: Icons.logout, label: 'Logout', onTap: _signingOut ? null : _signOut),
          ),
        ],
      ),
      body: Stack(children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: _AG.bg)),
        const _Blobs(),
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
                    _heroHeader(),
                    const SizedBox(height: 22),
                    _stats(provider),
                    const SizedBox(height: 22),
                    _menu(),
                    const SizedBox(height: 22),
                    _quickActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// ---------------- HERO HEADER (comme la maquette) ----------------
  Widget _heroHeader() {
    return _Glass(
      radius: _AG.rXXL,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Stack(
        children: [
          Row(
            children: [
              _SoftIcon(icon: Icons.agriculture, color: _AG.leaf),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GAEC de la BARADE',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _AG.ink)),
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

  /// ---------------- STATS ----------------
  Widget _stats(FirebaseProviderV4 provider) {
    final parcelles = provider.parcelles;
    final chargements = provider.chargements;

    if (_selectedYear == null) {
      final years = chargements.map((c) => c.dateChargement.year).toSet().toList()..sort((a, b) => b - a);
      _selectedYear = years.isNotEmpty ? years.first : DateTime.now().year;
    }

    final yearLoads = chargements.where((c) => c.dateChargement.year == _selectedYear).toList();
    final idsRecoltees = <String>{}..addAll(yearLoads.map((c) => c.parcelleId));

    double surfaceRecoltee = 0.0;
    for (final p in parcelles) {
      final id = p.firebaseId ?? p.id.toString();
      if (idsRecoltees.contains(id)) surfaceRecoltee += p.surface;
    }
    final poidsTotalNormeAnnee = yearLoads.fold<double>(0, (s, c) => s + c.poidsNormes);
    final rendementMoyenNorme = surfaceRecoltee > 0 ? poidsTotalNormeAnnee / (surfaceRecoltee * 1000) : 0.0;

    return _Glass(
      radius: _AG.rXL,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.insights, color: _AG.leaf, size: 22),
          SizedBox(width: 10),
          Text('Aperçu général', style: TextStyle(color: _AG.ink, fontSize: 18, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 16),

        // Sélecteur Année -> pilule verre
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: _AG.ink),
            const SizedBox(width: 8),
            const Text('Année', style: TextStyle(color: _AG.ink, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Expanded(
              child: _Glass(
                radius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    icon: const Icon(Icons.expand_more, color: _AG.ink),
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

        Row(children: [
          Expanded(
            child: _StatTile(
              title: 'Surface récoltée',
              value: '${surfaceRecoltee.toStringAsFixed(1)} ha',
              icon: Icons.landscape,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatTile(
              title: 'Rendement $_selectedYear',
              value: '${rendementMoyenNorme.toStringAsFixed(1)} T/ha',
              icon: Icons.trending_up,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: _StatTile(
              title: 'Poids total $_selectedYear',
              value: '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(1)} T',
              icon: Icons.scale,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatTile(
              title: 'Parcelles',
              value: '${parcelles.length}',
              icon: Icons.grid_view_rounded,
            ),
          ),
        ]),
      ]),
    );
  }

  /// ---------------- MENU ----------------
  Widget _menu() {
    Widget tile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_AG.rL),
        child: _Glass(
          radius: _AG.rL,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SoftIcon(icon: icon, color: _AG.leaf),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _AG.ink)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF5E6B64))),
          ]),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.menu_rounded, title: 'Menu principal'),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.14,
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

  /// ---------------- QUICK ACTIONS ----------------
  Widget _quickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(icon: Icons.flash_on_rounded, title: 'Actions rapides'),
        const SizedBox(height: 16),
        Row(children: [
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
        ]),
      ],
    );
  }
}

/// ===================== WIDGETS STYLE =====================

/// Fond avec blobs lumineux (évite l’aspect “plat” et renforce l’effet verre)
class _Blobs extends StatelessWidget {
  const _Blobs();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(children: const [
        _Blob(top: -80, left: -60, size: 220, color: _AG.wheat),
        _Blob(bottom: -50, right: -50, size: 200, color: _AG.meadow),
        _Blob(top: 140, right: -40, size: 160, color: _AG.clay),
      ]),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double? top, left, bottom, right;
  const _Blob({Key? key, this.top, this.left, this.bottom, this.right, required this.size, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, left: left, bottom: bottom, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(.55), blurRadius: size * .8, spreadRadius: size * .3)],
        ),
      ),
    );
  }
}

/// Carte verre : blur + dégradé + bordure + reflet + ombre interne
class _Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  const _Glass({Key? key, required this.child, this.padding, this.radius = _AG.rXL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(children: [
        // blur AR BG (faible pour web pour éviter les artefacts)
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14)),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(.55), Colors.white.withOpacity(.30)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(.38), width: 1),
            boxShadow: _AG.shadowFloat,
          ),
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
        // Reflet doux
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(.18), Colors.transparent],
                  stops: const [.0, .6],
                ),
              ),
            ),
          ),
        ),
        // Ombre interne bas/droite
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.bottomRight, end: Alignment.topLeft,
                  colors: [Colors.black.withOpacity(.05), Colors.transparent],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Petite tuile statut “verre”
class _StatTile extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _StatTile({Key? key, required this.title, required this.value, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: _AG.rL,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _SoftIcon(icon: icon, color: _AG.leaf),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // <- ICI la correction : on enlève une parenthèse
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5B6A63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _AG.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// Icône sur pastille douce (comme les ronds de la maquette)
class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SoftIcon({Key? key, required this.icon, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

/// Titres de section
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({Key? key, required this.icon, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: _AG.leaf.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: _AG.leaf, size: 22),
      ),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(fontSize: 18, color: _AG.ink, fontWeight: FontWeight.w900)),
    ]);
  }
}

/// Boutons pilule (plein/outline)
class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool outline, big;

  const _Pill.icon({Key? key, required this.icon, required this.label, required this.onTap})
      : outline = false, big = false, super(key: key);
  const _Pill.big({Key? key, required this.icon, required this.label, required this.onTap})
      : outline = false, big = true, super(key: key);
  const _Pill.bigOutline({Key? key, required this.icon, required this.label, required this.onTap})
      : outline = true, big = true, super(key: key);

  @override
  Widget build(BuildContext context) {
    final inner = Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: outline ? _AG.leaf : Colors.white, size: big ? 22 : 18),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: outline ? _AG.leaf : Colors.white, fontWeight: FontWeight.w800)),
    ]);

    if (outline) {
      return InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: big ? 16 : 12, vertical: big ? 14 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _AG.leaf.withOpacity(.35), width: 1.6),
            color: Colors.white.withOpacity(.85),
          ),
          child: inner,
        ),
      );
    }
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: big ? 16 : 12, vertical: big ? 14 : 8),
        decoration: const BoxDecoration(gradient: _AG.pill, borderRadius: BorderRadius.all(Radius.circular(32))),
        child: inner,
      ),
    );
  }
}
