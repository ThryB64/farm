import 'dart:convert';
import 'variete_surface.dart';
import 'variete.dart';

class Semis {
  int? id;
  String? firebaseId; // ID Firebase (string)
  final String parcelleId;
  final DateTime date;
  final List<VarieteSurface> varietesSurfaces;
  final String? notes;
  final double? densite; // Densité de semis (graines/hectare)

  Semis({
    this.id,
    this.firebaseId,
    required this.parcelleId,
    required this.date,
    required this.varietesSurfaces,
    this.notes,
    this.densite,
  });

  // Getter pour la compatibilité avec le code existant
  List<String> get varietes => varietesSurfaces.map((v) => v.nom).toList();
  
  // Calculer le coût total du semis (nécessite les prix des variétés)
  double coutTotal(Map<String, Variete> varietes, int annee) {
    if (densite == null || densite! <= 0) return 0.0;
    
    double coutTotal = 0.0;
    for (final varieteSurface in varietesSurfaces) {
      final variete = varietes[varieteSurface.nom];
      if (variete != null && variete.prixParAnnee.containsKey(annee)) {
        final prixDose = variete.prixParAnnee[annee]!;
        final nombreDoses = (densite! * varieteSurface.surface) / 50000;
        coutTotal += nombreDoses * prixDose;
      }
    }
    
    return coutTotal;
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
      densite: double.tryParse(map['densite']?.toString() ?? ''),
    );
  }

  @override
  String toString() => 'Semis(id: $id, parcelleId: $parcelleId, date: $date, varietesSurfaces: $varietesSurfaces)';
} 