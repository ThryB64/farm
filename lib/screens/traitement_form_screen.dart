import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/traitement.dart';
import '../models/produit.dart';
import '../models/produit_traitement.dart';

class TraitementFormScreen extends StatefulWidget {
  final Traitement? traitement;
  final int annee;

  const TraitementFormScreen({
    Key? key,
    this.traitement,
    required this.annee,
  }) : super(key: key);

  @override
  State<TraitementFormScreen> createState() => _TraitementFormScreenState();
}

class _TraitementFormScreenState extends State<TraitementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  String? _selectedParcelleId;
  List<ProduitTraitement> _produits = [];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.traitement != null) {
      _loadTraitementData();
    }
  }

  void _loadTraitementData() {
    final traitement = widget.traitement!;
    _notesController.text = traitement.notes ?? '';
    _selectedParcelleId = traitement.parcelleId;
    _produits = List.from(traitement.produits);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.traitement == null ? 'Nouveau traitement' : 'Modifier le traitement'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Parcelle
              Consumer<FirebaseProviderV4>(
                builder: (context, provider, child) {
                  final parcelles = provider.parcelles;
                  final traitements = provider.traitements;
                  
                  // Filtrer les parcelles déjà traitées pour cette année
                  final parcellesDisponibles = parcelles.where((p) {
                    final parcelleId = p.firebaseId ?? p.id.toString();
                    final traitementExistant = traitements.any((t) => 
                        t.parcelleId == parcelleId && t.annee == widget.annee);
                    
                    // Si on modifie un traitement existant, on garde la parcelle actuelle
                    if (widget.traitement != null && _selectedParcelleId == parcelleId) {
                      return true;
                    }
                    
                    return !traitementExistant;
                  }).toList();
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedParcelleId,
                    decoration: const InputDecoration(
                      labelText: 'Parcelle *',
                      border: OutlineInputBorder(),
                    ),
                    items: parcellesDisponibles.map((p) {
                      return DropdownMenuItem(
                        value: p.firebaseId ?? p.id.toString(),
                        child: Text(p.nom),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedParcelleId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une parcelle';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // Informations de la parcelle sélectionnée
              if (_selectedParcelleId != null) _buildParcelleInfo(),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Produits
              _buildProduitsSection(),
              
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
                      text: widget.traitement == null ? 'Créer' : 'Modifier',
                      isLoading: _isLoading,
                      onPressed: _saveTraitement,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProduitsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produits utilisés',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addProduit,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            if (_produits.isEmpty)
              const Center(
                child: Text(
                  'Aucun produit ajouté',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ..._produits.asMap().entries.map((entry) {
                final index = entry.key;
                final produit = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: ListTile(
                    title: Text(produit.nomProduit),
                    subtitle: Text('${produit.quantite} ${produit.mesure} - ${produit.prixUnitaire.toStringAsFixed(2)} €/${produit.mesure} - ${_formatDate(produit.date)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${produit.coutTotal.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editProduit(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _removeProduit(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            
            if (_produits.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingM),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Coût total (parcelle):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_calculerCoutTotal().toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addProduit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProduitSelectionScreen(
          annee: widget.annee,
          onProduitSelected: (produit) {
            setState(() {
              _produits.add(produit);
            });
          },
        ),
      ),
    );
  }

  void _editProduit(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProduitSelectionScreen(
          annee: widget.annee,
          produit: _produits[index],
          onProduitSelected: (produit) {
            setState(() {
              _produits[index] = produit;
            });
          },
        ),
      ),
    ).then((_) {
      // Rafraîchir l'état après modification
      setState(() {});
    });
  }

  void _removeProduit(int index) {
    setState(() {
      _produits.removeAt(index);
    });
  }

  double _calculerCoutTotal() {
    if (_selectedParcelleId == null) return 0.0;
    
    // Récupérer la surface de la parcelle
    final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
    final parcelle = provider.getParcelleById(_selectedParcelleId!);
    if (parcelle == null) return 0.0;
    
    // Calculer le coût total en multipliant par la surface de la parcelle
    return _produits.fold(0.0, (sum, produit) => sum + (produit.coutTotal * parcelle.surface));
  }

  Future<void> _saveTraitement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_produits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins un produit')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final traitement = Traitement(
        id: widget.traitement?.id,
        firebaseId: widget.traitement?.firebaseId,
        parcelleId: _selectedParcelleId!,
        date: _produits.isNotEmpty ? _produits.first.date : DateTime.now(),
        annee: widget.annee,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        produits: _produits,
        coutTotal: _calculerCoutTotal(),
      );

      final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
      
      if (widget.traitement == null) {
        await provider.ajouterTraitement(traitement);
      } else {
        await provider.modifierTraitement(traitement);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.traitement == null 
                ? 'Traitement créé avec succès' 
                : 'Traitement modifié avec succès'),
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

  Widget _buildParcelleInfo() {
    return Consumer<FirebaseProviderV4>(
      builder: (context, provider, child) {
        final parcelle = provider.getParcelleById(_selectedParcelleId!);
        if (parcelle == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.landscape, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parcelle sélectionnée',
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parcelle.nom,
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${parcelle.surface.toStringAsFixed(2)} hectares',
                      style: AppTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
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
}

// Écran de sélection de produit
class _ProduitSelectionScreen extends StatefulWidget {
  final int annee;
  final ProduitTraitement? produit;
  final Function(ProduitTraitement) onProduitSelected;

  const _ProduitSelectionScreen({
    Key? key,
    required this.annee,
    this.produit,
    required this.onProduitSelected,
  }) : super(key: key);

  @override
  State<_ProduitSelectionScreen> createState() => _ProduitSelectionScreenState();
}

class _ProduitSelectionScreenState extends State<_ProduitSelectionScreen> {
  Produit? _selectedProduit;
  final _quantiteController = TextEditingController();
  double _prixUnitaire = 0.0;
  DateTime _selectedDate = DateTime.now();
  int _selectedAnnee = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    if (widget.produit != null) {
      _loadProduitData();
    }
  }

  void _loadProduitData() {
    final produitTraitement = widget.produit!;
    _quantiteController.text = produitTraitement.quantite.toString();
    _prixUnitaire = produitTraitement.prixUnitaire;
    _selectedDate = produitTraitement.date;
    _selectedAnnee = widget.annee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un produit'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final produits = provider.produits;
          
          return Column(
            children: [
              // Sélection du produit
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: DropdownButtonFormField<Produit>(
                  value: _selectedProduit,
                  decoration: const InputDecoration(
                    labelText: 'Produit *',
                    border: OutlineInputBorder(),
                  ),
                  items: produits.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p.nom),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProduit = value;
                      if (value != null) {
                        _prixUnitaire = value.getPrixUnitairePourAnnee(_selectedAnnee);
                      }
                    });
                  },
                ),
              ),
              
              if (_selectedProduit != null) ...[
                // Quantité
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                  child: TextFormField(
                    controller: _quantiteController,
                    decoration: const InputDecoration(
                      labelText: 'Quantité par hectare *',
                      border: OutlineInputBorder(),
                      helperText: 'Quantité à appliquer par hectare de parcelle',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                
                // Date
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date d\'application *',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(_formatDate(_selectedDate)),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                
                // Sélection de l'année pour le prix
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                  child: DropdownButtonFormField<int>(
                    value: _selectedAnnee,
                    decoration: const InputDecoration(
                      labelText: 'Année du prix',
                      border: OutlineInputBorder(),
                    ),
                    items: () {
                      final years = _selectedProduit!.prixParAnnee.keys.toList()
                        ..sort((a, b) => b.compareTo(a));
                      return years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text('$year (${_selectedProduit!.getPrixPourAnnee(year).toStringAsFixed(2)} €/${_selectedProduit!.mesure})'),
                        );
                      }).toList();
                    }(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAnnee = value!;
                        if (_selectedProduit != null) {
                          _prixUnitaire = _selectedProduit!.getPrixUnitairePourAnnee(_selectedAnnee);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                
                const SizedBox(height: AppTheme.spacingM),
                
                // Résumé
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Column(
                      children: [
                        Text(
                          _selectedProduit!.nom,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text('Quantité: ${_quantiteController.text} ${_selectedProduit!.mesure}'),
                        Text('Prix unitaire (${_selectedAnnee}): ${_prixUnitaire.toStringAsFixed(2)} €/${_selectedProduit!.mesure}'),
                        Text(
                          'Coût par hectare: ${_calculerCoutTotal().toStringAsFixed(2)} €/ha',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Boutons
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Row(
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
                        onPressed: _selectedProduit != null && _quantiteController.text.isNotEmpty
                            ? _addProduit
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _calculerCoutTotal() {
    final quantite = double.tryParse(_quantiteController.text) ?? 0.0;
    // Calculer le coût par hectare (quantité * prix unitaire)
    return quantite * _prixUnitaire;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addProduit() {
    final quantite = double.tryParse(_quantiteController.text) ?? 0.0;
    if (quantite <= 0) return;

    final produitTraitement = ProduitTraitement(
      produitId: _selectedProduit!.firebaseId ?? _selectedProduit!.id.toString(),
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
