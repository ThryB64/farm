import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      home: const AuthGate(),
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

// AuthGate : source de vérité unique pour l'authentification
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _hasClearedData = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        print('AuthGate: Auth state changed - user: ${user?.uid ?? 'null'}');
        
        if (user == null) {
          // Utilisateur non connecté - nettoyer les données UNE SEULE FOIS
          if (!_hasClearedData) {
            print('AuthGate: User not authenticated, clearing data');
            _hasClearedData = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
              provider.clearAll();
            });
          }
          return const SecureLoginScreen();
        }
        
        // Reset le flag quand l'utilisateur se reconnecte
        _hasClearedData = false;
        
        // Utilisateur connecté - s'assurer que le provider est prêt
        print('AuthGate: User authenticated, initializing data');
        return FutureBuilder<void>(
          future: Provider.of<FirebaseProviderV4>(context, listen: false).ensureInitializedFor(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const HomeScreen();
            }
            return const SplashScreen();
          },
        );
      },
    );
  }
} 