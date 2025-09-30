# 🎨 Guide du Système de Design

## 📋 Vue d'ensemble

Le système de design de l'application est centralisé dans `lib/theme/app_theme.dart`. Tous les styles, couleurs, et composants UI sont définis dans ce fichier pour assurer une cohérence visuelle à travers toute l'application.

## 🎯 Principes du Design System

### 1. **Centralisation**
- Tous les styles sont définis dans `AppTheme`
- Aucun style hardcodé dans les pages
- Cohérence garantie à travers l'application

### 2. **Réutilisabilité**
- Composants UI réutilisables
- Méthodes helper pour les styles courants
- Styles spécialisés par type de page

### 3. **Maintenabilité**
- Modifications centralisées
- Évolution facile du design
- Documentation intégrée

## 🎨 Utilisation du Système

### Couleurs Principales

```dart
// Couleurs de base
AppTheme.primary          // Vert principal
AppTheme.secondary        // Bleu secondaire
AppTheme.accent           // Orange accent
AppTheme.success          // Vert succès
AppTheme.warning          // Orange avertissement
AppTheme.error            // Rouge erreur
AppTheme.info             // Bleu information
```

### Styles de Cartes

```dart
// Cartes principales
Container(
  decoration: AppTheme.cardDecoration,
  child: // contenu
)

// Cartes avec accent coloré
Container(
  decoration: AppTheme.cardDecorationWithAccent(AppTheme.primary),
  child: // contenu
)

// Cartes spécialisées par page
Container(
  decoration: AppTheme.parcelleCardDecoration,  // Pour les parcelles
  child: // contenu
)
```

### Styles de Boutons

```dart
// Boutons principaux
ElevatedButton(
  style: AppTheme.primaryButtonStyle,
  onPressed: () {},
  child: Text('Bouton Principal'),
)

// Boutons outlined
OutlinedButton(
  style: AppTheme.outlinedButtonStyle,
  onPressed: () {},
  child: Text('Bouton Outlined'),
)

// Boutons avec couleurs personnalisées
ElevatedButton(
  style: AppTheme.buttonStyleWithColor(AppTheme.accent, Colors.white),
  onPressed: () {},
  child: Text('Bouton Personnalisé'),
)
```

### Styles de Formulaires

```dart
// Champs de saisie standard
TextFormField(
  decoration: AppTheme.inputDecoration,
  // autres propriétés
)

// Champs avec icône
TextFormField(
  decoration: AppTheme.inputDecorationWithIcon(Icons.person),
  // autres propriétés
)
```

### Styles de Listes

```dart
// Éléments de liste
Container(
  decoration: AppTheme.listItemDecoration,
  child: // contenu de l'élément
)

// Éléments sélectionnés
Container(
  decoration: AppTheme.selectedListItemDecoration,
  child: // contenu de l'élément
)

// Puces de sélection (FilterChip)
FilterChip(
  selected: isSelected,
  onSelected: (selected) {},
  label: Text('Option'),
  backgroundColor: AppTheme.surface,
  selectedColor: AppTheme.primary.withOpacity(0.1),
  checkmarkColor: AppTheme.primary,
)
```

### AppBars Spécialisées

```dart
// AppBar principale
AppBar(
  title: Text('Titre'),
  backgroundColor: AppTheme.primary,
  foregroundColor: Colors.white,
)

// Ou utiliser les thèmes prédéfinis
AppBar(
  title: Text('Titre'),
  theme: AppTheme.primaryAppBarTheme,
)
```

## 📱 Styles par Page

### Page d'Accueil
```dart
Container(
  decoration: AppTheme.homeCardDecoration,
  child: // contenu de la carte d'accueil
)
```

### Statistiques
```dart
Container(
  decoration: AppTheme.statsCardDecoration,
  child: // contenu des statistiques
)
```

### Parcelles
```dart
Container(
  decoration: AppTheme.parcelleCardDecoration,
  child: // contenu de la parcelle
)
```

### Semis
```dart
Container(
  decoration: AppTheme.semisCardDecoration,
  child: // contenu du semis
)
```

### Traitements
```dart
Container(
  decoration: AppTheme.treatmentCardDecoration,
  child: // contenu du traitement
)
```

