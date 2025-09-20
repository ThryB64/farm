#!/bin/bash

# Script pour mettre à jour les règles Firebase pour la ferme partagée

echo "🔐 Mise à jour des règles Firebase pour la ferme partagée..."

# Créer le fichier de règles Firebase
cat > firebase_rules.json << 'EOF'
{
  "rules": {
    "farms": {
      "$farmId": {
        ".read": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true",
        ".write": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true",
        "parcelles": {
          ".read": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true",
          ".write": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true"
        },
        "cellules": {
          ".read": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true",
          ".write": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true"
        },
        "chargements": {
          ".read": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true",
          ".write": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true"
        },
        "semis": {
          ".read": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true",
          ".write": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true"
        },
        "varietes": {
          ".read": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true",
          ".write": "auth != null && root.child('farmMembers').child($farmId).child(auth.uid).val() === true"
        }
      }
    },
    "farmMembers": {
      "$farmId": {
        "$uid": {
          ".read": "auth != null && auth.uid === $uid",
          ".write": "auth != null && (auth.uid === $uid || root.child('farmAdmins').child($farmId).child(auth.uid).val() === true)"
        }
      }
    },
    "farmAdmins": {
      "$farmId": {
        "$uid": {
          ".read": "auth != null && auth.uid === $uid",
          ".write": "auth != null && auth.uid === $uid"
        }
      }
    },
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid === $uid",
        ".write": "auth != null && auth.uid === $uid"
      }
    }
  }
}
EOF

echo "✅ Règles Firebase créées dans firebase_rules.json"
echo ""
echo "📋 Instructions pour appliquer les règles :"
echo "   1. Allez sur https://console.firebase.google.com/"
echo "   2. Sélectionnez votre projet 'farmgaec'"
echo "   3. Allez dans 'Realtime Database' → 'Rules'"
echo "   4. Copiez le contenu de firebase_rules.json"
echo "   5. Collez-le dans l'éditeur de règles"
echo "   6. Cliquez sur 'Publish'"
echo ""
echo "👥 Pour ajouter des membres à la ferme :"
echo "   - Allez dans 'Realtime Database' → 'Data'"
echo "   - Créez le nœud: farmMembers/gaec_berard/<uid>: true"
echo "   - Remplacez <uid> par l'UID de chaque membre"
echo ""
echo "🔐 Les règles permettent :"
echo "   ✅ Lecture/écriture pour les membres de la ferme"
echo "   ✅ Gestion des membres par les admins"
echo "   ✅ Données privées utilisateur protégées"
echo "   ✅ Accès partagé aux données de la ferme"
