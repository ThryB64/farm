import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../theme/app_theme.dart';
import 'export_bilan_campagne_screen.dart';

class BilanCampagneScreen extends StatefulWidget {
  const BilanCampagneScreen({Key? key}) : super(key: key);

  @override
  State<BilanCampagneScreen> createState() => _BilanCampagneScreenState();
}

class _BilanCampagneScreenState extends State<BilanCampagneScreen> {
  int? _selectedYear;
  final _prixValorisationController = TextEditingController();
  final _humiditeCibleController = TextEditingController(text: '15.0');
  final _coutPointController = TextEditingController(text: '2.0');
  final _forfaitTransportController = TextEditingController(text: '0.0');
  final _forfaitMecaController = TextEditingController(text: '0.0');
  
  bool _usePrixMoyenVendu = true;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  void dispose() {
    _prixValorisationController.dispose();
    _humiditeCibleController.dispose();
    _coutPointController.dispose();
    _forfaitTransportController.dispose();
    _forfaitMecaController.dispose();
    super.dispose();
  }

  void _generateBilan() {
    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une année')),
      );
      return;
    }

    final params = {
      'annee': _selectedYear!,
      'usePrixMoyenVendu': _usePrixMoyenVendu,
      'prixValorisationStock': _usePrixMoyenVendu 
          ? null 
          : double.tryParse(_prixValorisationController.text) ?? 0.0,
      'humiditeCible': double.tryParse(_humiditeCibleController.text) ?? 15.0,
      'coutPoint': double.tryParse(_coutPointController.text) ?? 2.0,
      'forfaitTransport': double.tryParse(_forfaitTransportController.text) ?? 0.0,
      'forfaitMeca': double.tryParse(_forfaitMecaController.text) ?? 0.0,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExportBilanCampagneScreen(params: params),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FirebaseProviderV4>(context);
    final years = provider.getAvailableYears();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilan de Campagne'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_rounded,
                    size: 48,
                    color: AppTheme.onPrimary,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Bilan de Campagne',
                    style: AppTheme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Analyse complète : Production • Intrants • Ventes • Marge',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onPrimary.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Sélection année
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.primary),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Campagne',
                          style: AppTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: AppTheme.createInputDecoration(
                        labelText: 'Année',
                      ),
                      items: years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Paramètres de valorisation
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.euro, color: AppTheme.primary),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Valorisation du Stock',
                          style: AppTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    CheckboxListTile(
                      title: const Text('Utiliser le prix moyen vendu'),
                      value: _usePrixMoyenVendu,
                      onChanged: (value) {
                        setState(() {
                          _usePrixMoyenVendu = value ?? true;
                        });
                      },
                    ),
                    if (!_usePrixMoyenVendu) ...[
                      const SizedBox(height: AppTheme.spacingS),
                      TextFormField(
                        controller: _prixValorisationController,
                        decoration: AppTheme.createInputDecoration(
                          labelText: 'Prix de valorisation (€/t)',
                          hintText: 'Ex: 220.00',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Paramètres de séchage
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop, color: AppTheme.primary),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Séchage',
                          style: AppTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _humiditeCibleController,
                            decoration: AppTheme.createInputDecoration(
                              labelText: 'Humidité cible (%)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: TextFormField(
                            controller: _coutPointController,
                            decoration: AppTheme.createInputDecoration(
                              labelText: 'Coût/point (€/t)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Forfaits optionnels
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, color: AppTheme.primary),
                        const SizedBox(width: AppTheme.spacingS),
                        Text(
                          'Forfaits (optionnel)',
                          style: AppTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _forfaitTransportController,
                            decoration: AppTheme.createInputDecoration(
                              labelText: 'Transport (€/t)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: TextFormField(
                            controller: _forfaitMecaController,
                            decoration: AppTheme.createInputDecoration(
                              labelText: 'Mécanisation (€/ha)',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Bouton de génération
            ElevatedButton.icon(
              onPressed: _generateBilan,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Générer le Bilan PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

