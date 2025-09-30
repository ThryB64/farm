#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Checking for forbidden inline styles..."

# Patterns interdits (styles inline)
PATTERNS=(
  "Color\\("
  "Color\\.fromARGB"
  "Color\\.fromRGBO"
  "Colors\\.[a-zA-Z0-9_]+"
  "TextStyle\\("
  "fontSize:"
  "fontWeight:"
  "letterSpacing:"
  "EdgeInsets\\.all"
  "EdgeInsets\\.symmetric"
  "EdgeInsets\\.only"
  "EdgeInsets\\("
  "BorderRadius\\.circular"
  "BorderRadius\\.only"
  "BorderRadius\\.all"
  "BorderRadius\\("
  "BoxShadow\\("
  "blurRadius:"
  "spreadRadius:"
  "Duration\\("
  "milliseconds:"
  "microseconds:"
  "seconds:"
  "elevation:\\s*[0-9]+"
  "SizedBox\\((height|width):\\s*[0-9]+"
  "Icon\\([^)]*size:\\s*[0-9]+"
  "BorderSide\\([^)]*width:\\s*[0-9]+"
  "RoundedRectangleBorder\\([^)]*borderRadius:"
)

# Compteur d'erreurs
ERRORS=0

# Vérifier chaque pattern
for pattern in "${PATTERNS[@]}"; do
  echo "  Checking pattern: $pattern"
  
  # Chercher le pattern dans lib/ mais exclure lib/theme/
  if grep -RInE "$pattern" lib/ | grep -v "lib/theme" | grep -v "app_theme.dart"; then
    echo "❌ Found forbidden pattern: $pattern"
    echo "   Please use theme tokens instead of inline styles."
    echo "   Use context.space.*, context.radius.*, context.colors.*, etc."
    ERRORS=$((ERRORS + 1))
  fi
done

# Vérifier les constantes de style dans les widgets
echo "  Checking for style constants in widgets..."
if grep -RInE "const.*Color\\(" lib/ | grep -v "lib/theme" | grep -v "app_theme.dart"; then
  echo "❌ Found const Color() outside theme files"
  echo "   Please move color constants to app_theme.dart"
  ERRORS=$((ERRORS + 1))
fi

if grep -RInE "const.*TextStyle\\(" lib/ | grep -v "lib/theme" | grep -v "app_theme.dart"; then
  echo "❌ Found const TextStyle() outside theme files"
  echo "   Please move text styles to app_theme.dart"
  ERRORS=$((ERRORS + 1))
fi

if grep -RInE "const.*EdgeInsets\\(" lib/ | grep -v "lib/theme" | grep -v "app_theme.dart"; then
  echo "❌ Found const EdgeInsets() outside theme files"
  echo "   Please use context.space.* instead"
  ERRORS=$((ERRORS + 1))
fi

if grep -RInE "const.*BorderRadius\\(" lib/ | grep -v "lib/theme" | grep -v "app_theme.dart"; then
  echo "❌ Found const BorderRadius() outside theme files"
  echo "   Please use context.radius.* instead"
  ERRORS=$((ERRORS + 1))
fi

# Vérifier les durées littérales
if grep -RInE "Duration\\(milliseconds:\\s*[0-9]+\\)" lib/ | grep -v "lib/theme" | grep -v "app_theme.dart"; then
  echo "❌ Found Duration literals outside theme files"
  echo "   Please use context.motion.* instead"
  ERRORS=$((ERRORS + 1))
fi

# Résultat final
if [ $ERRORS -eq 0 ]; then
  echo "✅ No inline styles found. All styles are properly themed!"
  exit 0
else
  echo "❌ Found $ERRORS style violations."
  echo ""
  echo "📚 Usage examples:"
  echo "   Instead of: color: Color(0xFF123456)"
  echo "   Use: color: context.colors.primary"
  echo ""
  echo "   Instead of: padding: EdgeInsets.all(16)"
  echo "   Use: padding: EdgeInsets.all(context.space.m)"
  echo ""
  echo "   Instead of: borderRadius: BorderRadius.circular(12)"
  echo "   Use: borderRadius: context.radius.m"
  echo ""
  echo "   Instead of: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)"
  echo "   Use: context.text.titleMedium"
  exit 1
fi
