import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:html' as html;
import '../theme/app_theme.dart';
import '../services/security_service.dart';

class DebugLoginScreen extends StatefulWidget {
  const DebugLoginScreen({Key? key}) : super(key: key);

  @override
  State<DebugLoginScreen> createState() => _DebugLoginScreenState();
}

class _DebugLoginScreenState extends State<DebugLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _securityService = SecurityService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String _debugInfo = '';
  bool _showDebugInfo = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _debugInfo = '';
    });

    try {
      print('DebugLoginScreen: Starting sign in process');
      await _securityService.signInOncePerDevice(
        _emailController.text.trim(),
        _passwordController.text,
      );
      print('DebugLoginScreen: Sign in successful');
    } on FirebaseAuthException catch (e) {
      print('DebugLoginScreen: Firebase auth error: ${e.code}');
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
        _debugInfo = 'Erreur Firebase: ${e.code}\nMessage: ${e.message}';
      });
    } catch (e) {
      print('DebugLoginScreen: General error: $e');
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _debugInfo = 'Erreur générale: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _debugInfo = '';
    });

    try {
      String info = '=== DIAGNOSTIC DE CONNEXION ===\n\n';
      
      // 1. Vérifier l'état de Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      info += '1. Utilisateur actuel: ${user?.uid ?? 'Aucun'}\n';
      info += '   Email: ${user?.email ?? 'N/A'}\n\n';
      
      // 2. Vérifier le device ID
      final deviceId = _securityService.ensureDeviceId();
      info += '2. Device ID: $deviceId\n\n';
      
      // 3. Vérifier localStorage
      final localStorage = html.window.localStorage;
      info += '3. LocalStorage:\n';
      info += '   - mais_tracker_device_id: ${localStorage['mais_tracker_device_id'] ?? 'N/A'}\n';
      info += '   - Keys: ${localStorage.keys.toList()}\n\n';
      
      // 4. Tester la connexion Firebase Database
      try {
        final database = FirebaseDatabase.instance;
        final snapshot = await database.ref('test').get();
        info += '4. Firebase Database: ✅ Connecté\n\n';
      } catch (e) {
        info += '4. Firebase Database: ❌ Erreur - $e\n\n';
      }
      
      // 5. Vérifier la whitelist (si connecté)
      if (user != null) {
        try {
          final isAllowed = await _securityService.isUserAllowed(user.uid);
          info += '5. Whitelist: ${isAllowed ? '✅ Autorisé' : '❌ Non autorisé'}\n\n';
        } catch (e) {
          info += '5. Whitelist: ❌ Erreur - $e\n\n';
        }
      } else {
        info += '5. Whitelist: ⏸️ Non vérifiable (pas connecté)\n\n';
      }
      
      // 6. Vérifier la liaison d'appareil (si connecté)
      if (user != null) {
        try {
          final deviceInfo = await _securityService.getDeviceInfo();
          info += '6. Liaison appareil: ${deviceInfo != null ? '✅ Lié' : '❌ Non lié'}\n';
          if (deviceInfo != null) {
            info += '   Device ID lié: ${deviceInfo['primaryDeviceId']}\n';
            info += '   Lié le: ${DateTime.fromMillisecondsSinceEpoch(deviceInfo['boundAt'] ?? 0)}\n';
          }
        } catch (e) {
          info += '6. Liaison appareil: ❌ Erreur - $e\n';
        }
      } else {
        info += '6. Liaison appareil: ⏸️ Non vérifiable (pas connecté)\n';
      }
      
      setState(() {
        _debugInfo = info;
        _showDebugInfo = true;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Erreur lors du diagnostic: $e';
        _showDebugInfo = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    try {
      // Déconnexion Firebase
      await FirebaseAuth.instance.signOut();
      
      // Nettoyer localStorage
      html.window.localStorage.clear();
      
      // Nettoyer les données de l'application
      html.window.localStorage.remove('parcelles');
      html.window.localStorage.remove('cellules');
      html.window.localStorage.remove('chargements');
      html.window.localStorage.remove('semis');
      html.window.localStorage.remove('varietes');
      html.window.localStorage.remove('ventes');
      html.window.localStorage.remove('traitements');
      html.window.localStorage.remove('produits');
      
      setState(() {
        _debugInfo = '✅ Toutes les données ont été effacées. Redémarrez l\'application.';
        _showDebugInfo = true;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Erreur lors du nettoyage: $e';
        _showDebugInfo = true;
      });
    }
  }

  Future<void> _resetDeviceBinding() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _debugInfo = '❌ Aucun utilisateur connecté pour réinitialiser la liaison.';
          _showDebugInfo = true;
        });
        return;
      }
      
      await _securityService.resetDeviceBinding();
      
      setState(() {
        _debugInfo = '✅ Liaison d\'appareil réinitialisée avec succès.';
        _showDebugInfo = true;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Erreur lors de la réinitialisation: $e';
        _showDebugInfo = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic de Connexion'),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: AppTheme.padding(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Formulaire de connexion
                AppTheme.glass(
                  child: Padding(
                    padding: AppTheme.padding(AppTheme.spacingM),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Test de Connexion',
                            style: AppTheme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: AppTheme.spacingM),
                          
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
                          
                          SizedBox(height: AppTheme.spacingM),
                          
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
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: AppTheme.onPrimary,
                              padding: AppTheme.padding(AppTheme.spacingM),
                            ),
                            child: _isLoading 
                              ? const CircularProgressIndicator(color: AppTheme.onPrimary)
                              : const Text('Tester la Connexion'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: AppTheme.spacingM),
                
                // Outils de diagnostic
                AppTheme.glass(
                  child: Padding(
                    padding: AppTheme.padding(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Outils de Diagnostic',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        
                        SizedBox(height: AppTheme.spacingM),
                        
                        ElevatedButton(
                          onPressed: _isLoading ? null : _runDiagnostics,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondary,
                            foregroundColor: AppTheme.onSecondary,
                            padding: AppTheme.padding(AppTheme.spacingM),
                          ),
                          child: const Text('Lancer le Diagnostic'),
                        ),
                        
                        SizedBox(height: AppTheme.spacingS),
                        
                          ElevatedButton(
                            onPressed: _resetDeviceBinding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warning,
                              foregroundColor: AppTheme.textPrimary,
                              padding: AppTheme.padding(AppTheme.spacingM),
                            ),
                            child: const Text('Réinitialiser la Liaison d\'Appareil'),
                          ),
                          
                          SizedBox(height: AppTheme.spacingS),
                          
                          ElevatedButton(
                            onPressed: _clearAllData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              foregroundColor: AppTheme.textPrimary,
                              padding: AppTheme.padding(AppTheme.spacingM),
                            ),
                            child: const Text('Effacer Toutes les Données'),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Informations de diagnostic
                if (_showDebugInfo) ...[
                  SizedBox(height: AppTheme.spacingM),
                  AppTheme.glass(
                    child: Padding(
                      padding: AppTheme.padding(AppTheme.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations de Diagnostic',
                            style: AppTheme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          
                          SizedBox(height: AppTheme.spacingM),
                          
                          Container(
                            width: double.infinity,
                            padding: AppTheme.padding(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: AppTheme.background.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                            ),
                            child: SelectableText(
                              _debugInfo,
                              style: AppTheme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
