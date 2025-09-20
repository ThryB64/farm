#!/bin/bash

# Script pour mettre à jour le service Firebase pour utiliser des chemins partagés

echo "🔄 Mise à jour vers les chemins partagés de ferme..."

# Fichier à modifier
FILE="lib/services/firebase_service_v3.dart"

# Remplacer _userRef par _farmRef pour les opérations partagées
echo "🔧 Remplacement des références utilisateur par ferme..."

# Remplacer les streams (lecture partagée)
sed -i 's/_userRef!\.child('\''parcelles'\'')/_farmRef!.child('\''parcelles'\'')/g' "$FILE"
sed -i 's/_userRef!\.child('\''cellules'\'')/_farmRef!.child('\''cellules'\'')/g' "$FILE"
sed -i 's/_userRef!\.child('\''chargements'\'')/_farmRef!.child('\''chargements'\'')/g' "$FILE"
sed -i 's/_userRef!\.child('\''semis'\'')/_farmRef!.child('\''semis'\'')/g' "$FILE"
sed -i 's/_userRef!\.child('\''varietes'\'')/_farmRef!.child('\''varietes'\'')/g' "$FILE"

# Remplacer les insertions (écriture partagée)
sed -i 's/if (_userRef != null)/if (_farmRef != null)/g' "$FILE"

# Remplacer les updates (écriture partagée)
sed -i 's/_userRef!\.child('\''parcelles'\'')\.child(\([^)]*\))\.update/_farmRef!.child('\''parcelles'\'').child(\1).update/g' "$FILE"
sed -i 's/_userRef!\.child('\''cellules'\'')\.child(\([^)]*\))\.update/_farmRef!.child('\''cellules'\'').child(\1).update/g' "$FILE"
sed -i 's/_userRef!\.child('\''chargements'\'')\.child(\([^)]*\))\.update/_farmRef!.child('\''chargements'\'').child(\1).update/g' "$FILE"
sed -i 's/_userRef!\.child('\''semis'\'')\.child(\([^)]*\))\.update/_farmRef!.child('\''semis'\'').child(\1).update/g' "$FILE"
sed -i 's/_userRef!\.child('\''varietes'\'')\.child(\([^)]*\))\.update/_farmRef!.child('\''varietes'\'').child(\1).update/g' "$FILE"

# Remplacer les suppressions (écriture partagée)
sed -i 's/_userRef!\.child('\''parcelles'\'')\.child(\([^)]*\))\.remove/_farmRef!.child('\''parcelles'\'').child(\1).remove/g' "$FILE"
sed -i 's/_userRef!\.child('\''cellules'\'')\.child(\([^)]*\))\.remove/_farmRef!.child('\''cellules'\'').child(\1).remove/g' "$FILE"
sed -i 's/_userRef!\.child('\''chargements'\'')\.child(\([^)]*\))\.remove/_farmRef!.child('\''chargements'\'').child(\1).remove/g' "$FILE"
sed -i 's/_userRef!\.child('\''semis'\'')\.child(\([^)]*\))\.remove/_farmRef!.child('\''semis'\'').child(\1).remove/g' "$FILE"
sed -i 's/_userRef!\.child('\''varietes'\'')\.child(\([^)]*\))\.remove/_farmRef!.child('\''varietes'\'').child(\1).remove/g' "$FILE"

echo "✅ Mise à jour terminée !"
echo ""
echo "📋 Changements effectués :"
echo "   🔄 Streams de lecture → chemins partagés /farms/gaec_berard/"
echo "   ✏️  Insertions → chemins partagés /farms/gaec_berard/"
echo "   🔧 Mises à jour → chemins partagés /farms/gaec_berard/"
echo "   🗑️  Suppressions → chemins partagés /farms/gaec_berard/"
echo ""
echo "🌐 Maintenant tous les appareils partageront les mêmes données !"
