import 'package:flutter_test/flutter_test.dart';
import 'package:mais_tracker/utils/poids_utils.dart';
import 'package:mais_tracker/models/parcelle.dart';
import 'package:mais_tracker/models/cellule.dart';
import 'package:mais_tracker/models/chargement.dart';
import 'package:mais_tracker/models/variete.dart';
import 'helper/test_database_helper.dart';

void main() {
  group('PoidsUtils Tests', () {
    test('calculPoidsNet should calculate correctly', () {
      expect(PoidsUtils.calculPoidsNet(1000.0, 200.0), equals(800.0));
      expect(PoidsUtils.calculPoidsNet(500.0, 100.0), equals(400.0));
    });

    test('calculPoidsNet should throw error for invalid weights', () {
      expect(() => PoidsUtils.calculPoidsNet(100.0, 200.0), 
             throwsA(isA<ArgumentError>()));
    });

    test('calculPoidsNormes should calculate correctly for 15% humidity', () {
      final poidsNet = 1000.0;
      final humidite = 15.0;
      final poidsNormes = PoidsUtils.calculPoidsNormes(poidsNet, humidite);
      expect(poidsNormes, equals(1000.0)); // Pas de correction à 15%
    });

    test('calculPoidsNormes should calculate correctly for 20% humidity', () {
      final poidsNet = 1000.0;
      final humidite = 20.0;
      final poidsNormes = PoidsUtils.calculPoidsNormes(poidsNet, humidite);
      expect(poidsNormes, equals(940.0)); // Coefficient 0.940 pour 20%
    });

    test('estPoidsValide should validate correctly', () {
      expect(PoidsUtils.estPoidsValide(100.0), isTrue);
      expect(PoidsUtils.estPoidsValide(0.0), isFalse);
      expect(PoidsUtils.estPoidsValide(-10.0), isFalse);
    });

    test('estHumiditeValide should validate correctly', () {
      expect(PoidsUtils.estHumiditeValide(15.0), isTrue);
      expect(PoidsUtils.estHumiditeValide(0.0), isTrue);
      expect(PoidsUtils.estHumiditeValide(100.0), isTrue);
      expect(PoidsUtils.estHumiditeValide(-5.0), isFalse);
      expect(PoidsUtils.estHumiditeValide(105.0), isFalse);
    });
  });

  group('Model Tests', () {
    test('Parcelle should create and serialize correctly', () {
      final parcelle = Parcelle(
        nom: 'Test Parcelle',
        surface: 10.5,
        dateCreation: DateTime(2024, 1, 1),
        notes: 'Test notes',
      );

      expect(parcelle.nom, equals('Test Parcelle'));
      expect(parcelle.surface, equals(10.5));
      expect(parcelle.notes, equals('Test notes'));

      final map = parcelle.toMap();
      expect(map['nom'], equals('Test Parcelle'));
      expect(map['surface'], equals(10.5));

      final parcelleFromMap = Parcelle.fromMap(map);
      expect(parcelleFromMap.nom, equals(parcelle.nom));
      expect(parcelleFromMap.surface, equals(parcelle.surface));
    });

    test('Cellule should create and serialize correctly', () {
      final cellule = Cellule(
        reference: 'C-001',
        dateCreation: DateTime(2024, 1, 1),
        notes: 'Test cellule',
      );

      expect(cellule.reference, equals('C-001'));
      expect(cellule.capacite, equals(320000.0));

      final map = cellule.toMap();
      expect(map['reference'], equals('C-001'));
      expect(map['capacite'], equals(320000.0));
    });

    test('Chargement should create and serialize correctly', () {
      final chargement = Chargement(
        celluleId: 1,
        parcelleId: 1,
        remorque: 'R-001',
        dateChargement: DateTime(2024, 1, 1),
        poidsPlein: 1000.0,
        poidsVide: 200.0,
        poidsNet: 800.0,
        poidsNormes: 800.0,
        humidite: 15.0,
        variete: 'Test Variété',
      );

      expect(chargement.celluleId, equals(1));
      expect(chargement.poidsPlein, equals(1000.0));
      expect(chargement.poidsVide, equals(200.0));
      expect(chargement.poidsNet, equals(800.0));

      final map = chargement.toMap();
      expect(map['cellule_id'], equals(1));
      expect(map['poids_plein'], equals(1000.0));
    });

    test('Variete should create and serialize correctly', () {
      final variete = Variete(
        nom: 'Test Variété',
        description: 'Description test',
        dateCreation: DateTime(2024, 1, 1),
      );

      expect(variete.nom, equals('Test Variété'));
      expect(variete.description, equals('Description test'));

      final map = variete.toMap();
      expect(map['nom'], equals('Test Variété'));
      expect(map['description'], equals('Description test'));
    });
  });

  group('Database Tests', () {
    setUpAll(() async {
      await TestDatabaseHelper.initializeTestDatabase();
    });

    tearDownAll(() async {
      await TestDatabaseHelper.closeTestDatabase();
    });

    tearDown(() async {
      await TestDatabaseHelper.cleanTestDatabase();
    });

    test('Database should be initialized', () {
      expect(TestDatabaseHelper.database, isNotNull);
    });

    test('Database should have correct tables', () async {
      final db = TestDatabaseHelper.database!;
      
      // Vérifier que les tables existent
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );
      
      final tableNames = tables.map((table) => table['name'] as String).toList();
      
      expect(tableNames, contains('parcelles'));
      expect(tableNames, contains('cellules'));
      expect(tableNames, contains('chargements'));
      expect(tableNames, contains('semis'));
      expect(tableNames, contains('varietes'));
    });
  });
}
