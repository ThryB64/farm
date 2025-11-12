# 🔗 Associer un utilisateur à une ferme dans Firebase

## 📋 Informations nécessaires

D'après le diagnostic, vous avez :
- **UID utilisateur** : `C6PPci3ca3TarM6SDMqli7mk2uh1`
- **Email** : `thierryber64@gmail.com`

## ✅ Solution : Configuration manuelle dans Firebase Console

### Étape 1 : Ouvrir Firebase Console

1. Allez sur [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Sélectionnez votre projet : **`farmgaec`**
3. Allez dans **Realtime Database**

### Étape 2 : Créer la ferme (si elle n'existe pas)

1. Dans l'arborescence de la base de données, cliquez sur **`farms`**
2. Si la ferme `agricorn_demo` n'existe pas, créez-la :
   - Cliquez sur le bouton **`+`** à côté de `farms`
   - Clé : `agricorn_demo`
   - Type : **objet**
   - Cliquez sur **Ajouter**

3. À l'intérieur de `farms/agricorn_demo`, créez la structure suivante :
   ```
   farms/
     └── agricorn_demo/
         ├── parcelles: {}
         ├── cellules: {}
         ├── chargements: {}
         ├── semis: {}
         ├── varietes: {}
         ├── traitements: {}
         ├── ventes: {}
         └── produits: {}
   ```

### Étape 3 : Associer l'utilisateur à la ferme

1. **Créer `userFarms/{uid}/farmId`** :
   - Cliquez sur le bouton **`+`** à la racine
   - Clé : `userFarms`
   - Type : **objet**
   - Cliquez sur **Ajouter**
   
   - À l'intérieur de `userFarms`, cliquez sur **`+`**
   - Clé : `C6PPci3ca3TarM6SDMqli7mk2uh1` (votre UID)
   - Type : **objet**
   - Cliquez sur **Ajouter**
   
   - À l'intérieur de `userFarms/C6PPci3ca3TarM6SDMqli7mk2uh1`, cliquez sur **`+`**
   - Clé : `farmId`
   - Type : **string**
   - Valeur : `agricorn_demo`
   - Cliquez sur **Ajouter**

2. **Créer `farmMembers/{farmId}/{uid}`** :
   - À la racine, créez `farmMembers` (si n'existe pas)
   - À l'intérieur de `farmMembers`, créez `agricorn_demo` (si n'existe pas)
   - À l'intérieur de `farmMembers/agricorn_demo`, cliquez sur **`+`**
   - Clé : `C6PPci3ca3TarM6SDMqli7mk2uh1`
   - Type : **boolean**
   - Valeur : `true`
   - Cliquez sur **Ajouter**

3. **Créer `allowedUsers/{uid}`** :
   - À la racine, créez `allowedUsers` (si n'existe pas)
   - À l'intérieur de `allowedUsers`, cliquez sur **`+`**
   - Clé : `C6PPci3ca3TarM6SDMqli7mk2uh1`
   - Type : **boolean**
   - Valeur : `true`
   - Cliquez sur **Ajouter**

### Étape 4 : Vérification

La structure finale doit ressembler à ceci :

```
userFarms/
  └── C6PPci3ca3TarM6SDMqli7mk2uh1/
      └── farmId: "agricorn_demo"

farmMembers/
  └── agricorn_demo/
      └── C6PPci3ca3TarM6SDMqli7mk2uh1: true

allowedUsers/
  └── C6PPci3ca3TarM6SDMqli7mk2uh1: true

farms/
  └── agricorn_demo/
      ├── parcelles: {}
      ├── cellules: {}
      ├── chargements: {}
      ├── semis: {}
      ├── varietes: {}
      ├── traitements: {}
      ├── ventes: {}
      └── produits: {}
```

## 🎉 Après configuration

1. **Rafraîchissez l'application** dans le navigateur (F5)
2. **Reconnectez-vous** si nécessaire
3. **Cliquez sur "Diagnostic"** pour vérifier :
   - `Farm ID (userFarms)` devrait maintenant afficher `agricorn_demo`
   - `Ferme existe` devrait être `true`
4. **Cliquez sur "Rafraîchir les données"** pour charger les données

## 📝 Note

Si vous avez déjà des données dans Firebase que vous voulez restaurer, vous pouvez :
1. Les importer via l'écran "Import/Export" de l'application
2. Ou les copier directement dans `farms/agricorn_demo/` dans Firebase Console

