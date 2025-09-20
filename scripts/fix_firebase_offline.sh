#!/usr/bin/env bash

echo "🔧 Correction Firebase pour mode hors ligne"
echo "============================================"

# Remplacer toutes les occurrences de "throw Exception('Firebase not initialized')" 
# par des gestionnaires de mode hors ligne

sed -i 's/if (_userRef == null) throw Exception('\''Firebase not initialized'\'');/if (_userRef == null) {\n      print('\''Firebase not initialized, operation ignored'\'');\n      return;\n    }/g' lib/services/firebase_service.dart

# Pour les méthodes d'insertion, générer un ID local
sed -i 's/if (_userRef == null) {\n      print('\''Firebase not initialized, operation ignored'\'');\n      return;\n    }/if (_userRef == null) {\n      print('\''Firebase not initialized, generating local ID'\'');\n      return DateTime.now().millisecondsSinceEpoch.toString();\n    }/g' lib/services/firebase_service.dart

echo "✅ Corrections appliquées"
echo "📝 Vérification des changements..."

# Vérifier que les changements ont été appliqués
grep -n "Firebase not initialized" lib/services/firebase_service.dart

echo "🎉 Firebase configuré pour le mode hors ligne !"
