#!/bin/bash

# Script pour forcer la synchronisation et vider le cache

echo "🔄 Forçage de la synchronisation et nettoyage du cache..."

# 1. Vider complètement le cache du navigateur
echo "🧹 Nettoyage complet du cache du navigateur..."

# Chrome/Chromium
if command -v google-chrome &> /dev/null; then
    echo "🌐 Nettoyage Chrome..."
    google-chrome --clear-cache --clear-storage --clear-app-cache --disable-web-security --user-data-dir=/tmp/chrome-cache-clear 2>/dev/null &
    sleep 2
    pkill -f chrome
fi

# Firefox
if command -v firefox &> /dev/null; then
    echo "🦊 Nettoyage Firefox..."
    firefox -new-instance -P "default" -no-remote -silent 2>/dev/null &
    sleep 2
    pkill -f firefox
fi

# 2. Supprimer les données localStorage
echo "💾 Suppression des données localStorage..."
rm -rf ~/.cache/chromium/Default/Local\ Storage/
rm -rf ~/.cache/google-chrome/Default/Local\ Storage/
rm -rf ~/.mozilla/firefox/*/storage/

# 3. Nettoyer le cache Flutter
echo "📱 Nettoyage Flutter..."
flutter clean
flutter pub get

# 4. Rebuild complet
echo "🔨 Rebuild complet..."
rm -rf build/
flutter build web --release

# 5. Créer un fichier de version pour forcer le refresh
echo "📝 Création d'un fichier de version..."
echo "Version: $(date +%s)" > build/web/version.txt

# 6. Instructions pour l'utilisateur
echo ""
echo "✅ Nettoyage terminé !"
echo ""
echo "📋 Instructions pour forcer la synchronisation :"
echo "   1. Ouvrez votre navigateur en mode privé/incognito"
echo "   2. Allez sur votre application web"
echo "   3. Ouvrez les outils de développement (F12)"
echo "   4. Allez dans l'onglet 'Application' ou 'Storage'"
echo "   5. Supprimez toutes les données localStorage et sessionStorage"
echo "   6. Rechargez la page (Ctrl+F5 ou Cmd+Shift+R)"
echo ""
echo "🔧 Si le problème persiste :"
echo "   - Videz complètement le cache du navigateur"
echo "   - Redémarrez le navigateur"
echo "   - Testez sur un autre navigateur"
echo ""
echo "🌐 L'application devrait maintenant synchroniser correctement entre tous les appareils !"
