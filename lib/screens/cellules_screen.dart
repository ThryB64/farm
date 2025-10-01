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
import '../providers/theme_provider.dart';
import 'cellule_form_screen.dart';
import 'cellule_details_screen.dart';
import 'fermer_cellule_screen.dart';
class CellulesScreen extends StatefulWidget {
  const CellulesScreen({Key? key}) : super(key: key);
  @override
  State<CellulesScreen> createState() => _CellulesScreenState();
}
class _CellulesScreenState extends State<CellulesScreen> with TickerProviderStateMixin {
  int? _selectedYear;
  final Map<String, AnimationController> _animationControllers = {};
  @override
  void dispose() {
    // Nettoyer les contrôleurs d'animation
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = AppTheme.getColors(themeProvider.isDarkMode);
    final gradients = AppTheme.getGradients(themeProvider.isDarkMode);
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Cellules'),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradients.appBg),
        child: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final cellules = provider.cellules;
          final chargements = provider.chargements;
          if (cellules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warehouse,
                    size: AppTheme.iconSizeXXL,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Aucune cellule enregistrée',
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingL),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CelluleFormScreen()),
                    ),
                    icon: Icon(Icons.add, color: AppTheme.onPrimary),
                    label: Text('Ajouter une cellule', style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.onPrimary)),
                    style: AppTheme.buttonStyle(
                      backgroundColor: AppTheme.primary,
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingM),
                    ),
                  ),
                ],
              ),
            );
          }
          // Grouper les cellules par année de création
          final Map<int, List<Cellule>> cellulesParAnnee = {};
          for (var cellule in cellules) {
            final annee = cellule.dateCreation.year;
            if (!cellulesParAnnee.containsKey(annee)) {
              cellulesParAnnee[annee] = [];
            }
            cellulesParAnnee[annee]!.add(cellule);
          }
          // Trier les années par ordre décroissant
          final List<int> annees = cellulesParAnnee.keys.toList()..sort((a, b) => b.compareTo(a));
          // Trier les cellules par date décroissante dans chaque année
          cellulesParAnnee.forEach((annee, cellules) {
            cellules.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
          });
          // Si aucune année n'est sélectionnée, sélectionner la plus récente
          if (_selectedYear == null && annees.isNotEmpty) {
            _selectedYear = annees.first;
          } else if (_selectedYear == null) {
            _selectedYear = DateTime.now().year;
          }
          // Calculer les statistiques de l'année sélectionnée
          final chargementsAnnee = _selectedYear != null ? chargements.where(
            (c) => c.dateChargement.year == _selectedYear &&
                   cellulesParAnnee[_selectedYear]!.any((cell) => (cell.firebaseId ?? cell.id.toString()) == c.celluleId)
          ).toList() : [];
          final poidsTotalNormeAnnee = chargementsAnnee.fold<double>(
            0,
            (sum, c) => sum + c.poidsNormes,
          );
          final poidsTotalNetAnnee = chargementsAnnee.fold<double>(
            0,
            (sum, c) => sum + c.poidsNet,
          );
          return Column(
            children: [
              Container(
                padding: AppTheme.padding(AppTheme.spacingM),
                color: AppTheme.primary.withOpacity(0.1),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: AppTheme.createInputDecoration(
                        labelText: 'Année',
                        prefixIcon: Icons.calendar_today,
                      ),
                      items: annees.map((annee) {
                        return DropdownMenuItem(
                          value: annee,
                          child: Text(annee.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                    if (_selectedYear != null) ...[
                      SizedBox(height: AppTheme.spacingM),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Poids total normé',
                            '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(2)} T',
                            Icons.scale,
                            AppTheme.primary,
                          ),
                          _buildStatCard(
                            'Poids total net',
                            '${(poidsTotalNetAnnee / 1000).toStringAsFixed(2)} T',
                            Icons.monitor_weight,
                            AppTheme.success,
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacingS),
                      if (cellulesParAnnee[_selectedYear] != null) Text(
                        '${cellulesParAnnee[_selectedYear]!.length} cellules en $_selectedYear',
                        style: AppTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _selectedYear == null
                    ? Center(child: Text('Sélectionnez une année'))
                    : cellulesParAnnee[_selectedYear] == null
                        ? Center(child: Text('Aucune cellule pour cette année'))
                        : ListView.builder(
                            padding: AppTheme.padding(AppTheme.spacingM),
                            itemCount: cellulesParAnnee[_selectedYear]!.length,
                            itemBuilder: (context, index) {
                              final cellule = cellulesParAnnee[_selectedYear]![index];
                              
                              // Calculer les statistiques de la cellule pour l'année sélectionnée
                              final chargementsCellule = chargements
                                  .where((c) => c.celluleId == (cellule.firebaseId ?? cellule.id.toString()) && 
                                               c.dateChargement.year == _selectedYear)
                                  .toList();
                              final poidsTotal = chargementsCellule.fold<double>(
                                0,
                                (sum, c) => sum + c.poidsNet,
                              );
                              final poidsTotalNorme = chargementsCellule.fold<double>(
                                0,
                                (sum, c) => sum + c.poidsNormes,
                              );
                              final tauxRemplissage = (poidsTotalNorme / cellule.capacite) * 100;
                              final humiditeMoyenne = chargementsCellule.isEmpty ? 0.0 : 
                                chargementsCellule.fold<double>(0, (sum, c) => sum + c.humidite) / chargementsCellule.length;
                              return Card(
                                margin: EdgeInsets.only(bottom: AppTheme.spacingM),
                                elevation: AppTheme.elevationS,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppTheme.radius(AppTheme.radiusMedium),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CelluleDetailsScreen(
                                          cellule: cellule,
                                        ),
                                      ),
                                    ).then((_) => setState(() {}));
                                  },
                                  borderRadius: AppTheme.radius(AppTheme.radiusMedium),
                                  child: Padding(
                                    padding: AppTheme.padding(AppTheme.spacingM),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Cellule ${cellule.reference}',
                                                style: AppTheme.textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _buildAnimatedLock(cellule),
                                                SizedBox(width: AppTheme.spacingS),
                                                IconButton(
                                                  icon: Icon(Icons.info, color: AppTheme.primary, size: AppTheme.iconSizeM),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => CelluleDetailsScreen(
                                                          cellule: cellule,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete, color: AppTheme.error, size: AppTheme.iconSizeM),
                                                  onPressed: () => _showDeleteConfirmation(context, cellule),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: AppTheme.spacingS),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.warehouse,
                                              size: AppTheme.iconSizeS,
                                              color: AppTheme.textSecondary,
                                            ),
                                            SizedBox(width: AppTheme.spacingXS),
                                            Text(
                                              '${(cellule.capacite / 1000).toStringAsFixed(2)} T',
                                              style: AppTheme.textTheme.bodySmall?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            SizedBox(width: AppTheme.spacingM),
                                            Icon(
                                              Icons.calendar_today,
                                              size: AppTheme.iconSizeS,
                                              color: AppTheme.textSecondary,
                                            ),
                                            SizedBox(width: AppTheme.spacingXS),
                                            Text(
                                              'Créée le ${_formatDate(cellule.dateCreation)}',
                                              style: AppTheme.textTheme.bodySmall?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (chargementsCellule.isNotEmpty) ...[
                                          SizedBox(height: AppTheme.spacingS),
                                          LinearProgressIndicator(
                                            value: tauxRemplissage / 100,
                                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              tauxRemplissage > 90
                                                  ? AppTheme.error
                                                  : tauxRemplissage > 70
                                                      ? AppTheme.warning
                                                      : AppTheme.primary,
                                            ),
                                            minHeight: AppTheme.spacingS,
                                          ),
                                          SizedBox(height: AppTheme.spacingS),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Taux de remplissage: ${tauxRemplissage.toStringAsFixed(1)}%',
                                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              Text(
                                                'Net: ${(poidsTotal / 1000).toStringAsFixed(2)} T\nNormé: ${(poidsTotalNorme / 1000).toStringAsFixed(2)} T',
                                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: AppTheme.spacingXS),
                                          Text(
                                            'Humidité moyenne: ${humiditeMoyenne.toStringAsFixed(1)}%',
                                            style: AppTheme.textTheme.bodySmall?.copyWith(
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CelluleFormScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        child: Icon(Icons.add, color: AppTheme.onPrimary),
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  void _showDeleteConfirmation(BuildContext context, Cellule cellule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radius(AppTheme.radiusMedium),
        ),
        content: Text('Êtes-vous sûr de vouloir supprimer cette cellule ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final key = cellule.firebaseId ?? cellule.id.toString();
              context.read<FirebaseProviderV4>().supprimerCellule(key);
              Navigator.pop(context);
            },
            style: AppTheme.buttonStyle(
              backgroundColor: AppTheme.error,
              foregroundColor: AppTheme.onPrimary,
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.radius(AppTheme.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: AppTheme.iconSizeS),
              SizedBox(width: AppTheme.spacingXS),
              Text(
                label,
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingXS),
          Text(
            value,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  // Widget animé pour le cadenas
  Widget _buildAnimatedLock(Cellule cellule) {
    final celluleId = cellule.firebaseId ?? cellule.id.toString();
    
    // Créer le contrôleur d'animation s'il n'existe pas
    if (!_animationControllers.containsKey(celluleId)) {
      _animationControllers[celluleId] = AnimationController(
        duration: AppTheme.durationFast,
        vsync: this,
      );
      
      // Définir l'état initial basé sur l'état de la cellule
      if (cellule.fermee) {
        _animationControllers[celluleId]!.value = 1.0;
      }
    }
    final animation = _animationControllers[celluleId]!;
    return GestureDetector(
      onTap: () => _toggleCelluleState(cellule),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: animation.value * 0.1, // Légère rotation pour l'effet
            child: Container(
              padding: AppTheme.padding(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: cellule.fermee ? AppTheme.error.withOpacity(0.1) : AppTheme.success.withOpacity(0.1),
                borderRadius: AppTheme.radius(AppTheme.radiusSmall),
                border: Border.all(
                  color: cellule.fermee ? AppTheme.error : AppTheme.success,
                  width: 1,
                ),
              ),
              child: Icon(
                cellule.fermee ? Icons.lock : Icons.lock_open,
                color: cellule.fermee ? AppTheme.error : AppTheme.success,
                size: AppTheme.iconSizeM,
              ),
            ),
          );
        },
      ),
    );
  }
  // Méthode pour basculer l'état de la cellule
  void _toggleCelluleState(Cellule cellule) async {
    final celluleId = cellule.firebaseId ?? cellule.id.toString();
    final controller = _animationControllers[celluleId];
    
    if (controller == null) return;
    if (cellule.fermee) {
      // Ouvrir la cellule directement
      await controller.reverse();
      final updatedCellule = Cellule(
        id: cellule.id,
        firebaseId: cellule.firebaseId,
        reference: cellule.reference,
        dateCreation: cellule.dateCreation,
        notes: cellule.notes,
        nom: cellule.nom,
        fermee: false,
        quantiteGaz: null,
        prixGaz: null,
      );
      context.read<FirebaseProviderV4>().modifierCellule(updatedCellule);
    } else {
      // Fermer la cellule via l'écran de fermeture
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FermerCelluleScreen(cellule: cellule),
        ),
      );
    }
  }
} 