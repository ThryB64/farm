import 'dart:convert';
import 'variete_surface.dart';

class Semis {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String parcelleId;
  final DateTime date;
  final List<VarieteSurface> varietesSurfaces;
  final String? notes;
  final double? prix; // Prix par hectare
  final double? densite; // Densité de semis (graines/hectare)

  Semis({
    this.id,
    this.firebaseId,
    required this.parcelleId,
    required this.date,
    required this.varietesSurfaces,
    this.notes,
    this.prix,
    this.densite,
  });

  // Getter pour la compatibilité avec le code existant
  List<String> get varietes => varietesSurfaces.map((v) => v.nom).toList();
  
  // Calculer le coût total du semis
  double get coutTotal {
    if (prix == null || prix! <= 0) return 0.0;
    
    double surfaceTotale = 0.0;
    for (final varieteSurface in varietesSurfaces) {
      surfaceTotale += varieteSurface.surface;
    }
    
    return prix! * surfaceTotale;
  }
  
  // Calculer le nombre de doses nécessaires
  double get nombreDoses {
    if (densite == null || densite! <= 0) return 0.0;
    
    double surfaceTotale = 0.0;
    for (final varieteSurface in varietesSurfaces) {
      surfaceTotale += varieteSurface.surface;
    }
    
    // 1 dose = 50000 graines, densité = graines/hectare
    // Nombre de doses = (densité * surface) / 50000
    return (densite! * surfaceTotale) / 50000;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'parcelle_id': parcelleId,
      'date': date.toIso8601String(),
      'varietes_surfaces': jsonEncode(varietesSurfaces.map((v) => v.toMap()).toList()),
      'notes': notes,
      'prix': prix,
      'densite': densite,
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
      prix: double.tryParse(map['prix']?.toString() ?? ''),
      densite: double.tryParse(map['densite']?.toString() ?? ''),
    );
  }

  @override
  String toString() => 'Semis(id: $id, parcelleId: $parcelleId, date: $date, varietesSurfaces: $varietesSurfaces)';
} 