import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/security_service.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_buttons.dart';
import 'home_screen.dart';

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
  bool _hasAttemptedAutoLogin = false; // Flag pour empêcher la reconnexion automatique


  @override
  void initState() {
    super.initState();
    // Pré-remplir les champs avec les valeurs par défaut pour éviter la reconnexion automatique
    _emailController.text = 'arnaudberard@gmail.com';
    _passwordController.text = 'Thierry64530*';
    
    // Connexion automatique au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasAttemptedAutoLogin) {
        _signIn();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_authInProgress) return;
    if (!_formKey.currentState!.validate()) return;

    // Empêcher la reconnexion automatique
    if (_hasAttemptedAutoLogin) {
      print('SecureLoginScreen: Auto-login already attempted, ignoring');
      return;
    }

    _authInProgress = true;
    _hasAttemptedAutoLogin = true;
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo et titre
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'GAEC de la BARADE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestion des récoltes de maïs',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Formulaire de connexion
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Connexion sécurisée',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Accès restreint aux membres autorisés',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
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
                          
                          const SizedBox(height: 16),
                          
                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre mot de passe';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Message d'erreur
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Bouton de connexion automatique
                          ModernButton(
                            text: 'Connexion automatique',
                            onPressed: _isLoading ? null : _signIn,
                            isLoading: _isLoading,
                            isFullWidth: true,
                            backgroundColor: AppTheme.primary,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Bouton de connexion manuelle
                          ModernButton(
                            text: 'Se connecter manuellement',
                            onPressed: _isLoading ? null : _signIn,
                            isLoading: _isLoading,
                            isFullWidth: true,
                            backgroundColor: AppTheme.secondary,
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
