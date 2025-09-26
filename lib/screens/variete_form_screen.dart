import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/variete.dart';

class VarieteFormScreen extends StatefulWidget {
  final Variete? variete;

  const VarieteFormScreen({Key? key, this.variete}) : super(key: key);

  @override
  State<VarieteFormScreen> createState() => _VarieteFormScreenState();
}

class _VarieteFormScreenState extends State<VarieteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  
  // Gestion des prix par année
  Map<int, double> _prixParAnnee = {};
  int _selectedAnnee = DateTime.now().year;
  final TextEditingController _prixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.variete?.nom ?? '');
    _descriptionController = TextEditingController(text: widget.variete?.description ?? '');
    
    // Initialiser les prix par année
    if (widget.variete != null) {
      _prixParAnnee = Map.from(widget.variete!.prixParAnnee);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.variete == null ? 'Nouvelle variété' : 'Modifier la variété'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  if (value.length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  if (value.length > 50) {
                    return 'Le nom ne doit pas dépasser 50 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'La description ne doit pas dépasser 500 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              
              // Section Prix par année
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix par année',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      
                      // Sélection d'année et prix
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<int>(
                              value: _selectedAnnee,
                              decoration: InputDecoration(
                                labelText: 'Année',
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(5, (index) {
                                final annee = DateTime.now().year - 2 + index;
                                return DropdownMenuItem(
                                  value: annee,
                                  child: Text(annee.toString()),
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
                          SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _prixController,
                              decoration: InputDecoration(
                                labelText: 'Prix de la dose (€)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final prix = double.tryParse(value);
                                if (prix != null && prix > 0) {
                                  _prixParAnnee[_selectedAnnee] = prix;
                                } else {
                                  _prixParAnnee.remove(_selectedAnnee);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Liste des prix existants
                      if (_prixParAnnee.isNotEmpty) ...[
                        Text(
                          'Prix enregistrés:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 8),
                        ..._prixParAnnee.entries.map((entry) => 
                          ListTile(
                            title: Text('${entry.key}: ${entry.value.toStringAsFixed(2)} €/dose'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _prixParAnnee.remove(entry.key);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final variete = Variete(
                        id: widget.variete?.id,
                        firebaseId: widget.variete?.firebaseId, // ✅ Préserver le firebaseId
                        nom: _nomController.text.trim(),
                        description: _descriptionController.text.isEmpty ? null : _descriptionController.text.trim(),
                        dateCreation: widget.variete?.dateCreation ?? DateTime.now(),
                        prixParAnnee: _prixParAnnee,
                      );

                      if (widget.variete == null) {
                        await context.read<FirebaseProviderV4>().ajouterVariete(variete);
                      } else {
                        await context.read<FirebaseProviderV4>().modifierVariete(variete);
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
                  widget.variete == null ? 'Ajouter' : 'Modifier',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 