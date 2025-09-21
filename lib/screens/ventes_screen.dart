import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/vente.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import 'vente_form_screen.dart';

class VentesScreen extends StatefulWidget {
  const VentesScreen({Key? key}) : super(key: key);

  @override
  State<VentesScreen> createState() => _VentesScreenState();
}

class _VentesScreenState extends State<VentesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedAnnee;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Ventes de Maïs'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ventes en cours'),
            Tab(text: 'Ventes terminées'),
          ],
        ),
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erreur: ${provider.error}',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.initialize(),
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildAnneeSelector(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVentesEnCours(provider),
                    _buildVentesTerminees(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddVenteDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAnneeSelector(FirebaseProviderV4 provider) {
    final annees = provider.anneesDisponibles;
    if (annees.isEmpty) return SizedBox.shrink();
    
    // Si aucune année n'est sélectionnée, prendre la plus récente
    if (_selectedAnnee == null && annees.isNotEmpty) {
      _selectedAnnee = annees.first;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.green),
          SizedBox(width: 8),
          Text(
            'Année:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedAnnee,
              decoration: InputDecoration(
                labelText: 'Sélectionner une année',
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
                  _selectedAnnee = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVentesEnCours(FirebaseProviderV4 provider) {
    if (_selectedAnnee == null) {
      return Center(child: Text('Sélectionnez une année'));
    }
    
    final ventesEnCours = provider.getVentesEnCoursParAnnee(_selectedAnnee!);
    
    if (ventesEnCours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune vente en cours',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Appuyez sur + pour ajouter une vente',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddVenteDialog(context),
              icon: Icon(Icons.add),
              label: Text('Ajouter une vente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildStockSummary(provider),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ventesEnCours.length,
            itemBuilder: (context, index) {
              final vente = ventesEnCours[index];
              return _buildVenteCard(vente, provider, isEnCours: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVentesTerminees(FirebaseProviderV4 provider) {
    if (_selectedAnnee == null) {
      return Center(child: Text('Sélectionnez une année'));
    }
    
    final ventesTerminees = provider.getVentesTermineesParAnnee(_selectedAnnee!);
    
    if (ventesTerminees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune vente terminée',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Les ventes terminées apparaîtront ici',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ventesTerminees.length,
      itemBuilder: (context, index) {
        final vente = ventesTerminees[index];
        return _buildVenteCard(vente, provider, isEnCours: false);
      },
    );
  }

  Widget _buildStockSummary(FirebaseProviderV4 provider) {
    if (_selectedAnnee == null) return SizedBox.shrink();
    
    final stockRestant = provider.getStockRestantParAnnee(_selectedAnnee!);
    final ventesEnCours = provider.getVentesEnCoursParAnnee(_selectedAnnee!);
    final totalVentesEnCours = ventesEnCours.fold<double>(0, (sum, v) => sum + (v.poidsNet ?? v.poidsNetCalcule));
    final chiffreAffaires = provider.getChiffreAffairesParAnnee(_selectedAnnee!);

    return ModernCard(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé du stock - $_selectedAnnee',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock restant', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    Text(
                      '${stockRestant.toStringAsFixed(1)} kg',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ventes en cours', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    Text(
                      '${totalVentesEnCours.toStringAsFixed(1)} kg',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chiffre d\'affaires', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    Text(
                      '${chiffreAffaires.toStringAsFixed(2)} €',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
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

  Widget _buildVenteCard(Vente vente, FirebaseProviderV4 provider, {required bool isEnCours}) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEnCours ? Colors.orange : Colors.green,
          child: Icon(
            isEnCours ? Icons.shopping_cart : Icons.check_circle,
            color: Colors.white,
          ),
        ),
        title: Text(
          vente.numeroTicket,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client: ${vente.client}'),
            Text('Date: ${_formatDate(vente.date)}'),
            Text('Année récolte: ${vente.annee}'),
            Text('Poids net final: ${(vente.poidsNet ?? vente.poidsNetCalcule).toStringAsFixed(1)} kg'),
            if (vente.ecartPoidsNet != null)
              Text('Écart client: ${vente.ecartPoidsNet!.toStringAsFixed(1)} kg', 
                   style: TextStyle(
                     color: vente.ecartPoidsNet! > 0 ? Colors.red : Colors.green,
                     fontWeight: FontWeight.bold,
                   )),
            if (vente.prix != null)
              Text('Prix total: ${vente.prix!.toStringAsFixed(2)} €'),
            if (vente.payer) 
              Text('✅ Payé - Vente terminée', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditVenteDialog(context, vente),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, vente, provider),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showQuickAddVenteDialog(BuildContext context) {
    final numeroTicketController = TextEditingController();
    final clientController = TextEditingController();
    final poidsVideController = TextEditingController();
    final poidsPleinController = TextEditingController();
    final prixController = TextEditingController();
    
    int selectedAnnee = DateTime.now().year;
    bool payer = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une vente rapide'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numeroTicketController,
                decoration: InputDecoration(
                  labelText: 'Numéro de ticket *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: clientController,
                decoration: InputDecoration(
                  labelText: 'Client *',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: poidsVideController,
                      decoration: InputDecoration(
                        labelText: 'Poids vide (kg) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: poidsPleinController,
                      decoration: InputDecoration(
                        labelText: 'Poids plein (kg) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: prixController,
                      decoration: InputDecoration(
                        labelText: 'Prix (€/tonne)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: selectedAnnee,
                      decoration: InputDecoration(
                        labelText: 'Année *',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(5, (index) => DateTime.now().year - index + 1)
                          .map((year) => DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        selectedAnnee = value!;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Payé'),
                value: payer,
                onChanged: (value) {
                  payer = value ?? false;
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (numeroTicketController.text.isEmpty || 
                  clientController.text.isEmpty ||
                  poidsVideController.text.isEmpty ||
                  poidsPleinController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
                );
                return;
              }

              try {
                final poidsVide = double.parse(poidsVideController.text);
                final poidsPlein = double.parse(poidsPleinController.text);
                final poidsNet = poidsPlein - poidsVide;
                final prixParTonne = double.tryParse(prixController.text) ?? 0;
                final prixTotal = prixParTonne * (poidsNet / 1000);

                final vente = Vente(
                  date: DateTime.now(),
                  annee: selectedAnnee,
                  numeroTicket: numeroTicketController.text.trim(),
                  client: clientController.text.trim(),
                  immatriculationRemorque: '',
                  cmr: '',
                  poidsVide: poidsVide,
                  poidsPlein: poidsPlein,
                  poidsNet: poidsNet,
                  payer: payer,
                  prix: prixTotal > 0 ? prixTotal : null,
                  terminee: payer,
                );

                final provider = context.read<FirebaseProviderV4>();
                await provider.ajouterVente(vente);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vente ajoutée avec succès')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showAddVenteDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VenteFormScreen(),
      ),
    );
  }

  void _showEditVenteDialog(BuildContext context, Vente vente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VenteFormScreen(vente: vente),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Vente vente, FirebaseProviderV4 provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la vente'),
        content: Text('Êtes-vous sûr de vouloir supprimer la vente ${vente.numeroTicket} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final key = vente.firebaseId ?? vente.id.toString();
              provider.supprimerVente(key);
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
