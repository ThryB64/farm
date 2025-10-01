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
import 'export_ventes_screen.dart';
import 'export_traitements_screen.dart';
import 'export_recoltes_screen.dart';

class ExportsPdfScreen extends StatelessWidget {
  const ExportsPdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exports PDF'),
        backgroundColor: AppTheme.primary(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            // Export PDF Récolte
            MenuCard(
              title: 'Export PDF Récolte',
              subtitle: 'Générer un PDF des données de récolte',
              icon: Icons.picture_as_pdf,
              color: AppTheme.primary(context),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportRecoltesScreen()),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Export PDF Ventes
            MenuCard(
              title: 'Export PDF Ventes',
              subtitle: 'Générer un PDF des données de ventes',
              icon: Icons.sell,
              color: AppTheme.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportVentesScreen()),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Export PDF Traitements
            MenuCard(
              title: 'Export PDF Traitements',
              subtitle: 'Générer un PDF des données de traitements',
              icon: Icons.science,
              color: AppTheme.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportTraitementsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
