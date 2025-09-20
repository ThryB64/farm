#!/usr/bin/env bash

echo "🚀 Test de tous les builds"
echo "========================="

# Nettoyer
echo "🧹 Nettoyage..."
flutter clean
flutter pub get

# Test 1: Build Web (PWA pour iOS)
echo "🌐 Test build Web PWA..."
flutter build web --release
if [ $? -eq 0 ]; then
    echo "✅ Build Web réussi"
else
    echo "❌ Build Web échoué"
fi

# Test 2: Build Linux
echo "🐧 Test build Linux..."
flutter build linux --release
if [ $? -eq 0 ]; then
    echo "✅ Build Linux réussi"
else
    echo "❌ Build Linux échoué"
fi

# Test 3: Build Windows
echo "🪟 Test build Windows..."
flutter build windows --release
if [ $? -eq 0 ]; then
    echo "✅ Build Windows réussi"
else
    echo "❌ Build Windows échoué"
fi

# Test 4: Build iOS (avec configuration Altstore)
echo "📱 Test build iOS pour Altstore..."
./scripts/build_ios_altstore.sh
if [ $? -eq 0 ]; then
    echo "✅ Build iOS réussi"
else
    echo "❌ Build iOS échoué"
fi

echo ""
echo "📊 Résumé des builds :"
echo "======================"
echo "🌐 Web PWA: $(test -f build/web/index.html && echo "✅ Réussi" || echo "❌ Échoué")"
echo "🐧 Linux: $(test -d build/linux/x64/release/bundle && echo "✅ Réussi" || echo "❌ Échoué")"
echo "🪟 Windows: $(test -d build/windows/runner/Release && echo "✅ Réussi" || echo "❌ Échoué")"
echo "📱 iOS: $(test -f mais-tracker.ipa && echo "✅ Réussi" || echo "❌ Échoué")"

echo ""
echo "🎯 Solutions pour iOS :"
echo "======================="
echo "1. 📱 Altstore: Utilisez mais-tracker.ipa"
echo "2. 🌐 PWA: Ouvrez build/web/index.html dans Safari"
echo "3. 📲 Installation PWA: Ajoutez à l'écran d'accueil depuis Safari"
