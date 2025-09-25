import 'dart:convert';

/// Normalise n'importe quelle valeur RTDB (interop JS sur Web) en vraie Map<String,dynamic>
Map<String, dynamic> normalizeToStringKeyMap(Object? raw) {
  if (raw == null) return <String, dynamic>{};

  // Méthode la plus robuste sur Web : JSON round-trip
  // -> convertit les objets interop JS en vraies Maps/List Dart
  final j = jsonDecode(jsonEncode(raw));

  if (j is Map<String, dynamic>) return j;
  if (j is Map) return Map<String, dynamic>.from(j);

  throw FormatException('Expected an object (Map) but got ${j.runtimeType}');
}

/// Idem mais accepte aussi List -> Map(index->val)
Map<String, dynamic> normalizeLoose(Object? raw) {
  if (raw == null) return <String, dynamic>{};

  final j = jsonDecode(jsonEncode(raw));

  if (j is Map<String, dynamic>) return j;
  if (j is Map) return Map<String, dynamic>.from(j);
  if (j is List) {
    // Si jamais un produit a été stocké sous forme de liste (données anciennes)
    final m = <String, dynamic>{};
    for (var i = 0; i < j.length; i++) {
      m[i.toString()] = j[i];
    }
    return m;
  }
  throw FormatException('Unsupported JSON root ${j.runtimeType}');
}
