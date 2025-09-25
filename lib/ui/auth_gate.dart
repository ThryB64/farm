import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../core/app_firebase.dart';
import '../data/firebase_provider.dart';
import 'screens/home_screen.dart';
import 'screens/secure_login_screen.dart';
import 'screens/splash_screen.dart';

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
    final Stream<User?> auth$ = AppFirebase.auth
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
              final fp = context.read<FirebaseProvider>();
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

        final ready = context.select<FirebaseProvider, bool>((fp) => fp.ready);
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
