import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/cellule.dart';
import '../utils/cout_utils.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_buttons.dart';

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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.cellule == null ? 'Nouvelle cellule' : 'Modifier la cellule',
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
              // Année
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: InputDecoration(
                  labelText: 'Année',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: AppTheme.spacingXL),
              
              // Section Gaz (seulement si la cellule est fermée)
              if (widget.cellule?.fermee == true) ...[
                Text(
                  'Données de gaz (enregistrées à la fermeture)',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                
                // Quantité de gaz
                TextFormField(
                  controller: _quantiteGazController,
                  decoration: InputDecoration(
                    labelText: 'Quantité de gaz utilisée (m³)',
                    hintText: 'Ex: 150.5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                const SizedBox(height: AppTheme.spacingL),
                
                // Prix du gaz
                TextFormField(
                  controller: _prixGazController,
                  decoration: InputDecoration(
                    labelText: 'Prix du gaz (€/kWh)',
                    hintText: 'Ex: 0.15',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                const SizedBox(height: AppTheme.spacingL),
                
                // Coût total du gaz
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
                              'Coût total du gaz',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              '${_coutTotalGaz.toStringAsFixed(2)} €',
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
                const SizedBox(height: AppTheme.spacingXL),
              ],
              
              // Bouton de validation
              ModernButton(
                text: widget.cellule == null ? 'Ajouter la cellule' : 'Modifier la cellule',
                icon: Icons.save,
                backgroundColor: AppTheme.primary,
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