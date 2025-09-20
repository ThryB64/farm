#!/bin/bash

echo "🔍 Test d'import avec debug"
echo "=========================="

# Aller dans le répertoire du projet
cd "/home/cytech/Info/devweb/app final"

echo "📦 Nettoyage et build..."
flutter clean
flutter pub get
flutter build web --release

echo ""
echo "✅ Build terminé"
echo ""
echo "🌐 Pour tester l'import :"
echo "1. Ouvrez l'application dans le navigateur"
echo "2. Ouvrez la console développeur (F12)"
echo "3. Allez dans Import/Export"
echo "4. Importez le fichier vide mais_tracker_export_20250921 (3).json"
echo "5. Regardez les logs dans la console"
echo ""
echo "📋 Logs à surveiller :"
echo "- '📊 Import: 0 éléments à importer'"
echo "- '🔄 Début du refresh forcé...'"
echo "- '📊 État après refresh: 0, 0, 0, 0, 0'"
echo "- '✅ Données rafraîchies avec succès'"
echo ""
echo "🔄 Si l'interface ne se vide pas, la page devrait se recharger automatiquement"
echo ""
echo "🚀 Application prête pour le test !"
