import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/cellule.dart';
import '../theme/theme.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';
import 'cellule_form_screen.dart';

class CellulesScreen extends StatefulWidget {
  const CellulesScreen({Key? key}) : super(key: key);

  @override
  State<CellulesScreen> createState() => _CellulesScreenState();
}

class _CellulesScreenState extends State<CellulesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cellules', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          GradientButton(
            label: 'Add',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CelluleFormScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final cellules = provider.cellules;
          final filteredCellules = _filterCellules(cellules);

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
                      hintText: 'Rechercher une cellule...',
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
                          '${cellules.length} cellules',
                          Icons.grid_view,
                          AppColors.coral,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Capacité totale',
                          '${_calculateTotalCapacity(cellules).toStringAsFixed(1)} kg',
                          Icons.storage,
                          AppColors.salmon,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Liste des cellules
                Expanded(
                  child: filteredCellules.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: filteredCellules.length,
                          itemBuilder: (context, index) {
                            final cellule = filteredCellules[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCelluleCard(context, cellule, provider),
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

  Widget _buildCelluleCard(BuildContext context, Cellule cellule, FirebaseProviderV3 provider) {
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
                      'Cellule #${cellule.id}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capacité: ${cellule.capacite.toStringAsFixed(1)} kg',
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
                  '${cellule.capacite.toStringAsFixed(1)} kg',
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
                child: _buildInfoItem(Icons.storage, 'Capacité', '${cellule.capacite.toStringAsFixed(1)} kg'),
              ),
              Expanded(
                child: _buildInfoItem(Icons.location_on, 'Localisation', cellule.localisation ?? 'Non spécifiée'),
              ),
              Expanded(
                child: _buildInfoItem(Icons.calendar_today, 'Créée', _formatDate(cellule.dateCreation)),
              ),
            ],
          ),
          if (cellule.description != null && cellule.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Description: ${cellule.description}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
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
                        builder: (context) => CelluleFormScreen(cellule: cellule),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, cellule, provider);
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
              Icons.grid_view,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune cellule trouvée',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucune cellule ne correspond à votre recherche'
                : 'Commencez par ajouter votre première cellule',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Ajouter une cellule',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CelluleFormScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Cellule> _filterCellules(List<Cellule> cellules) {
    var filtered = cellules.where((cellule) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!(cellule.localisation?.toLowerCase().contains(query) ?? false) &&
            !(cellule.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Trier par capacité (plus grande en premier)
    filtered.sort((a, b) => b.capacite.compareTo(a.capacite));
    return filtered;
  }

  double _calculateTotalCapacity(List<Cellule> cellules) {
    return cellules.fold<double>(0, (sum, cellule) => sum + cellule.capacite);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(BuildContext context, Cellule cellule, FirebaseProviderV3 provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Supprimer la cellule',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette cellule ?\n\nCette action est irréversible.',
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
              provider.supprimerCellule(cellule.id.toString());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cellule supprimée'),
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
