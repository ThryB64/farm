# 🔄 Migration de `gaec_berard` vers `farms/gaec_berard`

## 📋 Situation actuelle

Votre base de données a deux structures :
- ✅ `farms/agricorn_demo/` (structure correcte)
- ⚠️ `gaec_berard/` (à la racine, doit être déplacé)

## ✅ Solution : Déplacer `gaec_berard` dans `farms/`

### Option 1 : Via Firebase Console (Recommandé)

1. **Ouvrez Firebase Console** → Realtime Database → Données

2. **Sauvegarder les données de `gaec_berard`** :
   - Cliquez sur `gaec_berard`
   - Cliquez sur les trois points `⋯` → **Exporter JSON**
   - Sauvegardez le fichier JSON

3. **Créer `farms/gaec_berard`** :
   - Cliquez sur `farms`
   - Cliquez sur `+` pour ajouter un nœud
   - Clé : `gaec_berard`
   - Type : **objet**

4. **Importer les données** :
   - Cliquez sur `farms/gaec_berard`
   - Cliquez sur les trois points `⋯` → **Importer JSON**
   - Sélectionnez le fichier JSON sauvegardé
   - Confirmez l'import

5. **Vérifier** :
   - Vérifiez que toutes les données sont dans `farms/gaec_berard/`
   - Vérifiez que `farms/gaec_berard/membres/` existe (ou créez-le)

6. **Supprimer l'ancien `gaec_berard`** :
   - Cliquez sur `gaec_berard` (à la racine)
   - Cliquez sur la poubelle 🗑️
   - Confirmez la suppression

### Option 2 : Via script (si vous avez beaucoup de données)

Si vous avez beaucoup de données, je peux créer un script pour automatiser la migration.

## 📝 Structure finale attendue

```
farms/
  ├── agricorn_demo/
  │   ├── membres/
  │   ├── parcelles: {}
  │   ├── cellules: {}
  │   └── ...
  └── gaec_berard/
      ├── membres/
      ├── parcelles: {}
      ├── cellules: {}
      ├── chargements: {}
      └── ...
```

## ⚠️ Important

- **Ne supprimez pas `gaec_berard` avant d'avoir vérifié** que toutes les données sont bien dans `farms/gaec_berard/`
- **Mettez à jour les associations utilisateurs** : Vérifiez que `userFarms/{uid}/farmId = "gaec_berard"` pour tous les utilisateurs de cette ferme
- **Créez la section `membres`** dans `farms/gaec_berard/` si elle n'existe pas

## 🔍 Vérification après migration

1. Tous les utilisateurs de `gaec_berard` ont `userFarms/{uid}/farmId = "gaec_berard"`
2. `farms/gaec_berard/` contient toutes les données
3. `farms/gaec_berard/membres/` existe et contient les membres
4. L'ancien `gaec_berard/` à la racine est supprimé
5. L'application fonctionne correctement après migration

