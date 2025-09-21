#!/bin/bash

echo "🔧 Fixing FirebaseProvider V4 optimistic updates..."

# Fix chargements
sed -i 's/Future<String> ajouterChargement(Chargement chargement) async {/Future<String> ajouterChargement(Chargement chargement) async {\n    try {\n      final key = await _service.insertChargement(chargement);\n      \n      \/\/ Mise à jour optimiste locale\n      chargement.firebaseId = key;\n      _chargementsMap[key] = chargement;\n      notifyListeners();\n      \n      print('"'"'FirebaseProvider V4: Chargement added with key: $key'"'"');\n      return key;\n    } catch (e) {\n      _error = '"'"'Erreur lors de l'"'"'ajout du chargement: $e'"'"';\n      notifyListeners();\n      rethrow;\n    }\n  }/' lib/providers/firebase_provider_v4.dart

echo "✅ Provider V4 optimistic updates fixed"
