# 🔒 Configuration des règles de sécurité Firebase

## ⚠️ Problème actuel

L'erreur **"Permission denied"** indique que les règles de sécurité Firebase Realtime Database bloquent l'accès aux données.

## ✅ Solution : Configurer les règles de sécurité

### Méthode 1 : Via la Console Firebase (Recommandé)

1. **Ouvrez la Console Firebase** : [https://console.firebase.google.com/](https://console.firebase.google.com/)

2. **Sélectionnez votre projet** : `farmgaec`

3. **Allez dans Realtime Database** → **Règles** (onglet en haut)

4. **Remplacez les règles existantes** par le contenu suivant :

```json
{
  "rules": {
    "userFarms": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "farmMembers": {
      "$farmId": {
        ".read": "auth != null && root.child('userFarms').child(auth.uid).child('farmId').val() === $farmId",
        ".write": "auth != null && root.child('userFarms').child(auth.uid).child('farmId').val() === $farmId"
      }
    },
    "farms": {
      "$farmId": {
        ".read": "auth != null && root.child('userFarms').child(auth.uid).child('farmId').val() === $farmId",
        ".write": "auth != null && root.child('userFarms').child(auth.uid).child('farmId').val() === $farmId"
      }
    },
    "allowedUsers": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('allowedUsers').child(auth.uid).val() === true",
        ".write": "auth != null && (root.child('allowedUsers').child(auth.uid).child('admin').val() === true || $uid === auth.uid)"
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

5. **Cliquez sur "Publier"** pour sauvegarder les règles

### Méthode 2 : Via Firebase CLI (Avancé)

Si vous avez Firebase CLI installé :

```bash
firebase deploy --only database
```

## 📋 Explication des règles

- **userFarms** : Les utilisateurs peuvent lire/écrire uniquement leur propre association ferme
- **farmMembers** : Les utilisateurs peuvent accéder uniquement aux membres de leur ferme
- **farms** : Les utilisateurs peuvent accéder uniquement aux données de leur ferme assignée
- **allowedUsers** : Système de whitelist pour les utilisateurs autorisés
- **userDevices** : Les utilisateurs peuvent gérer uniquement leur propre liaison d'appareil

## 🔍 Vérification

Après avoir configuré les règles :

1. **Rafraîchissez l'application** dans le navigateur
2. **Reconnectez-vous** si nécessaire
3. **Cliquez sur "Diagnostic"** pour vérifier que l'erreur "Permission denied" a disparu
4. **Cliquez sur "Rafraîchir les données"** pour charger les données

## ⚠️ Important

- Les règles ci-dessus permettent l'accès uniquement aux utilisateurs **authentifiés**
- Chaque utilisateur ne peut accéder qu'aux données de **sa ferme assignée**
- Assurez-vous que l'association `userFarms/{uid}/farmId` existe dans la base de données

## 🆘 Si le problème persiste

1. Vérifiez que l'utilisateur est bien **authentifié** (pas `null` dans le diagnostic)
2. Vérifiez que `userFarms/{uid}/farmId` existe et pointe vers une ferme valide
3. Vérifiez que la ferme existe dans `farms/{farmId}`
4. Consultez les logs de la console Firebase pour plus de détails

