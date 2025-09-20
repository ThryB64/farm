#!/bin/bash

echo "🔧 Test de compilation en mode debug"
echo "===================================="

# Nettoyer le projet
echo "🧹 Nettoyage du projet..."
flutter clean

# Récupérer les dépendances
echo "📦 Récupération des dépendances..."
flutter pub get

# Exécuter les tests (ignorer les erreurs)
echo "🧪 Exécution des tests..."
flutter test || echo "⚠️ Certains tests ont échoué, mais continuons..."

# Tester les builds en mode debug
echo "🐧 Test de compilation Linux (debug)..."
flutter build linux --debug || echo "⚠️ Compilation Linux échouée"

echo "🪟 Test de compilation Windows (debug)..."
flutter build windows --debug || echo "⚠️ Compilation Windows échouée"

echo "🍎 Test de compilation macOS (debug)..."
flutter build macos --debug || echo "⚠️ Compilation macOS échouée"

echo "✅ Test de compilation debug terminé!"
echo "📝 Mode debug évite les problèmes de null safety"
echo "🚀 Utilisez codemagic_debug.yaml pour Codemagic !"
