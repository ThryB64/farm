import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/parcelle.dart';
import '../theme/theme.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';
import 'parcelle_form_screen.dart';
import 'parcelle_details_screen.dart';

class ParcellesScreen extends StatefulWidget {
  const ParcellesScreen({Key? key}) : super(key: key);

  @override
  State<ParcellesScreen> createState() => _ParcellesScreenState();
}

class _ParcellesScreenState extends State<ParcellesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Toutes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcelles', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          GradientButton(
            label: 'Add',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParcelleFormScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final parcelles = provider.parcelles;
          final filteredParcelles = _filterParcelles(parcelles);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre de recherche
                Glass(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  radius: 20,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Rechercher une parcelle...',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filtres
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Toutes', _selectedFilter == 'Toutes'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Petites (< 2 ha)', _selectedFilter == 'Petites'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Moyennes (2-5 ha)', _selectedFilter == 'Moyennes'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Grandes (> 5 ha)', _selectedFilter == 'Grandes'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Statistiques
                Glass(
                  padding: const EdgeInsets.all(16),
                  radius: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total',
                          '${parcelles.length} parcelles',
                          Icons.landscape,
                          AppColors.coral,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Surface',
                          '${_calculateTotalSurface(parcelles).toStringAsFixed(1)} ha',
                          Icons.area_chart,
                          AppColors.salmon,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Liste des parcelles
                Expanded(
                  child: filteredParcelles.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: filteredParcelles.length,
                          itemBuilder: (context, index) {
                            final parcelle = filteredParcelles[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildParcelleCard(context, parcelle, provider),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Glass(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        radius: 20,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.navy,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, color: AppColors.navy, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildParcelleCard(BuildContext context, Parcelle parcelle, FirebaseProviderV3 provider) {
    return Glass(
      padding: const EdgeInsets.all(20),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parcelle.nom,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${parcelle.code} • Année: ${parcelle.annee}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${parcelle.surface.toStringAsFixed(1)} ha',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Informations détaillées
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(Icons.landscape, 'Surface', '${parcelle.surface.toStringAsFixed(1)} ha'),
              ),
              Expanded(
                child: _buildInfoItem(Icons.calendar_today, 'Année', parcelle.annee.toString()),
              ),
              Expanded(
                child: _buildInfoItem(Icons.tag, 'Code', parcelle.code),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Modifier',
                  icon: Icons.edit,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParcelleFormScreen(parcelle: parcelle),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, parcelle, provider);
                  },
                  child: Glass(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    radius: 16,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: AppColors.navy, size: 16),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: AppColors.navy, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Glass(
            padding: const EdgeInsets.all(40),
            radius: 40,
            child: Icon(
              Icons.landscape,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune parcelle trouvée',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucune parcelle ne correspond à votre recherche'
                : 'Commencez par ajouter votre première parcelle',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Ajouter une parcelle',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParcelleFormScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Parcelle> _filterParcelles(List<Parcelle> parcelles) {
    var filtered = parcelles.where((parcelle) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!parcelle.nom.toLowerCase().contains(query) &&
            !parcelle.code.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtre par taille
      switch (_selectedFilter) {
        case 'Petites':
          return parcelle.surface < 2.0;
        case 'Moyennes':
          return parcelle.surface >= 2.0 && parcelle.surface <= 5.0;
        case 'Grandes':
          return parcelle.surface > 5.0;
        default:
          return true;
      }
    }).toList();

    // Trier par nom
    filtered.sort((a, b) => a.nom.compareTo(b.nom));
    return filtered;
  }

  double _calculateTotalSurface(List<Parcelle> parcelles) {
    return parcelles.fold<double>(0, (sum, parcelle) => sum + parcelle.surface);
  }

  void _showDeleteDialog(BuildContext context, Parcelle parcelle, FirebaseProviderV3 provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Supprimer la parcelle',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la parcelle "${parcelle.nom}" ?\n\nCette action est irréversible.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          GradientButton(
            label: 'Annuler',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          GradientButton(
            label: 'Supprimer',
            onPressed: () {
              provider.supprimerParcelle(parcelle.id.toString());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Parcelle "${parcelle.nom}" supprimée'),
                  backgroundColor: AppColors.coral,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
