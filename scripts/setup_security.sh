#!/bin/bash

# Script de configuration de la sécurité Firebase
# Ce script configure la whitelist et les règles de sécurité

echo "🔐 Configuration de la sécurité Firebase..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Vérifier que Firebase CLI est installé
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI n'est pas installé. Installez-le avec: npm install -g firebase-tools"
    exit 1
fi

# Vérifier que l'utilisateur est connecté à Firebase
if ! firebase projects:list &> /dev/null; then
    print_error "Vous n'êtes pas connecté à Firebase. Connectez-vous avec: firebase login"
    exit 1
fi

print_info "Configuration de la sécurité pour le projet Firebase..."

# 1. Déployer les règles de sécurité
print_info "Déploiement des règles de sécurité..."
if firebase deploy --only database:rules; then
    print_success "Règles de sécurité déployées avec succès"
else
    print_error "Échec du déploiement des règles de sécurité"
    exit 1
fi

# 2. Instructions pour créer les comptes utilisateurs
print_info "Étapes suivantes à effectuer manuellement:"
echo ""
print_warning "1. Créer les comptes utilisateurs dans Firebase Console:"
echo "   - Allez sur https://console.firebase.google.com"
echo "   - Sélectionnez votre projet"
echo "   - Allez dans Authentication > Users"
echo "   - Cliquez sur 'Add user'"
echo "   - Créez les comptes suivants:"
echo "     • admin@gaec-berard.fr"
echo "     • pere@gaec-berard.fr" 
echo "     • frere@gaec-berard.fr"
echo ""

print_warning "2. Ajouter les utilisateurs à la whitelist:"
echo "   - Allez dans Realtime Database"
echo "   - Créez le nœud 'allowedUsers'"
echo "   - Ajoutez les UID des utilisateurs créés:"
echo "     • allowedUsers/{uid_admin}: true"
echo "     • allowedUsers/{uid_pere}: true"
echo "     • allowedUsers/{uid_frere}: true"
echo ""

print_warning "3. Configurer App Check:"
echo "   - Allez dans App Check dans la console Firebase"
echo "   - Activez App Check pour Realtime Database"
echo "   - Configurez reCAPTCHA v3 pour Web"
echo "   - Obtenez votre clé reCAPTCHA et mettez-la à jour dans le code"
echo ""

print_warning "4. Mettre à jour la clé reCAPTCHA dans le code:"
echo "   - Ouvrez lib/services/firebase_service_v4.dart"
echo "   - Remplacez '6LfXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' par votre vraie clé"
echo ""

print_success "Configuration de base terminée !"
print_info "Suivez les étapes manuelles ci-dessus pour finaliser la configuration."
