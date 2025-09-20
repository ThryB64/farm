import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/semis.dart';
import '../theme/theme.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';
import 'semis_form_screen.dart';

class SemisScreen extends StatefulWidget {
  const SemisScreen({Key? key}) : super(key: key);

  @override
  State<SemisScreen> createState() => _SemisScreenState();
}

class _SemisScreenState extends State<SemisScreen> {
  String _searchQuery = '';
  String _selectedYear = 'Toutes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semis', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          GradientButton(
            label: 'Add',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SemisFormScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final semis = provider.semis;
          final filteredSemis = _filterSemis(semis);

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
                      hintText: 'Rechercher un semis...',
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
                      ..._getAvailableYears(semis).map((year) => 
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
                          '${semis.length} semis',
                          Icons.eco,
                          AppColors.coral,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Variétés',
                          '${_getUniqueVarieties(semis).length} variétés',
                          Icons.park,
                          AppColors.salmon,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Liste des semis
                Expanded(
                  child: filteredSemis.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: filteredSemis.length,
                          itemBuilder: (context, index) {
                            final semis = filteredSemis[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildSemisCard(context, semis, provider),
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

  Widget _buildSemisCard(BuildContext context, Semis semis, FirebaseProviderV3 provider) {
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
                      'Semis #${semis.id}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${_formatDate(semis.dateSemis)}',
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
                  '${semis.quantite.toStringAsFixed(1)} kg',
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
                child: _buildInfoItem(Icons.scale, 'Quantité', '${semis.quantite.toStringAsFixed(1)} kg'),
              ),
              Expanded(
                child: _buildInfoItem(Icons.calendar_today, 'Date', _formatDate(semis.dateSemis)),
              ),
              Expanded(
                child: _buildInfoItem(Icons.park, 'Variétés', '${semis.varietes.length}'),
              ),
            ],
          ),
          if (semis.varietes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Variétés: ${semis.varietes.join(', ')}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          if (semis.notes != null && semis.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${semis.notes}',
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
                        builder: (context) => SemisFormScreen(semis: semis),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, semis, provider);
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
              Icons.eco,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun semis trouvé',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun semis ne correspond à votre recherche'
                : 'Commencez par ajouter votre premier semis',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Ajouter un semis',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SemisFormScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Semis> _filterSemis(List<Semis> semis) {
    var filtered = semis.where((semis) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!semis.varietes.any((v) => v.toLowerCase().contains(query)) &&
            !(semis.notes?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Filtre par année
      if (_selectedYear != 'Toutes') {
        final year = int.tryParse(_selectedYear);
        if (year != null && semis.dateSemis.year != year) {
          return false;
        }
      }

      return true;
    }).toList();

    // Trier par date (plus récent en premier)
    filtered.sort((a, b) => b.dateSemis.compareTo(a.dateSemis));
    return filtered;
  }

  List<int> _getAvailableYears(List<Semis> semis) {
    final years = semis.map((s) => s.dateSemis.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  List<String> _getUniqueVarieties(List<Semis> semis) {
    final varieties = <String>{};
    for (final s in semis) {
      varieties.addAll(s.varietes);
    }
    return varieties.toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(BuildContext context, Semis semis, FirebaseProviderV3 provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Supprimer le semis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce semis ?\n\nCette action est irréversible.',
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
              provider.supprimerSemis(semis.id.toString());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Semis supprimé'),
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
