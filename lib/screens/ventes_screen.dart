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
        backgroundColor: AppTheme.success,
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
                  Icon(Icons.error, size: AppTheme.iconSizeXXL, color: AppTheme.error),
                  SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Erreur: ${provider.error}',
                    style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.error),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  ElevatedButton(
                    onPressed: () {
                      // L'initialisation est gérée par AuthGate
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('L\'initialisation est gérée automatiquement')),
                      );
                    },
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildVentesEnCours(provider),
              _buildVentesTerminees(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVenteDialog(context),
        backgroundColor: AppTheme.success,
        child: Icon(Icons.add, color: AppTheme.onPrimary),
      ),
    );
  }
  Widget _buildAnneeSelector(FirebaseProviderV4 provider) {
    final annees = provider.anneesDisponibles;
    if (annees.isEmpty) return SizedBox.shrink();
    
    // Si aucune année n'est sélectionnée, prendre la plus récente
    if (_selectedAnnee == null && annees.isNotEmpty) {
      _selectedAnnee = annees.first;
    } else if (_selectedAnnee == null) {
      _selectedAnnee = DateTime.now().year;
    }
    
    return Container(
      padding: AppTheme.padding(AppTheme.spacingM),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppTheme.success),
          SizedBox(width: AppTheme.spacingS),
          Text(
            'Année:',
            style: AppTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedAnnee,
              decoration: AppTheme.createInputDecoration(
                labelText: 'Sélectionner une année',
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
    final ventesEnCours = provider.ventesEnCours;
    
    if (ventesEnCours.isEmpty) {
      return _buildEmptyState(
        'Aucune vente en cours',
        'Commencez par ajouter votre première vente',
        Icons.shopping_cart_outlined,
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: AppTheme.padding(AppTheme.spacingM),
            itemCount: ventesEnCours.length,
            itemBuilder: (context, index) {
              final vente = ventesEnCours[index];
              return _buildVenteCard(vente, provider, isEnCours: true);
            },
          ),
        ),
        _buildTotauxVentesEnCours(provider),
      ],
    );
  }
  Widget _buildVentesTerminees(FirebaseProviderV4 provider) {
    return Column(
      children: [
        _buildAnneeSelector(provider),
        Expanded(
          child: _buildVentesTermineesContent(provider),
        ),
      ],
    );
  }
  Widget _buildVentesTermineesContent(FirebaseProviderV4 provider) {
    if (_selectedAnnee == null) {
      return Center(
        child: Text(
          'Sélectionnez une année',
          style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
      );
    }
    
    final ventesTerminees = provider.getVentesTermineesParAnnee(_selectedAnnee!);
    
    if (ventesTerminees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: AppTheme.iconSizeXXL, color: AppTheme.textLight),
            SizedBox(height: AppTheme.spacingM),
            Text(
              'Aucune vente terminée',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.spacingS),
            Text(
              'Les ventes terminées apparaîtront ici',
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: AppTheme.padding(AppTheme.spacingM),
            itemCount: ventesTerminees.length,
            itemBuilder: (context, index) {
              final vente = ventesTerminees[index];
              return _buildVenteCard(vente, provider, isEnCours: false);
            },
          ),
        ),
        _buildTotauxVentesTerminees(provider),
      ],
    );
  }
  Widget _buildStockSummary(FirebaseProviderV4 provider) {
    if (_selectedAnnee == null) return SizedBox.shrink();
    
    final stockRestant = provider.getStockRestantParAnnee(_selectedAnnee!);
    final ventesEnCours = provider.getVentesEnCoursParAnnee(_selectedAnnee!);
    final totalVentesEnCours = ventesEnCours.fold<double>(0, (sum, v) => sum + (v.poidsNet ?? v.poidsNetCalcule));
    final chiffreAffaires = provider.getChiffreAffairesParAnnee(_selectedAnnee!);
    return ModernCard(
      margin: AppTheme.padding(AppTheme.spacingM),
      child: Padding(
        padding: AppTheme.padding(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé du stock - $_selectedAnnee',
              style: AppTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.success,
              ),
            ),
            SizedBox(height: AppTheme.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock restant', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                    Text(
                      '${stockRestant.toStringAsFixed(1)} kg',
                      style: AppTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ventes en cours', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                    Text(
                      '${totalVentesEnCours.toStringAsFixed(1)} kg',
                      style: AppTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.warning),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chiffre d\'affaires', style: AppTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                    Text(
                      '${chiffreAffaires.toStringAsFixed(2)} €',
                      style: AppTheme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary),
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
      margin: EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEnCours ? AppTheme.warning : AppTheme.success,
          child: Icon(
            isEnCours ? Icons.shopping_cart : Icons.check_circle,
            color: AppTheme.onPrimary,
          ),
        ),
        title: Text(
          vente.numeroTicket,
          style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                   style: AppTheme.textTheme.bodyMedium?.copyWith(
                     color: vente.ecartPoidsNet! > 0 ? AppTheme.error : AppTheme.success,
                     fontWeight: FontWeight.bold,
                   )),
            if (vente.prix != null)
              Text('Prix total: ${vente.prix!.toStringAsFixed(2)} €'),
            if (vente.payer) 
              Text('✅ Payé - Vente terminée', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.success, fontWeight: FontWeight.bold)),
        ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppTheme.primary, size: AppTheme.iconSizeM),
              onPressed: () => _showEditVenteDialog(context, vente),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppTheme.error, size: AppTheme.iconSizeM),
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
  Widget _buildEmptyState(String title, [String? subtitle, IconData? icon]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.shopping_cart_outlined,
              size: AppTheme.iconSizeXL,
              color: AppTheme.success,
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
          Text(
            title,
            style: AppTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppTheme.spacingS),
            Text(
              subtitle,
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppTheme.spacingXL),
          ElevatedButton.icon(
            onPressed: () => _showAddVenteDialog(context),
            icon: Icon(Icons.add, color: AppTheme.onPrimary),
            label: Text(
              'Ajouter une vente',
              style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.onPrimary),
            ),
            style: AppTheme.buttonStyle(
              backgroundColor: AppTheme.success,
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingM),
            ),
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
            child: Text('Supprimer', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
  Widget _buildTotauxVentesEnCours(FirebaseProviderV4 provider) {
    final ventesEnCours = provider.ventesEnCours;
    
    final totalPoids = ventesEnCours.fold<double>(0, (sum, v) => sum + (v.poidsNet ?? v.poidsNetCalcule));
    final totalPrix = ventesEnCours.fold<double>(0, (sum, v) => sum + (v.prix ?? 0));
    final totalEcart = ventesEnCours.fold<double>(0, (sum, v) => sum + (v.ecartPoidsNet ?? 0));
    
    return Container(
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: AppTheme.warning.withOpacity(0.3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Totaux - Ventes en cours',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.warning,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem('Poids total', '${totalPoids.toStringAsFixed(1)} kg', AppTheme.warning),
              _buildTotalItem('Prix total', '${totalPrix.toStringAsFixed(2)} €', AppTheme.success),
              _buildTotalItem('Écart total', '${totalEcart.toStringAsFixed(1)} kg', AppTheme.primary),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildTotauxVentesTerminees(FirebaseProviderV4 provider) {
    if (_selectedAnnee == null) return SizedBox.shrink();
    
    final ventesTerminees = provider.getVentesTermineesParAnnee(_selectedAnnee!);
    final stockRestant = provider.getStockRestantParAnnee(_selectedAnnee!);
    
    final totalPoids = ventesTerminees.fold<double>(0, (sum, v) => sum + (v.poidsNet ?? v.poidsNetCalcule));
    final totalPrix = ventesTerminees.fold<double>(0, (sum, v) => sum + (v.prix ?? 0));
    final totalEcart = ventesTerminees.fold<double>(0, (sum, v) => sum + (v.ecartPoidsNet ?? 0));
    
    return Container(
      padding: AppTheme.padding(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: AppTheme.success.withOpacity(0.3), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Totaux - Ventes terminées ($_selectedAnnee)',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.success,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTotalItem('Poids total', '${totalPoids.toStringAsFixed(1)} kg', AppTheme.success),
              _buildTotalItem('Prix total', '${totalPrix.toStringAsFixed(2)} €', AppTheme.success),
              _buildTotalItem('Écart total', '${totalEcart.toStringAsFixed(1)} kg', AppTheme.primary),
            ],
          ),
          SizedBox(height: AppTheme.spacingS),
          Container(
            padding: AppTheme.padding(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: AppTheme.radius(AppTheme.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory, color: AppTheme.primary, size: AppTheme.iconSizeM),
                SizedBox(width: AppTheme.spacingS),
                Text(
                  'Stock restant: ${stockRestant.toStringAsFixed(1)} kg',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTotalItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
