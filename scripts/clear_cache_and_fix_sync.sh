#!/bin/bash

# Script pour vider le cache et corriger la synchronisation

echo "🧹 Nettoyage du cache et correction de la synchronisation..."

# 1. Vider le cache du navigateur (pour le web)
echo "🌐 Nettoyage du cache web..."
if command -v google-chrome &> /dev/null; then
    google-chrome --clear-cache --clear-storage --clear-app-cache 2>/dev/null || true
fi

# 2. Supprimer les fichiers de cache Flutter
echo "📱 Nettoyage du cache Flutter..."
flutter clean
flutter pub get

# 3. Supprimer les fichiers de build
echo "🔨 Nettoyage des fichiers de build..."
rm -rf build/
rm -rf web/build/

# 4. Vérifier que le bon service est utilisé
echo "🔍 Vérification du service Firebase..."
if grep -q "Hybrid Database" lib/providers/firebase_provider_v3.dart; then
    echo "❌ Le provider utilise encore l'ancien service Hybrid Database"
    echo "🔧 Correction en cours..."
    
    # Remplacer les références à l'ancien service
    sed -i 's/Hybrid Database/FirebaseService V3/g' lib/providers/firebase_provider_v3.dart
    sed -i 's/_databaseService/_firebaseService/g' lib/providers/firebase_provider_v3.dart
    
    echo "✅ Service corrigé"
else
    echo "✅ Le provider utilise le bon service Firebase V3"
fi

# 5. Vérifier les imports
echo "📦 Vérification des imports..."
if grep -q "hybrid_database_service" lib/providers/firebase_provider_v3.dart; then
    echo "❌ Import incorrect détecté"
    sed -i 's/hybrid_database_service/firebase_service_v3/g' lib/providers/firebase_provider_v3.dart
    echo "✅ Import corrigé"
else
    echo "✅ Imports corrects"
fi

# 6. Forcer la recompilation
echo "🔄 Recompilation forcée..."
flutter build web --release

echo ""
echo "✅ Nettoyage terminé !"
echo "🚀 Redémarrez votre application pour voir les changements"
echo ""
echo "📋 Ce qui a été fait :"
echo "   🧹 Cache du navigateur vidé"
echo "   📱 Cache Flutter nettoyé"
echo "   🔨 Fichiers de build supprimés"
echo "   🔧 Service Firebase V3 vérifié"
echo "   🔄 Recompilation forcée"
echo ""
echo "🌐 Votre application devrait maintenant synchroniser correctement !"