### Cellules
```dart
Container(
  decoration: AppTheme.celluleCardDecoration,
  child: // contenu de la cellule
)
```

### Chargements
```dart
Container(
  decoration: AppTheme.chargementCardDecoration,
  child: // contenu du chargement
)
```

### Exports PDF
```dart
Container(
  decoration: AppTheme.exportCardDecoration,
  child: // contenu de l'export
)
```

### Imports
```dart
Container(
  decoration: AppTheme.importCardDecoration,
  child: // contenu de l'import
)
```

## 🛠️ Méthodes Helper

### Styles de Texte Personnalisés
```dart
Text(
  'Mon texte',
  style: AppTheme.textStyleWithColor(
    AppTheme.textTheme.titleMedium,
    AppTheme.primary,
  ),
)
```

### Styles de Boutons Personnalisés
```dart
ElevatedButton(
  style: AppTheme.buttonStyleWithColor(
    AppTheme.accent,
    Colors.white,
  ),
  onPressed: () {},
  child: Text('Bouton Personnalisé'),
)
```

### Cartes avec Accent Personnalisé
```dart
Container(
  decoration: AppTheme.cardDecorationWithCustomAccent(AppTheme.warning),
  child: // contenu
)
```

### Containers avec Gradient
```dart
Container(
  decoration: AppTheme.containerWithGradient([
    AppTheme.primary,
    AppTheme.primaryLight,
  ]),
  child: // contenu
)
```

## 📏 Espacements et Rayons

### Espacements
```dart
const SizedBox(height: AppTheme.spacingXS)  // 4.0
const SizedBox(height: AppTheme.spacingS)   // 8.0
const SizedBox(height: AppTheme.spacingM)    // 16.0
const SizedBox(height: AppTheme.spacingL)   // 24.0
const SizedBox(height: AppTheme.spacingXL)  // 32.0
const SizedBox(height: AppTheme.spacingXXL) // 48.0
```

### Rayons de Bordure
```dart
BorderRadius.circular(AppTheme.radiusSmall)   // 8.0
BorderRadius.circular(AppTheme.radiusMedium) // 12.0
BorderRadius.circular(AppTheme.radiusLarge)  // 16.0
BorderRadius.circular(AppTheme.radiusXLarge) // 24.0
```

## 🎨 Couleurs et Gradients

### Gradients Prédéfinis
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
  ),
  child: // contenu
)
```

### Ombres
```dart
Container(
  decoration: BoxDecoration(
    boxShadow: AppTheme.cardShadow,      // Ombre légère
    boxShadow: AppTheme.elevatedShadow, // Ombre plus prononcée
  ),
  child: // contenu
)
```

## 📝 Bonnes Pratiques

### ✅ À FAIRE
- Utiliser toujours `AppTheme` pour les styles
- Utiliser les styles spécialisés par page
- Utiliser les méthodes helper pour la personnalisation
- Maintenir la cohérence visuelle

### ❌ À ÉVITER
- Ne pas hardcoder les couleurs dans les pages
- Ne pas créer des styles dupliqués
- Ne pas ignorer le système de design
- Ne pas mélanger les styles personnalisés avec le système

## 🔄 Migration des Pages Existantes

Pour migrer une page existante vers le nouveau système :

1. **Identifier les styles utilisés**
2. **Remplacer par les équivalents AppTheme**
3. **Utiliser les styles spécialisés par page**
4. **Tester la cohérence visuelle**

### Exemple de Migration

**Avant :**
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        offset: Offset(0, 2),
        blurRadius: 8,
      ),
    ],
  ),
  child: // contenu
)
```

**Après :**
```dart
Container(
  decoration: AppTheme.cardDecoration,
  child: // contenu
)
```

## 🎯 Avantages du Système

1. **Cohérence** : Design uniforme à travers l'application
2. **Maintenabilité** : Modifications centralisées
3. **Productivité** : Développement plus rapide
4. **Évolutivité** : Facile d'ajouter de nouveaux styles
5. **Documentation** : Styles auto-documentés

## 📚 Ressources

- **Fichier principal** : `lib/theme/app_theme.dart`
- **Widgets personnalisés** : `lib/widgets/`
- **Exemples d'utilisation** : Voir les pages existantes

---

*Ce guide est maintenu à jour avec l'évolution du système de design.*
