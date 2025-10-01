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
      print('💰 Prix ajouté: ${_anneeSelectionnee} -> $prix €');
      print('💰 Tous les prix: $_prixParAnnee');
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
          style: AppTheme.textTheme.headlineSmall?.copyWith(color: AppTheme.onPrimary),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.padding(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nom de la variété
              TextFormField(
                controller: _nomController,
                decoration: AppTheme.createInputDecoration(
                  labelText: 'Nom de la variété',
                  hintText: 'Ex: Pioneer P1234',
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
              SizedBox(height: AppTheme.spacingL),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: AppTheme.createInputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Caractéristiques de la variété...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'La description ne doit pas dépasser 500 caractères';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppTheme.spacingXL),
              
              // Section Prix par année
              Text(
                'Prix de la dose par année',
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppTheme.spacingM),
              
              // Ajout d'un nouveau prix
              Container(
                padding: AppTheme.padding(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
                            decoration: AppTheme.createInputDecoration(
                              labelText: 'Année',
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
                        SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _prixController,
                            decoration: AppTheme.createInputDecoration(
                              labelText: 'Prix de la dose (€)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingM),
                        ElevatedButton(
                          onPressed: _ajouterPrix,
                          style: AppTheme.buttonStyle(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radius(AppTheme.radiusMedium),
                            ),
                          ),
                          child: Icon(Icons.add, color: AppTheme.onPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacingM),
              
              // Liste des prix existants
              if (_prixParAnnee.isNotEmpty) ...[
                Container(
                  padding: AppTheme.padding(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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
                      SizedBox(height: AppTheme.spacingS),
                      ..._prixParAnnee.entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingXS),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${entry.key}: ${entry.value.toStringAsFixed(2)} €'),
                              ),
                              IconButton(
                                onPressed: () => _supprimerPrix(entry.key),
                                icon: Icon(Icons.delete, color: AppTheme.error, size: AppTheme.iconSizeM),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.spacingL),
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
                      
                      print('💾 Sauvegarde variété: ${variete.nom}');
                      print('💾 Prix par année: ${variete.prixParAnnee}');
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
                              borderRadius: AppTheme.radius(AppTheme.radiusMedium),
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