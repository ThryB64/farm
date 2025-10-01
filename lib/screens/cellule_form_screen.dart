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
import '../utils/cout_utils.dart';
class CelluleFormScreen extends StatefulWidget {
  final Cellule? cellule;
  const CelluleFormScreen({Key? key, this.cellule}) : super(key: key);
  @override
  State<CelluleFormScreen> createState() => _CelluleFormScreenState();
}
class _CelluleFormScreenState extends State<CelluleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedYear;
  late TextEditingController _quantiteGazController;
  late TextEditingController _prixGazController;
  double _coutTotalGaz = 0.0;
  @override
  void initState() {
    super.initState();
    _selectedYear = widget.cellule?.dateCreation.year ?? DateTime.now().year;
    _quantiteGazController = TextEditingController(
      text: widget.cellule?.quantiteGaz?.toString() ?? '',
    );
    _prixGazController = TextEditingController(
      text: widget.cellule?.prixGaz?.toString() ?? '',
    );
    _calculerCoutTotalGaz();
  }
  @override
  void dispose() {
    _quantiteGazController.dispose();
    _prixGazController.dispose();
    super.dispose();
  }
  void _calculerCoutTotalGaz() {
    final quantite = double.tryParse(_quantiteGazController.text) ?? 0.0;
    final prix = double.tryParse(_prixGazController.text) ?? 0.0;
    setState(() {
      _coutTotalGaz = CoutUtils.calculerCoutTotalGaz(quantite, prix);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        title: Text(
          widget.cellule == null ? 'Nouvelle cellule' : 'Modifier la cellule',
          style: AppTheme.textTheme(context).headlineSmall?.copyWith(color: AppTheme.onPrimary(context)),
        ),
        backgroundColor: AppTheme.primary(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.padding(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Année
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: AppTheme.createInputDecoration(context,
                  labelText: 'Année',
                ),
                items: List.generate(20, (index) {
                  final year = 2020 + index;
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une année';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppTheme.spacingXL),
              
              // Section Gaz (seulement si la cellule est fermée)
              if (widget.cellule?.fermee == true) ...[
                Text(
                  'Données de gaz (enregistrées à la fermeture)',
                  style: AppTheme.textTheme(context).titleMedium?.copyWith(
                    color: AppTheme.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacingM),
                
                // Quantité de gaz
                TextFormField(
                  controller: _quantiteGazController,
                  decoration: AppTheme.createInputDecoration(context,
                    labelText: 'Quantité de gaz utilisée (m³)',
                    hintText: 'Ex: 150.5',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculerCoutTotalGaz(),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final quantite = double.tryParse(value);
                      if (quantite == null || !CoutUtils.estQuantiteGazValide(quantite)) {
                        return 'Quantité invalide';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppTheme.spacingL),
                
                // Prix du gaz
                TextFormField(
                  controller: _prixGazController,
                  decoration: AppTheme.createInputDecoration(context,
                    labelText: 'Prix du gaz (€/kWh)',
                    hintText: 'Ex: 0.15',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculerCoutTotalGaz(),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final prix = double.tryParse(value);
                      if (prix == null || !CoutUtils.estPrixGazValide(prix)) {
                        return 'Prix invalide';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppTheme.spacingL),
                
                // Coût total du gaz
                Container(
                  padding: AppTheme.padding(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.primary(context).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calculate, color: AppTheme.primary(context)),
                      SizedBox(width: AppTheme.spacingS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coût total du gaz',
                              style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary(context),
                              ),
                            ),
                            Text(
                              '${_coutTotalGaz.toStringAsFixed(2)} €',
                              style: AppTheme.textTheme(context).titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.spacingXL),
              ],
              
              // Bouton de validation
              ModernButton(
                text: widget.cellule == null ? 'Ajouter la cellule' : 'Modifier la cellule',
                icon: Icons.save,
                backgroundColor: AppTheme.primary(context),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final dateCreation = DateTime(_selectedYear!, DateTime.now().month, DateTime.now().day);
                      final cellule = Cellule(
                        id: widget.cellule?.id,
                        firebaseId: widget.cellule?.firebaseId,
                        dateCreation: dateCreation,
                        quantiteGaz: _quantiteGazController.text.isNotEmpty 
                            ? double.tryParse(_quantiteGazController.text) 
                            : null,
                        prixGaz: _prixGazController.text.isNotEmpty 
                            ? double.tryParse(_prixGazController.text) 
                            : null,
                      );
                      if (widget.cellule == null) {
                        await context.read<FirebaseProviderV4>().ajouterCellule(cellule);
                      } else {
                        await context.read<FirebaseProviderV4>().modifierCellule(cellule);
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