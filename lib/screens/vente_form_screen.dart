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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
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
  int _selectedAnnee = DateTime.now().year;
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
    
    // Calculer le prix par tonne à partir du prix total et du poids net
    if (vente.prix != null && vente.poidsNet != null && vente.poidsNet! > 0) {
      final prixParTonne = (vente.prix! / (vente.poidsNet! / 1000)).toStringAsFixed(2);
      _prixController.text = prixParTonne;
    } else {
      _prixController.text = '';
    }
    
    _selectedDate = vente.date;
    _selectedAnnee = vente.annee;
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
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBgGradient),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
          padding: AppTheme.padding(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicInfoCard(),
              SizedBox(height: AppTheme.spacingM),
              _buildWeightCard(),
              SizedBox(height: AppTheme.spacingM),
              _buildStatusCard(),
              SizedBox(height: AppTheme.spacingL),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    ),
    );
  }
  Widget _buildBasicInfoCard() {
    return ModernCard(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de base',
              style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _numeroTicketController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Numéro de ticket *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le numéro de ticket est requis';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _clientController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Client *',
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
            SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _immatriculationController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Immatriculation remorque *',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'immatriculation est requise';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _cmrController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'CMR *',
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
            SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: AppTheme.createInputDecoration(
                        labelText: 'Date de la vente *',
                      ),
                      child: Text(_formatDate(_selectedDate)),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedAnnee,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Année de la récolte *',
                    ),
                    items: _getAnneeOptions().map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAnnee = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'L\'année est requise';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildWeightCard() {
    return ModernCard(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poids',
              style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _poidsVideController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Poids vide (kg) *',
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
                SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _poidsPleinController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Poids plein (kg) *',
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
            SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _poidsNetController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Poids net (kg)',
                      helperText: 'Calculé automatiquement',
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: TextFormField(
                    controller: _ecartPoidsNetController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Écart client (kg)',
                      helperText: 'Différence pesée par le client (+/-)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _calculatePoidsNetFinal,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacingS),
            Text(
              'Poids net final: ${_getPoidsNetFinal().toStringAsFixed(1)} kg',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatusCard() {
    return ModernCard(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut de la vente',
              style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prixController,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Prix (€/tonne)',
                      helperText: 'Prix par tonne de maïs',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _calculatePrixTotal,
                  ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Prix total: ${_getPrixTotal().toStringAsFixed(2)} €',
                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingS),
                      CheckboxListTile(
                        title: Text('Payé'),
                        value: _payer,
                        onChanged: (value) {
                          setState(() {
                            _payer = value ?? false;
                            // Si payé, la vente est automatiquement terminée
                            if (_payer) {
                              _terminee = true;
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_payer)
                        Text(
                          'Vente terminée (payée)',
                          style: AppTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
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
        SizedBox(width: AppTheme.spacingM),
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
  List<int> _getAnneeOptions() {
    final currentYear = DateTime.now().year;
    final years = <int>[];
    // Générer les années de 2020 à l'année actuelle + 1
    for (int year = 2020; year <= currentYear + 1; year++) {
      years.add(year);
    }
    return years.reversed.toList(); // Années récentes en premier
  }
  void _calculatePoidsNet(String value) {
    final poidsVide = double.tryParse(_poidsVideController.text);
    final poidsPlein = double.tryParse(_poidsPleinController.text);
    
    if (poidsVide != null && poidsPlein != null) {
      final poidsNet = poidsPlein - poidsVide;
      _poidsNetController.text = poidsNet.toStringAsFixed(1);
      _calculatePrixTotal('');
    }
  }
  void _calculatePoidsNetFinal(String value) {
    setState(() {
      // Recalculer l'affichage du poids net final
    });
  }
  double _getPoidsNetFinal() {
    final poidsNet = double.tryParse(_poidsNetController.text) ?? 0;
    final ecart = double.tryParse(_ecartPoidsNetController.text) ?? 0;
    return poidsNet + ecart; // L'écart peut être positif ou négatif
  }
  void _calculatePrixTotal(String value) {
    setState(() {
      // Recalculer l'affichage du prix total
    });
  }
  double _getPrixTotal() {
    final prixParTonne = double.tryParse(_prixController.text) ?? 0;
    final poidsNetFinal = _getPoidsNetFinal();
    final tonnes = poidsNetFinal / 1000; // Convertir kg en tonnes
    return prixParTonne * tonnes;
  }
  void _saveVente() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final poidsNetFinal = _getPoidsNetFinal();
      final prixTotal = _getPrixTotal();
      
      final vente = Vente(
        id: widget.vente?.id,
        firebaseId: widget.vente?.firebaseId,
        date: _selectedDate,
        annee: _selectedAnnee,
        numeroTicket: _numeroTicketController.text.trim(),
        client: _clientController.text.trim(),
        immatriculationRemorque: _immatriculationController.text.trim(),
        cmr: _cmrController.text.trim(),
        poidsVide: double.parse(_poidsVideController.text),
        poidsPlein: double.parse(_poidsPleinController.text),
        poidsNet: poidsNetFinal, // Utiliser le poids net final (avec écart)
        ecartPoidsNet: _ecartPoidsNetController.text.isNotEmpty ? double.parse(_ecartPoidsNetController.text) : null,
        payer: _payer,
        prix: _prixController.text.isNotEmpty ? prixTotal : null, // Utiliser le prix total calculé
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
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
