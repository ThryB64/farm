#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Migrating inline styles to theme tokens..."

# Fonction pour remplacer les styles dans un fichier
migrate_file() {
  local file="$1"
  echo "  Migrating $file..."
  
  # Remplacer les couleurs
  sed -i 's/AppTheme\.primary/context.colors.primary/g' "$file"
  sed -i 's/AppTheme\.secondary/context.colors.secondary/g' "$file"
  sed -i 's/AppTheme\.accent/context.colors.tertiary/g' "$file"
  sed -i 's/AppTheme\.surface/context.colors.surface/g' "$file"
  sed -i 's/AppTheme\.background/context.colors.background/g' "$file"
  sed -i 's/AppTheme\.textPrimary/context.colors.onSurface/g' "$file"
  sed -i 's/AppTheme\.textSecondary/context.colors.onSurface.withOpacity(0.7)/g' "$file"
  sed -i 's/AppTheme\.textLight/context.colors.onSurface.withOpacity(0.5)/g' "$file"
  sed -i 's/AppTheme\.success/context.colors.primary/g' "$file"
  sed -i 's/AppTheme\.warning/context.colors.tertiary/g' "$file"
  sed -i 's/AppTheme\.error/context.colors.error/g' "$file"
  sed -i 's/AppTheme\.info/context.colors.secondary/g' "$file"
  sed -i 's/AppTheme\.border/context.colors.outline/g' "$file"
  
  # Remplacer les espacements
  sed -i 's/AppTheme\.spacingXS/context.space.xxs/g' "$file"
  sed -i 's/AppTheme\.spacingS/context.space.s/g' "$file"
  sed -i 's/AppTheme\.spacingM/context.space.m/g' "$file"
  sed -i 's/AppTheme\.spacingL/context.space.l/g' "$file"
  sed -i 's/AppTheme\.spacingXL/context.space.xl/g' "$file"
  sed -i 's/AppTheme\.spacingXXL/context.space.xxl/g' "$file"
  
  # Remplacer les rayons
  sed -i 's/AppTheme\.radiusSmall/context.radius.s/g' "$file"
  sed -i 's/AppTheme\.radiusMedium/context.radius.m/g' "$file"
  sed -i 's/AppTheme\.radiusLarge/context.radius.l/g' "$file"
  sed -i 's/AppTheme\.radiusXLarge/context.radius.xl/g' "$file"
  
  # Remplacer les textes
  sed -i 's/AppTheme\.textTheme\.headlineLarge/context.text.headlineLarge/g' "$file"
  sed -i 's/AppTheme\.textTheme\.headlineMedium/context.text.headlineMedium/g' "$file"
  sed -i 's/AppTheme\.textTheme\.headlineSmall/context.text.headlineSmall/g' "$file"
  sed -i 's/AppTheme\.textTheme\.titleLarge/context.text.titleLarge/g' "$file"
  sed -i 's/AppTheme\.textTheme\.titleMedium/context.text.titleMedium/g' "$file"
  sed -i 's/AppTheme\.textTheme\.titleSmall/context.text.titleSmall/g' "$file"
  sed -i 's/AppTheme\.textTheme\.bodyLarge/context.text.bodyLarge/g' "$file"
  sed -i 's/AppTheme\.textTheme\.bodyMedium/context.text.bodyMedium/g' "$file"
  sed -i 's/AppTheme\.textTheme\.bodySmall/context.text.bodySmall/g' "$file"
}

# Migrer tous les fichiers Dart dans lib/
echo "📁 Finding Dart files to migrate..."
find lib -name "*.dart" -not -path "lib/theme/*" | while read -r file; do
  migrate_file "$file"
done

echo "✅ Migration completed!"
echo ""
echo "📝 Next steps:"
echo "1. Review the changes"
echo "2. Fix any remaining compilation errors"
echo "3. Test the application"
echo "4. Run ./tool/check_styles.sh to verify no inline styles remain"
