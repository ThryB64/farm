import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/semis.dart';
import '../models/variete_surface.dart';
import '../models/parcelle.dart';
import '../models/variete.dart';
import '../utils/cout_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_buttons.dart';

class SemisFormScreen extends StatefulWidget {
  final Semis? semis;

  const SemisFormScreen({Key? key, this.semis}) : super(key: key);

  @override
  State<SemisFormScreen> createState() => _SemisFormScreenState();
}

class _SemisFormScreenState extends State<SemisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _notesController;
  late TextEditingController _densiteController;
  String? _selectedParcelleId;
  List<VarieteSurface> _selectedVarietesSurfaces = [];
  bool _showHectares = false;
  int? _selectedYear;
  double _densiteMais = CoutUtils.DENSITE_DEFAUT;
  double _prixSemis = 0.0;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.semis?.date != null
          ? _formatDate(widget.semis!.date)
          : _formatDate(DateTime.now()),
    );
    _notesController = TextEditingController(text: widget.semis?.notes ?? '');
    _densiteController = TextEditingController(
      text: widget.semis?.densiteMais.toString() ?? CoutUtils.DENSITE_DEFAUT.toString(),
    );
    _selectedParcelleId = widget.semis?.parcelleId?.toString();
    _selectedVarietesSurfaces = widget.semis?.varietesSurfaces ?? [];
    _showHectares = _selectedVarietesSurfaces.length > 1;
    _selectedYear = widget.semis?.date.year ?? DateTime.now().year;
    _densiteMais = widget.semis?.densiteMais ?? CoutUtils.DENSITE_DEFAUT;
    _prixSemis = widget.semis?.prixSemis ?? 0.0;
    
    // Calculer le prix initial si on modifie un semis existant
    if (widget.semis != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculerPrixSemis();
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    _densiteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _calculerPrixSemis() {
    if (_selectedYear == null) return;
    
    double totalPrix = 0.0;
    final provider = context.read<FirebaseProviderV4>();
    
    print('🔍 Calcul prix semis - Année: $_selectedYear, Densité: $_densiteMais');
    
    for (final varieteSurface in _selectedVarietesSurfaces) {
      final variete = provider.getVarieteById(varieteSurface.varieteId);
      print('🔍 Variété: ${variete?.nom}, Prix par année: ${variete?.prixParAnnee}');
      
      if (variete != null && variete.prixParAnnee.containsKey(_selectedYear)) {
        final prixDose = variete.prixParAnnee[_selectedYear]!;
        final coutParHectare = CoutUtils.calculerCoutSemisParHectare(prixDose, _densiteMais);
        final coutTotal = coutParHectare * varieteSurface.surface;
        totalPrix += coutTotal;
        
        print('💰 Prix dose: $prixDose, Coût/ha: $coutParHectare, Surface: ${varieteSurface.surface}, Total: $coutTotal');
      } else {
        print('⚠️ Pas de prix trouvé pour ${variete?.nom} en $_selectedYear');
      }
    }
    
    print('💰 Prix total semis: $totalPrix');
    
    setState(() {
      _prixSemis = totalPrix;
    });
  }

  void _onDensiteChanged(String value) {
    final densite = double.tryParse(value);
    if (densite != null && CoutUtils.estDensiteValide(densite)) {
      setState(() {
        _densiteMais = densite;
      });
      _calculerPrixSemis();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.semis?.date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }



  List<Parcelle> _getParcellesDisponibles(FirebaseProviderV4 provider) {
    if (_selectedYear == null) return provider.parcelles;
    
    // Obtenir les parcelles qui ont déjà des semis cette année
    final parcellesAvecSemis = <String>{};
    for (final semis in provider.semis) {
      if (semis.date.year == _selectedYear) {
        parcellesAvecSemis.add(semis.parcelleId);
      }
    }
    
    // Retourner seulement les parcelles qui n'ont pas de semis cette année
    return provider.parcelles.where((parcelle) {
      final parcelleKey = parcelle.firebaseId ?? parcelle.id.toString();
      return !parcellesAvecSemis.contains(parcelleKey);
    }).toList();
  }

  double _getParcelleSurface() {
    if (_selectedParcelleId == null) return 0.0;
    
    final provider = context.read<FirebaseProviderV4>();
    final parcelle = provider.parcelles.firstWhere(
      (p) => (p.firebaseId ?? p.id.toString()) == _selectedParcelleId,
      orElse: () => Parcelle(nom: '', surface: 0),
    );
    return parcelle.surface;
  }

  Widget _buildVarietesSection(FirebaseProviderV4 provider) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Variétés',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children: provider.varietes.map((variete) {
                final isSelected = _selectedVarietesSurfaces
                    .any((v) => v.nom == variete.nom);

                return FilterChip(
                  label: Text(variete.nom),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (!isSelected) {
                          _selectedVarietesSurfaces.add(
                            VarieteSurface(
                              nom: variete.nom, 
                              surface: 0,
                              varieteId: variete.firebaseId ?? variete.id.toString(),
                            ),
                          );
                        }
                      } else {
                        _selectedVarietesSurfaces
                            .removeWhere((v) => v.nom == variete.nom);
                      }
                      _showHectares = _selectedVarietesSurfaces.length > 1;
                      // Auto-complétion immédiate si une seule variété
                      if (_selectedVarietesSurfaces.length == 1) {
                        _autoCompleteRemaining();
                      }
                    });
                    // Recalculer le prix après changement de variétés
                    _calculerPrixSemis();
                  },
                );
              }).toList(),
            ),
          ),
          if (_selectedVarietesSurfaces.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Veuillez sélectionner au moins une variété',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          
          // Section hectares pour les variétés sélectionnées
          if (_selectedVarietesSurfaces.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildHectaresSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildHectaresSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Surface par variété (hectares)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          // Aide pour l'auto-complétion
          if (_selectedVarietesSurfaces.length > 1)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getAutoCompleteHint(),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedVarietesSurfaces.length,
            itemBuilder: (context, index) {
              final varieteSurface = _selectedVarietesSurfaces[index];
              final isAutoCompleted = _isAutoCompleted(index);
              
              return ListTile(
                title: Text(varieteSurface.nom),
                subtitle: isAutoCompleted 
                    ? const Text('Auto-complété', style: TextStyle(color: Colors.green, fontSize: 10))
                    : null,
                trailing: SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: varieteSurface.surface > 0
                        ? varieteSurface.surface.toString()
                        : '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffix: const Text('ha'),
                      isDense: true,
                      filled: isAutoCompleted,
                      fillColor: isAutoCompleted ? Colors.green.shade50 : null,
                    ),
                    onChanged: (value) {
                      final hectares = double.tryParse(value) ?? 0;
                      setState(() {
                        _selectedVarietesSurfaces[index] = VarieteSurface(
                          nom: varieteSurface.nom,
                          surface: hectares,
                          varieteId: varieteSurface.varieteId,
                        );
                        _autoCompleteRemaining();
                      });
                      // Recalculer le prix après changement de surface
                      _calculerPrixSemis();
                    },
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final h = double.tryParse(value);
                        if (h == null || h < 0) {
                          return 'Surface invalide';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getAutoCompleteHint() {
    final total = _getParcelleSurface();
    final count = _selectedVarietesSurfaces.length;
    
    if (count == 1) {
      return 'Une seule variété : la surface totale (${total.toStringAsFixed(2)} ha) sera automatiquement assignée.';
    } else if (count == 2) {
      return 'Deux variétés : remplissez la première, la seconde sera auto-complétée.';
    } else {
      return 'Plusieurs variétés : remplissez ${count - 1} variétés, la dernière sera auto-complétée.';
    }
  }

  bool _isAutoCompleted(int index) {
    final total = _getParcelleSurface();
    final filledCount = _selectedVarietesSurfaces.where((v) => v.surface > 0).length;
    final count = _selectedVarietesSurfaces.length;
    
    if (count == 1) {
      return true; // Toujours auto-complété
    } else if (count == 2) {
      return index == 1; // La deuxième est auto-complétée
    } else {
      return index == count - 1 && filledCount == count - 1; // La dernière est auto-complétée
    }
  }

  void _autoCompleteRemaining() {
    final total = _getParcelleSurface();
    final count = _selectedVarietesSurfaces.length;
    
    if (count == 1) {
      // Une seule variété : assigner le total
      setState(() {
        _selectedVarietesSurfaces[0] = VarieteSurface(
          nom: _selectedVarietesSurfaces[0].nom,
          surface: total,
          varieteId: _selectedVarietesSurfaces[0].varieteId,
        );
      });
    } else if (count == 2) {
      // Deux variétés : auto-compléter la deuxième
      final firstSurface = _selectedVarietesSurfaces[0].surface;
      if (firstSurface > 0) {
        setState(() {
          _selectedVarietesSurfaces[1] = VarieteSurface(
            nom: _selectedVarietesSurfaces[1].nom,
            surface: total - firstSurface,
            varieteId: _selectedVarietesSurfaces[1].varieteId,
          );
        });
      }
    } else {
      // Plusieurs variétés : auto-compléter la dernière
      final filledCount = _selectedVarietesSurfaces.where((v) => v.surface > 0).length;
      if (filledCount == count - 1) {
        final filledTotal = _selectedVarietesSurfaces.take(count - 1).fold<double>(0, (sum, v) => sum + v.surface);
        setState(() {
          _selectedVarietesSurfaces[count - 1] = VarieteSurface(
            nom: _selectedVarietesSurfaces[count - 1].nom,
            surface: total - filledTotal,
            varieteId: _selectedVarietesSurfaces[count - 1].varieteId,
          );
        });
      }
    }
  }

  double _getTotalHectares() {
    return _selectedVarietesSurfaces.fold<double>(0, (sum, v) => sum + v.surface);
  }

  bool _isTotalValid() {
    if (_selectedVarietesSurfaces.length <= 1) return true;
    final parcelleSurface = _getParcelleSurface();
    final totalHectares = _getTotalHectares();
    return (totalHectares - parcelleSurface).abs() < 0.01; // Tolérance de 0.01 ha
  }

  Future<void> _saveSemis() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedParcelleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une parcelle')),
      );
      return;
    }

    if (_selectedVarietesSurfaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins une variété')),
      );
      return;
    }

    // Vérifier la cohérence des hectares si plusieurs variétés
    if (_selectedVarietesSurfaces.length > 1 && !_isTotalValid()) {
      final parcelleSurface = _getParcelleSurface();
      final totalHectares = _getTotalHectares();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Le total des hectares (${totalHectares.toStringAsFixed(2)} ha) doit correspondre à la surface de la parcelle (${parcelleSurface.toStringAsFixed(2)} ha)',
          ),
        ),
      );
      return;
    }

    // Utiliser l'année sélectionnée pour la date
    final dateParts = _dateController.text.split('/');
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = _selectedYear!;
    
    final semis = Semis(
      id: widget.semis?.id,
      firebaseId: widget.semis?.firebaseId, // ✅ Préserver le firebaseId
      parcelleId: _selectedParcelleId!,
      date: DateTime(year, month, day),
      varietesSurfaces: _selectedVarietesSurfaces,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      densiteMais: _densiteMais,
      prixSemis: _prixSemis,
    );

    try {
      if (widget.semis == null) {
        await context.read<FirebaseProviderV4>().ajouterSemis(semis);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semis ajouté avec succès')),
        );
      } else {
        await context.read<FirebaseProviderV4>().modifierSemis(semis);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semis modifié avec succès')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.semis == null ? 'Nouveau semis' : 'Modifier le semis'),
        actions: [
          TextButton(
            onPressed: _saveSemis,
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection de l'année
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Année *',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(10, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value;
                    _selectedParcelleId = null; // Réinitialiser la parcelle
                  });
                  // Recalculer le prix après changement d'année
                  _calculerPrixSemis();
                },
                validator: (value) {
                  if (value == null) return 'Veuillez sélectionner une année';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Sélection de la parcelle (filtrée par année)
              Consumer<FirebaseProviderV4>(
                builder: (context, provider, child) {
                  final parcellesDisponibles = _getParcellesDisponibles(provider);
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedParcelleId,
                    decoration: const InputDecoration(
                      labelText: 'Parcelle *',
                      border: OutlineInputBorder(),
                    ),
                    items: parcellesDisponibles.map((parcelle) {
                      final key = parcelle.firebaseId ?? parcelle.id.toString();
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text('${parcelle.nom} (${parcelle.surface} ha)'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedParcelleId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Veuillez sélectionner une parcelle';
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Date
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélection des variétés
              Consumer<FirebaseProviderV4>(
                builder: (context, provider, child) {
                  return _buildVarietesSection(provider);
                },
              ),

              // Résumé des surfaces
              if (_showHectares && _selectedParcelleId != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: _isTotalValid() ? Colors.green.shade50 : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résumé des surfaces:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Surface de la parcelle: ${_getParcelleSurface().toStringAsFixed(2)} ha'),
                        Text('Total des variétés: ${_getTotalHectares().toStringAsFixed(2)} ha'),
                        if (!_isTotalValid())
                          const Text(
                            '⚠️ Le total des hectares doit correspondre à la surface de la parcelle',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Densité de maïs
              TextFormField(
                controller: _densiteController,
                decoration: const InputDecoration(
                  labelText: 'Densité de maïs (graines/ha)',
                  hintText: 'Ex: 83000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: _onDensiteChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une densité';
                  }
                  final densite = double.tryParse(value);
                  if (densite == null || !CoutUtils.estDensiteValide(densite)) {
                    return 'Densité invalide (entre 50 000 et 150 000)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Prix du semis (calculé automatiquement)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calculate, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prix du semis calculé',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            '${_prixSemis.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Boutons de validation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Annuler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _canSave() ? _saveSemis : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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

  bool _canSave() {
    return _selectedParcelleId != null &&
           _selectedVarietesSurfaces.isNotEmpty &&
           _dateController.text.isNotEmpty &&
           _isTotalValid();
  }
}
