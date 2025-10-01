import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Services & providers
import 'providers/firebase_provider_v4.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/secure_login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Si un widget crashe, on affiche une carte rouge au lieu d'un écran blanc
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      theme: AppTheme.lightThemeCompat,
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Container(
            padding: AppTheme.padding(AppTheme.spacingM),
            decoration: AppTheme.createCardDecoration(
              color: AppTheme.error.withOpacity(0.1),
              borderColor: AppTheme.error.withOpacity(0.4),
            ),
            child: SingleChildScrollView(
              child: Text(
                'Flutter UI error:\n\n${details.exceptionAsString()}',
                style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.onBackground),
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
              ChangeNotifierProvider<ThemeProvider>(
                create: (context) => ThemeProvider(),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Maïs Tracker',
          theme: AppTheme.getTheme(themeProvider.isDarkMode),
          home: const AuthGate(),
        );
      },
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
        backgroundColor: AppTheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: AppTheme.iconSizeXXL,
              color: AppTheme.primary,
            ),
            SizedBox(height: AppTheme.spacingL),
            Text(
              'Hello Web 👋',
              style: AppTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingS),
            Text(
              'Maïs Tracker - Version Web',
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
            Text(
              'L\'application fonctionne !',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.primary,
              ),
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
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.agriculture, 
                color: AppTheme.onPrimary, 
                size: AppTheme.iconSizeXL,
              ),
              SizedBox(height: AppTheme.spacingM),
              Text(
                'Chargement...',
                style: AppTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppTheme.spacingL),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
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
  String? _lastUid;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirebaseProviderV4>();
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final uid = user?.uid;
        print('AuthGate: Auth state changed - user: ${uid ?? 'null'}');
        
        if (uid == null) {
          // logout : vider et afficher login SEULEMENT si on était connecté
          if (_lastUid != null) {
            print('AuthGate: User not authenticated, clearing data');
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              await context.read<FirebaseProviderV4>().disposeAuthBoundResources();
              if (mounted) setState(() => _lastUid = null);
            });
          }
          return const SecureLoginScreen();
        }
        
        // user != null
        if (_lastUid == uid && provider.ready) {
          // déjà prêt
          return const HomeScreen();
        }
        
        // nouveau UID : initialiser
        if (uid != _lastUid) {
          print('AuthGate: User authenticated, initializing data for $uid');
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            await context.read<FirebaseProviderV4>().initializeForUser(uid);
            if (mounted) setState(() => _lastUid = uid);
          });
        }
        
        return const SplashScreen();
      },
    );
  }
} 