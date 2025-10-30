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
import 'package:fl_chart/fl_chart.dart';
import '../providers/firebase_provider_v4.dart';
class StatistiquesScreen extends StatefulWidget {
  const StatistiquesScreen({Key? key}) : super(key: key);
  @override
  State<StatistiquesScreen> createState() => _StatistiquesScreenState();
}
class _StatistiquesScreenState extends State<StatistiquesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedYear;
  String? _selectedParcelleId;
  int? _anneeA; // Année de référence
  int? _anneeB; // Année de comparaison
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppTheme.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vue générale'),
            Tab(text: 'Détail par parcelle'),
            Tab(text: 'Analyse variétés'),
            Tab(text: 'Comparaison annuelle'),
          ],
          onTap: (index) {
            if (index != 1) {
              setState(() {
                _selectedParcelleId = null;
              });
            }
          },
        ),
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final chargements = provider.chargements;
          final semis = provider.semis;
          final parcelles = provider.parcelles;
          // Calculer les statistiques annuelles
          final Map<int, Map<String, dynamic>> statsParAnnee = {};
          for (var chargement in chargements) {
            final annee = chargement.dateChargement.year;
            if (!statsParAnnee.containsKey(annee)) {
              statsParAnnee[annee] = {
                'poidsTotal': 0.0,
                'humiditeMoyenne': 0.0,
                'nombreChargements': 0,
              };
            }
            statsParAnnee[annee]!['poidsTotal'] = statsParAnnee[annee]!['poidsTotal'] + chargement.poidsNormes;
            statsParAnnee[annee]!['humiditeMoyenne'] = statsParAnnee[annee]!['humiditeMoyenne'] + chargement.humidite;
            statsParAnnee[annee]!['nombreChargements'] = statsParAnnee[annee]!['nombreChargements'] + 1;
          }
          // Calculer les moyennes d'humidité
          statsParAnnee.forEach((annee, stats) {
            stats['humiditeMoyenne'] /= stats['nombreChargements'];
          });
          // Trier les années par ordre décroissant
          final annees = statsParAnnee.keys.toList()..sort((a, b) => b.compareTo(a));
          // Si aucune année n'est sélectionnée, prendre la plus récente
          if (_selectedYear == null && annees.isNotEmpty) {
            _selectedYear = annees.first;
          } else if (_selectedYear == null) {
            _selectedYear = DateTime.now().year;
          }
          return Column(
            children: [
              Padding(
                padding: AppTheme.padding(AppTheme.spacingM),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: AppTheme.createInputDecoration(
                          labelText: 'Année',
                          border: OutlineInputBorder(),
                        ),
                        items: annees.map((year) {
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
                    if (_tabController.index == 1) ...[
                      SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedParcelleId,
                          decoration: AppTheme.createInputDecoration(
                            labelText: 'Parcelle',
                            border: OutlineInputBorder(),
                          ),
                          items: parcelles.map((parcelle) {
                            final key = parcelle.firebaseId ?? parcelle.id.toString();
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(parcelle.nom),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedParcelleId = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Vue générale annuelle
                    SingleChildScrollView(
                      padding: AppTheme.padding(AppTheme.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildEvolutionRendementChart(statsParAnnee),
                          SizedBox(height: 24),
                          _buildEvolutionHumiditeChart(statsParAnnee),
                        ],
                      ),
                    ),
                    // Détail par parcelle
                    SingleChildScrollView(
                      padding: AppTheme.padding(AppTheme.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildComparaisonRendementsParcellesChart(chargements, parcelles),
                          SizedBox(height: 24),
                          Card(
                            child: Padding(
                              padding: AppTheme.padding(AppTheme.spacingM),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sélectionnez une parcelle pour voir ses statistiques détaillées',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _selectedParcelleId,
                                    decoration: AppTheme.createInputDecoration(
                                      labelText: 'Parcelle',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: parcelles.map((parcelle) {
                                      final key = parcelle.firebaseId ?? parcelle.id.toString();
                                      return DropdownMenuItem<String>(
                                        value: key,
                                        child: Text(parcelle.nom),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedParcelleId = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedParcelleId != null) ...[
                            SizedBox(height: 24),
                            _buildEvolutionRendementParcelleChart(chargements, _selectedParcelleId!, parcelles),
                            SizedBox(height: 24),
                            _buildEvolutionHumiditeParcelleChart(chargements, _selectedParcelleId!, parcelles),
                          ],
                        ],
                      ),
                    ),
                    // Analyse des variétés
                    SingleChildScrollView(
                      padding: AppTheme.padding(AppTheme.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildComparaisonRendementsVarietesChart(chargements, semis, parcelles),
                          SizedBox(height: 24),
                          _buildRepartitionSurfacesVarietesChart(semis, parcelles),
                        ],
                      ),
                    ),
                    // Comparaison annuelle
                    _buildComparaisonAnnuelle(provider, statsParAnnee),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildEvolutionRendementChart(Map<int, Map<String, dynamic>> statsParAnnee) {
    final annees = statsParAnnee.keys.toList()..sort();
    if (annees.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Évolution du rendement total par an (T/ha)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              const Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Évolution du rendement total par an (T/ha)',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            annees[value.toInt()].toString(),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: annees.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          statsParAnnee[entry.value]!['poidsTotal'] / 1000,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEvolutionHumiditeChart(Map<int, Map<String, dynamic>> statsParAnnee) {
    final annees = statsParAnnee.keys.toList()..sort();
    if (annees.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Évolution de l\'humidité moyenne annuelle (%)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              const Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Évolution de l\'humidité moyenne annuelle (%)',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            annees[value.toInt()].toString(),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: annees.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          statsParAnnee[entry.value]!['humiditeMoyenne'],
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.secondary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildComparaisonRendementsParcellesChart(List<Chargement> chargements, List<Parcelle> parcelles) {
    final Map<String, double> rendements = {};
    for (var parcelle in parcelles) {
      final parcelleKey = parcelle.firebaseId ?? parcelle.id.toString();
      final chargementsParcelle = chargements
          .where((c) => c.parcelleId == parcelleKey && c.dateChargement.year == _selectedYear)
          .toList();
      if (chargementsParcelle.isNotEmpty) {
        final poidsTotal = chargementsParcelle.fold<double>(
          0,
          (sum, c) => sum + c.poidsNormes,
        );
        rendements[parcelleKey] = (poidsTotal / 1000) / parcelle.surface;
      }
    }
    if (rendements.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comparaison du rendement (T/ha) entre toutes les parcelles pour $_selectedYear',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              const Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparaison du rendement (T/ha) entre toutes les parcelles pour $_selectedYear',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: rendements.values.reduce((a, b) => a > b ? a : b) * 1.2,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final parcelleKey = rendements.keys.elementAt(value.toInt());
                          final parcelle = parcelles.firstWhere(
                            (p) => (p.firebaseId ?? p.id.toString()) == parcelleKey,
                            orElse: () => Parcelle(id: 0, nom: 'Inconnu', surface: 0, dateCreation: DateTime.now()),
                          );
                          return Padding(
                            padding: EdgeInsets.only(top: AppTheme.spacingS),
                            child: Text(
                              parcelle.nom,
                              style: AppTheme.textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: rendements.entries.map((entry) {
                    return BarChartGroupData(
                      x: rendements.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: AppTheme.primary,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEvolutionRendementParcelleChart(List<Chargement> chargements, String parcelleId, List<Parcelle> parcelles) {
    final parcelle = parcelles.firstWhere(
      (p) => (p.firebaseId ?? p.id.toString()) == parcelleId,
      orElse: () => Parcelle(id: 0, nom: 'Inconnu', surface: 0, dateCreation: DateTime.now()),
    );
    final chargementsParcelle = chargements.where((c) => c.parcelleId == parcelleId).toList();
    // Grouper les chargements par année
    final Map<int, double> rendementsParAnnee = {};
    for (var chargement in chargementsParcelle) {
      final annee = chargement.dateChargement.year;
      if (!rendementsParAnnee.containsKey(annee)) {
        rendementsParAnnee[annee] = 0.0;
      }
      rendementsParAnnee[annee] = rendementsParAnnee[annee]! + chargement.poidsNormes;
    }
    final annees = rendementsParAnnee.keys.toList()..sort();
    if (annees.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Évolution du rendement par an pour ${parcelle.nom} (T/ha)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              const Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final maxRendement = rendementsParAnnee.values.reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évolution du rendement par an pour ${parcelle.nom} (T/ha)',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            annees[value.toInt()].toString(),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: annees.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          rendementsParAnnee[entry.value]! / 1000,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.success,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY: maxRendement / 1000 * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEvolutionHumiditeParcelleChart(List<Chargement> chargements, String parcelleId, List<Parcelle> parcelles) {
    final parcelle = parcelles.firstWhere(
      (p) => (p.firebaseId ?? p.id.toString()) == parcelleId,
      orElse: () => Parcelle(id: 0, nom: 'Inconnu', surface: 0, dateCreation: DateTime.now()),
    );
    final chargementsParcelle = chargements.where((c) => c.parcelleId == parcelleId).toList();
    // Grouper les chargements par année
    final Map<int, double> humiditeParAnnee = {};
    final Map<int, int> nombreChargementsParAnnee = {};
    for (var chargement in chargementsParcelle) {
      final annee = chargement.dateChargement.year;
      if (!humiditeParAnnee.containsKey(annee)) {
        humiditeParAnnee[annee] = 0.0;
        nombreChargementsParAnnee[annee] = 0;
      }
      humiditeParAnnee[annee] = humiditeParAnnee[annee]! + chargement.humidite;
      nombreChargementsParAnnee[annee] = nombreChargementsParAnnee[annee]! + 1;
    }
    // Calculer les moyennes
    humiditeParAnnee.forEach((annee, total) {
      humiditeParAnnee[annee] = total / nombreChargementsParAnnee[annee]!;
    });
    final annees = humiditeParAnnee.keys.toList()..sort();
    if (annees.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Évolution de l\'humidité moyenne par an pour ${parcelle.nom} (%)',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 16),
              const Center(
                child: Text(
                  'Aucune donnée disponible',
                  style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final maxHumidite = humiditeParAnnee.values.reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évolution de l\'humidité moyenne par an pour ${parcelle.nom} (%)',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            annees[value.toInt()].toString(),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: AppTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: annees.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          humiditeParAnnee[entry.value]!,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.secondary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY: maxHumidite * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildComparaisonRendementsVarietesChart(List<Chargement> chargements, List<Semis> semis, List<Parcelle> parcelles) {
    final anneeSelectionnee = _selectedYear ?? DateTime.now().year;
    
    // Structure pour stocker les données par variété
    final poidsParVariete = <String, double>{};
    final surfacesParVariete = <String, double>{};
    
    // Calculer les surfaces par variété pour l'année sélectionnée
    for (var semis in semis.where((s) => s.date.year == anneeSelectionnee)) {
      for (var varieteSurface in semis.varietesSurfaces) {
        // La surface est maintenant directement en hectares dans le modèle
        surfacesParVariete[varieteSurface.nom] = (surfacesParVariete[varieteSurface.nom] ?? 0) + varieteSurface.surface;
      }
    }
    
    // Calculer les poids par variété pour l'année sélectionnée
    for (var chargement in chargements.where((c) => c.dateChargement.year == anneeSelectionnee)) {
      // Vérifier que la variété existe dans les semis de l'année
      if (surfacesParVariete.containsKey(chargement.variete)) {
        poidsParVariete[chargement.variete] = (poidsParVariete[chargement.variete] ?? 0) + chargement.poidsNormes;
      }
    }
    
    // Calculer les rendements en tonnes par hectare
    final rendementsMoyens = <String, double>{};
    surfacesParVariete.forEach((variete, surface) {
      final poidsTotal = poidsParVariete[variete] ?? 0;
      if (surface > 0) {
        rendementsMoyens[variete] = (poidsTotal / 1000) / surface; // Conversion en tonnes par hectare
      }
    });
    
    if (rendementsMoyens.isEmpty) {
      return const Center(
        child: Text('Aucune donnée disponible pour cette année'),
      );
    }
    return Column(
      children: [
        const Text(
          'Rendements par variété',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: rendementsMoyens.values.reduce((a, b) => a > b ? a : b) * 1.2,
              barGroups: rendementsMoyens.entries.map((entry) {
                return BarChartGroupData(
                  x: rendementsMoyens.keys.toList().indexOf(entry.key),
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: AppTheme.primary,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value < rendementsMoyens.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            rendementsMoyens.keys.elementAt(value.toInt()),
                            style: AppTheme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toStringAsFixed(1)} T/ha',
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildRepartitionSurfacesVarietesChart(List<Semis> semis, List<Parcelle> parcelles) {
    final anneeSelectionnee = _selectedYear ?? DateTime.now().year;
    
    // Calculer les surfaces par variété en tenant compte des pourcentages
    final surfacesParVariete = <String, double>{};
    
    // Filtrer les semis pour l'année sélectionnée
    final semisAnnee = semis.where((s) => s.date.year == anneeSelectionnee).toList();
    
    for (var semis in semisAnnee) {
      // Pour chaque variété dans le semis, ajouter sa surface réelle (déjà en hectares)
      for (var varieteSurface in semis.varietesSurfaces) {
        surfacesParVariete[varieteSurface.nom] = (surfacesParVariete[varieteSurface.nom] ?? 0) + varieteSurface.surface;
      }
    }
    
    if (surfacesParVariete.isEmpty) {
      return const Center(
        child: Text('Aucune donnée disponible pour cette année'),
      );
    }
    final totalSurface = surfacesParVariete.values.reduce((a, b) => a + b);
    
    // Définir une palette de couleurs pour les variétés
    final List<Color> couleurs = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.success,
      AppTheme.warning,
      AppTheme.error,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    
    return Column(
      children: [
        const Text(
          'Répartition des surfaces par variété',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: surfacesParVariete.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final varieteEntry = entry.value;
                return PieChartSectionData(
                  value: varieteEntry.value,
                  title: '${(varieteEntry.value / totalSurface * 100).toStringAsFixed(1)}%',
                  radius: 100,
                  color: couleurs[index % couleurs.length],
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 16,
          children: surfacesParVariete.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final varieteEntry = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: couleurs[index % couleurs.length],
                ),
                SizedBox(width: 4),
                Text(
                  '${varieteEntry.key}: ${varieteEntry.value.toStringAsFixed(1)} ha',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildComparaisonAnnuelle(FirebaseProviderV4 provider, Map<int, Map<String, dynamic>> statsParAnnee) {
    final annees = statsParAnnee.keys.toList()..sort((a, b) => b.compareTo(a));
    
    // Initialiser les années A et B si non définies
    if (_anneeA == null && annees.isNotEmpty) {
      _anneeA = annees.length > 1 ? annees[1] : annees.first;
    }
    if (_anneeB == null && annees.isNotEmpty) {
      _anneeB = annees.first;
    }
    
    if (annees.isEmpty) {
      return Center(
        child: Padding(
          padding: AppTheme.padding(AppTheme.spacingXL),
          child: Text(
            'Aucune donnée disponible pour la comparaison',
            style: AppTheme.textTheme.titleLarge,
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: AppTheme.padding(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filtres - Sélection des années
          _buildAnneesSelector(annees),
          SizedBox(height: AppTheme.spacingL),
          
          // KPI Cards
          _buildKPICards(provider, statsParAnnee),
          SizedBox(height: AppTheme.spacingL),
          
          // Analyse des écarts
          _buildAnalyseEcarts(provider, statsParAnnee),
          SizedBox(height: AppTheme.spacingL),
          
          // Tendances multi-années
          _buildTendancesMultiAnnees(statsParAnnee),
        ],
      ),
    );
  }
  
  Widget _buildAnneesSelector(List<int> annees) {
    return Card(
      color: AppTheme.surface,
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélection des années à comparer',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _anneeA,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Année A (référence)',
                      border: OutlineInputBorder(),
                    ),
                    items: annees.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _anneeA = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: AppTheme.spacingM),
                Icon(Icons.compare_arrows, color: AppTheme.primary),
                SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _anneeB,
                    decoration: AppTheme.createInputDecoration(
                      labelText: 'Année B (comparaison)',
                      border: OutlineInputBorder(),
                    ),
                    items: annees.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _anneeB = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKPICards(FirebaseProviderV4 provider, Map<int, Map<String, dynamic>> statsParAnnee) {
    if (_anneeA == null || _anneeB == null) {
      return SizedBox.shrink();
    }
    
    // Calculer les KPI pour chaque année
    final kpiA = _calculateKPIs(provider, _anneeA!);
    final kpiB = _calculateKPIs(provider, _anneeB!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicateurs clés de performance',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppTheme.spacingM),
        
        // Ligne 1: CA, Volume, Prix moyen
        Row(
          children: [
            Expanded(child: _buildKPICard('CA Total', kpiA['ca'], kpiB['ca'], '€', true)),
            SizedBox(width: AppTheme.spacingS),
            Expanded(child: _buildKPICard('Volume vendu', kpiA['volume'], kpiB['volume'], 't', false)),
            SizedBox(width: AppTheme.spacingS),
            Expanded(child: _buildKPICard('Prix moyen', kpiA['prixMoyen'], kpiB['prixMoyen'], '€/t', true)),
          ],
        ),
        SizedBox(height: AppTheme.spacingS),
        
        // Ligne 2: Surface, Rendement, Coûts
        Row(
          children: [
            Expanded(child: _buildKPICard('Surface totale', kpiA['surface'], kpiB['surface'], 'ha', false)),
            SizedBox(width: AppTheme.spacingS),
            Expanded(child: _buildKPICard('Rendement', kpiA['rendement'], kpiB['rendement'], 't/ha', true)),
            SizedBox(width: AppTheme.spacingS),
            Expanded(child: _buildKPICard('Coûts variables', kpiA['coutsVariables'], kpiB['coutsVariables'], '€', false)),
          ],
        ),
        SizedBox(height: AppTheme.spacingS),
        
        // Ligne 3: Marge brute, Prix équilibre
        Row(
          children: [
            Expanded(child: _buildKPICard('Marge brute', kpiA['margeBrute'], kpiB['margeBrute'], '€', true)),
            SizedBox(width: AppTheme.spacingS),
            Expanded(child: _buildKPICard('Marge/ha', kpiA['margeParHa'], kpiB['margeParHa'], '€/ha', true)),
            SizedBox(width: AppTheme.spacingS),
            Expanded(child: _buildKPICard('Prix équilibre', kpiA['prixEquilibre'], kpiB['prixEquilibre'], '€/t', false)),
          ],
        ),
      ],
    );
  }
  
  Map<String, double> _calculateKPIs(FirebaseProviderV4 provider, int annee) {
    final ventes = provider.ventes.where((v) => v.dateVente.year == annee).toList();
    final chargements = provider.chargements.where((c) => c.dateChargement.year == annee).toList();
    final semis = provider.semis.where((s) => s.date.year == annee).toList();
    final traitements = provider.traitements.where((t) => t.annee == annee).toList();
    final parcelles = provider.parcelles;
    
    // CA et Volume
    double ca = 0;
    double volumeVendu = 0;
    for (var vente in ventes) {
      ca += vente.prix * (vente.poidsNet / 1000); // Prix en € × tonnes
      volumeVendu += vente.poidsNet / 1000; // En tonnes
    }
    
    double prixMoyen = volumeVendu > 0 ? ca / volumeVendu : 0;
    
    // Production
    double volumeProduit = 0;
    for (var chargement in chargements) {
      volumeProduit += chargement.poidsNormes / 1000; // En tonnes
    }
    
    // Surface
    double surfaceTotale = 0;
    for (var semis in semis) {
      for (var vs in semis.varietesSurfaces) {
        surfaceTotale += vs.surface;
      }
    }
    
    double rendement = surfaceTotale > 0 ? volumeProduit / surfaceTotale : 0;
    
    // Coûts variables (semences + traitements)
    double coutsVariables = 0;
    
    // Semences
    for (var semis in semis) {
      coutsVariables += semis.prixSemis;
    }
    
    // Traitements
    for (var traitement in traitements) {
      final parcelle = parcelles.firstWhere(
        (p) => (p.firebaseId ?? p.id.toString()) == traitement.parcelleId,
        orElse: () => Parcelle(id: 0, nom: '', surface: 0, dateCreation: DateTime.now()),
      );
      final coutParHectare = traitement.produits.fold<double>(
        0.0,
        (sum, produit) => sum + produit.coutTotal,
      );
      coutsVariables += coutParHectare * parcelle.surface;
    }
    
    // Marge brute
    double margeBrute = ca - coutsVariables;
    double margeParHa = surfaceTotale > 0 ? margeBrute / surfaceTotale : 0;
    
    // Prix d'équilibre
    double prixEquilibre = volumeVendu > 0 ? coutsVariables / volumeVendu : 0;
    
    return {
      'ca': ca,
      'volume': volumeVendu,
      'prixMoyen': prixMoyen,
      'surface': surfaceTotale,
      'rendement': rendement,
      'coutsVariables': coutsVariables,
      'margeBrute': margeBrute,
      'margeParHa': margeParHa,
      'prixEquilibre': prixEquilibre,
    };
  }
  
  Widget _buildKPICard(String label, double valueA, double valueB, String unite, bool higherIsBetter) {
    final delta = valueB - valueA;
    final deltaPercent = valueA != 0 ? (delta / valueA) * 100 : 0;
    final isPositive = higherIsBetter ? delta > 0 : delta < 0;
    final color = delta == 0 ? AppTheme.textSecondary : (isPositive ? AppTheme.success : AppTheme.error);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.spacingXS),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${valueB.toStringAsFixed(1)} $unite',
                      style: AppTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'vs ${valueA.toStringAsFixed(1)}',
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          delta > 0 ? Icons.arrow_upward : (delta < 0 ? Icons.arrow_downward : Icons.remove),
                          color: color,
                          size: 16,
                        ),
                        Text(
                          '${delta.abs().toStringAsFixed(1)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${deltaPercent >= 0 ? '+' : ''}${deltaPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnalyseEcarts(FirebaseProviderV4 provider, Map<int, Map<String, dynamic>> statsParAnnee) {
    // TODO: Implémenter les analyses détaillées d'écarts
    return Card(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analyse des écarts',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Décomposition détaillée à venir : Prix/Volume, Surface/Rendement, etc.',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTendancesMultiAnnees(Map<int, Map<String, dynamic>> statsParAnnee) {
    // TODO: Implémenter les graphiques de tendances
    return Card(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendances multi-années',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Graphiques de tendances à venir : CA, Rendement, Prix, etc.',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 