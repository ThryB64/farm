import '../models/variete_surface.dart';
import '../models/produit_traitement.dart';
import '../models/produit.dart';
import '../models/traitement.dart';
import '../models/vente.dart';
import '../models/semis.dart';
import '../models/chargement.dart';
import '../models/cellule.dart';
import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import 'produit_form_screen.dart';
class ProduitsScreen extends StatefulWidget {
  const ProduitsScreen({Key? key}) : super(key: key);
  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}
class _ProduitsScreenState extends State<ProduitsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final produits = provider.produits;
          if (produits.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final produit = produits[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: const Icon(
                      Icons.science,
                      color: AppTheme.onPrimary,
                    ),
                  ),
                  title: Text(
                    produit.nom,
                    style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mesure: ${produit.mesure}'),
                      if (produit.notes != null && produit.notes!.isNotEmpty)
                        Text('Notes: ${produit.notes}'),
                      Text('Prix: ${produit.prixParAnnee.length} année(s) configurée(s)'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProduitFormScreen(produit: produit),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: AppTheme.iconSizeM, color: AppTheme.error),
                        onPressed: () => _confirmDelete(provider, produit),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProduitFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau produit'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Aucun produit',
            style: AppTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Commencez par ajouter un produit',
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProduitFormScreen(),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un produit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _confirmDelete(FirebaseProviderV4 provider, Produit produit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.supprimerProduit(produit.firebaseId ?? produit.id.toString());
            },
            child: Text('Supprimer', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
