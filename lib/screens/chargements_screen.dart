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
import 'chargement_form_screen.dart';
class ChargementsScreen extends StatefulWidget {
  const ChargementsScreen({Key? key}) : super(key: key);
  @override
  State<ChargementsScreen> createState() => _ChargementsScreenState();
}
class _ChargementsScreenState extends State<ChargementsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int? _selectedYear;
  bool _showDebugInfo = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppThemePageBuilder.buildScrollablePage(
        context: context,
        title: 'Chargements',
        actions: [
        Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) => IconButton(
            onPressed: () => _debugJoins(context, provider),
            icon: const Icon(Icons.analytics),
            tooltip: 'Diagnostic des jointures',
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _showDebugInfo = !_showDebugInfo),
          icon: Icon(_showDebugInfo ? Icons.visibility_off : Icons.bug_report),
          tooltip: _showDebugInfo ? 'Masquer debug' : 'Afficher debug',
        ),
      ],
      children: [
        Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) {
            final chargements = provider.chargements;
            final cellules = provider.cellules;
            final parcelles = provider.parcelles;
            if (chargements.isEmpty) {
              return _buildEmptyState();
            }
          // Utiliser les maps optimisées du provider
          final cellulesById = provider.cellulesById;
          final parcellesById = provider.parcellesById;
          // Grouper les chargements par année
          final Map<int, List<Chargement>> chargementsParAnnee = {};
          for (var chargement in chargements) {
            final annee = chargement.dateChargement.year;
            chargementsParAnnee.putIfAbsent(annee, () => []).add(chargement);
          }
          // Trier les années par ordre décroissant
          final List<int> annees = chargementsParAnnee.keys.toList()..sort((a, b) => b.compareTo(a));
          // Trier les chargements par date décroissante dans chaque année
          chargementsParAnnee.forEach((annee, chargements) {
            chargements.sort((a, b) => b.dateChargement.compareTo(a.dateChargement));
          });
          // Si aucune année n'est sélectionnée, sélectionner la plus récente
          if (_selectedYear == null && annees.isNotEmpty) {
            _selectedYear = annees.first;
          } else if (_selectedYear == null) {
            _selectedYear = DateTime.now().year;
          }
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(chargementsParAnnee),
                if (_showDebugInfo) _buildDebugInfo(chargements, cellules, parcelles),
                Expanded(
                  child: _selectedYear == null
                      ? const Center(child: Text('Sélectionnez une année'))
                      : _buildChargementsList(
                          chargementsParAnnee[_selectedYear]!,
                          cellulesById,
                          parcellesById,
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChargementFormScreen(),
          ),
        ),
        backgroundColor: AppTheme.primary(context),
        foregroundColor: AppTheme.onPrimary(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  Widget _buildEmptyState() {
    return AppThemePageBuilder.buildEmptyState(
      context: context,
      message: 'Aucun chargement enregistré\nCommencez par ajouter votre premier chargement',
      icon: Icons.local_shipping,
      actionText: 'Ajouter un chargement',
      onAction: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChargementFormScreen(),
        ),
      ),
    );
  }
  Widget _buildHeader(Map<int, List<Chargement>> chargementsParAnnee) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: AppTheme.createInputDecoration(context,
                          labelText: 'Année',
                          prefixIcon: Icons.calendar_today,
                        ),
              items: chargementsParAnnee.keys.map((year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value;
                          });
                        },
                      ),
                    ),
          const SizedBox(width: AppTheme.spacingM),
                    Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
                      decoration: BoxDecoration(
              color: AppTheme.primary(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Text(
                        '${chargementsParAnnee[_selectedYear]?.length ?? 0} chargements',
              style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                          color: AppTheme.onPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
  Widget _buildDebugInfo(List<Chargement> chargements, List<Cellule> cellules, List<Parcelle> parcelles) {
    // Utiliser les maps optimisées du provider
    final cellulesById = {for (final c in cellules) 
      if (c.firebaseId != null) c.firebaseId!: c
      else if (c.id != null) c.id.toString(): c
    };
    final parcellesById = {for (final p in parcelles) 
      if (p.firebaseId != null) p.firebaseId!: p
      else if (p.id != null) p.id.toString(): p
    };
    
    int chargementsAvecCellule = 0;
    int chargementsAvecParcelle = 0;
    int chargementsSansCellule = 0;
    int chargementsSansParcelle = 0;
    for (final chargement in chargements) {
      if (cellulesById.containsKey(chargement.celluleId)) {
        chargementsAvecCellule++;
      } else {
        chargementsSansCellule++;
      }
      
      if (parcellesById.containsKey(chargement.parcelleId)) {
        chargementsAvecParcelle++;
      } else {
        chargementsSansParcelle++;
      }
    }
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: AppTheme.warning),
                const SizedBox(width: AppTheme.spacingS),
                const Text(
                  'Debug - Jointures',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildDebugStat('Cellules', chargementsAvecCellule, chargementsSansCellule, AppTheme.secondary(context)),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildDebugStat('Parcelles', chargementsAvecParcelle, chargementsSansParcelle, AppTheme.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDebugStat(String label, int avec, int sans, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.textTheme(context).bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: AppTheme.spacingXS),
          Text(
            '$avec OK',
            style: AppTheme.textTheme(context).bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.success,
            ),
          ),
          if (sans > 0)
            Text(
              '$sans KO',
              style: AppTheme.textTheme(context).bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.error,
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildChargementsList(
    List<Chargement> chargements,
    Map<String, Cellule> cellulesById,
    Map<String, Parcelle> parcellesById,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: chargements.length,
      itemBuilder: (context, index) {
        final chargement = chargements[index];
        final cellule = cellulesById[chargement.celluleId];
        final parcelle = parcellesById[chargement.parcelleId];
        
        // Debug: afficher les IDs pour diagnostiquer
        if (cellule == null) {
          print('DEBUG: Cellule non trouvée pour chargement ${chargement.id}');
          print('  - Chargement celluleId: ${chargement.celluleId}');
          print('  - Cellules disponibles: ${cellulesById.keys.toList()}');
          print('  - Cellules: ${cellulesById.values.map((c) => '${c.firebaseId ?? c.id}: ${c.reference}').toList()}');
        }
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: ModernCard(
            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.primary(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Icon(
                        Icons.local_shipping,
                        color: AppTheme.primary(context),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                          Text(
                            cellule?.label ?? 'Cellule inconnue',
                            style: AppTheme.textTheme(context).titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          SizedBox(height: AppTheme.spacingXS),
                          Text(
                            '${_formatDate(chargement.dateChargement)} • ${chargement.remorque}',
                            style: AppTheme.textTheme(context).bodyMedium?.copyWith(
                              color: AppTheme.textSecondary(context),
                            ),
                                  ),
                                ],
                              ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChargementFormScreen(chargement: chargement),
                            ),
                          );
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(chargement);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: AppTheme.primary(context)),
                              SizedBox(width: AppTheme.spacingS),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppTheme.error),
                              SizedBox(width: AppTheme.spacingS),
                              Text('Supprimer'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        '${(chargement.poidsNet / 1000).toStringAsFixed(2)} T',
                        Icons.scale,
                        AppTheme.primary(context),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: _buildInfoChip(
                        '${(chargement.poidsNormes / 1000).toStringAsFixed(2)} T normé',
                        Icons.trending_up,
                        AppTheme.secondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        '${chargement.humidite}% humidité',
                        Icons.water_drop,
                        AppTheme.info,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: _buildInfoChip(
                        parcelle?.nom ?? 'Parcelle inconnue',
                        Icons.landscape,
                        AppTheme.success,
                      ),
              ),
            ],
                ),
                if (_showDebugInfo) ...[
                  const SizedBox(height: AppTheme.spacingM),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warning,
                          ),
                        ),
                        Text(
                          'Chargement ID: ${chargement.id}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        Text(
                          'Cellule ID: ${chargement.celluleId} (${cellule != null ? 'Trouvée' : 'Manquante'})',
                          style: const TextStyle(fontSize: 10),
                        ),
                        Text(
                          'Parcelle ID: ${chargement.parcelleId} (${parcelle != null ? 'Trouvée' : 'Manquante'})',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textTheme(context).bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  // Méthode de diagnostic des jointures
  void _debugJoins(BuildContext context, FirebaseProviderV4 provider) {
    final stats = provider.debugJoins();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnostic des jointures'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total chargements: ${stats['total']}'),
            SizedBox(height: AppTheme.spacingS),
            Text('Jointures OK: ${stats['ok']}', 
                 style: AppTheme.textTheme(context).bodyMedium?.copyWith(color: AppTheme.success, fontWeight: FontWeight.bold)),
            Text('Cellules manquantes: ${stats['missCell']}', 
                 style: AppTheme.textTheme(context).bodyMedium?.copyWith(color: stats['missCell']! > 0 ? AppTheme.error : AppTheme.success)),
            Text('Parcelles manquantes: ${stats['missParc']}', 
                 style: AppTheme.textTheme(context).bodyMedium?.copyWith(color: stats['missParc']! > 0 ? AppTheme.error : AppTheme.success)),
            SizedBox(height: AppTheme.spacingM),
            if (stats['missCell']! > 0 || stats['missParc']! > 0)
              const Text(
                '⚠️ Des jointures échouent. Vérifiez que les cellules et parcelles sont bien chargées.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.warning,
                ),
              )
            else
              const Text(
                '✅ Toutes les jointures sont correctes !',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  Future<void> _showDeleteConfirmation(Chargement chargement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        content: const Text('Voulez-vous vraiment supprimer ce chargement ?'),
        actions: [
          ModernTextButton(
            text: 'Annuler',
            onPressed: () => Navigator.pop(context, false),
          ),
          ModernButton(
            text: 'Supprimer',
            backgroundColor: AppTheme.error,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final key = chargement.firebaseId ?? chargement.id.toString();
      await context.read<FirebaseProviderV4>().supprimerChargement(key);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chargement supprimé'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }
} 