import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/app_firebase.dart';

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

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E7D32),
              const Color(0xFF1B5E20),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              SizedBox(height: 30),
              Text(
                'Chargement...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AuthGate : source de vérité unique pour l'authentification (sans boucles)
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastUid;
  bool _transitioning = false;

  @override
  Widget build(BuildContext context) {
    final auth$ = AppFirebase.auth
        .userChanges()
        .distinct((a, b) => a?.uid == b?.uid);

    return StreamBuilder<User?>(
      stream: auth$,
      builder: (_, snap) {
        final uid = snap.data?.uid;
        print('AuthGate: User changed - uid: ${uid ?? 'null'}, lastUid: $_lastUid, transitioning: $_transitioning');
        
        // 🔁 Lance l'init seulement quand l'UID change
        if (!_transitioning && uid != _lastUid) {
          _transitioning = true;
          print('AuthGate: uid changed $_lastUid -> $uid');
          
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              final fp = context.read<FirebaseProviderV4>();
              if (uid == null) {
                print('AuthGate: Disposing auth bound resources');
                await fp.disposeAuthBoundResources();
              } else {
                print('AuthGate: Initializing for user $uid');
                await fp.ensureInitializedFor(uid);
              }
              _lastUid = uid;
              print('AuthGate: Transition completed for uid: $uid');
            } catch (e) {
              print('AuthGate: Error during transition: $e');
            } finally {
              if (mounted) {
                setState(() {
                  _transitioning = false;
                });
              }
            }
          });
        }

        if (uid == null) {
          print('AuthGate: Showing login screen');
          return const SecureLoginScreen();            // ❌ jamais Splash ici
        }

        final ready = context.select<FirebaseProviderV4, bool>((fp) => fp.ready);
        print('AuthGate: User $uid, ready: $ready');
        
        if (!ready) {
          print('AuthGate: Showing splash screen (provider not ready)');
          return const SplashScreen();
        }

        print('AuthGate: Showing home screen');
        return const HomeScreen();
      },
    );
  }
} 