import 'dart:convert';
import 'variete_surface.dart';

class Semis {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String parcelleId;
  final DateTime date;
  final List<VarieteSurface> varietesSurfaces;
  final String? notes;
  final double densiteMais; // Densité de maïs (défaut: 83000)
  final double prixSemis; // Prix du semis calculé automatiquement

  Semis({
    this.id,
    this.firebaseId,
    required this.parcelleId,
    required this.date,
    required this.varietesSurfaces,
    this.notes,
    this.densiteMais = 83000.0, // Valeur par défaut
    this.prixSemis = 0.0,
  });

  // Getter pour la compatibilité avec le code existant
  List<String> get varietes => varietesSurfaces.map((v) => v.nom).toList();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'parcelle_id': parcelleId,
      'date': date.toIso8601String(),
      'varietes_surfaces': jsonEncode(varietesSurfaces.map((v) => v.toMap()).toList()),
      'notes': notes,
      'densite_mais': densiteMais,
      'prix_semis': prixSemis,
    };
  }

  factory Semis.fromMap(Map<String, dynamic> map) {
    final List<dynamic> varietesData = jsonDecode(map['varietes_surfaces']);
    return Semis(
      id: map['id'],
      firebaseId: map['firebaseId'],
      parcelleId: map['parcelle_id']?.toString() ?? '',
      date: DateTime.parse(map['date']),
      varietesSurfaces: varietesData.map((v) => VarieteSurface.fromMap(v)).toList(),
      notes: map['notes'],
      densiteMais: (map['densite_mais'] ?? 83000.0).toDouble(),
      prixSemis: (map['prix_semis'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() => 'Semis(id: $id, parcelleId: $parcelleId, date: $date, varietesSurfaces: $varietesSurfaces)';
} 