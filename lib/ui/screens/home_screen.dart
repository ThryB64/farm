import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_firebase.dart';
import '../../data/firebase_provider.dart';
import 'secure_login_screen.dart';
import 'splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _signingOut = false;

  Future<void> _logout() async {
    if (_signingOut) return;
    _signingOut = true;
    
    try {
      print('HomeScreen: Starting sign out process');
      await AppFirebase.auth.signOut();
      await context.read<FirebaseProvider>().disposeAuthBoundResources();
      print('HomeScreen: Sign out successful, AuthGate will handle navigation');
      
      // Fallback unique : navigation de sécurité
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SecureLoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      print('HomeScreen: Sign out error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de déconnexion: $e')),
        );
      }
    } finally {
      _signingOut = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.select<FirebaseProvider, String?>((p) => p.uid);
    final ready = context.select<FirebaseProvider, bool>((p) => p.ready);
    
    // Éviter l'affichage "fantôme" si le provider n'est pas prêt
    if (!ready) {
      return const SplashScreen();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text(
          'GAEC de la BARADE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signingOut ? null : _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.agriculture,
              size: 100,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenue !',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connecté: ${uid ?? "-"}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Application en cours de développement...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
