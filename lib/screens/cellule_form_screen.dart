import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/cellule.dart';

class CelluleFormScreen extends StatefulWidget {
  final Cellule? cellule;

  const CelluleFormScreen({Key? key, this.cellule}) : super(key: key);

  @override
  State<CelluleFormScreen> createState() => _CelluleFormScreenState();
}

class _CelluleFormScreenState extends State<CelluleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedYear;
  late TextEditingController _nomController;
  late TextEditingController _notesController;
  late TextEditingController _quantiteGazController;
  late TextEditingController _prixGazController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.cellule?.dateCreation.year ?? DateTime.now().year;
    _nomController = TextEditingController(text: widget.cellule?.nom ?? '');
    _notesController = TextEditingController(text: widget.cellule?.notes ?? '');
    _quantiteGazController = TextEditingController(text: widget.cellule?.quantiteGaz?.toString() ?? '');
    _prixGazController = TextEditingController(text: widget.cellule?.prixGaz?.toString() ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _notesController.dispose();
    _quantiteGazController.dispose();
    _prixGazController.dispose();
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
        title: Text(widget.cellule == null ? 'Nouvelle cellule' : 'Modifier la cellule'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Année',
                  border: OutlineInputBorder(),
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
              SizedBox(height: 16),
              
              // Nom de la cellule
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la cellule (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final dateCreation = DateTime(_selectedYear!, DateTime.now().month, DateTime.now().day);
                      final cellule = Cellule(
                        id: widget.cellule?.id,
                        firebaseId: widget.cellule?.firebaseId, // ✅ Préserver le firebaseId
                        dateCreation: dateCreation,
                        nom: _nomController.text.isEmpty ? null : _nomController.text.trim(),
                        notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
                        // Conserver les données gaz existantes lors de la modification
                        quantiteGaz: widget.cellule?.quantiteGaz,
                        prixGaz: widget.cellule?.prixGaz,
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
                  widget.cellule == null ? 'Ajouter' : 'Modifier',
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