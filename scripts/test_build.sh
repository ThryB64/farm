#!/bin/bash

# Script de test de compilation pour Maïs Tracker
# Ce script peut être exécuté localement pour tester la compilation

set -e  # Arrêter en cas d'erreur

echo "🌱 Début des tests de compilation pour Maïs Tracker"
echo "=================================================="

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

echo "✅ Flutter trouvé: $(flutter --version | head -n 1)"

# Vérifier la version de Flutter
echo "📋 Vérification de la version Flutter..."
flutter --version

# Nettoyer le projet
echo "🧹 Nettoyage du projet..."
flutter clean

# Obtenir les dépendances
echo "📦 Récupération des dépendances..."
flutter pub get

# Vérifier les dépendances
echo "🔍 Vérification des dépendances..."
flutter pub deps

# Analyser le code
echo "🔍 Analyse du code..."
flutter analyze

# Exécuter les tests
echo "🧪 Exécution des tests..."
flutter test

# Test de compilation pour Android
echo "🤖 Test de compilation Android..."
flutter build apk --debug

# Test de compilation pour Linux
echo "🐧 Test de compilation Linux..."
flutter build linux --debug

# Test de compilation pour Windows (si sur Windows)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "🪟 Test de compilation Windows..."
    flutter build windows --debug
fi

# Test de compilation pour macOS (si sur macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Test de compilation macOS..."
    flutter build macos --debug
fi

echo "✅ Tous les tests de compilation sont passés avec succès!"
echo "🚀 L'application est prête pour Codemagic!"
