import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/vente.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';

class VenteFormScreen extends StatefulWidget {
  final Vente? vente;

  const VenteFormScreen({Key? key, this.vente}) : super(key: key);

  @override
  State<VenteFormScreen> createState() => _VenteFormScreenState();
}

class _VenteFormScreenState extends State<VenteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroTicketController = TextEditingController();
  final _clientController = TextEditingController();
  final _immatriculationController = TextEditingController();
  final _cmrController = TextEditingController();
  final _poidsVideController = TextEditingController();
  final _poidsPleinController = TextEditingController();
  final _poidsNetController = TextEditingController();
  final _ecartPoidsNetController = TextEditingController();
  final _prixController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _payer = false;
  bool _terminee = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vente != null) {
      _loadVenteData();
    }
  }

  void _loadVenteData() {
    final vente = widget.vente!;
    _numeroTicketController.text = vente.numeroTicket;
    _clientController.text = vente.client;
    _immatriculationController.text = vente.immatriculationRemorque;
    _cmrController.text = vente.cmr;
    _poidsVideController.text = vente.poidsVide.toString();
    _poidsPleinController.text = vente.poidsPlein.toString();
    _poidsNetController.text = vente.poidsNet?.toString() ?? '';
    _ecartPoidsNetController.text = vente.ecartPoidsNet?.toString() ?? '';
    _prixController.text = vente.prix?.toString() ?? '';
    _selectedDate = vente.date;
    _payer = vente.payer;
    _terminee = vente.terminee;
  }

  @override
  void dispose() {
    _numeroTicketController.dispose();
    _clientController.dispose();
    _immatriculationController.dispose();
    _cmrController.dispose();
    _poidsVideController.dispose();
    _poidsPleinController.dispose();
    _poidsNetController.dispose();
    _ecartPoidsNetController.dispose();
    _prixController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vente == null ? 'Nouvelle vente' : 'Modifier la vente'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoCard(),
              SizedBox(height: 16),
              _buildWeightCard(),
              SizedBox(height: 16),
              _buildStatusCard(),
              SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de base',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _numeroTicketController,
                    decoration: InputDecoration(
                      labelText: 'Numéro de ticket *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le numéro de ticket est requis';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _clientController,
                    decoration: InputDecoration(
                      labelText: 'Client *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le client est requis';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _immatriculationController,
                    decoration: InputDecoration(
                      labelText: 'Immatriculation remorque *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'immatriculation est requise';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cmrController,
                    decoration: InputDecoration(
                      labelText: 'CMR *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le CMR est requis';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date de la vente *',
                  border: OutlineInputBorder(),
                ),
                child: Text(_formatDate(_selectedDate)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poids',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _poidsVideController,
                    decoration: InputDecoration(
                      labelText: 'Poids vide (kg) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le poids vide est requis';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                    onChanged: _calculatePoidsNet,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _poidsPleinController,
                    decoration: InputDecoration(
                      labelText: 'Poids plein (kg) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le poids plein est requis';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                    onChanged: _calculatePoidsNet,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _poidsNetController,
                    decoration: InputDecoration(
                      labelText: 'Poids net (kg)',
                      border: OutlineInputBorder(),
                      helperText: 'Calculé automatiquement',
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ecartPoidsNetController,
                    decoration: InputDecoration(
                      labelText: 'Écart poids net (kg)',
                      border: OutlineInputBorder(),
                      helperText: 'Différence avec le poids calculé',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut de la vente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prixController,
                    decoration: InputDecoration(
                      labelText: 'Prix (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text('Payé'),
                        value: _payer,
                        onChanged: (value) {
                          setState(() {
                            _payer = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: Text('Terminée'),
                        value: _terminee,
                        onChanged: (value) {
                          setState(() {
                            _terminee = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ModernOutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            text: 'Annuler',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ModernButton(
            onPressed: _isLoading ? null : _saveVente,
            text: widget.vente == null ? 'Ajouter' : 'Modifier',
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _calculatePoidsNet(String value) {
    final poidsVide = double.tryParse(_poidsVideController.text);
    final poidsPlein = double.tryParse(_poidsPleinController.text);
    
    if (poidsVide != null && poidsPlein != null) {
      final poidsNet = poidsPlein - poidsVide;
      _poidsNetController.text = poidsNet.toStringAsFixed(1);
    }
  }

  void _saveVente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vente = Vente(
        id: widget.vente?.id,
        firebaseId: widget.vente?.firebaseId,
        date: _selectedDate,
        numeroTicket: _numeroTicketController.text.trim(),
        client: _clientController.text.trim(),
        immatriculationRemorque: _immatriculationController.text.trim(),
        cmr: _cmrController.text.trim(),
        poidsVide: double.parse(_poidsVideController.text),
        poidsPlein: double.parse(_poidsPleinController.text),
        poidsNet: _poidsNetController.text.isNotEmpty ? double.parse(_poidsNetController.text) : null,
        ecartPoidsNet: _ecartPoidsNetController.text.isNotEmpty ? double.parse(_ecartPoidsNetController.text) : null,
        payer: _payer,
        prix: _prixController.text.isNotEmpty ? double.parse(_prixController.text) : null,
        terminee: _terminee,
      );

      final provider = context.read<FirebaseProviderV4>();
      
      if (widget.vente == null) {
        await provider.ajouterVente(vente);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vente ajoutée avec succès')),
        );
      } else {
        await provider.modifierVente(vente);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vente modifiée avec succès')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
