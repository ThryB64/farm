import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/chargement.dart';
import '../models/cellule.dart';
import '../models/parcelle.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Debug - Jointures'),
        backgroundColor: AppTheme.warning,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final chargements = provider.chargements;
          final cellules = provider.cellules;
          final parcelles = provider.parcelles;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(chargements, cellules, parcelles),
                const SizedBox(height: AppTheme.spacingL),
                _buildChargementsAnalysis(chargements, cellules, parcelles),
                const SizedBox(height: AppTheme.spacingL),
                _buildCellulesAnalysis(cellules),
                const SizedBox(height: AppTheme.spacingL),
                _buildParcellesAnalysis(parcelles),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Chargement> chargements, List<Cellule> cellules, List<Parcelle> parcelles) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.bug_report,
                  color: AppTheme.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              const Text(
                'Résumé des données',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildStatRow('Chargements', chargements.length, AppTheme.primary),
          _buildStatRow('Cellules', cellules.length, AppTheme.secondary),
          _buildStatRow('Parcelles', parcelles.length, AppTheme.success),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargementsAnalysis(List<Chargement> chargements, List<Cellule> cellules, List<Parcelle> parcelles) {
    // Créer des maps pour les jointures
    final cellulesById = {for (final c in cellules) c.id: c};
    final parcellesById = {for (final p in parcelles) p.id: p};

    // Analyser les jointures
    int chargementsAvecCellule = 0;
    int chargementsAvecParcelle = 0;
    int chargementsSansCellule = 0;
    int chargementsSansParcelle = 0;
    
    final List<Map<String, dynamic>> problemes = [];

    for (final chargement in chargements) {
      final celluleTrouvee = cellulesById[chargement.celluleId];
      final parcelleTrouvee = parcellesById[chargement.parcelleId];

      if (celluleTrouvee != null) {
        chargementsAvecCellule++;
      } else {
        chargementsSansCellule++;
        problemes.add({
          'type': 'cellule',
          'chargementId': chargement.id,
          'celluleId': chargement.celluleId,
          'message': 'Chargement ${chargement.id} référence cellule ${chargement.celluleId} introuvable'
        });
      }

      if (parcelleTrouvee != null) {
        chargementsAvecParcelle++;
      } else {
        chargementsSansParcelle++;
        problemes.add({
          'type': 'parcelle',
          'chargementId': chargement.id,
          'parcelleId': chargement.parcelleId,
          'message': 'Chargement ${chargement.id} référence parcelle ${chargement.parcelleId} introuvable'
        });
      }
    }

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse des jointures - Chargements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildStatRow('Avec cellule', chargementsAvecCellule, AppTheme.success),
          _buildStatRow('Sans cellule', chargementsSansCellule, AppTheme.error),
          _buildStatRow('Avec parcelle', chargementsAvecParcelle, AppTheme.success),
          _buildStatRow('Sans parcelle', chargementsSansParcelle, AppTheme.error),
          if (problemes.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            const Text(
              'Problèmes détectés:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            ...problemes.take(10).map((probleme) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• ${probleme['message']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.error,
                ),
              ),
            )),
            if (problemes.length > 10)
              Text(
                '... et ${problemes.length - 10} autres problèmes',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCellulesAnalysis(List<Cellule> cellules) {
    final ids = cellules.map((c) => c.id).toList()..sort();
    final minId = ids.isNotEmpty ? ids.first : 0;
    final maxId = ids.isNotEmpty ? ids.last : 0;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse des cellules',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildStatRow('Total', cellules.length, AppTheme.secondary),
          _buildStatRow('ID min', minId ?? 0, AppTheme.info),
          _buildStatRow('ID max', maxId ?? 0, AppTheme.info),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Premières cellules:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          ...cellules.take(5).map((cellule) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              'ID ${cellule.id}: ${cellule.reference}',
              style: const TextStyle(fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildParcellesAnalysis(List<Parcelle> parcelles) {
    final ids = parcelles.map((p) => p.id).toList()..sort();
    final minId = ids.isNotEmpty ? ids.first : 0;
    final maxId = ids.isNotEmpty ? ids.last : 0;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analyse des parcelles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildStatRow('Total', parcelles.length, AppTheme.success),
          _buildStatRow('ID min', minId ?? 0, AppTheme.info),
          _buildStatRow('ID max', maxId ?? 0, AppTheme.info),
          const SizedBox(height: AppTheme.spacingM),
          const Text(
            'Premières parcelles:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          ...parcelles.take(5).map((parcelle) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              'ID ${parcelle.id}: ${parcelle.nom}',
              style: const TextStyle(fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }
}
