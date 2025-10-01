import '../models/variete_surface.dart';
import '../models/produit_traitement.dart';
import '../models/produit.dart';
import '../models/traitement.dart';
import '../models/vente.dart';
import '../models/semis.dart';
import '../models/chargement.dart';
import '../models/cellule.dart';
import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import 'traitement_form_screen.dart';
import 'produits_screen.dart';
import 'traitement_raccourci_screen.dart';
class TraitementsScreen extends StatefulWidget {
  const TraitementsScreen({Key? key}) : super(key: key);
  @override
  State<TraitementsScreen> createState() => _TraitementsScreenState();
}
class _TraitementsScreenState extends State<TraitementsScreen> {
  int? _selectedYear;
  String? _selectedParcelleId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelections();
    });
  }
  void _initializeSelections() {
    final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
    
    // Initialiser l'année
    if (_selectedYear == null) {
      final annees = provider.traitements
          .map((t) => t.annee)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));
      if (annees.isNotEmpty) {
        setState(() {
          _selectedYear = annees.first;
        });
      } else {
        setState(() {
          _selectedYear = DateTime.now().year;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traitements'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProduitsScreen()),
            ),
            tooltip: 'Gérer les produits',
          ),
        ],
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final traitements = provider.traitements;
          final parcelles = provider.parcelles;
          return Column(
            children: [
              // Filtres
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                color: AppTheme.surface,
                child: Column(
                  children: [
                    // Sélecteur d'année
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppTheme.primary),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Année:',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: AppTheme.createInputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingS, vertical: AppTheme.spacingXS),
                            ),
                            items: () {
                              final annees = traitements
                                  .map((t) => t.annee)
                                  .toSet()
                                  .toList();
                              annees.sort((a, b) => b.compareTo(a));
                              return annees.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }).toList();
                            }(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = value;
                                _selectedParcelleId = null; // Reset parcelle selection
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    // Sélecteur de parcelle
                    Row(
                      children: [
                        const Icon(Icons.landscape, color: AppTheme.primary),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Parcelle:',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedParcelleId,
                            decoration: AppTheme.createInputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingS, vertical: AppTheme.spacingXS),
                              hintText: 'Toutes les parcelles',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Toutes les parcelles'),
                              ),
                              ...parcelles.map((p) {
                                return DropdownMenuItem(
                                  value: p.firebaseId ?? p.id.toString(),
                                  child: Text(p.nom),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedParcelleId = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Liste des traitements
              Expanded(
                child: _buildTraitementsList(provider, traitements, parcelles),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bouton raccourci
          FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TraitementRaccourciScreen(),
              ),
            ),
            icon: const Icon(Icons.speed),
            label: const Text('Raccourci'),
            backgroundColor: AppTheme.secondary,
            foregroundColor: AppTheme.onPrimary,
            heroTag: "raccourci",
          ),
          const SizedBox(height: 16),
          // Bouton principal
          FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TraitementFormScreen(
                  annee: _selectedYear ?? DateTime.now().year,
                ),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau traitement'),
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.onPrimary,
            heroTag: "nouveau",
          ),
        ],
      ),
    );
  }
  Widget _buildTraitementsList(
    FirebaseProviderV4 provider,
    List<Traitement> traitements,
    List<Parcelle> parcelles,
  ) {
    // Filtrer les traitements
    var traitementsFiltres = traitements.where((t) {
      if (_selectedYear != null && t.annee != _selectedYear) return false;
      if (_selectedParcelleId != null && t.parcelleId != _selectedParcelleId) return false;
      return true;
    }).toList();
    // Trier par date décroissante
    traitementsFiltres.sort((a, b) => b.date.compareTo(a.date));
    if (traitementsFiltres.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: traitementsFiltres.length,
      itemBuilder: (context, index) {
        final traitement = traitementsFiltres[index];
        final parcelle = parcelles.firstWhere(
          (p) => (p.firebaseId ?? p.id.toString()) == traitement.parcelleId,
          orElse: () => Parcelle(
            id: 0,
            nom: 'Parcelle inconnue',
            surface: 0,
            dateCreation: DateTime.now(),
          ),
        );
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary,
              child: const Icon(
                Icons.science,
                color: AppTheme.onPrimary,
              ),
            ),
            title: Text(
              parcelle.nom,
              style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Parcelle: ${parcelle.nom}'),
                Text('Produits: ${traitement.produits.length}'),
                if (traitement.produits.isNotEmpty)
                  Text('Dates: ${traitement.produits.map((p) => _formatDate(p.date)).join(', ')}'),
                if (traitement.notes != null && traitement.notes!.isNotEmpty)
                  Text('Notes: ${traitement.notes}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${traitement.coutTotal.toStringAsFixed(2)} €',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TraitementFormScreen(
                            traitement: traitement,
                            annee: traitement.annee,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: AppTheme.iconSizeM, color: AppTheme.error),
                      onPressed: () => _confirmDelete(provider, traitement),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Aucun traitement',
            style: AppTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Commencez par ajouter un traitement',
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TraitementFormScreen(
                  annee: _selectedYear ?? DateTime.now().year,
                ),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un traitement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
            ),
          ),
        ],
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  void _confirmDelete(FirebaseProviderV4 provider, Traitement traitement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le traitement'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce traitement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.supprimerTraitement(traitement.firebaseId ?? traitement.id.toString());
            },
            child: Text('Supprimer', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
