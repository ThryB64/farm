import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/cellule.dart';
import 'cellule_form_screen.dart';
import 'cellule_details_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cellules'),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FirebaseProviderV4>(
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
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucune cellule enregistrée',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CelluleFormScreen()),
                    ),
                    icon: Icon(Icons.add),
                    label: Text('Ajouter une cellule'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                   cellulesParAnnee[_selectedYear]!.any((cell) => cell.id == c.celluleId)
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
                padding: const EdgeInsets.all(16),
                color: Colors.blue.withOpacity(0.1),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'Année',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: Colors.white,
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
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Poids total normé',
                            '${(poidsTotalNormeAnnee / 1000).toStringAsFixed(2)} T',
                            Icons.scale,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'Poids total net',
                            '${(poidsTotalNetAnnee / 1000).toStringAsFixed(2)} T',
                            Icons.monitor_weight,
                            Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (cellulesParAnnee[_selectedYear] != null) Text(
                        '${cellulesParAnnee[_selectedYear]!.length} cellules en $_selectedYear',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _selectedYear == null
                    ? const Center(child: Text('Sélectionnez une année'))
                    : cellulesParAnnee[_selectedYear] == null
                        ? const Center(child: Text('Aucune cellule pour cette année'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
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
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
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
                                  borderRadius: BorderRadius.circular(15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Cellule ${cellule.reference}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _buildAnimatedLock(cellule),
                                                SizedBox(width: 8),
                                                IconButton(
                                                  icon: Icon(Icons.info),
                                                  color: Colors.blue,
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
                                                  icon: Icon(Icons.delete),
                                                  color: Colors.red,
                                                  onPressed: () => _showDeleteConfirmation(context, cellule),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.warehouse,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${(cellule.capacite / 1000).toStringAsFixed(2)} T',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Créée le ${_formatDate(cellule.dateCreation)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (chargementsCellule.isNotEmpty) ...[
                                          SizedBox(height: 8),
                                          LinearProgressIndicator(
                                            value: tauxRemplissage / 100,
                                            backgroundColor: Colors.blue.withOpacity(0.2),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              tauxRemplissage > 90
                                                  ? Colors.red
                                                  : tauxRemplissage > 70
                                                      ? Colors.orange
                                                      : Colors.blue,
                                            ),
                                            minHeight: 8,
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Taux de remplissage: ${tauxRemplissage.toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Net: ${(poidsTotal / 1000).toStringAsFixed(2)} T\nNormé: ${(poidsTotalNorme / 1000).toStringAsFixed(2)} T',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                                textAlign: TextAlign.end,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Humidité moyenne: ${humiditeMoyenne.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CelluleFormScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
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
        title: const Text('Confirmer la suppression'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette cellule ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final key = cellule.firebaseId ?? cellule.id.toString();
              context.read<FirebaseProviderV4>().supprimerCellule(key);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
              Icon(icon, color: color, size: 16),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
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
        duration: const Duration(milliseconds: 300),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cellule.fermee ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: cellule.fermee ? Colors.red : Colors.green,
                  width: 1,
                ),
              ),
              child: Icon(
                cellule.fermee ? Icons.lock : Icons.lock_open,
                color: cellule.fermee ? Colors.red : Colors.green,
                size: 20,
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

    // Animer le changement
    if (cellule.fermee) {
      // Ouvrir la cellule
      await controller.reverse();
    } else {
      // Fermer la cellule
      await controller.forward();
    }

    // Mettre à jour l'état dans Firebase
    final updatedCellule = Cellule(
      id: cellule.id,
      firebaseId: cellule.firebaseId,
      reference: cellule.reference,
      dateCreation: cellule.dateCreation,
      notes: cellule.notes,
      nom: cellule.nom,
      fermee: !cellule.fermee,
    );

    // Mettre à jour via le provider
    context.read<FirebaseProviderV4>().modifierCellule(updatedCellule);
  }
} 