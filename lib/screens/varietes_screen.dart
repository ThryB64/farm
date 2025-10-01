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
import 'variete_form_screen.dart';
class VarietesScreen extends StatelessWidget {
  const VarietesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Variétés'),
        backgroundColor: AppTheme.primary(context),
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final varietes = provider.varietes;
          if (varietes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    size: 64,
                    color: AppTheme.textLight(context),
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Aucune variété enregistrée',
                    style: AppTheme.textTheme(context).titleLarge?.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingL),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VarieteFormScreen()),
                    ),
                    icon: Icon(Icons.add),
                    label: Text('Ajouter une variété'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingM),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: varietes.length,
            itemBuilder: (context, index) {
              final variete = varietes[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                child: ListTile(
                  title: Text(variete.nom),
                  subtitle: Text(variete.description ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VarieteFormScreen(
                                variete: variete,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmation'),
                              content: Text('Voulez-vous supprimer la variété "${variete.nom}" ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final key = variete.firebaseId ?? variete.id.toString();
                                    provider.supprimerVariete(key);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VarieteFormScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primary(context),
        child: Icon(Icons.add),
      ),
    );
  }
} 