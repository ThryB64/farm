import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/cellule.dart';
import '../utils/cout_utils.dart';

class FermerCelluleScreen extends StatefulWidget {
  final Cellule cellule;

  const FermerCelluleScreen({Key? key, required this.cellule}) : super(key: key);

  @override
  State<FermerCelluleScreen> createState() => _FermerCelluleScreenState();
}

class _FermerCelluleScreenState extends State<FermerCelluleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantiteGazController;
  late TextEditingController _prixGazController;
  double _coutTotalGaz = 0.0;

  @override
  void initState() {
    super.initState();
    _quantiteGazController = TextEditingController();
    _prixGazController = TextEditingController();
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

  Future<void> _fermerCellule() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final quantiteGaz = double.tryParse(_quantiteGazController.text);
      final prixGaz = double.tryParse(_prixGazController.text);
      
      // Créer une cellule fermée avec les données de gaz
      final celluleFermee = Cellule(
        id: widget.cellule.id,
        firebaseId: widget.cellule.firebaseId,
        reference: widget.cellule.reference,
        dateCreation: widget.cellule.dateCreation,
        notes: widget.cellule.notes,
        nom: widget.cellule.nom,
        fermee: true,
        quantiteGaz: quantiteGaz,
        prixGaz: prixGaz,
      );

      // Mettre à jour dans Firebase
      await context.read<FirebaseProviderV4>().modifierCellule(celluleFermee);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cellule fermée avec succès'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la fermeture: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Fermer la cellule',
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
              // Informations de la cellule
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cellule à fermer',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text('Référence: ${widget.cellule.reference}'),
                    if (widget.cellule.nom?.isNotEmpty == true)
                      Text('Nom: ${widget.cellule.nom}'),
                    Text('Capacité: ${widget.cellule.capacite.toStringAsFixed(0)} kg'),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Section données de gaz
              Text(
                'Données de gaz (obligatoires pour la fermeture)',
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
                  labelText: 'Quantité de gaz utilisée (m³) *',
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
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la quantité de gaz';
                  }
                  final quantite = double.tryParse(value);
                  if (quantite == null || !CoutUtils.estQuantiteGazValide(quantite)) {
                    return 'Quantité invalide (doit être positive)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Prix du gaz
              TextFormField(
                controller: _prixGazController,
                decoration: InputDecoration(
                  labelText: 'Prix du gaz (€/kWh) *',
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
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prix du gaz';
                  }
                  final prix = double.tryParse(value);
                  if (prix == null || !CoutUtils.estPrixGazValide(prix)) {
                    return 'Prix invalide (doit être positif)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingL),
              
              // Coût total du gaz
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calculate, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coût total du gaz',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            '${_coutTotalGaz.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Annuler',
                      icon: Icons.cancel,
                      backgroundColor: AppTheme.textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: ModernButton(
                      text: 'Fermer la cellule',
                      icon: Icons.lock,
                      backgroundColor: AppTheme.primary,
                      onPressed: _fermerCellule,
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
}
