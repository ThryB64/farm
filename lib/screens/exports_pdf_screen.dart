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
import 'package:flutter/services.dart';
import 'export_ventes_screen.dart';
import 'export_traitements_screen.dart';
import 'export_recoltes_screen.dart';
import 'bilan_campagne_screen.dart';

class ExportsPdfScreen extends StatelessWidget {
  const ExportsPdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exports PDF'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBgGradient),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            children: [
            // Export PDF Récolte
            _buildExportCard(
              context,
              'Export PDF Récolte',
              'Générer un PDF des données de récolte',
              Icons.picture_as_pdf,
              AppTheme.primary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportRecoltesScreen()),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Export PDF Ventes
            _buildExportCard(
              context,
              'Export PDF Ventes',
              'Générer un PDF des données de ventes',
              Icons.sell,
              AppTheme.success,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportVentesScreen()),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Export PDF Traitements
            _buildExportCard(
              context,
              'Export PDF Traitements',
              'Générer un PDF des données de traitements',
              Icons.science,
              AppTheme.warning,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportTraitementsScreen()),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Bilan de Campagne
            _buildExportCard(
              context,
              'Bilan de Campagne',
              'Analyse complète: Production, Intrants, Ventes & Marge',
              Icons.assessment_rounded,
              AppTheme.secondary,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BilanCampagneScreen()),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildExportCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AppTheme.glass(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: color, size: AppTheme.iconSizeL),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      subtitle,
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: AppTheme.iconSizeS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
