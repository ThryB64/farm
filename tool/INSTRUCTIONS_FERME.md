# Instructions pour créer une nouvelle ferme dans Firebase

## 🚀 Étape 1 : Exécuter le script d'initialisation

Pour créer la ferme `agricorn_demo` dans Firebase, exécutez :

```bash
cd "/home/cytech/Info/devweb/app final"
dart run tool/init_farm.dart
```

Ce script va :
- ✅ Créer la structure vide de la ferme `agricorn_demo`
- ✅ Supprimer la ferme si elle existe déjà (pour repartir à zéro)

## 👤 Étape 2 : Créer un utilisateur dans Firebase Authentication

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet (`farmgaec`)
3. Allez dans **Authentication** → **Users**
4. Cliquez sur **Add user**
5. Entrez l'email et le mot de passe de l'utilisateur
6. **Copiez l'UID** de l'utilisateur créé (important !)

## 🔗 Étape 3 : Assigner l'utilisateur à la ferme

Dans Firebase Realtime Database, ajoutez les données suivantes :

### Structure à créer :

```
userFarms/
  └── {UID_UTILISATEUR}/
      └── farmId = "agricorn_demo"

farmMembers/
  └── agricorn_demo/
      └── {UID_UTILISATEUR} = true

allowedUsers/
  └── {UID_UTILISATEUR} = true
```

### Comment faire :

1. Allez dans **Realtime Database** dans Firebase Console
2. Cliquez sur l'icône **+** pour ajouter un nœud
3. Créez la structure suivante :

**Nœud 1 : `userFarms/{UID}/farmId`**
- Clé : `userFarms`
- Sous-clé : `{UID_UTILISATEUR}` (remplacez par l'UID réel)
- Sous-sous-clé : `farmId`
- Valeur : `"agricorn_demo"` (type String)

**Nœud 2 : `farmMembers/agricorn_demo/{UID}`**
- Clé : `farmMembers`
- Sous-clé : `agricorn_demo`
- Sous-sous-clé : `{UID_UTILISATEUR}` (remplacez par l'UID réel)
- Valeur : `true` (type Boolean)

**Nœud 3 : `allowedUsers/{UID}`**
- Clé : `allowedUsers`
- Sous-clé : `{UID_UTILISATEUR}` (remplacez par l'UID réel)
- Valeur : `true` (type Boolean)

## ✅ Vérification

Une fois configuré, l'utilisateur peut :
1. Se connecter avec son email/mot de passe
2. Accéder automatiquement uniquement aux données de la ferme `agricorn_demo`
3. Ne pas voir les données des autres fermes (comme `gaec_berard`)

## 📝 Notes importantes

- Chaque utilisateur ne peut être assigné qu'à **une seule ferme**
- La ferme est déterminée automatiquement lors de la connexion
- Si un utilisateur n'a pas de ferme assignée, il ne pourra pas se connecter
- Les données de chaque ferme sont complètement isolées

## 🔄 Pour créer d'autres fermes

1. Modifiez le script `init_farm.dart` pour changer le `farmId`
2. Ou créez manuellement la structure dans Firebase Database
3. Assignez les utilisateurs à leur ferme respective via `userFarms`

