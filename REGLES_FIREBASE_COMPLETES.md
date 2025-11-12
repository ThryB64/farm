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
      "$farmId": {
        ".read": "auth != null && root.child('farms').child($farmId).child('allowedUsers').child(auth.uid).val() === true",
        ".write": "auth != null && root.child('farms').child($farmId).child('allowedUsers').child(auth.uid).val() === true",
        "allowedUsers": {
          "$uid": {
            ".read": "auth != null && root.child('farms').child($farmId).child('allowedUsers').child(auth.uid).val() === true",
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

### 1. `farms/{farmId}` (nœud dynamique pour chaque ferme)
- **Lecture** : Un utilisateur authentifié peut lire uniquement si `farms/{farmId}/allowedUsers/{uid}` existe et vaut `true`
- **Écriture** : Même condition pour l'écriture
- **Usage** : Protège toutes les données de la ferme (parcelles, cellules, chargements, etc.)

### 2. `farms/{farmId}/allowedUsers/{uid}`
- **Lecture** : Les utilisateurs autorisés peuvent voir la liste des utilisateurs autorisés
- **Écriture** : Les utilisateurs autorisés peuvent ajouter/modifier des utilisateurs autorisés
- **Usage** : Stocke les utilisateurs autorisés dans `farms/{farmId}/allowedUsers/{uid} = true`

### 3. `userDevices/{uid}`
- **Lecture** : Un utilisateur peut lire uniquement ses propres informations d'appareil
- **Écriture** : Un utilisateur peut modifier uniquement ses propres informations d'appareil
- **Usage** : Gestion de la liaison appareil unique

## 🔍 Exemple de structure protégée

Avec ces règles, la structure suivante est protégée :

```
farms/
  └── agricorn_demo/
      ├── allowedUsers/
      │   └── C6PPci3ca3TarM6SDMqli7mk2uh1: true
      ├── parcelles: {...}
      ├── cellules: {...}
      ├── chargements: {...}
      └── ...
```

## ⚠️ Important

- **Plus besoin de `userFarms`** : L'association utilisateur-ferme se fait directement via `farms/{farmId}/allowedUsers/{uid}`
- Les règles utilisent `$farmId` comme variable dynamique qui correspond à n'importe quel nom de ferme dans `farms/`
- Chaque utilisateur ne peut accéder qu'aux données de la ferme où il est dans `allowedUsers`
- La vérification se fait directement via `farms/{farmId}/allowedUsers/{auth.uid}`
- Les utilisateurs non authentifiés ne peuvent rien lire ni écrire

## 🧪 Test des règles

Pour tester si les règles fonctionnent :

1. **Utilisateur authentifié dans `allowedUsers`** : ✅ Peut lire/écrire dans sa ferme
2. **Utilisateur authentifié pas dans `allowedUsers`** : ❌ Ne peut rien lire/écrire
3. **Utilisateur authentifié dans une autre ferme** : ❌ Ne peut pas accéder aux données d'une autre ferme
4. **Utilisateur non authentifié** : ❌ Ne peut rien faire

## 📝 Migration depuis l'ancienne structure

Si vous aviez `userFarms/{uid}/farmId`, vous pouvez :
1. **Supprimer `userFarms`** complètement
2. **Vérifier** que tous les utilisateurs sont dans `farms/{farmId}/allowedUsers/{uid} = true`
3. **Tester** que l'application fonctionne correctement
