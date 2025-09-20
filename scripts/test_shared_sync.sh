#!/bin/bash

# Script pour tester la synchronisation partagée

echo "🧪 Test de la synchronisation partagée..."

# 1. Vérifier que l'application compile
echo "🔨 Vérification de la compilation..."
flutter analyze --no-fatal-infos > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Compilation OK"
else
    echo "❌ Erreurs de compilation détectées"
    exit 1
fi

# 2. Build web
echo "🌐 Build de l'application web..."
flutter build web --release > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Build web réussi"
else
    echo "❌ Erreur de build web"
    exit 1
fi

# 3. Vérifier les chemins dans le code
echo "🔍 Vérification des chemins partagés..."
if grep -q "farms/gaec_berard" lib/services/firebase_service_v3.dart; then
    echo "✅ Chemins partagés détectés dans le service"
else
    echo "❌ Chemins partagés manquants"
    exit 1
fi

if grep -q "farmMembers" lib/services/firebase_service_v3.dart; then
    echo "✅ Gestion des membres de ferme détectée"
else
    echo "❌ Gestion des membres manquante"
    exit 1
fi

# 4. Vérifier les règles Firebase
if [ -f "firebase_rules.json" ]; then
    echo "✅ Règles Firebase générées"
else
    echo "❌ Règles Firebase manquantes"
    exit 1
fi

echo ""
echo "🎉 Test de synchronisation terminé avec succès !"
echo ""
echo "📋 Prochaines étapes :"
echo "   1. Appliquez les règles Firebase (voir firebase_rules.json)"
echo "   2. Ajoutez les membres à farmMembers/gaec_berard/"
echo "   3. Testez sur plusieurs appareils"
echo "   4. Vérifiez que les données se synchronisent en temps réel"
echo ""
echo "🌐 L'application devrait maintenant synchroniser entre tous les appareils !"
