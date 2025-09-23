import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import 'export_screen.dart';
import 'export_ventes_screen.dart';

class ExportsPdfScreen extends StatelessWidget {
  const ExportsPdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exports PDF'),
        backgroundColor: AppTheme.primary,
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
              color: AppTheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportScreen()),
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
          ],
        ),
      ),
    );
  }
}
