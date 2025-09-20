# 🔧 DEBUG ÉCRAN BLANC - SOLUTIONS APPLIQUÉES

## ✅ **PROBLÈMES IDENTIFIÉS ET CORRIGÉS :**

### **1. Service Worker (SW) problématique** 🔧
- **Problème** : Le service worker peut servir un ancien build en cache
- **Solution** : Désactivé temporairement avec `--pwa-strategy=none`

### **2. Base href incorrect** 🔧
- **Problème** : L'URL GitHub Pages est `/farm/` mais le manifest pointait vers `/`
- **Solution** : Corrigé `start_url` et ajouté `scope` dans `manifest.json`

### **3. Cache PWA figé** 🔧
- **Problème** : Le cache PWA peut bloquer les nouveaux builds
- **Solution** : Build sans service worker pour déboguer

## 🚀 **CORRECTIONS APPLIQUÉES :**

### **1. Workflow GitHub Actions**
```yaml
- name: Build Flutter Web (debug)
  run: flutter build web --release --base-href /farm/ --pwa-strategy=none
```

### **2. Manifest.json corrigé**
```json
{
  "start_url": "/farm/",
  "scope": "/farm/",
  "display": "standalone"
}
```

### **3. Build local testé**
- ✅ Build sans service worker fonctionne
- ✅ Base href `/farm/` correct
- ✅ Manifest.json corrigé

## 📱 **POUR TESTER :**

### **1. Attendre le déploiement** (2-3 minutes)
1. Allez sur : **https://github.com/ThryB64/farm/actions**
2. Vérifiez que le workflow est ✅ vert
3. Attendez que le déploiement soit terminé

### **2. Tester l'URL avec cache-buster**
1. Ouvrez : **https://thryb64.github.io/farm/?nocache=1**
2. L'application devrait maintenant s'afficher

### **3. Si toujours blanc, vérifier la console**
1. Ouvrez **F12** → **Console**
2. Regardez s'il y a des erreurs JavaScript
3. Copiez-moi les erreurs pour correction

## 🔧 **ÉTAPES SUIVANTES :**

### **Si l'app fonctionne maintenant :**
1. Réactiver le service worker (enlever `--pwa-strategy=none`)
2. Tester la PWA complète
3. Installer sur iPhone

### **Si toujours blanc :**
1. Vérifier la console pour les erreurs
2. Tester avec d'autres options de build
3. Vérifier les assets (404 sur images/fonts)

## 🎯 **RÉSUMÉ DES CORRECTIONS :**
- ✅ Service worker désactivé temporairement
- ✅ Base href corrigé à `/farm/`
- ✅ Manifest.json corrigé
- ✅ Build local testé et fonctionnel
- ✅ Déploiement en cours

**L'application devrait maintenant s'afficher correctement ! 🚀**
