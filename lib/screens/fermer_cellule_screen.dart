import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/cellule.dart';

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
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _quantiteGazController = TextEditingController(text: widget.cellule.quantiteGaz?.toString() ?? '');
    _prixGazController = TextEditingController(text: widget.cellule.prixGaz?.toString() ?? '');
    _notesController = TextEditingController(text: widget.cellule.notes ?? '');
  }

  @override
  void dispose() {
    _quantiteGazController.dispose();
    _prixGazController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildGazCalculInfo() {
    final quantite = double.tryParse(_quantiteGazController.text);
    final prix = double.tryParse(_prixGazController.text);
    
    if (quantite == null || prix == null) {
      return Text('Veuillez remplir la quantité et le prix pour voir le calcul');
    }
    
    final coutTotal = quantite * prix;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quantité: ${quantite.toStringAsFixed(2)} kg'),
        Text('Prix: ${prix.toStringAsFixed(2)} €/kg'),
        SizedBox(height: 8),
        Text('Coût total: ${coutTotal.toStringAsFixed(2)} €', 
             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fermer la cellule ${widget.cellule.label}'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informations de la cellule
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations de la cellule',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Référence: ${widget.cellule.reference}'),
                          ),
                          Expanded(
                            child: Text('Capacité: ${widget.cellule.capacite.toStringAsFixed(0)} kg'),
                          ),
                        ],
                      ),
                      if (widget.cellule.nom != null) ...[
                        SizedBox(height: 8),
                        Text('Nom: ${widget.cellule.nom}'),
                      ],
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Section Gaz
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gaz utilisé pour la conservation',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantiteGazController,
                              decoration: const InputDecoration(
                                labelText: 'Quantité (kg)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {}); // Recalculer l'affichage
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _prixGazController,
                              decoration: const InputDecoration(
                                labelText: 'Prix (€/kg)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {}); // Recalculer l'affichage
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Calcul automatique du coût
                      if (_quantiteGazController.text.isNotEmpty && _prixGazController.text.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calcul automatique:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              _buildGazCalculInfo(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              SizedBox(height: 24),
              
              // Boutons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Annuler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final celluleFermee = Cellule(
                              id: widget.cellule.id,
                              firebaseId: widget.cellule.firebaseId,
                              reference: widget.cellule.reference,
                              dateCreation: widget.cellule.dateCreation,
                              nom: widget.cellule.nom,
                              notes: _notesController.text.isEmpty ? widget.cellule.notes : _notesController.text.trim(),
                              fermee: true, // Marquer comme fermée
                              quantiteGaz: double.tryParse(_quantiteGazController.text),
                              prixGaz: double.tryParse(_prixGazController.text),
                            );

                            await context.read<FirebaseProviderV4>().modifierCellule(celluleFermee);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cellule fermée avec succès'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.lock),
                      label: const Text('Fermer la cellule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
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
}
