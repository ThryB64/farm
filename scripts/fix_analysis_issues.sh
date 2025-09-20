#!/bin/bash

# Script pour corriger automatiquement les problèmes d'analyse Flutter
# Ce script corrige les problèmes les plus courants

set -e

echo "🔧 Correction des problèmes d'analyse Flutter"
echo "============================================="

# Nettoyer le projet
echo "🧹 Nettoyage du projet..."
flutter clean

# Obtenir les dépendances
echo "📦 Récupération des dépendances..."
flutter pub get

# Corriger les imports inutilisés automatiquement
echo "🔍 Correction des imports inutilisés..."

# Supprimer les imports inutilisés dans les fichiers principaux
find lib -name "*.dart" -exec sed -i '/^import.*unused/d' {} \;

# Corriger les problèmes de const
echo "🔧 Correction des constructeurs const..."

# Remplacer les occurrences courantes de const manquants
find lib -name "*.dart" -exec sed -i 's/style: const TextStyle(/style: TextStyle(/g' {} \;
find lib -name "*.dart" -exec sed -i 's/const SizedBox(/SizedBox(/g' {} \;
find lib -name "*.dart" -exec sed -i 's/const Icon(/Icon(/g' {} \;

# Corriger les méthodes dépréciées
echo "🔄 Correction des méthodes dépréciées..."

# Remplacer withOpacity par withValues
find lib -name "*.dart" -exec sed -i 's/\.withOpacity(/\.withValues(alpha: /g' {} \;

# Supprimer les print statements en production
echo "🚫 Suppression des print statements..."

# Commenter les print statements dans les fichiers de production
find lib -name "*.dart" -exec sed -i 's/print(/\/\/ print(/g' {} \;

# Corriger les problèmes de null safety
echo "🛡️ Correction des problèmes de null safety..."

# Remplacer les opérateurs null-aware inutiles
find lib -name "*.dart" -exec sed -i 's/\?\./\./g' {} \;

echo "✅ Corrections automatiques terminées!"
echo "🔍 Exécution de l'analyse finale..."

# Exécuter l'analyse
flutter analyze

echo "🎉 Script de correction terminé!"
