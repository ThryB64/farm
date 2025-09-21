import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/semis.dart';
import '../models/variete_surface.dart';
import '../models/parcelle.dart';
import '../models/variete.dart';

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
  int? _selectedParcelleId;
  List<VarieteSurface> _selectedVarietesSurfaces = [];
  bool _showHectares = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.semis?.date != null
          ? _formatDate(widget.semis!.date)
          : _formatDate(DateTime.now()),
    );
    _notesController = TextEditingController(text: widget.semis?.notes ?? '');
    _selectedParcelleId = widget.semis?.parcelleId;
    _selectedVarietesSurfaces = widget.semis?.varietesSurfaces ?? [];
    _showHectares = _selectedVarietesSurfaces.length > 1;
  }

  @override
  void dispose() {
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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



  double _getParcelleSurface() {
    final provider = context.read<FirebaseProviderV3>();
    final parcelle = provider.parcelles.firstWhere(
      (p) => p.id == _selectedParcelleId,
      orElse: () => Parcelle(nom: '', surface: 0),
    );
    return parcelle.surface;
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

    final semis = Semis(
      id: widget.semis?.id,
      parcelleId: _selectedParcelleId!,
      date: DateTime.parse(_dateController.text.split('/').reversed.join('-')),
      varietesSurfaces: _selectedVarietesSurfaces,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    try {
      if (widget.semis == null) {
        await context.read<FirebaseProviderV3>().ajouterSemis(semis);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semis ajouté avec succès')),
        );
      } else {
        await context.read<FirebaseProviderV3>().modifierSemis(semis);
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
              // Sélection de la parcelle
              Consumer<FirebaseProviderV3>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<int>(
                    value: _selectedParcelleId,
                    decoration: const InputDecoration(
                      labelText: 'Parcelle *',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.parcelles.map((parcelle) {
                      return DropdownMenuItem<int>(
                        value: parcelle.id,
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
              Consumer<FirebaseProviderV3>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Variétés *',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...provider.varietes.map((variete) {
                        final isSelected = _selectedVarietesSurfaces.any((vs) => vs.nom == variete.nom);
                        final selectedIndex = _selectedVarietesSurfaces.indexWhere((vs) => vs.nom == variete.nom);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    // Ajouter la variété
                                    _selectedVarietesSurfaces.add(VarieteSurface(
                                      nom: variete.nom,
                                      surface: 0,
                                    ));
                                  } else {
                                    // Supprimer la variété
                                    _selectedVarietesSurfaces.removeAt(selectedIndex);
                                  }
                                  _showHectares = _selectedVarietesSurfaces.length > 1;
                                });
                              },
                            ),
                            title: Text(
                              variete.nom,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blue : null,
                              ),
                            ),
                            subtitle: variete.description != null 
                                ? Text(variete.description!)
                                : null,
                            trailing: isSelected && _showHectares
                                ? SizedBox(
                                    width: 120,
                                    child: TextFormField(
                                      initialValue: _selectedVarietesSurfaces[selectedIndex].surface > 0 
                                          ? _selectedVarietesSurfaces[selectedIndex].surface.toString()
                                          : '',
                                      decoration: const InputDecoration(
                                        labelText: 'Ha',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final hectares = double.tryParse(value) ?? 0;
                                        setState(() {
                                          _selectedVarietesSurfaces[selectedIndex] = VarieteSurface(
                                            nom: variete.nom,
                                            surface: hectares,
                                          );
                                        });
                                      },
                                      validator: (value) {
                                        if (_showHectares) {
                                          final hectares = double.tryParse(value ?? '');
                                          if (hectares == null || hectares < 0) {
                                            return 'Surface invalide';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ],
                  );
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

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
