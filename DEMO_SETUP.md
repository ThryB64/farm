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

### 3. Créer la structure de données de démo

Dans Firebase Realtime Database, créez la structure suivante :

```
farms/
  agricorn_demo/
    parcelles/
      (données de démonstration)
    cellules/
      (données de démonstration)
    chargements/
      (données de démonstration)
    semis/
      (données de démonstration)
    varietes/
      (données de démonstration)
    ventes/
      (données de démonstration)
    traitements/
      (données de démonstration)
    produits/
      (données de démonstration)
```

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

- Les données de démonstration doivent être pré-remplies dans Firebase
- L'email de l'utilisateur démo est codé en dur : `demo@agricorn.app`
- Pour changer l'email de l'utilisateur démo, modifier la constante `_demoUserEmail` dans `lib/services/firebase_service_v4.dart`

