import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Services & providers
import 'providers/firebase_provider_v4.dart';
import 'services/security_service.dart';
import 'screens/home_screen.dart';
import 'screens/secure_login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Si un widget crashe, on affiche une carte rouge au lieu d'un écran blanc
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF101010),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.4)),
            ),
            child: SingleChildScrollView(
              child: Text(
                'Flutter UI error:\n\n${details.exceptionAsString()}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[BOOT] Widgets binding ready. kIsWeb=$kIsWeb');

    // Initialiser Firebase AVANT runApp
    try {
      debugPrint('[BOOT] Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('[BOOT] Firebase initialized successfully');
    } catch (e, s) {
      debugPrint('[BOOT] Firebase init error: $e\n$s');
      // Continuer même si Firebase échoue
    }

    // Trace le premier frame (si on n'y arrive pas, on saura que ça bloque avant)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[BOOT] First frame rendered');
    });

        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<FirebaseProviderV4>(
                create: (context) => FirebaseProviderV4(),
              ),
            ],
            child: const MyApp(),
          ),
        );
  }, (e, s) {
    debugPrint('Zoned error at boot: $e\n$s');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maïs Tracker',
      theme: AppTheme.lightTheme,
      home: const SecurityWrapper(),
    );
  }
}

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm (Web test)'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Hello Web 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Maïs Tracker - Version Web',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              'L\'application fonctionne !',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Attendre que le widget soit monté avant d'accéder au contexte
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        final provider = context.read<FirebaseProviderV4>();
        await provider.initialize();
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade700,
              Colors.green.shade500,
            ],
          ),
        ),
        child: Center(
          child: _isError
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    const Text(
                      'Erreur lors de l\'initialisation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _initializeApp,
                      child: const Text('Réessayer'),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 64,
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    const Text(
                      'Chargement...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Wrapper de sécurité qui vérifie l'authentification
class SecurityWrapper extends StatefulWidget {
  const SecurityWrapper({Key? key}) : super(key: key);

  @override
  State<SecurityWrapper> createState() => _SecurityWrapperState();
}

class _SecurityWrapperState extends State<SecurityWrapper> {
  final SecurityService _securityService = SecurityService();
  bool _isLoading = true;
  SecurityStatus _securityStatus = SecurityStatus.notAuthenticated;
  bool _isSigningOut = false;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkSecurityStatus();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    // Écouter les changements d'authentification via le SecurityService
    _authSubscription = _securityService.setupAuthListener(() {
      print('SecurityWrapper: Auth state changed, checking status');
      if (mounted && !_isSigningOut) {
        // Attendre très longtemps pour que la navigation se termine
        Future.delayed(const Duration(milliseconds: 10000), () {
          if (mounted && !_isSigningOut) {
            _checkSecurityStatus();
            _refreshDataAfterAuth();
          }
        });
      } else if (_isSigningOut) {
        print('SecurityWrapper: Ignoring auth state change during sign out');
      }
    });
  }
  
  void _refreshDataAfterAuth() {
    // Rafraîchir les données du provider après la connexion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
      provider.refreshAfterAuth();
    });
  }

  Future<void> _checkSecurityStatus() async {
    try {
      print('SecurityWrapper: Checking security status');
      final status = await _securityService.checkSecurityStatus();
      print('SecurityWrapper: Security status: $status');
      if (mounted) {
        setState(() {
          _securityStatus = status;
          _isLoading = false;
        });
        
        // Si l'utilisateur est authentifié, forcer le refresh des données
        if (status == SecurityStatus.authenticated) {
          print('SecurityWrapper: User authenticated, forcing data refresh');
          _refreshDataAfterAuth();
        }
      }
    } catch (e) {
      print('SecurityWrapper: Error checking security status: $e');
      if (mounted) {
        setState(() {
          _securityStatus = SecurityStatus.notAuthenticated;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    print('SecurityWrapper: Building with status: $_securityStatus');
    
    switch (_securityStatus) {
      case SecurityStatus.authenticated:
        return const HomeScreen();
      case SecurityStatus.notAuthenticated:
      case SecurityStatus.notAllowed:
        return const SecureLoginScreen();
    }
  }
} 