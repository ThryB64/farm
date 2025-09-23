import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/semis.dart';
import '../models/parcelle.dart';
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
      appBar: AppBar(
        title: const Text('Semis'),
        backgroundColor: Colors.purple,
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

          if (semis.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grass,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun semis enregistré',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SemisFormScreen()),
                    ),
                    icon: Icon(Icons.add),
                    label: Text('Ajouter un semis'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Année',
                    border: OutlineInputBorder(),
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
              ),
              // Résumé des hectares pour l'année sélectionnée
              if (_selectedYear != null) _buildHectaresSummary(semisParAnnee[_selectedYear]!, parcelles),
              Expanded(
                child: _selectedYear == null
                    ? const Center(child: Text('Sélectionnez une année'))
                    : ListView.builder(
                        itemCount: semisParAnnee[_selectedYear]!.length,
                        itemBuilder: (context, index) {
                          final semis = semisParAnnee[_selectedYear]![index];
                          final parcelle = parcelles.firstWhere(
                            (p) => (p.firebaseId ?? p.id.toString()) == semis.parcelleId,
                            orElse: () => Parcelle(
                              id: 0,
                              nom: 'Inconnu',
                              surface: 0,
                              dateCreation: DateTime.now(),
                            ),
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(parcelle.nom),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${_formatDate(semis.date)}'),
                                  Text('Variétés: ${semis.varietes.join(", ")}'),
                                  Text('Surface: ${parcelle.surface.toStringAsFixed(2)} ha'),
                                  if (semis.notes?.isNotEmpty ?? false) Text('Notes: ${semis.notes}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SemisFormScreen(
                                            semis: semis,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _showDeleteConfirmation(context, semis);
                                    },
                                  ),
                                ],
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
              builder: (context) => const SemisFormScreen(),
            ),
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildHectaresSummary(List<Semis> semisAnnee, List<Parcelle> parcelles) {
    // Calculer le total des hectares semés
    double totalHectaresSemes = 0;
    for (final semis in semisAnnee) {
      final hectaresSemes = semis.varietesSurfaces.fold<double>(0, (sum, v) => sum + v.surface);
      totalHectaresSemes += hectaresSemes;
    }

    // Calculer le total des surfaces de toutes les parcelles
    double totalSurfaceParcelles = 0;
    for (final parcelle in parcelles) {
      totalSurfaceParcelles += parcelle.surface;
    }

    final hectaresRestants = totalSurfaceParcelles - totalHectaresSemes;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé des hectares - ${_selectedYear}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total hectares semés: ${totalHectaresSemes.toStringAsFixed(2)} ha',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hectares restants à semer: ${hectaresRestants.toStringAsFixed(2)} ha',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: hectaresRestants > 0 ? Colors.orange : Colors.red,
            ),
          ),
        ],
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