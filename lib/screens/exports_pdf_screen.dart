import '../widgets/modern_card.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'export_recoltes_screen.dart';
import 'export_ventes_screen.dart';
import 'export_traitements_screen.dart';

class ExportsPdfScreen extends StatefulWidget {
  const ExportsPdfScreen({Key? key}) : super(key: key);

  @override
  State<ExportsPdfScreen> createState() => _ExportsPdfScreenState();
}

class _ExportsPdfScreenState extends State<ExportsPdfScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemePageBuilder.buildColumnPage(
      context: context,
      title: 'Exports PDF',
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildExportCard(
                context,
                'Export PDF Récolte',
                'Générer un rapport PDF des récoltes',
                Icons.agriculture,
                AppTheme.primary(context),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportRecoltesScreen()),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              _buildExportCard(
                context,
                'Export PDF Ventes',
                'Générer un rapport PDF des ventes',
                Icons.sell,
                AppTheme.secondary(context),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportVentesScreen()),
                ),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              _buildExportCard(
                context,
                'Export PDF Traitements',
                'Générer un rapport PDF des traitements',
                Icons.science,
                AppTheme.accent(context),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportTraitementsScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
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
    return ModernCard(
      onTap: onTap,
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Row(
          children: [
            Container(
              padding: AppTheme.padding(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(
                icon,
                size: AppTheme.iconSizeL,
                color: color,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.textTheme(context).titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    subtitle,
                    style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: AppTheme.iconSizeS,
              color: AppTheme.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}