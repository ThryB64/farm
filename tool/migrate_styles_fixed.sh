#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Migrating inline styles to theme tokens (fixed version)..."

# Fonction pour remplacer les styles dans un fichier
migrate_file() {
  local file="$1"
  echo "  Migrating $file..."
  
  # Remplacer les couleurs (sans const)
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
  
  # Remplacer les espacements (sans const)
  sed -i 's/const EdgeInsets\.all(AppTheme\.spacingXS)/EdgeInsets.all(context.space.xxs)/g' "$file"
  sed -i 's/const EdgeInsets\.all(AppTheme\.spacingS)/EdgeInsets.all(context.space.s)/g' "$file"
  sed -i 's/const EdgeInsets\.all(AppTheme\.spacingM)/EdgeInsets.all(context.space.m)/g' "$file"
  sed -i 's/const EdgeInsets\.all(AppTheme\.spacingL)/EdgeInsets.all(context.space.l)/g' "$file"
  sed -i 's/const EdgeInsets\.all(AppTheme\.spacingXL)/EdgeInsets.all(context.space.xl)/g' "$file"
  sed -i 's/const EdgeInsets\.all(AppTheme\.spacingXXL)/EdgeInsets.all(context.space.xxl)/g' "$file"
  
  # Remplacer les espacements dans EdgeInsets.symmetric
  sed -i 's/EdgeInsets\.symmetric(horizontal: AppTheme\.spacingXS)/EdgeInsets.symmetric(horizontal: context.space.xxs)/g' "$file"
  sed -i 's/EdgeInsets\.symmetric(horizontal: AppTheme\.spacingS)/EdgeInsets.symmetric(horizontal: context.space.s)/g' "$file"
  sed -i 's/EdgeInsets\.symmetric(horizontal: AppTheme\.spacingM)/EdgeInsets.symmetric(horizontal: context.space.m)/g' "$file"
  sed -i 's/EdgeInsets\.symmetric(horizontal: AppTheme\.spacingL)/EdgeInsets.symmetric(horizontal: context.space.l)/g' "$file"
  sed -i 's/EdgeInsets\.symmetric(vertical: AppTheme\.spacingXS)/EdgeInsets.symmetric(vertical: context.space.xxs)/g' "$file"
  sed -i 's/EdgeInsets\.symmetric(vertical: AppTheme\.spacingS)/EdgeInsets.symmetric(vertical: context.space.s)/g' "$file"
  sed -i 's/EdgeInsets\.symmetric(vertical: AppTheme\.spacingM)/EdgeInsets.symmetric(vertical: context.space.m)/g' "$file"
  sed -i 's/EdgeInsets\.symmetric(vertical: AppTheme\.spacingL)/EdgeInsets.symmetric(vertical: context.space.l)/g' "$file"
  
  # Remplacer les espacements dans EdgeInsets.only
  sed -i 's/EdgeInsets\.only(bottom: AppTheme\.spacingXS)/EdgeInsets.only(bottom: context.space.xxs)/g' "$file"
  sed -i 's/EdgeInsets\.only(bottom: AppTheme\.spacingS)/EdgeInsets.only(bottom: context.space.s)/g' "$file"
  sed -i 's/EdgeInsets\.only(bottom: AppTheme\.spacingM)/EdgeInsets.only(bottom: context.space.m)/g' "$file"
  sed -i 's/EdgeInsets\.only(bottom: AppTheme\.spacingL)/EdgeInsets.only(bottom: context.space.l)/g' "$file"
  
  # Remplacer les espacements dans SizedBox
  sed -i 's/const SizedBox(height: AppTheme\.spacingXS)/SizedBox(height: context.space.xxs)/g' "$file"
  sed -i 's/const SizedBox(height: AppTheme\.spacingS)/SizedBox(height: context.space.s)/g' "$file"
  sed -i 's/const SizedBox(height: AppTheme\.spacingM)/SizedBox(height: context.space.m)/g' "$file"
  sed -i 's/const SizedBox(height: AppTheme\.spacingL)/SizedBox(height: context.space.l)/g' "$file"
  sed -i 's/const SizedBox(height: AppTheme\.spacingXL)/SizedBox(height: context.space.xl)/g' "$file"
  sed -i 's/const SizedBox(width: AppTheme\.spacingXS)/SizedBox(width: context.space.xxs)/g' "$file"
  sed -i 's/const SizedBox(width: AppTheme\.spacingS)/SizedBox(width: context.space.s)/g' "$file"
  sed -i 's/const SizedBox(width: AppTheme\.spacingM)/SizedBox(width: context.space.m)/g' "$file"
  sed -i 's/const SizedBox(width: AppTheme\.spacingL)/SizedBox(width: context.space.l)/g' "$file"
  
  # Remplacer les rayons (corriger BorderRadius.circular)
  sed -i 's/BorderRadius\.circular(AppTheme\.radiusSmall)/context.radius.s/g' "$file"
  sed -i 's/BorderRadius\.circular(AppTheme\.radiusMedium)/context.radius.m/g' "$file"
  sed -i 's/BorderRadius\.circular(AppTheme\.radiusLarge)/context.radius.l/g' "$file"
  sed -i 's/BorderRadius\.circular(AppTheme\.radiusXLarge)/context.radius.xl/g' "$file"
  
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
