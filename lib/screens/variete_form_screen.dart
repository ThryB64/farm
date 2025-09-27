import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/variete.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_buttons.dart';

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
  Map<int, double> _prixParAnnee = {};
  int _anneeSelectionnee = DateTime.now().year;
  final TextEditingController _prixController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.variete?.nom ?? '');
    _descriptionController = TextEditingController(text: widget.variete?.description ?? '');
    _prixParAnnee = Map.from(widget.variete?.prixParAnnee ?? {});
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  void _ajouterPrix() {
    final prix = double.tryParse(_prixController.text);
    if (prix != null && prix > 0) {
      setState(() {
        _prixParAnnee[_anneeSelectionnee] = prix;
        _prixController.clear();
      });
    }
  }

  void _supprimerPrix(int annee) {
    setState(() {
      _prixParAnnee.remove(annee);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.variete == null ? 'Nouvelle variété' : 'Modifier la variété',
          style: AppTheme.textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nom de la variété
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom de la variété',
                  hintText: 'Ex: Pioneer P1234',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: AppTheme.spacingL),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Caractéristiques de la variété...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'La description ne doit pas dépasser 500 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Section Prix par année
              Text(
                'Prix de la dose par année',
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // Ajout d'un nouveau prix
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<int>(
                            value: _anneeSelectionnee,
                            decoration: const InputDecoration(
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
                              if (value != null) {
                                setState(() {
                                  _anneeSelectionnee = value;
                                  _prixController.text = _prixParAnnee[value]?.toString() ?? '';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _prixController,
                            decoration: const InputDecoration(
                              labelText: 'Prix de la dose (€)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        ElevatedButton(
                          onPressed: _ajouterPrix,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // Liste des prix existants
              if (_prixParAnnee.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix configurés',
                        style: AppTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      ..._prixParAnnee.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${entry.key}: ${entry.value.toStringAsFixed(2)} €'),
                              ),
                              IconButton(
                                onPressed: () => _supprimerPrix(entry.key),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
              ],
              
              // Bouton de validation
              ModernButton(
                text: widget.variete == null ? 'Ajouter la variété' : 'Modifier la variété',
                icon: Icons.save,
                backgroundColor: AppTheme.primary,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final variete = Variete(
                        id: widget.variete?.id,
                        firebaseId: widget.variete?.firebaseId,
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
                            backgroundColor: AppTheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 