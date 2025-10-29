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
    final themeProvider = context.watch<ThemeProvider>();
    final colors = AppTheme.getColors(themeProvider.isDarkMode);
    final gradients = AppTheme.getGradients(themeProvider.isDarkMode);
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Parcelles'),
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Toggle dark/light mode
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return GestureDetector(
                onTap: () {
                  themeProvider.toggleTheme();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.brightness_6_rounded : Icons.brightness_4_rounded,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => _showAddParcelleDialog(),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Ajouter une parcelle',
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.appBackground(context),
        child: Consumer<FirebaseProviderV4>(
          builder: (context, provider, child) {
            final parcelles = List<Parcelle>.from(provider.parcelles)
              ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
            if (parcelles.isEmpty) {
              return _buildEmptyState(colors);
            }
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: parcelles.length,
              itemBuilder: (context, index) {
                final parcelle = parcelles[index];
                return _buildParcelleCard(parcelle, provider, colors);
              },
            ),
          );
        },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.primary.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddParcelleDialog(),
          backgroundColor: Colors.transparent,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
  Widget _buildEmptyState(AppThemeColors colors) {
    return Center(
      child: AppTheme.glassAdapted(
        context: context,
        padding: AppTheme.padding(AppTheme.spacingXL),
        radius: 24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withOpacity(0.15),
                    colors.primary.withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.landscape_rounded,
                size: 64,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Aucune parcelle enregistrée',
              style: AppTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Commencez par ajouter votre première parcelle',
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            ModernButton(
              text: 'Ajouter une parcelle',
              icon: Icons.add_rounded,
              onPressed: () => _showAddParcelleDialog(),
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildParcelleCard(Parcelle parcelle, FirebaseProviderV4 provider, AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: AppTheme.glassAdapted(
        context: context,
        child: GestureDetector(
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primary.withOpacity(0.15),
                          colors.primary.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.landscape_rounded,
                      color: colors.primary,
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
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingXS),
                        Text(
                          'Créée le ${_formatDate(parcelle.dateCreation)}',
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
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
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, color: colors.primary),
                            SizedBox(width: AppTheme.spacingS),
                            Text('Modifier', style: TextStyle(color: colors.textPrimary)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: colors.error),
                            SizedBox(width: AppTheme.spacingS),
                            Text('Supprimer', style: TextStyle(color: colors.textPrimary)),
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
                      Icons.area_chart_rounded,
                      colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: _buildInfoChip(
                      'Surface',
                      Icons.info_outline_rounded,
                      colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.12),
            color.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            text,
            style: AppTheme.textTheme.bodyMedium?.copyWith(
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
    final themeProvider = context.watch<ThemeProvider>();
    final colors = AppTheme.getColors(themeProvider.isDarkMode);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Nouvelle Parcelle',
          style: TextStyle(color: colors.textPrimary),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: AppTheme.createInputDecoration(
                  labelText: 'Nom de la parcelle',
                  hintText: 'Ex: Parcelle Nord',
                  prefixIcon: Icons.landscape_rounded,
                ),
                style: TextStyle(color: colors.textPrimary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) => nom = value!,
              ),
              SizedBox(height: AppTheme.spacingM),
              TextFormField(
                decoration: AppTheme.createInputDecoration(
                  labelText: 'Surface (hectares)',
                  hintText: 'Ex: 2.5',
                  prefixIcon: Icons.area_chart_rounded,
                ),
                style: TextStyle(color: colors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(text: newValue.text.replaceAll(',', '.'));
                  }),
                ],
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
                    backgroundColor: colors.success,
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
    final themeProvider = context.watch<ThemeProvider>();
    final colors = AppTheme.getColors(themeProvider.isDarkMode);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Modifier la Parcelle',
          style: TextStyle(color: colors.textPrimary),
        ),
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
                decoration: AppTheme.createInputDecoration(
                  labelText: 'Nom de la parcelle',
                  prefixIcon: Icons.landscape_rounded,
                ),
                style: TextStyle(color: colors.textPrimary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) => nom = value!,
              ),
              SizedBox(height: AppTheme.spacingM),
              TextFormField(
                initialValue: parcelle.surface.toString(),
                decoration: AppTheme.createInputDecoration(
                  labelText: 'Surface (hectares)',
                  prefixIcon: Icons.area_chart_rounded,
                ),
                style: TextStyle(color: colors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return newValue.copyWith(text: newValue.text.replaceAll(',', '.'));
                  }),
                ],
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
                    backgroundColor: colors.success,
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
    final themeProvider = context.watch<ThemeProvider>();
    final colors = AppTheme.getColors(themeProvider.isDarkMode);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(color: colors.textPrimary),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer la parcelle "${parcelle.nom}" ?',
          style: TextStyle(color: colors.textPrimary),
        ),
        actions: [
          ModernTextButton(
            text: 'Annuler',
            onPressed: () => Navigator.pop(context, false),
          ),
          ModernButton(
            text: 'Supprimer',
            backgroundColor: colors.error,
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
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }
}