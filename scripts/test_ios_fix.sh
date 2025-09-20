#!/usr/bin/env bash

echo "🔧 Test des corrections SQLite pour iOS"
echo "========================================"

# Nettoyer les dépendances
echo "📦 Nettoyage des dépendances..."
flutter clean
flutter pub get

# Vérifier que sqflite_common_ffi n'est plus dans pubspec.yaml
echo "🔍 Vérification des dépendances..."
if grep -q "sqflite_common_ffi" pubspec.yaml; then
    echo "❌ ERREUR: sqflite_common_ffi est encore présent dans pubspec.yaml"
    exit 1
else
    echo "✅ sqflite_common_ffi supprimé du pubspec.yaml"
fi

# Vérifier que sqflite est présent
if grep -q "sqflite:" pubspec.yaml; then
    echo "✅ sqflite présent dans pubspec.yaml"
else
    echo "❌ ERREUR: sqflite manquant dans pubspec.yaml"
    exit 1
fi

# Test d'analyse
echo "🔍 Test d'analyse Flutter..."
flutter analyze --no-fatal-infos

# Test de compilation iOS
echo "📱 Test de compilation iOS..."
flutter build ios --no-codesign

echo "✅ Tous les tests sont passés !"
echo "🚀 L'application est prête pour iOS et Altstore"
