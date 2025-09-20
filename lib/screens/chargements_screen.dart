import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/chargement.dart';
import '../theme/theme.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';
import 'chargement_form_screen.dart';

class ChargementsScreen extends StatefulWidget {
  const ChargementsScreen({Key? key}) : super(key: key);

  @override
  State<ChargementsScreen> createState() => _ChargementsScreenState();
}

class _ChargementsScreenState extends State<ChargementsScreen> {
  String _searchQuery = '';
  String _selectedYear = 'Toutes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chargements', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          GradientButton(
            label: 'Add',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChargementFormScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final chargements = provider.chargements;
          final filteredChargements = _filterChargements(chargements);

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
                      hintText: 'Rechercher un chargement...',
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
                // Filtres par année
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Toutes', _selectedYear == 'Toutes'),
                      const SizedBox(width: 8),
                      ..._getAvailableYears(chargements).map((year) => 
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(year.toString(), _selectedYear == year.toString()),
                        ),
                      ),
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
                          '${chargements.length} chargements',
                          Icons.local_shipping,
                          AppColors.coral,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Poids total',
                          '${_calculateTotalWeight(chargements).toStringAsFixed(1)} kg',
                          Icons.scale,
                          AppColors.salmon,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Liste des chargements
                Expanded(
                  child: filteredChargements.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: filteredChargements.length,
                          itemBuilder: (context, index) {
                            final chargement = filteredChargements[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildChargementCard(context, chargement, provider),
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
          _selectedYear = label;
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

  Widget _buildChargementCard(BuildContext context, Chargement chargement, FirebaseProviderV3 provider) {
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
                      'Chargement #${chargement.id}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${_formatDate(chargement.dateChargement)}',
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
                  '${chargement.poids.toStringAsFixed(1)} kg',
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
                child: _buildInfoItem(Icons.scale, 'Poids', '${chargement.poids.toStringAsFixed(1)} kg'),
              ),
              Expanded(
                child: _buildInfoItem(Icons.calendar_today, 'Date', _formatDate(chargement.dateChargement)),
              ),
              Expanded(
                child: _buildInfoItem(Icons.info, 'Type', chargement.type ?? 'Non spécifié'),
              ),
            ],
          ),
          if (chargement.notes != null && chargement.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Notes: ${chargement.notes}',
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
                        builder: (context) => ChargementFormScreen(chargement: chargement),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, chargement, provider);
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
              Icons.local_shipping,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun chargement trouvé',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun chargement ne correspond à votre recherche'
                : 'Commencez par ajouter votre premier chargement',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Ajouter un chargement',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChargementFormScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Chargement> _filterChargements(List<Chargement> chargements) {
    var filtered = chargements.where((chargement) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!(chargement.type?.toLowerCase().contains(query) ?? false) &&
            !(chargement.notes?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Filtre par année
      if (_selectedYear != 'Toutes') {
        final year = int.tryParse(_selectedYear);
        if (year != null && chargement.dateChargement.year != year) {
          return false;
        }
      }

      return true;
    }).toList();

    // Trier par date (plus récent en premier)
    filtered.sort((a, b) => b.dateChargement.compareTo(a.dateChargement));
    return filtered;
  }

  List<int> _getAvailableYears(List<Chargement> chargements) {
    final years = chargements.map((c) => c.dateChargement.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  double _calculateTotalWeight(List<Chargement> chargements) {
    return chargements.fold<double>(0, (sum, chargement) => sum + chargement.poids);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(BuildContext context, Chargement chargement, FirebaseProviderV3 provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Supprimer le chargement',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce chargement ?\n\nCette action est irréversible.',
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
              provider.supprimerChargement(chargement.id.toString());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chargement supprimé'),
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
