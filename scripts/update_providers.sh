#!/bin/bash

# Script pour mettre à jour tous les providers vers V3

echo "🔄 Mise à jour des providers vers V3..."

# Liste des fichiers à mettre à jour
FILES=(
    "lib/screens/parcelles_screen.dart"
    "lib/screens/cellules_screen.dart"
    "lib/screens/chargements_screen.dart"
    "lib/screens/semis_screen.dart"
    "lib/screens/varietes_screen.dart"
    "lib/screens/parcelle_details_screen.dart"
    "lib/screens/parcelle_form_screen.dart"
    "lib/screens/cellule_details_screen.dart"
    "lib/screens/cellule_form_screen.dart"
    "lib/screens/chargement_form_screen.dart"
    "lib/screens/semis_form_screen.dart"
    "lib/screens/variete_form_screen.dart"
    "lib/screens/statistiques_screen.dart"
    "lib/screens/import_export_screen.dart"
    "lib/screens/export_screen.dart"
)

# Fonction pour mettre à jour un fichier
update_file() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "📝 Mise à jour de $file..."
        
        # Remplacer les imports
        sed -i 's/firebase_provider_v2\.dart/firebase_provider_v3.dart/g' "$file"
        sed -i 's/firebase_provider\.dart/firebase_provider_v3.dart/g' "$file"
        
        # Remplacer les références aux providers
        sed -i 's/FirebaseProviderV2/FirebaseProviderV3/g' "$file"
        sed -i 's/FirebaseProvider/FirebaseProviderV3/g' "$file"
        
        echo "✅ $file mis à jour"
    else
        echo "⚠️  Fichier $file non trouvé"
    fi
}

# Mettre à jour tous les fichiers
for file in "${FILES[@]}"; do
    update_file "$file"
done

echo "🎉 Mise à jour terminée !"
