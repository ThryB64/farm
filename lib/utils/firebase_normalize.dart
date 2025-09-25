import 'dart:convert';

/// Normalise les données Firebase Web qui peuvent être Map<Object?,Object?>
/// en Map<String, dynamic> pour éviter les erreurs de type
Map<String, dynamic> normalize(Object? raw) {
  if (raw == null) return <String, dynamic>{};
  // round-trip JSON pour forcer un Map<String,dynamic>
  return Map<String, dynamic>.from(jsonDecode(jsonEncode(raw)) as Map);
}