import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../theme/app_theme.dart';
import '../widgets/app_layout.dart';
import '../models/parcelle.dart';
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
    return AppLayout(
      title: 'Parcelles',
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showAddParcelleDialog(),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Ajouter'),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddParcelleDialog(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      child: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final parcelles = _filterParcelles(provider.parcelles);

          return Column(
            children: [
              _buildHeader(),
              const SizedBox(height: AppTheme.spacingL),
              _buildToolbar(),
              const SizedBox(height: AppTheme.spacingL),
              if (parcelles.isEmpty)
                _buildEmptyState()
              else
                _buildParcellesList(parcelles, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Parcelles',
          style: AppTheme.h1,
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddParcelleDialog(),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Ajouter'),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        // Recherche
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher une parcelle...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        // Filtres
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filtrer',
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Toutes', child: Text('Toutes')),
              DropdownMenuItem(value: 'Actives', child: Text('Actives')),
              DropdownMenuItem(value: 'En jachère', child: Text('En jachère')),
            ],
            onChanged: (value) => setState(() => _selectedFilter = value ?? 'Toutes'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.landscape,
                size: 64,
                color: AppTheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            Text(
              'Aucune parcelle pour l\'instant',
              style: AppTheme.h2.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Créez votre première parcelle pour commencer à suivre vos cultures.',
              style: AppTheme.body.copyWith(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            ElevatedButton.icon(
              onPressed: () => _showAddParcelleDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Créer une parcelle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParcellesList(List<Parcelle> parcelles, FirebaseProviderV3 provider) {
    return Expanded(
      child: ListView.builder(
        itemCount: parcelles.length,
        itemBuilder: (context, index) {
          final parcelle = parcelles[index];
          return _buildParcelleCard(parcelle, provider);
        },
      ),
    );
  }

  Widget _buildParcelleCard(Parcelle parcelle, FirebaseProviderV3 provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParcelleDetailsScreen(parcelle: parcelle),
            ),
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                // Icône
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.landscape,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parcelle.nom,
                        style: AppTheme.h3,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Créée le ${_formatDate(parcelle.dateCreation)}',
                        style: AppTheme.meta,
                      ),
                    ],
                  ),
                ),
                // Infos (surface, variété)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppTheme.buildStatusBadge(
                      '${parcelle.surface} ha',
                      AppTheme.success,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    AppTheme.buildStatusBadge(
                      'Surface',
                      AppTheme.textMuted,
                    ),
                  ],
                ),
                const SizedBox(width: AppTheme.spacingM),
                // Actions (éditer/supprimer)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditParcelleDialog(parcelle);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(parcelle);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                          SizedBox(width: AppTheme.spacingS),
                          Text('Éditer'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
                          SizedBox(width: AppTheme.spacingS),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Parcelle> _filterParcelles(List<Parcelle> parcelles) {
    var filtered = parcelles.where((p) {
      final matchesSearch = _searchQuery.isEmpty || 
          p.nom.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
    
    filtered.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    return filtered;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showAddParcelleDialog() async {
    final formKey = GlobalKey<FormState>();
    String nom = '';
    double surface = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Parcelle'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nom de la parcelle',
                  hintText: 'Ex: Parcelle Nord',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) => nom = value!,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Surface (hectares)',
                  hintText: 'Ex: 2.5',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une surface';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                onSaved: (value) => surface = double.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final parcelle = Parcelle(
                  nom: nom,
                  surface: surface,
                );
                context.read<FirebaseProviderV3>().ajouterParcelle(parcelle);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Parcelle ajoutée avec succès'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    ),
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditParcelleDialog(Parcelle parcelle) async {
    final formKey = GlobalKey<FormState>();
    String nom = parcelle.nom;
    double surface = parcelle.surface;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la Parcelle'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: parcelle.nom,
                decoration: const InputDecoration(
                  labelText: 'Nom de la parcelle',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) => nom = value!,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                initialValue: parcelle.surface.toString(),
                decoration: const InputDecoration(
                  labelText: 'Surface (hectares)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une surface';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                onSaved: (value) => surface = double.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final parcelleModifiee = Parcelle(
                  id: parcelle.id,
                  nom: nom,
                  surface: surface,
                  dateCreation: parcelle.dateCreation,
                );
                context.read<FirebaseProviderV3>().modifierParcelle(parcelleModifiee);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Parcelle modifiée avec succès'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    ),
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Parcelle parcelle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        content: Text('Voulez-vous vraiment supprimer la parcelle "${parcelle.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && parcelle.id != null) {
      context.read<FirebaseProviderV3>().supprimerParcelle(parcelle.id.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Parcelle supprimée'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
        ),
      );
    }
  }
}