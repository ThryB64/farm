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
import 'package:firebase_auth/firebase_auth.dart';
import '../services/security_service.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'farm_selection_screen.dart';
class SecureLoginScreen extends StatefulWidget {
  const SecureLoginScreen({Key? key}) : super(key: key);
  @override
  State<SecureLoginScreen> createState() => _SecureLoginScreenState();
}
class _SecureLoginScreenState extends State<SecureLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _securityService = SecurityService();
  
  bool _isLoading = false;
  bool _authInProgress = false;
  String? _errorMessage;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _signIn() async {
    if (_authInProgress) return;
    if (!_formKey.currentState!.validate()) return;
    _authInProgress = true;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      print('SecureLoginScreen: Starting sign in process');
      await _securityService.signInOncePerDevice(
        _emailController.text.trim(),
        _passwordController.text,
      );
      print('SecureLoginScreen: Sign in successful, AuthGate will handle navigation');
      // AuthGate gère automatiquement la navigation
    } on FirebaseAuthException catch (e) {
      print('SecureLoginScreen: Firebase auth error: ${e.code}');
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e.code);
        });
      }
    } catch (e) {
      print('SecureLoginScreen: General error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur de connexion: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _authInProgress = false;
    }
  }
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'user-not-allowed':
        return 'Votre compte n\'est pas autorisé.';
      case 'device-mismatch':
        return 'Ce compte est déjà lié à un autre appareil.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      default:
        return 'Erreur de connexion: $code';
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
                          'GAEC de la BARADE',
                          style: AppTheme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppTheme.spacingS),
                        Text(
                          'Gestion des récoltes de maïs',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.spacingXL),
                  
                  // Formulaire de connexion
                  Container(
                    padding: AppTheme.padding(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connexion sécurisée',
                            style: AppTheme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: AppTheme.spacingS),
                          
                          Text(
                            'Accès restreint aux membres autorisés',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: AppTheme.spacingL),
                          
                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: AppTheme.createInputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icons.email,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre email';
                              }
                              if (!value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: AppTheme.spacingM),
                          
                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            decoration: AppTheme.createInputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: Icons.lock,
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre mot de passe';
                              }
                              return null;
                            },
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
                          
                          // Bouton de connexion
                          ModernButton(
                            text: 'Se connecter',
                            onPressed: _isLoading ? null : _signIn,
                            isLoading: _isLoading,
                            isFullWidth: true,
                            backgroundColor: AppTheme.primary,
                          ),
                          
                          SizedBox(height: AppTheme.spacingM),
                          
                          // Bouton pour changer de ferme
                          TextButton.icon(
                            onPressed: _isLoading ? null : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const FarmSelectionScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.swap_horiz, color: AppTheme.textSecondary),
                            label: Text(
                              'Changer de ferme',
                              style: AppTheme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          
                        ],
                      ),
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
}
