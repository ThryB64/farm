import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/variete.dart';
import '../theme/theme.dart';
import '../widgets/glass.dart';
import '../widgets/gradient_button.dart';
import 'variete_form_screen.dart';

class VarietesScreen extends StatefulWidget {
  const VarietesScreen({Key? key}) : super(key: key);

  @override
  State<VarietesScreen> createState() => _VarietesScreenState();
}

class _VarietesScreenState extends State<VarietesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variétés', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          GradientButton(
            label: 'Add',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VarieteFormScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final varietes = provider.varietes;
          final filteredVarietes = _filterVarietes(varietes);

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
                      hintText: 'Rechercher une variété...',
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
                          '${varietes.length} variétés',
                          Icons.park,
                          AppColors.coral,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Utilisées',
                          '${_getUsedVarieties(varietes).length} utilisées',
                          Icons.check_circle,
                          AppColors.salmon,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Liste des variétés
                Expanded(
                  child: filteredVarietes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          itemCount: filteredVarietes.length,
                          itemBuilder: (context, index) {
                            final variete = filteredVarietes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildVarieteCard(context, variete, provider),
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

  Widget _buildVarieteCard(BuildContext context, Variete variete, FirebaseProviderV3 provider) {
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
                      variete.nom,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${variete.type}',
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
                  '${variete.rendement.toStringAsFixed(1)} t/ha',
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
                child: _buildInfoItem(Icons.agriculture, 'Rendement', '${variete.rendement.toStringAsFixed(1)} t/ha'),
              ),
              Expanded(
                child: _buildInfoItem(Icons.category, 'Type', variete.type),
              ),
              Expanded(
                child: _buildInfoItem(Icons.calendar_today, 'Créée', _formatDate(variete.dateCreation)),
              ),
            ],
          ),
          if (variete.description != null && variete.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Description: ${variete.description}',
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
                        builder: (context) => VarieteFormScreen(variete: variete),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, variete, provider);
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
              Icons.park,
              size: 60,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune variété trouvée',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.navy),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucune variété ne correspond à votre recherche'
                : 'Commencez par ajouter votre première variété',
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Ajouter une variété',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VarieteFormScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Variete> _filterVarietes(List<Variete> varietes) {
    var filtered = varietes.where((variete) {
      // Filtre par recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!variete.nom.toLowerCase().contains(query) &&
            !variete.type.toLowerCase().contains(query) &&
            !(variete.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Trier par nom
    filtered.sort((a, b) => a.nom.compareTo(b.nom));
    return filtered;
  }

  List<Variete> _getUsedVarieties(List<Variete> varietes) {
    // Cette logique devrait être implémentée en fonction de votre logique métier
    // Pour l'instant, on retourne toutes les variétés
    return varietes;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(BuildContext context, Variete variete, FirebaseProviderV3 provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sand,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Supprimer la variété',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.navy),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la variété "${variete.nom}" ?\n\nCette action est irréversible.',
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
              provider.supprimerVariete(variete.id.toString());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Variété "${variete.nom}" supprimée'),
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
