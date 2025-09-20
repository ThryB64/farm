# Configuration Codemagic pour Maïs Tracker

Ce document explique comment configurer votre application Flutter "Maïs Tracker" pour la compilation sur Codemagic.io.

## 📋 Prérequis

- Un compte Codemagic.io
- Votre projet Flutter configuré avec les dépendances appropriées
- Les fichiers de configuration déjà créés dans ce projet

## 🚀 Configuration sur Codemagic

### 1. Connexion du Repository

1. Connectez-vous à [Codemagic.io](https://codemagic.io)
2. Cliquez sur "Add application"
3. Sélectionnez votre repository Git (GitHub, GitLab, Bitbucket)
4. Autorisez Codemagic à accéder à votre repository

### 2. Configuration des Workflows

Le fichier `codemagic.yaml` contient plusieurs workflows prêts à l'emploi :

#### Workflows Disponibles

- **mais-tracker-android** : Compilation pour Android uniquement
- **mais-tracker-ios** : Compilation pour iOS uniquement  
- **mais-tracker-linux** : Compilation pour Linux uniquement
- **mais-tracker-windows** : Compilation pour Windows uniquement
- **mais-tracker-macos** : Compilation pour macOS uniquement
- **mais-tracker-all-platforms** : Compilation pour toutes les plateformes

#### Recommandations

- **Pour commencer** : Utilisez `mais-tracker-android` pour tester
- **Pour la production** : Utilisez `mais-tracker-all-platforms` pour toutes les plateformes

### 3. Configuration des Variables d'Environnement

Dans l'interface Codemagic, ajoutez ces variables d'environnement :

```
FLUTTER_BUILD_MODE=release
SQLITE_FFI_ENABLED=true
```

### 4. Configuration des Notifications

Modifiez l'email dans le fichier `codemagic.yaml` :

```yaml
publishing:
  email:
    recipients:
      - votre-email@example.com  # Remplacez par votre email
```

## 🧪 Tests Locaux

Avant de pousser sur Codemagic, testez localement :

```bash
# Exécuter le script de test
./scripts/test_build.sh

# Ou manuellement :
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## 📱 Plateformes Supportées

### Android
- ✅ APK de production
- ✅ Support SQLite FFI
- ✅ Génération de PDF
- ✅ Graphiques avec fl_chart

### iOS
- ✅ IPA sans signature (pour distribution interne)
- ✅ Support SQLite FFI
- ✅ Génération de PDF
- ✅ Graphiques avec fl_chart

### Linux
- ✅ Binaire Linux
- ✅ Support SQLite FFI natif
- ✅ Génération de PDF
- ✅ Interface graphique GTK

### Windows
- ✅ Exécutable Windows
- ✅ Support SQLite FFI
- ✅ Génération de PDF
- ✅ Interface Windows native

### macOS
- ✅ Application macOS
- ✅ Support SQLite FFI
- ✅ Génération de PDF
- ✅ Interface macOS native

## 🔧 Dépendances Spéciales

Votre application utilise des dépendances qui nécessitent une attention particulière :

### SQLite FFI
- Configuration automatique dans `main.dart`
- Support natif sur toutes les plateformes
- Pas de configuration supplémentaire requise

### Génération de PDF
- Package `pdf` et `printing`
- Fonctionne sur toutes les plateformes
- Aucune configuration supplémentaire requise

### Graphiques
- Package `fl_chart`
- Support complet sur toutes les plateformes
- Aucune configuration supplémentaire requise

## 🐛 Résolution de Problèmes

### Erreurs Communes

1. **Erreur SQLite FFI**
   - Vérifiez que `SQLITE_FFI_ENABLED=true` est défini
   - Assurez-vous que `sqflite_common_ffi` est dans les dépendances

2. **Erreur de compilation PDF**
   - Vérifiez que `pdf` et `printing` sont dans `pubspec.yaml`
   - Assurez-vous que les permissions sont correctes

3. **Erreur de tests**
   - Vérifiez que tous les tests passent localement
   - Assurez-vous que `TestDatabaseHelper` est correctement configuré

### Logs de Debug

Pour déboguer les problèmes :

1. Consultez les logs de build dans Codemagic
2. Vérifiez que toutes les dépendances sont résolues
3. Assurez-vous que les tests passent

## 📊 Monitoring

### Métriques de Build
- Durée de compilation
- Taille des artefacts
- Taux de succès des builds

### Notifications
- Email en cas de succès/échec
- Intégration Slack (optionnelle)
- Webhooks (optionnels)

## 🚀 Déploiement

### Artifacts Générés

Chaque build génère :
- **Android** : APK + mapping.txt
- **iOS** : IPA
- **Linux** : Bundle complet
- **Windows** : Exécutable + DLLs
- **macOS** : Application .app

### Distribution

1. **Téléchargement direct** : Artifacts disponibles dans Codemagic
2. **App Store Connect** : Configuration optionnelle pour iOS
3. **Google Play** : Configuration optionnelle pour Android

## 📝 Notes Importantes

- Les builds sont optimisés pour la production
- Tous les tests sont exécutés avant la compilation
- L'analyse de code est effectuée automatiquement
- Les artefacts sont signés automatiquement (si configuré)

## 🆘 Support

En cas de problème :
1. Consultez les logs de build dans Codemagic
2. Vérifiez la configuration locale
3. Contactez le support Codemagic si nécessaire

---

**Configuration terminée !** 🎉

Votre application Maïs Tracker est maintenant prête pour la compilation sur Codemagic.io.
