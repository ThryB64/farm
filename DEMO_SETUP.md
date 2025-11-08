# Configuration de la Ferme de Démonstration

## Vue d'ensemble

L'application AgriCorn supporte maintenant une ferme de démonstration complètement séparée de la ferme réelle. Cette ferme utilise un utilisateur démo dédié et des données isolées dans Firebase.

## Configuration

### 1. Créer l'utilisateur démo dans Firebase

1. Allez dans la console Firebase : https://console.firebase.google.com
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Users**
4. Cliquez sur **Add user**
5. Créez un utilisateur avec :
   - **Email** : `demo@agricorn.app`
   - **Password** : (choisissez un mot de passe sécurisé)
6. Notez l'UID de cet utilisateur

### 2. Ajouter l'utilisateur à la whitelist

1. Dans Firebase Realtime Database, allez dans la section `allowedUsers`
2. Ajoutez l'UID de l'utilisateur démo :
   ```
   allowedUsers/
     [UID_DEMO_USER]: true
   ```

### 3. Initialisation automatique de la ferme de démo

**La ferme de démonstration sera créée automatiquement lors de la première connexion de l'utilisateur démo.**

Lorsque l'utilisateur `demo@agricorn.app` se connecte pour la première fois, l'application :
- Détecte automatiquement qu'il s'agit de l'utilisateur démo
- Vérifie si la ferme `agricorn_demo` existe déjà
- Si elle n'existe pas, crée automatiquement toutes les données de démonstration :
  - 3 variétés de maïs (DK 391, Pioneer P1234, LG 30.222)
  - 3 parcelles (Nord, Sud, Est)
  - 3 cellules de stockage
  - Semis associés
  - Chargements de maïs
  - Produits de traitement
  - Traitements effectués
  - Ventes réalisées

**Aucune action manuelle n'est nécessaire** - la ferme de démo est créée automatiquement !

### 4. Ajouter l'utilisateur comme membre de la ferme

Dans Firebase Realtime Database :

```
farmMembers/
  agricorn_demo/
    [UID_DEMO_USER]: true
```

## Fonctionnement

- **Utilisateur réel** : Se connecte avec son email normal → Accède à `farms/gaec_berard`
- **Utilisateur démo** : Se connecte avec `demo@agricorn.app` → Accède automatiquement à `farms/agricorn_demo`

Le système détecte automatiquement l'utilisateur démo par son email et utilise la ferme de démonstration correspondante. Aucune sélection manuelle n'est nécessaire.

## Sécurité

- Les données de la ferme réelle (`gaec_berard`) et de la ferme de démo (`agricorn_demo`) sont complètement isolées
- L'utilisateur démo ne peut accéder qu'à la ferme de démonstration
- Les utilisateurs réels ne peuvent pas accéder à la ferme de démonstration

## Notes

- **Les données de démonstration sont créées automatiquement** lors de la première connexion de l'utilisateur démo
- L'email de l'utilisateur démo est codé en dur : `demo@agricorn.app`
- Pour changer l'email de l'utilisateur démo, modifier la constante `_demoUserEmail` dans `lib/services/firebase_service_v4.dart`
- Si vous souhaitez réinitialiser la ferme de démo, supprimez le nœud `farms/agricorn_demo` dans Firebase et reconnectez-vous avec l'utilisateur démo

