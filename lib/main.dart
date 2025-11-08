import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          title: 'AgriCorn',
          theme: AppTheme.getTheme(themeProvider.isDarkMode),
          home: const AuthGate(),
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
              child: child!,
            );
          },
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
              'AgriCorn - Version Web',
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
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBgGradient,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cornGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.cornGold.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.agriculture, 
                  color: AppTheme.cornGold, 
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AgriCorn',
                style: AppTheme.textTheme.headlineLarge?.copyWith(
                  color: AppTheme.cornGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chargement...',
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cornGold),
                  strokeWidth: 3,
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
  String? _lastUid;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirebaseProviderV4>();
    
    // Toujours afficher le SplashScreen en premier pour éviter l'écran blanc
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