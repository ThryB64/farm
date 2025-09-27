import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/semis.dart';
import '../models/parcelle.dart';
import '../models/variete.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_buttons.dart';
import 'semis_form_screen.dart';
import 'varietes_screen.dart';

class SemisScreen extends StatefulWidget {
  const SemisScreen({Key? key}) : super(key: key);

  @override
  State<SemisScreen> createState() => _SemisScreenState();
}

class _SemisScreenState extends State<SemisScreen> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Semis'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.eco),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VarietesScreen()),
            ),
            tooltip: 'Gérer les variétés',
          ),
        ],
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final semis = provider.semis;
          final parcelles = provider.parcelles;
          final varietes = provider.varietes;

          if (semis.isEmpty) {
            return _buildEmptyState();
          }

          // Grouper les semis par année
          final Map<int, List<Semis>> semisParAnnee = {};
          for (var s in semis) {
            final annee = s.date.year;
            semisParAnnee.putIfAbsent(annee, () => []).add(s);
          }

          // Trier les années par ordre décroissant
          final List<int> annees = semisParAnnee.keys.toList()..sort((a, b) => b.compareTo(a));

          // Trier les semis par date décroissante dans chaque année
          semisParAnnee.forEach((annee, semis) {
            semis.sort((a, b) => b.date.compareTo(a.date));
          });

          // Si aucune année n'est sélectionnée, sélectionner la plus récente
          if (_selectedYear == null && annees.isNotEmpty) {
            _selectedYear = annees.first;
          } else if (_selectedYear == null) {
            _selectedYear = DateTime.now().year;
          }

          return Column(
            children: [
              // Sélecteur d'année
              _buildYearSelector(annees),
              
              // Statistiques (fixes)
              if (_selectedYear != null) 
                _buildStatistics(semisParAnnee[_selectedYear]!, parcelles),
              
              // Liste des semis (scrollable)
              Expanded(
                child: _selectedYear == null
                    ? _buildEmptyYearState()
                    : _buildSemisList(semisParAnnee[_selectedYear]!, parcelles, varietes),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSemis,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau semis'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.grass,
              size: 64,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun semis enregistré',
            style: AppTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter votre premier semis',
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ModernButton(
            text: 'Ajouter un semis',
            icon: Icons.add,
            onPressed: _addSemis,
            backgroundColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyYearState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez une année',
            style: AppTheme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(List<int> annees) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text(
            'Année:',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<int>(
              value: _selectedYear,
              isExpanded: true,
              underline: const SizedBox(),
              items: annees.map((annee) {
                return DropdownMenuItem(
                  value: annee,
                  child: Text(
                    annee.toString(),
                    style: AppTheme.textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<Semis> semisAnnee, List<Parcelle> parcelles) {
    // Calculer le total des hectares semés
    double totalHectaresSemes = 0;
    double totalPrixSemis = 0;
    
    for (final semis in semisAnnee) {
      final hectaresSemes = semis.varietesSurfaces.fold<double>(0, (sum, v) => sum + v.surface);
      totalHectaresSemes += hectaresSemes;
      totalPrixSemis += semis.prixSemis;
    }

    // Calculer le total des surfaces de toutes les parcelles
    double totalSurfaceParcelles = 0;
    for (final parcelle in parcelles) {
      totalSurfaceParcelles += parcelle.surface;
    }

    final hectaresRestants = totalSurfaceParcelles - totalHectaresSemes;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withOpacity(0.1), AppTheme.primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Résumé ${_selectedYear}',
                style: AppTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Hectares semés',
                  '${totalHectaresSemes.toStringAsFixed(2)} ha',
                  Icons.grass,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Hectares restants',
                  '${hectaresRestants.toStringAsFixed(2)} ha',
                  Icons.timeline,
                  hectaresRestants > 0 ? Colors.orange : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Coût total semis',
            '${totalPrixSemis.toStringAsFixed(2)} €',
            Icons.euro,
            AppTheme.primary,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: fullWidth 
        ? Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSemisList(List<Semis> semisAnnee, List<Parcelle> parcelles, List<Variete> varietes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: semisAnnee.length,
      itemBuilder: (context, index) {
        final semis = semisAnnee[index];
        final parcelle = parcelles.firstWhere(
          (p) => (p.firebaseId ?? p.id.toString()) == semis.parcelleId,
          orElse: () => Parcelle(
            id: 0,
            nom: 'Parcelle inconnue',
            surface: 0,
            dateCreation: DateTime.now(),
          ),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // En-tête de la carte
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.grass, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        parcelle.nom,
                        style: AppTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editSemis(semis);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, semis);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(Icons.more_vert, color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
              
              // Contenu de la carte
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    _buildInfoRow(Icons.calendar_today, 'Date', _formatDate(semis.date)),
                    const SizedBox(height: 8),
                    
                    // Variétés avec surfaces
                    _buildVarietesInfo(semis, varietes),
                    const SizedBox(height: 8),
                    
                    // Surface totale
                    _buildInfoRow(Icons.area_chart, 'Surface totale', '${_getTotalSurface(semis.varietesSurfaces).toStringAsFixed(2)} ha'),
                    
                    // Prix du semis si défini
                    if (semis.prixSemis > 0) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.euro, 'Prix semis', '${semis.prixSemis.toStringAsFixed(2)} €'),
                    ],
                    
                    // Densité de maïs
                    if (semis.densiteMais > 0) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.grain, 'Densité maïs', '${semis.densiteMais.toStringAsFixed(0)} graines/ha'),
                    ],
                    
                    // Notes si présentes
                    if (semis.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.note, 'Notes', semis.notes!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVarietesInfo(Semis semis, List<Variete> varietes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.eco, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Variétés: ',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...semis.varietesSurfaces.map((varieteSurface) {
          final variete = varietes.firstWhere(
            (v) => v.firebaseId == varieteSurface.varieteId,
            orElse: () => Variete(
              id: 0,
              nom: 'Variété inconnue',
              dateCreation: DateTime.now(),
              prixParAnnee: {},
            ),
          );
          
          return Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 2),
            child: Text(
              '• ${variete.nom}: ${varieteSurface.surface.toStringAsFixed(2)} ha',
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  double _getTotalSurface(List<dynamic> varietesSurfaces) {
    return varietesSurfaces.fold<double>(0, (sum, v) => sum + v.surface);
  }

  void _addSemis() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SemisFormScreen()),
    );
  }

  void _editSemis(Semis semis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SemisFormScreen(semis: semis),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Semis semis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce semis ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final key = semis.firebaseId ?? semis.id.toString();
              context.read<FirebaseProviderV4>().supprimerSemis(key);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}