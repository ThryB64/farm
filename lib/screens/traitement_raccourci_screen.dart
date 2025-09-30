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
class TraitementRaccourciScreen extends StatefulWidget {
  const TraitementRaccourciScreen({Key? key}) : super(key: key);
  @override
  State<TraitementRaccourciScreen> createState() => _TraitementRaccourciScreenState();
}
class _TraitementRaccourciScreenState extends State<TraitementRaccourciScreen> {
  final List<String> _selectedParcelleIds = [];
  final List<ProduitTraitement> _produits = [];
  final TextEditingController _notesController = TextEditingController();
  int _selectedAnnee = DateTime.now().year;
  bool _isLoading = false;
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raccourci Traitements'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final parcelles = provider.parcelles;
          final produits = provider.produits;
          final annees = _getAvailableYears(provider);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sélecteur d'année
                _buildYearSelector(annees),
                const SizedBox(height: AppTheme.spacingL),
                
                // Sélection des parcelles
                _buildParcellesSection(parcelles),
                const SizedBox(height: AppTheme.spacingL),
                
                // Produits
                _buildProduitsSection(produits),
                const SizedBox(height: AppTheme.spacingL),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes communes',
                    border: OutlineInputBorder(),
                    hintText: 'Notes qui seront ajoutées à tous les traitements',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppTheme.spacingL),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: ModernOutlinedButton(
                        text: 'Annuler',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: ModernButton(
                        text: 'Appliquer à ${_selectedParcelleIds.length} parcelles',
                        isLoading: _isLoading,
                        onPressed: _canSave() ? _saveTraitements : null,
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
  Widget _buildYearSelector(List<int> annees) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Année des traitements',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedAnnee,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: annees.map((annee) {
              return DropdownMenuItem(
                value: annee,
                child: Text('$annee'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAnnee = value!;
              });
            },
          ),
        ],
      ),
    );
  }
  Widget _buildParcellesSection(List<Parcelle> parcelles) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parcelles sélectionnées (${_selectedParcelleIds.length})',
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  ModernOutlinedButton(
                    text: 'Tout sélectionner',
                    onPressed: _selectAllParcelles,
                  ),
                  const SizedBox(width: 8),
                  ModernOutlinedButton(
                    text: 'Tout désélectionner',
                    onPressed: _deselectAllParcelles,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_selectedParcelleIds.isEmpty)
            Text(
              'Aucune parcelle sélectionnée',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedParcelleIds.map((parcelleId) {
                final parcelle = parcelles.firstWhere((p) => p.firebaseId == parcelleId);
                return Chip(
                  label: Text(parcelle.nom),
                  onDeleted: () {
                    setState(() {
                      _selectedParcelleIds.remove(parcelleId);
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 18),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: parcelles.length,
              itemBuilder: (context, index) {
                final parcelle = parcelles[index];
                final isSelected = _selectedParcelleIds.contains(parcelle.firebaseId);
                
                return CheckboxListTile(
                  title: Text(parcelle.nom),
                  subtitle: Text('${parcelle.surface.toStringAsFixed(2)} ha'),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedParcelleIds.add(parcelle.firebaseId!);
                      } else {
                        _selectedParcelleIds.remove(parcelle.firebaseId);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProduitsSection(List<Produit> produits) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Produits (${_produits.length})',
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ModernOutlinedButton(
                text: 'Ajouter produit',
                onPressed: _addProduit,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_produits.isEmpty)
            Text(
              'Aucun produit ajouté',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          else
            ..._produits.asMap().entries.map((entry) {
              final index = entry.key;
              final produit = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produit.nomProduit,
                            style: AppTheme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${produit.quantite} ${produit.mesure} - ${produit.prixUnitaire.toStringAsFixed(2)} €/unité',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeProduit(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
  List<int> _getAvailableYears(FirebaseProviderV4 provider) {
    final traitements = provider.traitements;
    final semis = provider.semis;
    
    final anneesTraitements = traitements.map((t) => t.annee).toSet();
    final anneesSemis = semis.map((s) => s.date.year).toSet();
    
    final allAnnees = {...anneesTraitements, ...anneesSemis};
    final annees = allAnnees.toList()..sort();
    
    if (!annees.contains(DateTime.now().year)) {
      annees.add(DateTime.now().year);
    }
    
    return annees;
  }
  bool _canSave() {
    return _selectedParcelleIds.isNotEmpty && _produits.isNotEmpty;
  }
  void _addProduit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProduitSelectionScreen(
          annee: _selectedAnnee,
          onProduitSelected: (produit) {
            setState(() {
              _produits.add(produit);
            });
          },
        ),
      ),
    );
  }
  void _removeProduit(int index) {
    setState(() {
      _produits.removeAt(index);
    });
  }
  void _selectAllParcelles() {
    setState(() {
      final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
      _selectedParcelleIds.clear();
      _selectedParcelleIds.addAll(provider.parcelles.map((p) => p.firebaseId!).toList());
    });
  }
  void _deselectAllParcelles() {
    setState(() {
      _selectedParcelleIds.clear();
    });
  }
  Future<void> _saveTraitements() async {
    if (_selectedParcelleIds.isEmpty || _produits.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
      
      for (final parcelleId in _selectedParcelleIds) {
        // Vérifier s'il existe déjà un traitement pour cette parcelle et cette année
        final existingTraitement = provider.traitements.firstWhere(
          (t) => t.parcelleId == parcelleId && t.annee == _selectedAnnee,
          orElse: () => Traitement(
            id: 0,
            parcelleId: parcelleId,
            date: DateTime.now(),
            annee: _selectedAnnee,
            notes: '',
            produits: [],
            coutTotal: 0,
          ),
        );
        if (existingTraitement.id != 0) {
          // Mettre à jour le traitement existant
          final updatedTraitement = Traitement(
            id: existingTraitement.id,
            firebaseId: existingTraitement.firebaseId,
            parcelleId: parcelleId,
            date: existingTraitement.date,
            annee: _selectedAnnee,
            notes: _notesController.text.isNotEmpty 
                ? '${existingTraitement.notes}\n${_notesController.text}'.trim()
                : existingTraitement.notes,
            produits: _produits,
            coutTotal: _produits.fold(0.0, (sum, p) => sum + (p as ProduitTraitement).coutTotal),
          );
          
          await provider.modifierTraitement(updatedTraitement);
        } else {
          // Créer un nouveau traitement
          final nouveauTraitement = Traitement(
            id: 0,
            parcelleId: parcelleId,
            date: DateTime.now(),
            annee: _selectedAnnee,
            notes: _notesController.text,
            produits: _produits,
            coutTotal: _produits.fold(0.0, (sum, p) => sum + (p as ProduitTraitement).coutTotal),
          );
          
          await provider.ajouterTraitement(nouveauTraitement);
        }
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Traitements appliqués à ${_selectedParcelleIds.length} parcelles'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
// Écran de sélection de produit (réutilisé depuis TraitementFormScreen)
class _ProduitSelectionScreen extends StatefulWidget {
  final int annee;
  final Function(ProduitTraitement) onProduitSelected;
  const _ProduitSelectionScreen({
    required this.annee,
    required this.onProduitSelected,
  });
  @override
  State<_ProduitSelectionScreen> createState() => _ProduitSelectionScreenState();
}
class _ProduitSelectionScreenState extends State<_ProduitSelectionScreen> {
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  Produit? _selectedProduit;
  DateTime _selectedDate = DateTime.now();
  double _prixUnitaire = 0.0;
  @override
  void dispose() {
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final produits = provider.produits;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sélection du produit
                DropdownButtonFormField<Produit>(
                  value: _selectedProduit,
                  decoration: const InputDecoration(
                    labelText: 'Produit',
                    border: OutlineInputBorder(),
                  ),
                  items: produits.map((produit) {
                    return DropdownMenuItem(
                      value: produit,
                      child: Text(produit.nom),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProduit = value;
                      if (value != null) {
                        _prixUnitaire = value.prixParAnnee[widget.annee] ?? 0.0;
                        _prixController.text = _prixUnitaire.toString();
                        _calculerCoutTotal();
                      }
                    });
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Quantité
                TextFormField(
                  controller: _quantiteController,
                  decoration: const InputDecoration(
                    labelText: 'Quantité par hectare *',
                    border: OutlineInputBorder(),
                    helperText: 'Quantité appliquée par hectare',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _calculerCoutTotal(),
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Prix unitaire
                TextFormField(
                  controller: _prixController,
                  decoration: const InputDecoration(
                    labelText: 'Prix unitaire',
                    border: OutlineInputBorder(),
                    helperText: 'Prix par unité du produit',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _prixUnitaire = double.tryParse(value) ?? 0.0;
                    _calculerCoutTotal();
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Date
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                // Coût total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Coût par hectare: ${_calculerCoutTotal().toStringAsFixed(2)} €/ha',
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: ModernOutlinedButton(
                        text: 'Annuler',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: ModernButton(
                        text: 'Ajouter',
                        onPressed: _canSave() ? _saveProduit : null,
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
  bool _canSave() {
    return _selectedProduit != null &&
           _quantiteController.text.isNotEmpty &&
           _prixController.text.isNotEmpty;
  }
  double _calculerCoutTotal() {
    final quantite = double.tryParse(_quantiteController.text) ?? 0.0;
    return quantite * _prixUnitaire;
  }
  void _saveProduit() {
    final quantite = double.tryParse(_quantiteController.text) ?? 0.0;
    
    final produitTraitement = ProduitTraitement(
      produitId: _selectedProduit!.firebaseId!,
      nomProduit: _selectedProduit!.nom,
      quantite: quantite,
      mesure: _selectedProduit!.mesure,
      prixUnitaire: _prixUnitaire,
      coutTotal: _calculerCoutTotal(),
      date: _selectedDate,
    );
    widget.onProduitSelected(produitTraitement);
    Navigator.pop(context);
  }
}
