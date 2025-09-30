import '../models/variete.dart';
import '../models/parcelle.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_buttons.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import 'parcelle_details_screen.dart';

class ParcellesScreen extends StatefulWidget {
  const ParcellesScreen({Key? key}) : super(key: key);

  @override
  State<ParcellesScreen> createState() => _ParcellesScreenState();
}

class _ParcellesScreenState extends State<ParcellesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Parcelles'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showAddParcelleDialog(),
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une parcelle',
          ),
        ],
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final parcelles = List<Parcelle>.from(provider.parcelles)
            ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));

          if (parcelles.isEmpty) {
            return _buildEmptyState();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: parcelles.length,
              itemBuilder: (context, index) {
                final parcelle = parcelles[index];
                return _buildParcelleCard(parcelle, provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddParcelleDialog(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.landscape,
              size: 64,
              color: AppTheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Aucune parcelle enregistrée',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Commencez par ajouter votre première parcelle',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          ModernButton(
            text: 'Ajouter une parcelle',
            icon: Icons.add,
            onPressed: () => _showAddParcelleDialog(),
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildParcelleCard(Parcelle parcelle, FirebaseProviderV4 provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: ModernCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParcelleDetailsScreen(parcelle: parcelle),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: const Icon(
                    Icons.landscape,
                    color: AppTheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parcelle.nom,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Créée le ${_formatDate(parcelle.dateCreation)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditParcelleDialog(parcelle);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(parcelle);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppTheme.primary),
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
                    '${parcelle.surface} ha',
                    Icons.area_chart,
                    AppTheme.primary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: _buildInfoChip(
                    'Surface',
                    Icons.info_outline,
                    AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showAddParcelleDialog() async {
    final formKey = GlobalKey<FormState>();
    String nom = '';
    double surface = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle Parcelle'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nom de la parcelle',
                  hintText: 'Ex: Parcelle Nord',
                  prefixIcon: Icon(Icons.landscape),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) => nom = value!,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Surface (hectares)',
                  hintText: 'Ex: 2.5',
                  prefixIcon: Icon(Icons.area_chart),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une surface';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                onSaved: (value) => surface = double.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          ModernTextButton(
            text: 'Annuler',
            onPressed: () => Navigator.pop(context),
          ),
          ModernButton(
            text: 'Ajouter',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final parcelle = Parcelle(
                  nom: nom,
                  surface: surface,
                );
                context.read<FirebaseProviderV4>().ajouterParcelle(parcelle);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Parcelle ajoutée avec succès'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditParcelleDialog(Parcelle parcelle) async {
    final formKey = GlobalKey<FormState>();
    String nom = parcelle.nom;
    double surface = parcelle.surface;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la Parcelle'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: parcelle.nom,
                decoration: const InputDecoration(
                  labelText: 'Nom de la parcelle',
                  prefixIcon: Icon(Icons.landscape),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) => nom = value!,
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextFormField(
                initialValue: parcelle.surface.toString(),
                decoration: const InputDecoration(
                  labelText: 'Surface (hectares)',
                  prefixIcon: Icon(Icons.area_chart),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une surface';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
                onSaved: (value) => surface = double.parse(value!),
              ),
            ],
          ),
        ),
        actions: [
          ModernTextButton(
            text: 'Annuler',
            onPressed: () => Navigator.pop(context),
          ),
          ModernButton(
            text: 'Modifier',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final parcelleModifiee = Parcelle(
                  id: parcelle.id,
                  firebaseId: parcelle.firebaseId, // ✅ Préserver le firebaseId
                  nom: nom,
                  surface: surface,
                  dateCreation: parcelle.dateCreation,
                );
                context.read<FirebaseProviderV4>().modifierParcelle(parcelleModifiee);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Parcelle modifiée avec succès'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Parcelle parcelle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        content: Text('Voulez-vous vraiment supprimer la parcelle "${parcelle.nom}" ?'),
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
      final key = parcelle.firebaseId ?? parcelle.id.toString();
      context.read<FirebaseProviderV4>().supprimerParcelle(key);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Parcelle supprimée'),
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