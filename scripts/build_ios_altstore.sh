#!/usr/bin/env bash

echo "🚀 Build iOS pour Altstore"
echo "=========================="

# Nettoyer le projet
echo "🧹 Nettoyage..."
flutter clean
flutter pub get

# Configurer pour Altstore (pas de signature)
echo "⚙️ Configuration pour Altstore..."

# Modifier le projet Xcode pour désactiver la signature
cd ios
sed -i 's/CODE_SIGN_IDENTITY = "iPhone Developer";/CODE_SIGN_IDENTITY = "";/g' Runner.xcodeproj/project.pbxproj
sed -i 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' Runner.xcodeproj/project.pbxproj
sed -i 's/PROVISIONING_PROFILE_SPECIFIER = "";/PROVISIONING_PROFILE_SPECIFIER = "";/g' Runner.xcodeproj/project.pbxproj
cd ..

# Build iOS sans signature
echo "📱 Build iOS..."
flutter build ios

# Créer l'IPA pour Altstore
echo "📦 Création de l'IPA..."
cd build/ios/iphoneos
mkdir -p Payload
cp -r Runner.app Payload/
zip -r ../../../mais-tracker.ipa Payload/
cd ../../..

echo "✅ Build terminé !"
echo "📁 Fichiers générés :"
echo "   - build/ios/iphoneos/Runner.app"
echo "   - mais-tracker.ipa"
echo ""
echo "🚀 Pour installer avec Altstore :"
echo "   1. Téléchargez mais-tracker.ipa"
echo "   2. Ouvrez Altstore"
echo "   3. Glissez-déposez l'IPA dans Altstore"
echo "   4. Installez sur votre iPhone"
