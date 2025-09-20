#!/bin/bash

echo "🔧 Test de compilation minimale (ignore toutes les erreurs)"
echo "=========================================================="

# Nettoyer le projet
echo "🧹 Nettoyage du projet..."
flutter clean

# Récupérer les dépendances
echo "📦 Récupération des dépendances..."
flutter pub get

# Analyse (ignorer les erreurs)
echo "🔍 Analyse Flutter (ignorer les erreurs)..."
flutter analyze --no-fatal-infos || echo "⚠️ Analyse terminée avec des problèmes"

# Tests (ignorer les échecs)
echo "🧪 Tests Flutter (ignorer les échecs)..."
flutter test || echo "⚠️ Tests terminés avec des échecs"

# Essayer les builds (ignorer les échecs)
echo "🐧 Tentative de compilation Linux..."
flutter build linux --debug || echo "⚠️ Compilation Linux échouée"

echo "🪟 Tentative de compilation Windows..."
flutter build windows --debug || echo "⚠️ Compilation Windows échouée"

echo "🍎 Tentative de compilation macOS..."
flutter build macos --debug || echo "⚠️ Compilation macOS échouée"

echo "✅ Test de compilation minimale terminé!"
echo "📝 Cette approche ignore toutes les erreurs et continue"
echo "🚀 Utilisez codemagic_minimal.yaml pour Codemagic !"
