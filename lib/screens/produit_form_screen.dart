import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/produit.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_buttons.dart';

class ProduitFormScreen extends StatefulWidget {
  final Produit? produit;

  const ProduitFormScreen({Key? key, this.produit}) : super(key: key);

  @override
  State<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends State<ProduitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedMesure = 'kg';
  
  Map<int, double> _prixParAnnee = {};
  int _selectedAnnee = DateTime.now().year;
  final _prixController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.produit != null) {
      _loadProduitData();
    }
  }

  void _loadProduitData() {
    final produit = widget.produit!;
    _nomController.text = produit.nom;
    _selectedMesure = produit.mesure;
    _notesController.text = produit.notes ?? '';
    _prixParAnnee = Map.from(produit.prixParAnnee);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _notesController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produit == null ? 'Nouveau produit' : 'Modifier le produit'),
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
              // Nom du produit
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // Mesure
              DropdownButtonFormField<String>(
                value: _selectedMesure,
                decoration: const InputDecoration(
                  labelText: 'Mesure *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'L', child: Text('L')),
                  DropdownMenuItem(value: 'T', child: Text('T')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMesure = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La mesure est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              
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
              
              // Prix par année
              _buildPrixSection(),
              
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
                      text: widget.produit == null ? 'Créer' : 'Modifier',
                      isLoading: _isLoading,
                      onPressed: _saveProduit,
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

  Widget _buildPrixSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prix par année',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Ajouter un prix
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedAnnee,
                    decoration: const InputDecoration(
                      labelText: 'Année',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(10, (index) {
                      final year = DateTime.now().year - 5 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _selectedAnnee = value!;
                        _prixController.text = _prixParAnnee[value]?.toString() ?? '';
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _prixController,
                    decoration: const InputDecoration(
                      labelText: 'Prix (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                IconButton(
                  onPressed: _addPrix,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Liste des prix
            if (_prixParAnnee.isNotEmpty) ...[
              const Text(
                'Prix configurés:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.spacingS),
              ..._prixParAnnee.entries.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text('${entry.key}: ${entry.value.toStringAsFixed(2)} €'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _prixParAnnee.remove(entry.key);
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  void _addPrix() {
    final prix = double.tryParse(_prixController.text);
    if (prix != null && prix > 0) {
      setState(() {
        _prixParAnnee[_selectedAnnee] = prix;
        _prixController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un prix valide')),
      );
    }
  }

  Future<void> _saveProduit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final produit = Produit(
        id: widget.produit?.id,
        firebaseId: widget.produit?.firebaseId,
        nom: _nomController.text.trim(),
        mesure: _selectedMesure,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        prixParAnnee: _prixParAnnee,
      );

      final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
      
      if (widget.produit == null) {
        await provider.ajouterProduit(produit);
      } else {
        await provider.modifierProduit(produit);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.produit == null 
                ? 'Produit créé avec succès' 
                : 'Produit modifié avec succès'),
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
