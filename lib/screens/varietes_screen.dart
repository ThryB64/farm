import '../models/variete.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import 'variete_form_screen.dart';

class VarietesScreen extends StatelessWidget {
  const VarietesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppThemePageBuilder.buildScrollablePage(
      context: context,
      title: 'Variétés',
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VarieteFormScreen()),
        ),
        backgroundColor: AppTheme.primary(context),
        child: Icon(Icons.add, color: AppTheme.onPrimary(context)),
      ),
      children: [
        Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) {
            final varietes = provider.varietes;
            if (varietes.isEmpty) {
              return AppThemePageBuilder.buildEmptyState(
                context: context,
                message: 'Aucune variété enregistrée\nCommencez par ajouter une variété',
                icon: Icons.eco,
                actionText: 'Ajouter une variété',
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VarieteFormScreen()),
                ),
              );
            }
            return AppThemePageBuilder.buildItemList(
              context: context,
              items: varietes.map((variete) => _buildVarieteCard(context, variete, provider)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVarieteCard(BuildContext context, Variete variete, FirebaseProviderV4 provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.secondary(context),
          child: Icon(
            Icons.eco,
            color: AppTheme.onPrimary(context),
          ),
        ),
        title: Text(
          variete.nom,
          style: AppTheme.textTheme(context).titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${variete.description ?? 'Aucune description'}'),
            Text('Créée le: ${_formatDate(variete.dateCreation)}'),
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
                  builder: (context) => VarieteFormScreen(variete: variete),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _confirmDelete(context, provider, variete),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, FirebaseProviderV4 provider, Variete variete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la variété'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${variete.nom}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.supprimerVariete(variete);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}