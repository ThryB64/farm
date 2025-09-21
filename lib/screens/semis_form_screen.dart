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
                            VarieteSurface(nom: variete.nom, surface: 0),
                          );
                        }
                      } else {
                        _selectedVarietesSurfaces
                            .removeWhere((v) => v.nom == variete.nom);
                      }
                      _showHectares = _selectedVarietesSurfaces.length > 1;
                    });
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedVarietesSurfaces.length,
            itemBuilder: (context, index) {
              final varieteSurface = _selectedVarietesSurfaces[index];
              return ListTile(
                title: Text(varieteSurface.nom),
                trailing: SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: varieteSurface.surface > 0
                        ? varieteSurface.surface.toString()
                        : '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      suffix: Text('ha'),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final hectares = double.tryParse(value) ?? 0;
                      setState(() {
                        _selectedVarietesSurfaces[index] = VarieteSurface(
                          nom: varieteSurface.nom,
                          surface: hectares,
                        );
                      });
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
