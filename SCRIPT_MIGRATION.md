# 🔄 Script de migration vers la nouvelle structure

## 📋 Ce qui change

### Avant (ancienne structure)
```
farmMembers/{farmId}/{uid} = true
allowedUsers/{uid} = true
```

### Après (nouvelle structure)
```
farms/{farmId}/membres/{uid} = {
  email: "...",
  role: "member",
  addedAt: timestamp
}
```

## 🛠️ Migration manuelle dans Firebase Console

### Étape 1 : Migrer les membres

Pour chaque ferme dans `farmMembers` :

1. Ouvrez Firebase Console → Realtime Database
2. Pour chaque `farmMembers/{farmId}/{uid}` :
   - Notez le `farmId` et l'`uid`
   - Allez dans `farms/{farmId}/membres`
   - Créez un nouveau nœud avec la clé `{uid}`
   - Ajoutez les valeurs :
     ```json
     {
       "email": "user@example.com",  // Récupérez depuis Authentication
       "role": "member",
       "addedAt": 1234567890  // timestamp actuel
     }
     ```

### Étape 2 : Supprimer les anciens nœuds

Une fois la migration terminée :

1. Supprimez `farmMembers` (tout le nœud)
2. Supprimez `allowedUsers` (tout le nœud)

### Étape 3 : Mettre à jour les règles de sécurité

1. Allez dans Realtime Database → **Règles**
2. Remplacez par les nouvelles règles (voir `database.rules.json`)

## ✅ Vérification

Après migration, vérifiez que :
- ✅ `userFarms/{uid}/farmId` existe toujours
- ✅ `farms/{farmId}/membres/{uid}` existe avec les bonnes données
- ✅ `farmMembers` n'existe plus
- ✅ `allowedUsers` n'existe plus
- ✅ Les règles de sécurité sont mises à jour

## 🎯 Structure finale attendue

```
userFarms/
  └── {uid}/
      └── farmId: "{farmId}"

farms/
  └── {farmId}/
      ├── membres/
      │   └── {uid}: {
      │       ├── email: "..."
      │       ├── role: "member"
      │       └── addedAt: timestamp
      │   }
      ├── parcelles: {}
      ├── cellules: {}
      ├── chargements: {}
      ├── semis: {}
      ├── varietes: {}
      ├── traitements: {}
      ├── ventes: {}
      └── produits: {}
```

