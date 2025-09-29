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

/// ===================== THEME (exactement la palette des images) =====================
/// Peach / Coral / Navy  + verre brun
class _P {
  // Palette de la 2e image
  static const Color cream = Color(0xFFF6E8DF); // #F6E8DF
  static const Color peach = Color(0xFFFEAE96); // #FEAE96
  static const Color coral = Color(0xFFFE979C); // #FE979C
  static const Color navy  = Color(0xFF013237); // #013237

  // Tons “verre brun” de la 1re image
  static const Color cocoa = Color(0xFF8C6A55); // brun doux
  static const Color latte = Color(0xFFB58E74); // brun clair

  // Tokens
  static const double rXXL = 32;
  static const double rXL  = 26;
  static const double rL   = 20;
  static const double rM   = 16;

  static const List<BoxShadow> float = [
    BoxShadow(color: Colors.black12, blurRadius: 26, offset: Offset(0, 14)),
  ];

  static const LinearGradient bg = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [
      Color(0xFFFFFAF6), // clair
      cream,             // beige rosé
      Color(0xFFFDF1ED), // léger rose
    ],
  );

  // dégradé boutons (peach -> coral)
  static const LinearGradient pill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [peach, coral],
  );
}

/// ===================== ECRAN =====================
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
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic);
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
            style: TextStyle(color: _P.navy, fontWeight: FontWeight.w900, letterSpacing: .2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _Pill.icon(icon: Icons.logout, label: 'Logout', onTap: _signingOut ? null : _signOut),
          ),
        ],
      ),
      body: Stack(
        children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: _P.bg)),
          const _Vignette(),         // vignette subtile autour (comme maquette)
          const _BlobsWarm(),        // halos warm (peach/coral)
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
                      _headerHero(),
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
        ],
      ),
    );
  }

  /// ---------------- HEADER HERO (verre brun + chips rondes) ----------------
  Widget _headerHero() {
    return _BrownGlass(
      radius: _P.rXXL,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Row(
                children: const [
                  _SoftIcon(icon: Icons.agriculture, color: _P.navy),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GAEC de la BARADE',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Gestion des récoltes de maïs',
                            style: TextStyle(fontSize: 14, color: Color(0xFFF2E6DF))),
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
                  onTap: null, // remplacé ci-dessous pour garder stack cliquable
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // rangée de chips rondes façon “Devices” (style identique à la maquette)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlassChip(icon: Icons.wifi, label: 'WiFi'),
              _GlassChip(icon: Icons.light_mode, label: 'Light'),
              _GlassChip(icon: Icons.thermostat, label: 'Temp'),
              _GlassChip(icon: Icons.toys, label: 'Fan'),
            ],
          ),
        ],
      ),
      onTopRightTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatistiquesScreen())),
    );
  }

  /// ---------------- STATS (verre brun clair) ----------------
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

    return _BrownGlass(
      radius: _P.rXL,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      tint: _P.latte.withOpacity(.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.insights, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text('Aperçu général', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 16),

          // Sélecteur année (pilule claire)
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Color(0xFFF6ECE6)),
              const SizedBox(width: 8),
              const Text('Année', style: TextStyle(color: Color(0xFFF6ECE6), fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Expanded(
                child: _SoftGlass(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      icon: const Icon(Icons.expand_more, color: Colors.white),
                      dropdownColor: const Color(0xFF5D4435),
                      style: const TextStyle(color: Colors.white),
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
        ],
      ),
    );
  }

  /// ---------------- MENU (tuiles arrondies, verre clair) ----------------
  Widget _menu() {
    Widget tile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_P.rL),
        child: _SoftGlass(
          radius: _P.rL,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SoftIcon(icon: Icons.widgets_rounded, color: _P.navy),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _P.navy)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF6E5B50))),
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
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.14,
          children: [
            tile(
              title: 'Parcelles', subtitle: 'Gestion des parcelles', icon: Icons.landscape,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcellesScreen())),
            ),
            tile(
              title: 'Cellules', subtitle: 'Stockage des grains', icon: Icons.grid_view_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CellulesScreen())),
            ),
            tile(
              title: 'Chargements', subtitle: 'Récoltes et transport', icon: Icons.local_shipping,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChargementsScreen())),
            ),
            tile(
              title: 'Semis', subtitle: 'Plantations', icon: Icons.grass,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SemisScreen())),
            ),
            tile(
              title: 'Ventes', subtitle: 'Suivi des ventes', icon: Icons.shopping_cart,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VentesScreen())),
            ),
            tile(
              title: 'Traitements', subtitle: 'Produits phytosanitaires', icon: Icons.science,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TraitementsScreen())),
            ),
          ],
        ),
      ],
    );
  }

  /// ---------------- ACTIONS RAPIDES ----------------
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

