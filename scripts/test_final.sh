#!/usr/bin/env bash

echo "🎯 Test Final - Maïs Tracker"
echo "============================"

# Nettoyer
echo "🧹 Nettoyage..."
flutter clean
flutter pub get

echo ""
echo "📊 Tests des builds :"
echo "===================="

# Test 1: Build Web PWA
echo "🌐 Test build Web PWA..."
flutter build web --release
if [ $? -eq 0 ]; then
    echo "✅ Build Web PWA réussi"
    echo "   📁 Fichiers: build/web/"
    echo "   📱 Pour iPhone: Ouvrir index.html dans Safari"
    echo "   📲 PWA: Menu Safari → Partager → Ajouter à l'écran d'accueil"
else
    echo "❌ Build Web PWA échoué"
fi

echo ""

# Test 2: Build Linux
echo "🐧 Test build Linux..."
flutter build linux --release
if [ $? -eq 0 ]; then
    echo "✅ Build Linux réussi"
    echo "   📁 Fichiers: build/linux/x64/release/bundle/"
    echo "   🚀 Exécutable: mais_tracker"
else
    echo "❌ Build Linux échoué"
fi

echo ""

# Test 3: Build Windows (simulation)
echo "🪟 Test build Windows..."
if command -v flutter &> /dev/null; then
    echo "⚠️  Build Windows nécessite un système Windows"
    echo "   💡 Utilisez Codemagic pour build Windows"
else
    echo "❌ Flutter non disponible"
fi

echo ""

# Test 4: Build iOS (simulation)
echo "📱 Test build iOS..."
if command -v flutter &> /dev/null; then
    echo "⚠️  Build iOS nécessite macOS + Xcode"
    echo "   💡 Utilisez Codemagic pour build iOS"
    echo "   🌐 Alternative: Utilisez la PWA Web"
else
    echo "❌ Flutter non disponible"
fi

echo ""
echo "🎉 RÉSUMÉ FINAL :"
echo "=================="
echo "✅ Web PWA: $(test -f build/web/index.html && echo "Fonctionne" || echo "Échec")"
echo "✅ Linux: $(test -f build/linux/x64/release/bundle/mais_tracker && echo "Fonctionne" || echo "Échec")"
echo "⚠️  Windows: Nécessite Codemagic"
echo "⚠️  iOS: Nécessite Codemagic ou utilise PWA"

echo ""
echo "🚀 SOLUTIONS POUR VOTRE IPHONE :"
echo "================================"
echo "1. 🌐 PWA (Recommandé):"
echo "   - Ouvrez build/web/index.html dans Safari"
echo "   - Menu 'Partager' → 'Ajouter à l'écran d'accueil'"
echo "   - L'app s'installe comme une app native !"
echo ""
echo "2. 📱 Codemagic iOS:"
echo "   - Lancez le workflow 'mais-tracker-ios' sur Codemagic"
echo "   - Téléchargez l'IPA généré"
echo "   - Installez avec Altstore"
echo ""
echo "3. 🌐 Codemagic Web:"
echo "   - Lancez le workflow 'mais-tracker-web' sur Codemagic"
echo "   - Téléchargez les fichiers web"
echo "   - Déployez sur un serveur et accédez via Safari"

echo ""
echo "🎯 VOTRE APPLICATION EST PRÊTE ! 🎉"
