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
import 'package:flutter/services.dart';
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
        foregroundColor: AppTheme.onPrimary,
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final parcelles = provider.parcelles;
          final produits = provider.produits;
          final annees = _getAvailableYears(provider);
          return SingleChildScrollView(
            padding: AppTheme.padding(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sélecteur d'année
                _buildYearSelector(annees),
                SizedBox(height: AppTheme.spacingL),
                
                // Sélection des parcelles
                _buildParcellesSection(parcelles),
                SizedBox(height: AppTheme.spacingL),
                
                // Produits
                _buildProduitsSection(produits),
                SizedBox(height: AppTheme.spacingL),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: AppTheme.createInputDecoration(
                    labelText: 'Notes communes',
                    hintText: 'Notes qui seront ajoutées à tous les traitements',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: AppTheme.spacingL),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: ModernOutlinedButton(
                        text: 'Annuler',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingM),
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
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
          SizedBox(height: AppTheme.spacingS),
          DropdownButtonFormField<int>(
            value: _selectedAnnee,
            decoration: AppTheme.createInputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingS, vertical: AppTheme.spacingS),
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
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
                  SizedBox(width: AppTheme.spacingS),
                  ModernOutlinedButton(
                    text: 'Tout désélectionner',
                    onPressed: _deselectAllParcelles,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingS),
          if (_selectedParcelleIds.isEmpty)
            Text(
              'Aucune parcelle sélectionnée',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          else
            Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingS,
              children: _selectedParcelleIds.map((parcelleId) {
                final parcelle = parcelles.firstWhere((p) => p.firebaseId == parcelleId);
                return Chip(
                  label: Text(parcelle.nom),
                  onDeleted: () {
                    setState(() {
                      _selectedParcelleIds.remove(parcelleId);
                    });
                  },
                  deleteIcon: Icon(Icons.close, size: AppTheme.iconSizeS),
                );
              }).toList(),
            ),
          SizedBox(height: AppTheme.spacingS),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
        ],
      ),
    );
  }
  Widget _buildProduitsSection(List<Produit> produits) {
    return Container(
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
          SizedBox(height: AppTheme.spacingS),
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
                margin: EdgeInsets.only(bottom: AppTheme.spacingS),
                padding: AppTheme.padding(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: AppTheme.radius(AppTheme.radiusSmall),
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
                            '${produit.quantite} ${produit.mesure}/ha - ${produit.prixUnitaire.toStringAsFixed(2)} €/${produit.mesure}',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Coût: ${produit.coutTotal.toStringAsFixed(2)} €/ha',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeProduit(index),
                      icon: Icon(Icons.delete, color: AppTheme.error, size: AppTheme.iconSizeM),
                    ),
                  ],
                ),
              );
            }).toList(),
          if (_produits.isNotEmpty) ...[
            SizedBox(height: AppTheme.spacingM),
            Container(
              padding: AppTheme.padding(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: AppTheme.radius(AppTheme.radiusMedium),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total par hectare:',
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success,
                    ),
                  ),
                  Text(
                    '${_calculerCoutTotalParHectare().toStringAsFixed(2)} €/ha',
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          produitsDejaAjoutes: _produits,
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
  
  double _calculerCoutTotalParHectare() {
    return _produits.fold(0.0, (sum, p) => sum + p.coutTotal);
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
  final List<ProduitTraitement> produitsDejaAjoutes;
  final Function(ProduitTraitement) onProduitSelected;
  const _ProduitSelectionScreen({
    required this.annee,
    required this.produitsDejaAjoutes,
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
        foregroundColor: AppTheme.onPrimary,
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          // Filtrer les produits déjà ajoutés
          final produitsDejaAjoutesIds = widget.produitsDejaAjoutes
              .map((p) => p.produitId)
              .toSet();
          final produitsDisponibles = provider.produits
              .where((p) => !produitsDejaAjoutesIds.contains(p.firebaseId ?? p.id.toString()))
              .toList();
          
          return Padding(
            padding: AppTheme.padding(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sélection du produit
                DropdownButtonFormField<Produit>(
                  value: _selectedProduit,
                  decoration: AppTheme.createInputDecoration(
                    labelText: 'Produit',
                    helperText: produitsDisponibles.isEmpty 
                        ? 'Tous les produits ont déjà été ajoutés'
                        : null,
                  ),
                  items: produitsDisponibles.map((produit) {
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
                SizedBox(height: AppTheme.spacingM),
                // Quantité
                TextFormField(
                  controller: _quantiteController,
                  decoration: AppTheme.createInputDecoration(
                    labelText: 'Quantité par hectare *',
                    helperText: 'Quantité appliquée par hectare',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(text: newValue.text.replaceAll(',', '.'));
                    }),
                  ],
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                SizedBox(height: AppTheme.spacingM),
                // Prix unitaire
                TextFormField(
                  controller: _prixController,
                  decoration: AppTheme.createInputDecoration(
                    labelText: 'Prix unitaire',
                    helperText: 'Prix par unité du produit',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(text: newValue.text.replaceAll(',', '.'));
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _prixUnitaire = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
                SizedBox(height: AppTheme.spacingM),
                // Date
                ListTile(
                  title: Text('Date'),
                  subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: Icon(Icons.calendar_today, color: AppTheme.textSecondary),
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
                SizedBox(height: AppTheme.spacingM),
                // Coût total
                Container(
                  padding: AppTheme.padding(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
                SizedBox(height: AppTheme.spacingL),
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: ModernOutlinedButton(
                        text: 'Annuler',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingM),
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
