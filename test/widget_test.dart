import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mais_tracker/providers/database_provider.dart';
import 'package:mais_tracker/screens/home_screen.dart';
import 'helper/test_database_helper.dart';

void main() {
  group('Maïs Tracker Widget Tests', () {
    setUpAll(() async {
      // Initialiser la base de données de test
      await TestDatabaseHelper.initializeTestDatabase();
    });

    tearDownAll(() async {
      // Nettoyer la base de données de test
      await TestDatabaseHelper.closeTestDatabase();
    });

    testWidgets('HomeScreen loads without crashing', (WidgetTester tester) async {
      // Créer un provider de base de données pour les tests
      final databaseProvider = DatabaseProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<DatabaseProvider>(
            create: (context) => databaseProvider,
            child: const HomeScreen(),
          ),
        ),
      );

      // Vérifier que l'écran se charge
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('DatabaseProvider initializes correctly', (WidgetTester tester) async {
      final databaseProvider = DatabaseProvider();
      
      // Initialiser le provider
      await databaseProvider.initialize();
      
      // Vérifier que les listes sont initialisées
      expect(databaseProvider.parcelles, isA<List>());
      expect(databaseProvider.cellules, isA<List>());
      expect(databaseProvider.chargements, isA<List>());
      expect(databaseProvider.semis, isA<List>());
      expect(databaseProvider.varietes, isA<List>());
    });
  });
}
