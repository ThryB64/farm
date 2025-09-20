import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/semis.dart';
import '../models/variete_surface.dart';
import '../models/variete_surface_ha.dart';

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
  List<VarieteSurfaceHa> _selectedVarietesSurfacesHa = [];
  bool _showPourcentages = false;
  bool _useHectares = false; // Nouveau: utiliser les hectares au lieu des pourcentages

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
    _selectedVarietesSurfacesHa = widget.semis?.varietesSurfacesHa ?? [];
    _showPourcentages = _selectedVarietesSurfaces.isNotEmpty;
    _useHectares = _selectedVarietesSurfacesHa.isNotEmpty;
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
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != widget.semis?.date) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Widget _buildVarietesSection(FirebaseProviderV3 provider) {
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
          Wrap(
            spacing: 8,
            children: provider.varietes.map((variete) {
              final isSelected = _selectedVarietesSurfaces.any((v) => v.nom == variete.nom);
              return FilterChip(
                label: Text(variete.nom),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedVarietesSurfaces.add(VarieteSurface(
                        nom: variete.nom,
                        pourcentage: 0,
                      ));
                    } else {
                      _selectedVarietesSurfaces.removeWhere((v) => v.nom == variete.nom);
                      _selectedVarietesSurfacesHa.removeWhere((v) => v.nom == variete.nom);
                    }
                    _showPourcentages = _selectedVarietesSurfaces.isNotEmpty;
                    
                    // Si plus d'une variété, utiliser les hectares
                    if (_selectedVarietesSurfaces.length > 1) {
                      _useHectares = true;
                      // Initialiser les hectares si pas déjà fait
                      if (_selectedVarietesSurfacesHa.isEmpty) {
                        _selectedVarietesSurfacesHa = _selectedVarietesSurfaces.map((v) => 
                          VarieteSurfaceHa(nom: v.nom, hectares: 0.0)
                        ).toList();
                      }
                    } else {
                      _useHectares = false;
                      _selectedVarietesSurfacesHa.clear();
                    }
                  });
                },
              );
            }).toList(),
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
        ],
      ),
    );
  }

  Widget _buildPourcentagesSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _useHectares ? 'Hectares par variété' : 'Pourcentages de surface',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _useHectares ? _selectedVarietesSurfacesHa.length : _selectedVarietesSurfaces.length,
            itemBuilder: (context, index) {
              if (_useHectares) {
                final varieteSurfaceHa = _selectedVarietesSurfacesHa[index];
                return ListTile(
                  title: Text(varieteSurfaceHa.nom),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: varieteSurfaceHa.hectares > 0 
                          ? varieteSurfaceHa.hectares.toString()
                          : '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        suffix: Text('ha'),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final hectares = double.tryParse(value) ?? 0;
                        setState(() {
                          _selectedVarietesSurfacesHa[index] = VarieteSurfaceHa(
                            nom: varieteSurfaceHa.nom,
                            hectares: hectares,
                          );
                        });
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final hectares = double.tryParse(value);
                          if (hectares == null || hectares < 0) {
                            return 'Hectares invalides';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                );
              } else {
                final varieteSurface = _selectedVarietesSurfaces[index];
                return ListTile(
                  title: Text(varieteSurface.nom),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: varieteSurface.pourcentage > 0 
                          ? varieteSurface.pourcentage.toString()
                          : '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        suffix: Text('%'),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final pourcentage = double.tryParse(value) ?? 0;
                        setState(() {
                          _selectedVarietesSurfaces[index] = VarieteSurface(
                            nom: varieteSurface.nom,
                            pourcentage: pourcentage,
                          );
                        });
                      },
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final pourcentage = double.tryParse(value);
                          if (pourcentage == null || pourcentage < 0 || pourcentage > 100) {
                            return 'Pourcentage invalide';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _useHectares 
                ? 'Total : ${_selectedVarietesSurfacesHa.fold<double>(0, (sum, v) => sum + v.hectares)} ha'
                : 'Total : ${_selectedVarietesSurfaces.fold<double>(0, (sum, v) => sum + v.pourcentage)}%',
              style: TextStyle(
                color: _useHectares 
                  ? Colors.blue // Pour les hectares, on ne vérifie pas le total
                  : (_selectedVarietesSurfaces.fold<double>(0, (sum, v) => sum + v.pourcentage) == 100
                      ? Colors.green
                      : Colors.red),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.semis == null ? 'Nouveau semis' : 'Modifier le semis'),
        backgroundColor: Colors.orange,
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          // Obtenir l'année en cours
          final anneeEnCours = DateTime.now().year;

          // Obtenir les parcelles qui ont déjà un semis cette année
          final parcellesAvecSemis = provider.semis
              .where((s) => s.date.year == anneeEnCours)
              .map((s) => s.parcelleId)
              .toSet();

          // Filtrer les parcelles pour ne garder que celles sans semis
          final parcellesDisponibles = provider.parcelles
              .where((p) => !parcellesAvecSemis.contains(p.id))
              .toList();

          // Si on modifie un semis existant, ajouter sa parcelle à la liste
          if (widget.semis != null) {
            final parcelleDuSemis = provider.parcelles
                .firstWhere((p) => p.id == widget.semis!.parcelleId);
            if (!parcellesDisponibles.contains(parcelleDuSemis)) {
              parcellesDisponibles.add(parcelleDuSemis);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedParcelleId,
                    decoration: const InputDecoration(
                      labelText: 'Parcelle',
                      border: OutlineInputBorder(),
                    ),
                    items: parcellesDisponibles.map((parcelle) {
                      return DropdownMenuItem<int>(
                        value: parcelle.id,
                        child: Text(parcelle.nom),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedParcelleId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner une parcelle';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildVarietesSection(provider),
                  if (_showPourcentages) ...[
                    SizedBox(height: 16),
                    _buildPourcentagesSection(),
                  ],
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value != null && value.length > 500) {
                        return 'Les notes ne doivent pas dépasser 500 caractères';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedVarietesSurfaces.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez sélectionner au moins une variété'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Validation différente selon le mode
                        if (_useHectares) {
                          // Pour les hectares, on vérifie que le total ne dépasse pas la surface de la parcelle
                          final totalHectares = _selectedVarietesSurfacesHa.fold<double>(0, (sum, v) => sum + v.hectares);
                          if (totalHectares <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez saisir les hectares pour chaque variété'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        } else {
                          // Pour les pourcentages, on vérifie que le total fait 100%
                          final total = _selectedVarietesSurfaces.fold<double>(0, (sum, v) => sum + v.pourcentage);
                          if (total != 100) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Le total des pourcentages doit être égal à 100%'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }

                        try {
                          final dateParts = _dateController.text.split('/');
                          final date = DateTime(
                            int.parse(dateParts[2]),
                            int.parse(dateParts[1]),
                            int.parse(dateParts[0]),
                          );

                          final semis = Semis(
                            id: widget.semis?.id,
                            parcelleId: _selectedParcelleId!,
                            varietesSurfaces: _selectedVarietesSurfaces,
                            varietesSurfacesHa: _useHectares ? _selectedVarietesSurfacesHa : null,
                            date: date,
                            notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
                          );

                          if (widget.semis == null) {
                            await provider.ajouterSemis(semis);
                          } else {
                            await provider.modifierSemis(semis);
                          }

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.semis == null ? 'Ajouter' : 'Modifier',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 