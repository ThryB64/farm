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
  
  // Variables pour le simulateur What-if
  double? _simPrixVente;
  double? _simRendement;
  Map<String, double> _simPrixProduits = {};
  Map<String, double> _simQteProduits = {};
  double? _beneficeCible;
  
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
            Tab(text: 'Optimisation & What-if'),
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
                    // Optimisation & What-if
                    _buildOptimisationTab(provider, statsParAnnee),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildOptimisationTab(FirebaseProviderV4 provider, Map<int, Map<String, dynamic>> statsParAnnee) {
    if (_selectedYear == null) {
      return Center(
        child: Text('Sélectionnez une année', style: AppTheme.textTheme.titleLarge),
      );
    }
    
    // Calculer les KPIs pour l'année sélectionnée
    final kpiAnnee = _calculateKPIs(provider, _selectedYear!);
    
    // Calculer la moyenne des autres années
    final autresAnnees = statsParAnnee.keys.where((a) => a != _selectedYear).toList();
    final kpiMoyenne = _calculateKPIMoyenne(provider, autresAnnees);
    
    return SingleChildScrollView(
      padding: AppTheme.padding(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPIs de l'année
          _buildKPIBanner(kpiAnnee),
          SizedBox(height: AppTheme.spacingL),
          
          // Waterfall de décomposition
          _buildWaterfallDecomposition(provider, kpiAnnee, kpiMoyenne),
          SizedBox(height: AppTheme.spacingL),
          
          // Graphique Coût/ha par produit
          _buildCoutParProduitChart(provider, statsParAnnee),
          SizedBox(height: AppTheme.spacingL),
          
          // Targets
          _buildTargetsSection(kpiAnnee),
          SizedBox(height: AppTheme.spacingL),
          
          // Simulateur What-if
          _buildSimulateurWhatIf(provider, kpiAnnee),
        ],
      ),
    );
  }
  
  Map<String, double> _calculateKPIs(FirebaseProviderV4 provider, int annee) {
    final ventes = provider.ventes.where((v) => v.date.year == annee).toList();
    final chargements = provider.chargements.where((c) => c.dateChargement.year == annee).toList();
    final semis = provider.semis.where((s) => s.date.year == annee).toList();
    final traitements = provider.traitements.where((t) => t.annee == annee).toList();
    final parcelles = provider.parcelles;
    
    // CA et Volume vendu
    double ca = 0;
    double volumeVendu = 0;
    for (var vente in ventes) {
      final prix = vente.prix ?? 0;
      final poidsNet = vente.poidsNet ?? 0;
      ca += prix * (poidsNet / 1000);
      volumeVendu += poidsNet / 1000;
    }
    
    double prixMoyen = volumeVendu > 0 ? ca / volumeVendu : 0;
    
    // Production
    double volumeProduit = 0;
    for (var chargement in chargements) {
      volumeProduit += chargement.poidsNormes / 1000;
    }
    
    // Surface
    double surfaceTotale = 0;
    for (var s in semis) {
      for (var vs in s.varietesSurfaces) {
        surfaceTotale += vs.surface;
      }
    }
    
    double rendement = surfaceTotale > 0 ? volumeProduit / surfaceTotale : 0;
    
    // Coûts variables (semences + traitements)
    double coutsVariables = 0;
    
    // Semences
    for (var s in semis) {
      coutsVariables += s.prixSemis;
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
    
    double coutsParHa = surfaceTotale > 0 ? coutsVariables / surfaceTotale : 0;
    double margeBrute = ca - coutsVariables;
    double margeParHa = surfaceTotale > 0 ? margeBrute / surfaceTotale : 0;
    
    return {
      'ca': ca,
      'volume': volumeVendu,
      'prixMoyen': prixMoyen,
      'surface': surfaceTotale,
      'rendement': rendement,
      'coutsVariables': coutsVariables,
      'coutsParHa': coutsParHa,
      'margeBrute': margeBrute,
      'margeParHa': margeParHa,
    };
  }
  
  Map<String, double> _calculateKPIMoyenne(FirebaseProviderV4 provider, List<int> annees) {
    if (annees.isEmpty) {
      return {
        'ca': 0, 'volume': 0, 'prixMoyen': 0, 'surface': 0,
        'rendement': 0, 'coutsVariables': 0, 'coutsParHa': 0,
        'margeBrute': 0, 'margeParHa': 0,
      };
    }
    
    final kpis = annees.map((a) => _calculateKPIs(provider, a)).toList();
    final n = kpis.length.toDouble();
    
    return {
      'ca': kpis.fold<double>(0.0, (sum, k) => sum + (k['ca'] as double)) / n,
      'volume': kpis.fold<double>(0.0, (sum, k) => sum + (k['volume'] as double)) / n,
      'prixMoyen': kpis.fold<double>(0.0, (sum, k) => sum + (k['prixMoyen'] as double)) / n,
      'surface': kpis.fold<double>(0.0, (sum, k) => sum + (k['surface'] as double)) / n,
      'rendement': kpis.fold<double>(0.0, (sum, k) => sum + (k['rendement'] as double)) / n,
      'coutsVariables': kpis.fold<double>(0.0, (sum, k) => sum + (k['coutsVariables'] as double)) / n,
      'coutsParHa': kpis.fold<double>(0.0, (sum, k) => sum + (k['coutsParHa'] as double)) / n,
      'margeBrute': kpis.fold<double>(0.0, (sum, k) => sum + (k['margeBrute'] as double)) / n,
      'margeParHa': kpis.fold<double>(0.0, (sum, k) => sum + (k['margeParHa'] as double)) / n,
    };
  }
  
  Widget _buildKPIBanner(Map<String, double> kpi) {
    return Card(
      color: AppTheme.primary.withOpacity(0.1),
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KPIs année $_selectedYear',
              style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildKPIItem('CA', '${kpi['ca']!.toStringAsFixed(0)} €'),
                _buildKPIItem('Prix moyen', '${kpi['prixMoyen']!.toStringAsFixed(1)} €/t'),
                _buildKPIItem('Surface', '${kpi['surface']!.toStringAsFixed(1)} ha'),
                _buildKPIItem('Rendement', '${kpi['rendement']!.toStringAsFixed(2)} t/ha'),
                _buildKPIItem('Coûts/ha', '${kpi['coutsParHa']!.toStringAsFixed(0)} €/ha'),
                _buildKPIItem('Bénéfice/ha', '${kpi['margeParHa']!.toStringAsFixed(0)} €/ha'),
                _buildKPIItem('Bénéfice total', '${kpi['margeBrute']!.toStringAsFixed(0)} €'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKPIItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
        Text(value, style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildWaterfallDecomposition(FirebaseProviderV4 provider, Map<String, double> kpiAnnee, Map<String, double> kpiMoyenne) {
    return Card(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Décomposition ΔBénéfice (vs moyenne des autres années)',
              style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Fonctionnalité en cours de développement...',
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCoutParProduitChart(FirebaseProviderV4 provider, Map<int, Map<String, dynamic>> statsParAnnee) {
    return Card(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coût/ha par produit (multi-années)',
              style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Graphique en cours de développement...',
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTargetsSection(Map<String, double> kpi) {
    return Card(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Targets - Objectifs',
              style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            TextFormField(
              decoration: AppTheme.createInputDecoration(
                labelText: 'Bénéfice cible (€)',
                hintText: 'Ex: 100000',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _beneficeCible = double.tryParse(value);
                });
              },
            ),
            SizedBox(height: AppTheme.spacingM),
            if (_beneficeCible != null) ...[
              Text(
                'Pour atteindre ${_beneficeCible!.toStringAsFixed(0)} € de bénéfice:',
                style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppTheme.spacingS),
              Text(
                'Prix cible: ${_calculatePrixCible(kpi, _beneficeCible!).toStringAsFixed(1)} €/t',
                style: AppTheme.textTheme.bodyLarge,
              ),
              Text(
                'Rendement cible: ${_calculateRendementCible(kpi, _beneficeCible!).toStringAsFixed(2)} t/ha',
                style: AppTheme.textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  double _calculatePrixCible(Map<String, double> kpi, double beneficeCible) {
    final volume = kpi['volume']!;
    if (volume == 0) return 0;
    return (kpi['coutsVariables']! + beneficeCible) / volume;
  }
  
  double _calculateRendementCible(Map<String, double> kpi, double beneficeCible) {
    final surface = kpi['surface']!;
    final prix = kpi['prixMoyen']!;
    if (surface == 0 || prix == 0) return 0;
    return (kpi['coutsVariables']! + beneficeCible) / (prix * surface);
  }
  
  Widget _buildSimulateurWhatIf(FirebaseProviderV4 provider, Map<String, double> kpi) {
    return Card(
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulateur What-if',
              style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Simulateur interactif en cours de développement...',
              style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
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
} 