/// ===================== FOND / VIGNETTE / BLOBS =====================
class _Vignette extends StatelessWidget {
  const _Vignette();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.9),
            radius: 1.2,
            colors: [Colors.transparent, Colors.black.withOpacity(.06)],
            stops: const [0.7, 1.0],
          ),
        ),
      ),
    );
  }
}

class _BlobsWarm extends StatelessWidget {
  const _BlobsWarm();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          _Blob(top: -80, left: -60, size: 220, color: _P.peach),
          _Blob(bottom: -50, right: -50, size: 200, color: _P.coral),
          _Blob(top: 140, right: -40, size: 160, color: _P.cream),
        ],
      ),
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

/// ===================== WIDGETS VERRE =====================
/// Verre brun (comme la 1re maquette) : blur + dégradé brun + bordure + reflets
class _BrownGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? tint;
  final VoidCallback? onTopRightTap;

  const _BrownGlass({
    Key? key,
    required this.child,
    this.padding,
    this.radius = _P.rXL,
    this.tint,
    this.onTopRightTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: r,
      child: Stack(
        children: [
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12)),
          Container(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xAA6F503E), // haut plus sombre
                  const Color(0x885F4536), // milieu
                  const Color(0x664D3A2E), // bas
                ],
              ),
              color: (tint ?? Colors.transparent),
              border: Border.all(color: Colors.white.withOpacity(.28), width: 1),
              boxShadow: _P.float,
            ),
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
          // Highlight en haut (reflet)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: r,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(.12), Colors.transparent],
                    stops: const [0.0, 0.45],
                  ),
                ),
              ),
            ),
          ),
          // Ombre interne bas
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: r,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(.10), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          // Bouton top-right optionnel
          if (onTopRightTap != null)
            Positioned(
              right: 12, top: 12,
              child: GestureDetector(
                onTap: onTopRightTap,
                child: _Pill.icon(icon: Icons.analytics_outlined, label: 'Stats', onTap: onTopRightTap),
              ),
            ),
        ],
      ),
    );
  }
}

/// Verre clair (pour menu / input)
class _SoftGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  const _SoftGlass({Key? key, required this.child, this.padding, this.radius = _P.rL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: r,
      child: Stack(
        children: [
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10)),
          Container(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(.60), Colors.white.withOpacity(.30)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(.35), width: 1),
              boxShadow: _P.float,
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Stat tile (verre brun clair)
class _StatTile extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _StatTile({Key? key, required this.title, required this.value, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _BrownGlass(
      radius: _P.rL,
      padding: const EdgeInsets.all(16),
      tint: _P.latte.withOpacity(.04),
      child: Row(
        children: [
          const _SoftIcon(icon: Icons.circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFF0E6E0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const SizedBox(height: 0),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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

/// Icône “chip” douce
class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SoftIcon({Key? key, required this.icon, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(12),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

/// Chips rondes comme “Devices”
class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassChip({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Stack(
            children: [
              BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10)),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(.55), Colors.white.withOpacity(.25)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(.35), width: 1),
                  boxShadow: _P.float,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(icon, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
      ],
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
    return Row(children: const [
      _SoftIcon(icon: Icons.menu_rounded, color: _P.navy),
      SizedBox(width: 12),
      Text('Menu principal', style: TextStyle(fontSize: 18, color: _P.navy, fontWeight: FontWeight.w900)),
    ]);
  }
}

/// Boutons pilule (peach->coral / outline)
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
      Icon(icon, color: outline ? _P.navy : Colors.white, size: big ? 22 : 18),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: outline ? _P.navy : Colors.white, fontWeight: FontWeight.w800)),
    ]);

    if (outline) {
      return InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: big ? 16 : 12, vertical: big ? 14 : 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _P.navy.withOpacity(.25), width: 1.4),
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
        decoration: const BoxDecoration(gradient: _P.pill, borderRadius: BorderRadius.all(Radius.circular(32))),
        child: inner,
      ),
    );
  }
}
