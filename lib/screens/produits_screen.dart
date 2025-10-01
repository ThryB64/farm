import '../models/produit.dart';
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
    return AppThemePageBuilder.buildScrollablePage(
      context: context,
      title: 'Produits',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProduitFormScreen(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau produit'),
        backgroundColor: AppTheme.primary(context),
        foregroundColor: AppTheme.onPrimary(context),
      ),
      children: [
        Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) {
            final produits = provider.produits;
            if (produits.isEmpty) {
              return _buildEmptyState();
            }
            return AppThemePageBuilder.buildItemList(
              context: context,
              items: produits.map((produit) => _buildProduitCard(context, produit, provider)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProduitCard(BuildContext context, Produit produit, FirebaseProviderV4 provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary(context),
          child: Icon(
            Icons.science,
            color: AppTheme.onPrimary(context),
          ),
        ),
        title: Text(
          produit.nom,
          style: AppTheme.textTheme(context).titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _confirmDelete(context, provider, produit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppThemePageBuilder.buildEmptyState(
      context: context,
      message: 'Aucun produit\nCommencez par ajouter un produit',
      icon: Icons.science_outlined,
      actionText: 'Ajouter un produit',
      onAction: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProduitFormScreen(),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FirebaseProviderV4 provider, Produit produit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${produit.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.supprimerProduit(produit.firebaseId ?? produit.id.toString());
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}