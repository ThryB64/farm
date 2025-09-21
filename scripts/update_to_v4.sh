#!/bin/bash

echo "🔄 Updating all screens to use FirebaseProviderV4..."

# Update all screen files
find lib/screens -name "*.dart" -exec sed -i 's/FirebaseProviderV3/FirebaseProviderV4/g' {} \;

# Update import statements
find lib/screens -name "*.dart" -exec sed -i 's/firebase_provider_v3/firebase_provider_v4/g' {} \;

echo "✅ All screens updated to V4"
echo "📝 Files updated:"
find lib/screens -name "*.dart" -exec grep -l "FirebaseProviderV4" {} \;
