# 🔒 Règles de sécurité Firebase Realtime Database - Version complète

## 📋 Structure de données

La base de données utilise la structure suivante :
- `farms/{farmId}/` (ex: `farms/agricorn_demo/`, `farms/gaec_berard/`)
- Les utilisateurs autorisés sont dans `farms/{farmId}/allowedUsers/{uid} = true`
- **Plus besoin de `userFarms`** - l'association se fait directement via `allowedUsers`

## ✅ Règles complètes à copier dans Firebase Console

Copiez-collez ces règles dans **Firebase Console → Realtime Database → Règles** :

```json
{
  "rules": {
    "farms": {
      ".read": "auth != null",
      "$farmId": {
        ".read": "auth != null && root.child('farms').child($farmId).child('allowedUsers').child(auth.uid).val() === true",
        ".write": "auth != null && root.child('farms').child($farmId).child('allowedUsers').child(auth.uid).val() === true",
        "allowedUsers": {
          ".read": "auth != null",
          "$uid": {
            ".read": "auth != null",
            ".write": "auth != null && root.child('farms').child($farmId).child('allowedUsers').child(auth.uid).val() === true"
          }
        }
      }
    },
    "userDevices": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

## 📖 Explication des règles

### 1. `farms` (niveau racine)
- **Lecture** : Tous les utilisateurs authentifiés peuvent lire la liste des fermes
- **Usage** : Nécessaire pour que l'application puisse parcourir `farms` et trouver dans quelle ferme l'utilisateur est dans `allowedUsers`

### 2. `farms/{farmId}/allowedUsers`
- **Lecture** : Tous les utilisateurs authentifiés peuvent lire `allowedUsers`
- **Usage** : Nécessaire pour vérifier si un utilisateur est dans `allowedUsers` avant d'accéder aux données

### 3. `farms/{farmId}/allowedUsers/{uid}`
- **Lecture** : Tous les utilisateurs authentifiés peuvent lire (pour vérification)
- **Écriture** : Seuls les utilisateurs déjà dans `allowedUsers` peuvent ajouter d'autres utilisateurs
- **Usage** : Stocke les utilisateurs autorisés dans `farms/{farmId}/allowedUsers/{uid} = true`

### 4. `farms/{farmId}` (données de la ferme)
- **Lecture** : Uniquement si l'utilisateur est dans `allowedUsers` de cette ferme
- **Écriture** : Uniquement si l'utilisateur est dans `allowedUsers` de cette ferme
- **Usage** : Protège toutes les données de la ferme (parcelles, cellules, chargements, etc.)

### 5. `userDevices/{uid}`
- **Lecture** : Un utilisateur peut lire uniquement ses propres informations d'appareil
- **Écriture** : Un utilisateur peut modifier uniquement ses propres informations d'appareil
- **Usage** : Gestion de la liaison appareil unique

## 🔍 Exemple de structure protégée

Avec ces règles, la structure suivante est protégée :

```
farms/
  └── agricorn_demo/
      ├── allowedUsers/
      │   └── C6PPci3ca3TarM6SDMqli7mk2uh1: true  ← Lisible par tous les auth
      ├── parcelles: {...}  ← Lisible uniquement si dans allowedUsers
      ├── cellules: {...}  ← Lisible uniquement si dans allowedUsers
      ├── chargements: {...}
      └── ...
```

## ⚠️ Important

- **`farms` et `farms/{farmId}/allowedUsers` sont lisibles** : Nécessaire pour que l'application puisse trouver dans quelle ferme l'utilisateur est autorisé
- **Les données de la ferme sont protégées** : Seuls les utilisateurs dans `allowedUsers` peuvent y accéder
- **Plus besoin de `userFarms`** : L'association utilisateur-ferme se fait directement via `farms/{farmId}/allowedUsers/{uid}`
- Les utilisateurs non authentifiés ne peuvent rien lire ni écrire

## 🧪 Test des règles

Pour tester si les règles fonctionnent :

1. **Utilisateur authentifié dans `allowedUsers`** : ✅ Peut lire/écrire dans sa ferme
2. **Utilisateur authentifié pas dans `allowedUsers`** : ✅ Peut lire `farms` et `allowedUsers` (pour vérification), ❌ Ne peut pas lire les données
3. **Utilisateur authentifié dans une autre ferme** : ❌ Ne peut pas accéder aux données d'une autre ferme
4. **Utilisateur non authentifié** : ❌ Ne peut rien faire

## 📝 Migration depuis l'ancienne structure

Si vous aviez `userFarms/{uid}/farmId`, vous pouvez :
1. **Supprimer `userFarms`** complètement
2. **Vérifier** que tous les utilisateurs sont dans `farms/{farmId}/allowedUsers/{uid} = true`
3. **Tester** que l'application fonctionne correctement
