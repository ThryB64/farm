#!/bin/bash

# Script pour ajouter un utilisateur à la whitelist
# Usage: ./add_user.sh "email@example.com" "motdepasse"

echo "🔐 Ajout d'un utilisateur à la whitelist..."

if [ $# -ne 2 ]; then
    echo "Usage: $0 <email> <motdepasse>"
    echo "Exemple: $0 thierryber64@gmail.com Thierry64530*"
    exit 1
fi

EMAIL="$1"
PASSWORD="$2"

echo "📧 Email: $EMAIL"
echo "🔑 Mot de passe: [masqué]"

echo ""
echo "📋 Étapes à suivre manuellement :"
echo ""
echo "1. Allez sur https://console.firebase.google.com"
echo "2. Sélectionnez votre projet"
echo "3. Allez dans Authentication > Users"
echo "4. Cliquez sur 'Add user'"
echo "5. Entrez l'email: $EMAIL"
echo "6. Entrez le mot de passe: $PASSWORD"
echo "7. Cliquez sur 'Add user'"
echo "8. Copiez l'UID de l'utilisateur créé"
echo ""
echo "9. Allez dans Realtime Database"
echo "10. Créez le nœud 'allowedUsers' s'il n'existe pas"
echo "11. Ajoutez: allowedUsers/{UID}: true"
echo ""
echo "✅ Une fois terminé, l'utilisateur pourra se connecter à l'application !"
