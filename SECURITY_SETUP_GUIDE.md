# 🔐 Guide de Configuration de la Sécurité

## Vue d'ensemble

Ce guide vous explique comment configurer la sécurité complète de l'application avec :

- ✅ **Comptes fermés (whitelist)**
- ✅ **Session persistante (une seule connexion par appareil)**
- ✅ **Règles RTDB qui n'autorisent que vos UID**
- ✅ **App Check pour bloquer les appels hors de votre app**

## 📋 Étapes de Configuration

### 1. Créer les Comptes Utilisateurs

1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet
3. Allez dans **Authentication > Users**
4. Cliquez sur **"Add user"**
5. Créez les 3 comptes suivants :

| Email | Mot de passe | Rôle |
|-------|-------------|------|
| `admin@gaec-berard.fr` | `[mot-de-passe-admin]` | Administrateur |
| `pere@gaec-berard.fr` | `[mot-de-passe-pere]` | Utilisateur |
| `frere@gaec-berard.fr` | `[mot-de-passe-frere]` | Utilisateur |

### 2. Configurer la Whitelist

1. Allez dans **Realtime Database**
2. Créez le nœud `allowedUsers`
3. Ajoutez les UID des utilisateurs créés :

```json
{
  "allowedUsers": {
    "UID_ADMIN": true,
    "UID_PERE": true,
    "UID_FRERE": true
  }
}
```

### 3. Déployer les Règles de Sécurité

1. Allez dans **Realtime Database > Rules**
2. Remplacez les règles existantes par le contenu de `firebase_rules_secure.json`
3. Cliquez sur **"Publish"**

### 4. Configurer App Check (Optionnel)

1. Allez dans **App Check** dans la console Firebase
2. Activez App Check pour **Realtime Database**
3. Configurez **reCAPTCHA v3** pour Web
4. Obtenez votre clé reCAPTCHA
5. Mettez à jour le code dans `lib/services/firebase_service_v4.dart` :

```dart
await FirebaseAppCheck.instance.activate(
  webRecaptchaSiteKey: 'VOTRE_CLE_RECAPTCHA_ICI',
);
```

## 🚀 Déploiement

### Script Automatique

```bash
# Rendre le script exécutable
chmod +x scripts/setup_security.sh

# Exécuter la configuration
./scripts/setup_security.sh
```

### Déploiement Manuel

```bash
# Déployer les règles de sécurité
firebase deploy --only database:rules

# Déployer l'application
flutter build web --release
firebase deploy --only hosting
```

## 🔒 Fonctionnalités de Sécurité

### 1. Comptes Fermés
- ✅ Seuls les utilisateurs dans `allowedUsers` peuvent accéder
- ✅ Pas de création de compte depuis l'application
- ✅ Gestion centralisée des accès

### 2. Liaison Appareil Unique
- ✅ Chaque utilisateur ne peut se connecter que sur un seul appareil
- ✅ Device ID stocké dans localStorage
- ✅ Vérification automatique à chaque connexion

### 3. Règles Firebase Strictes
- ✅ Accès refusé par défaut
- ✅ Vérification de la whitelist pour toutes les opérations
- ✅ Protection des données métier

### 4. App Check (Optionnel)
- ✅ Protection contre les scripts externes
- ✅ reCAPTCHA v3 pour Web
- ✅ Vérification d'intégrité

## 🛠️ Gestion des Utilisateurs

### Ajouter un Utilisateur

1. Créer le compte dans Firebase Auth
2. Ajouter l'UID dans `allowedUsers/{uid}: true`
3. L'utilisateur peut maintenant se connecter

### Réinitialiser un Appareil

1. Supprimer `userDevices/{uid}/primaryDeviceId`
2. L'utilisateur peut se reconnecter sur un nouvel appareil

### Retirer un Utilisateur

1. Supprimer l'entrée dans `allowedUsers`
2. L'utilisateur ne peut plus accéder à l'application

## 🔧 Dépannage

### Problème : "Compte non autorisé"
- Vérifiez que l'UID est dans `allowedUsers`
- Vérifiez que l'utilisateur est bien connecté

### Problème : "Appareil déjà lié"
- L'utilisateur est déjà connecté sur un autre appareil
- Supprimez `userDevices/{uid}/primaryDeviceId` pour réinitialiser

### Problème : "Erreur de connexion"
- Vérifiez les règles Firebase
- Vérifiez que l'utilisateur existe dans Auth
- Vérifiez la configuration App Check

## 📱 Test de la Sécurité

1. **Test de connexion** : Connectez-vous avec un compte autorisé
2. **Test de liaison** : Essayez de vous connecter sur un autre appareil
3. **Test de whitelist** : Créez un compte non autorisé et essayez de vous connecter
4. **Test de déconnexion** : Vérifiez que la déconnexion fonctionne

## 🎯 Avantages de cette Configuration

- ✅ **Sécurité maximale** : Accès restreint aux membres autorisés
- ✅ **Simplicité** : Pas de gestion complexe des rôles
- ✅ **Contrôle total** : Gestion centralisée des accès
- ✅ **Protection des données** : Règles strictes sur toutes les opérations
- ✅ **Facilité de maintenance** : Ajout/suppression d'utilisateurs simple

## 📞 Support

En cas de problème :

1. Vérifiez les logs de la console Firebase
2. Vérifiez les règles de sécurité
3. Testez la connexion avec un compte autorisé
4. Vérifiez la configuration App Check

---

**Note** : Cette configuration est optimale pour une équipe de 3-5 personnes avec des besoins de sécurité élevés et une gestion simple des accès.
