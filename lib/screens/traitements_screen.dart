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
import 'package:flutter/services.dart';
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Traitements'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
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
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBgGradient),
        child: Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) {
          final traitements = provider.traitements;
          final parcelles = provider.parcelles;
          return Padding(
            padding: const EdgeInsets.only(bottom: 140), // Espace pour les boutons flottants
            child: Column(
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
              
              // Total global
              _buildTotalSection(traitements),
            ],
            ),
          );
        },
        ),
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
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: AppTheme.glass(
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
                SizedBox(height: 8),
                Text(
                  'Surface: ${parcelle.surface.toStringAsFixed(2)} ha',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Produits utilisés:',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                ...traitement.produits.map((produit) => Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    '• ${produit.nomProduit}: ${produit.quantite} ${produit.mesure}/ha (${produit.prixUnitaire.toStringAsFixed(2)} €/${produit.mesure})',
                    style: AppTheme.textTheme.bodySmall,
                  ),
                )).toList(),
                SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    // Calculer le coût par hectare à partir des produits
                    final coutParHectare = traitement.produits.fold<double>(
                      0.0,
                      (sum, produit) => sum + produit.coutTotal,
                    );
                    // Calculer le coût total de la parcelle
                    final coutTotalParcelle = coutParHectare * parcelle.surface;
                    
                    return Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coût par hectare: ${coutParHectare.toStringAsFixed(2)} €/ha',
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Coût total parcelle: ${coutTotalParcelle.toStringAsFixed(2)} €',
                            style: AppTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (traitement.notes != null && traitement.notes!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    'Notes: ${traitement.notes}',
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
            isThreeLine: true,
          ),
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
  Widget _buildTotalSection(List<Traitement> traitements) {
    // Filtrer les traitements selon les critères sélectionnés
    var traitementsFiltres = traitements.where((t) {
      if (_selectedYear != null && t.annee != _selectedYear) return false;
      if (_selectedParcelleId != null && t.parcelleId != _selectedParcelleId) return false;
      return true;
    }).toList();
    
    if (traitementsFiltres.isEmpty) return const SizedBox.shrink();
    
    return Consumer<FirebaseProviderV4>(
      builder: (context, provider, child) {
        // Calculer le total et la surface totale
        double totalCout = 0.0;
        double surfaceTotale = 0.0;
        final parcellesUniques = <String>{};
        
        for (final traitement in traitementsFiltres) {
          parcellesUniques.add(traitement.parcelleId);
          
          final parcelle = provider.getParcelleById(traitement.parcelleId);
          if (parcelle != null) {
            // Calculer le coût par hectare à partir des produits
            final coutParHectare = traitement.produits.fold<double>(
              0.0,
              (sum, produit) => sum + produit.coutTotal,
            );
            // Calculer le coût total de cette parcelle
            totalCout += coutParHectare * parcelle.surface;
            surfaceTotale += parcelle.surface;
          }
        }
        
        final coutMoyenParHa = surfaceTotale > 0 ? totalCout / surfaceTotale : 0.0;
        
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            border: Border(
              top: BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Informations à gauche
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL GÉNÉRAL',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${parcellesUniques.length} parcelle(s) • ${traitementsFiltres.length} traitement(s) • ${surfaceTotale.toStringAsFixed(2)} ha',
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Coût total
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Coût total',
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${totalCout.toStringAsFixed(2)} €',
                      style: AppTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: AppTheme.spacingM),
              
              // Prix moyen
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Prix moyen',
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${coutMoyenParHa.toStringAsFixed(2)} €/ha',
                      style: AppTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
