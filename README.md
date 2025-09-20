# 🌽 Maïs Tracker - PWA

Application de gestion des récoltes de maïs - Progressive Web App

## 📱 Installation sur iPhone

### Méthode 1: GitHub Pages (Recommandée)
1. Ouvrez Safari sur votre iPhone
2. Allez sur : `https://[votre-username].github.io/mais-tracker`
3. Menu "Partager" → "Ajouter à l'écran d'accueil"
4. L'app s'installe comme une app native !

### Méthode 2: Local
1. Ouvrez `build/web/index.html` dans Safari
2. Menu "Partager" → "Ajouter à l'écran d'accueil"

## 🚀 Déploiement automatique

Cette PWA se déploie automatiquement sur GitHub Pages à chaque push sur la branche `main`.

## 🛠️ Développement local

```bash
# Installer les dépendances
flutter pub get

# Build pour le web
flutter build web --release

# Tester localement
cd build/web
python -m http.server 8000
# Ouvrir http://localhost:8000
```

## 📋 Fonctionnalités

- ✅ Gestion des parcelles
- ✅ Gestion des cellules de stockage
- ✅ Suivi des chargements
- ✅ Gestion des semis
- ✅ Statistiques et rapports
- ✅ Export PDF
- ✅ Base de données SQLite (IndexedDB sur web)

## 🔧 Technologies

- Flutter Web
- Progressive Web App (PWA)
- SQLite (IndexedDB)
- GitHub Pages
- GitHub Actions