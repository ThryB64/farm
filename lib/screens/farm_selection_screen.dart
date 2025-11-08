import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../services/firebase_service_v4.dart';
import '../services/demo_data_service.dart';
import '../providers/firebase_provider_v4.dart';
import 'package:provider/provider.dart';
import 'secure_login_screen.dart';

class FarmSelectionScreen extends StatefulWidget {
  const FarmSelectionScreen({Key? key}) : super(key: key);

  @override
  State<FarmSelectionScreen> createState() => _FarmSelectionScreenState();
}

class _FarmSelectionScreenState extends State<FarmSelectionScreen> {
  final FirebaseServiceV4 _firebaseService = FirebaseServiceV4();
  final DemoDataService _demoDataService = DemoDataService();
  bool _isLoading = false;
  String? _selectedFarm;
  String? _errorMessage;
  bool _demoDataInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedFarm = _firebaseService.farmId;
    _checkDemoDataStatus();
  }

  Future<void> _checkDemoDataStatus() async {
    // Vérifier si des données existent déjà pour la ferme de démo
    // Pour simplifier, on suppose que si la ferme est 'agricorn_demo', 
    // on peut vérifier si des données existent
    if (_selectedFarm == 'agricorn_demo') {
      // Cette vérification pourrait être améliorée
      setState(() {
        _demoDataInitialized = true; // À améliorer avec une vraie vérification
      });
    }
  }

  Future<void> _selectFarm(String farmId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _firebaseService.setFarmId(farmId);
      
      // Réinitialiser le provider pour charger les nouvelles données
      final provider = context.read<FirebaseProviderV4>();
      await provider.disposeAuthBoundResources();
      
      setState(() {
        _selectedFarm = farmId;
        _isLoading = false;
      });

      // Retourner à l'écran de connexion
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SecureLoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du changement de ferme: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeDemoData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // S'assurer qu'on est sur la ferme de démo
      if (_selectedFarm != 'agricorn_demo') {
        await _firebaseService.setFarmId('agricorn_demo');
        _selectedFarm = 'agricorn_demo';
      }

      // Générer les données de démonstration
      await _demoDataService.generateDemoData();

      setState(() {
        _demoDataInitialized = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Données de démonstration créées avec succès !'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la création des données: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = AppTheme.getColors(themeProvider.isDarkMode);

    return Scaffold(
      body: Container(
        decoration: AppTheme.appBackground(context),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppTheme.padding(AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo et titre
                  Container(
                    padding: AppTheme.padding(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      color: colors.textPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: AppTheme.iconSizeXXL,
                          color: colors.textPrimary,
                        ),
                        SizedBox(height: AppTheme.spacingM),
                        Text(
                          'AgriCorn',
                          style: AppTheme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppTheme.spacingS),
                        Text(
                          'Sélection de la ferme',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.spacingXL),

                  // Sélection de ferme
                  Container(
                    padding: AppTheme.padding(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Choisir une ferme',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: AppTheme.spacingL),

                        // Ferme réelle
                        _buildFarmCard(
                          title: 'Ferme Réelle',
                          subtitle: 'GAEC de la BARADE',
                          farmId: 'gaec_berard',
                          icon: Icons.business,
                          color: AppTheme.primary,
                          isSelected: _selectedFarm == 'gaec_berard',
                        ),

                        SizedBox(height: AppTheme.spacingM),

                        // Ferme de démonstration
                        _buildFarmCard(
                          title: 'Ferme de Démonstration',
                          subtitle: 'Données de présentation',
                          farmId: 'agricorn_demo',
                          icon: Icons.presentation_chart,
                          color: AppTheme.success,
                          isSelected: _selectedFarm == 'agricorn_demo',
                        ),

                        SizedBox(height: AppTheme.spacingL),

                        // Message d'erreur
                        if (_errorMessage != null) ...[
                          Container(
                            padding: AppTheme.padding(AppTheme.spacingS),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: AppTheme.error, size: AppTheme.iconSizeM),
                                SizedBox(width: AppTheme.spacingS),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppTheme.spacingM),
                        ],

                        // Bouton pour initialiser les données de démo
                        if (_selectedFarm == 'agricorn_demo' && !_demoDataInitialized) ...[
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _initializeDemoData,
                            icon: Icon(Icons.data_object, color: AppTheme.onPrimary),
                            label: Text(
                              'Créer les données de démonstration',
                              style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.onPrimary),
                            ),
                            style: AppTheme.buttonStyle(
                              backgroundColor: AppTheme.success,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingL,
                                vertical: AppTheme.spacingM,
                              ),
                            ),
                          ),
                          SizedBox(height: AppTheme.spacingM),
                        ],

                        // Indicateur de chargement
                        if (_isLoading)
                          Center(
                            child: Padding(
                              padding: AppTheme.padding(AppTheme.spacingM),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFarmCard({
    required String title,
    required String subtitle,
    required String farmId,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _selectFarm(farmId),
      child: Container(
        padding: AppTheme.padding(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? color : AppTheme.surface,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: AppTheme.padding(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: color, size: AppTheme.iconSizeL),
            ),
            SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXS),
                  Text(
                    subtitle,
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: AppTheme.iconSizeM),
          ],
        ),
      ),
    );
  }
}

