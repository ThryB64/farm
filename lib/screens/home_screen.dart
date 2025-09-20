import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../theme/theme.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';
import '../widgets/room_tile.dart';
import '../widgets/device_chip.dart';
import 'parcelles_screen.dart';
import 'cellules_screen.dart';
import 'chargements_screen.dart';
import 'semis_screen.dart';
import 'varietes_screen.dart';
import 'import_export_screen.dart';
import 'statistiques_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi Thierry 👋', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: const [SizedBox(width: 8)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddMenu(context);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: const SizedBox.shrink(),
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final parcelles = provider.parcelles;
          final chargements = provider.chargements;
          final cellules = provider.cellules;
          final semis = provider.semis;
          final varietes = provider.varietes;

          // Calculer les statistiques
          final surfaceTotale = parcelles.fold<double>(0, (sum, p) => sum + p.surface);
          final nombreParcelles = parcelles.length;
          final nombreChargements = chargements.length;
          final nombreVarietes = varietes.length;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: ListView(
              children: [
                // Carte température "Display" (glass)
                Glass(
                  padding: const EdgeInsets.all(18),
                  radius: 28,
                  child: Row(
                    children: [
                      Text('${surfaceTotale.toStringAsFixed(1)} ha', 
                        style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: AppColors.navy)),
                      const Spacer(),
                      GradientButton(
                        label: 'Add Parcelle', 
                        icon: Icons.add, 
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ParcellesScreen()),
                          );
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('All Sections', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy)),
                const SizedBox(height: 14),
                // Grille de tuiles "room" pour les sections
                LayoutBuilder(builder: (c, s) {
                  final cross = s.maxWidth > 960 ? 4 : s.maxWidth > 640 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: cross,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: .78,
                    children: [
                      RoomTile(
                        title: 'Parcelles', 
                        meta: '$nombreParcelles parcelles • ${surfaceTotale.toStringAsFixed(1)} ha', 
                        photo: const AssetImage('assets/logo.png')
                      ),
                      RoomTile(
                        title: 'Chargements', 
                        meta: '$nombreChargements chargements', 
                        photo: const AssetImage('assets/logo.png')
                      ),
                      RoomTile(
                        title: 'Variétés', 
                        meta: '$nombreVarietes variétés', 
                        photo: const AssetImage('assets/logo.png')
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                Text('Quick Actions', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy)),
                const SizedBox(height: 12),
                Row(children: [
                  DeviceChip(icon: Icons.landscape, label: 'Parcelles', active: true),
                  const SizedBox(width: 12),
                  DeviceChip(icon: Icons.local_shipping, label: 'Chargements'),
                  const SizedBox(width: 12),
                  DeviceChip(icon: Icons.eco, label: 'Semis'),
                  const SizedBox(width: 12),
                  DeviceChip(icon: Icons.park, label: 'Variétés'),
                ]),
                const SizedBox(height: 24),
                // Statistiques détaillées
                Glass(
                  padding: const EdgeInsets.all(20),
                  radius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Farm Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.navy)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem('Parcelles', nombreParcelles.toString(), Icons.landscape),
                          ),
                          Expanded(
                            child: _buildStatItem('Surface', '${surfaceTotale.toStringAsFixed(1)} ha', Icons.area_chart),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem('Chargements', nombreChargements.toString(), Icons.local_shipping),
                          ),
                          Expanded(
                            child: _buildStatItem('Variétés', nombreVarietes.toString(), Icons.park),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Navigation rapide
                Text('Quick Navigation', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Parcelles',
                        icon: Icons.landscape,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ParcellesScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Chargements',
                        icon: Icons.local_shipping,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChargementsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Semis',
                        icon: Icons.eco,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SemisScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Variétés',
                        icon: Icons.park,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VarietesScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Statistiques',
                        icon: Icons.analytics,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StatistiquesScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Import/Export',
                        icon: Icons.settings,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ImportExportScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.coral, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, color: AppColors.navy, fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.sand,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Item',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Parcelle',
                        icon: Icons.landscape,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ParcellesScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Chargement',
                        icon: Icons.local_shipping,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChargementsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Semis',
                        icon: Icons.eco,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SemisScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Variété',
                        icon: Icons.park,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VarietesScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
