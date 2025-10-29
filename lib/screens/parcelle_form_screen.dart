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
import '../providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
class ParcelleFormScreen extends StatefulWidget {
  final Parcelle? parcelle;
  const ParcelleFormScreen({Key? key, this.parcelle}) : super(key: key);
  @override
  State<ParcelleFormScreen> createState() => _ParcelleFormScreenState();
}
class _ParcelleFormScreenState extends State<ParcelleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _codeController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _anneeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    if (widget.parcelle != null) {
      _nomController.text = widget.parcelle!.nom;
      _codeController.text = widget.parcelle!.code;
      _surfaceController.text = widget.parcelle!.surface.toString();
      _anneeController.text = widget.parcelle!.annee.toString();
      _descriptionController.text = widget.parcelle!.description ?? '';
    } else {
      _anneeController.text = DateTime.now().year.toString();
    }
  }
  @override
  void dispose() {
    _nomController.dispose();
    _codeController.dispose();
    _surfaceController.dispose();
    _anneeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.parcelle != null;
    final themeProvider = context.watch<ThemeProvider>();
    final colors = AppTheme.getColors(themeProvider.isDarkMode);
    final gradients = AppTheme.getGradients(themeProvider.isDarkMode);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier la parcelle AgriCorn' : 'Nouvelle parcelle AgriCorn',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBgGradient),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(AppTheme.spacingL, AppTheme.spacingS, AppTheme.spacingL, AppTheme.spacingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                AppTheme.glassAdapted(
                  context: context,
                  padding: AppTheme.padding(AppTheme.spacingL),
                  radius: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.landscape_rounded, color: colors.primary, size: AppTheme.iconSizeM),
                          const SizedBox(width: 12),
                          Text(
                            isEditing ? 'Modifier la parcelle' : 'Créer une nouvelle parcelle',
                            style: AppTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: colors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEditing
                            ? 'Modifiez les informations de votre parcelle'
                            : 'Remplissez les informations de votre nouvelle parcelle',
                        style: AppTheme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // Formulaire
              AppTheme.glassAdapted(
                context: context,
                padding: AppTheme.padding(AppTheme.spacingL),
                radius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de base',
                      style: AppTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    // Nom de la parcelle
                    _buildTextField(
                      controller: _nomController,
                      label: 'Nom de la parcelle',
                      hint: 'Ex: Parcelle Nord',
                      icon: Icons.landscape_rounded,
                      colors: colors,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Code de la parcelle
                    _buildTextField(
                      controller: _codeController,
                      label: 'Code de la parcelle',
                      hint: 'Ex: PN001',
                      icon: Icons.tag_rounded,
                      colors: colors,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le code est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Surface et année
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _surfaceController,
                            label: 'Surface (ha)',
                            hint: 'Ex: 2.5',
                            icon: Icons.area_chart_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                return newValue.copyWith(text: newValue.text.replaceAll(',', '.'));
                              }),
                            ],
                            colors: colors,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La surface est obligatoire';
                              }
                              final surface = double.tryParse(value);
                              if (surface == null || surface <= 0) {
                                return 'Surface invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _anneeController,
                            label: 'Année',
                            hint: 'Ex: 2024',
                            icon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                            colors: colors,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'L\'année est obligatoire';
                              }
                              final annee = int.tryParse(value);
                              if (annee == null || annee < 2000 || annee > 2030) {
                                return 'Année invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (optionnel)',
                      hint: 'Ajoutez des détails sur cette parcelle...',
                      icon: Icons.description_rounded,
                      maxLines: 3,
                      colors: colors,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Glass(
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingM),
                        radius: 16,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, color: AppTheme.textPrimary, size: AppTheme.iconSizeS),
                            SizedBox(width: AppTheme.spacingS),
                            Text('Annuler', style: AppTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientButton(
                      label: isEditing ? 'Modifier' : 'Créer',
                      icon: isEditing ? Icons.save : Icons.add,
                      onPressed: _isLoading ? null : _saveParcelle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required AppThemeColors colors,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            prefixIcon: Icon(icon, color: colors.textSecondary, size: AppTheme.iconSizeM),
            filled: true,
            fillColor: colors.surface.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.surface, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.surface, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.error, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingM),
          ),
        ),
      ],
    );
  }
  Future<void> _saveParcelle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
      
      final parcelle = Parcelle(
        id: widget.parcelle?.id,
        firebaseId: widget.parcelle?.firebaseId, // ✅ Préserver le firebaseId
        nom: _nomController.text.trim(),
        code: _codeController.text.trim(),
        surface: double.parse(_surfaceController.text),
        annee: int.parse(_anneeController.text),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        dateCreation: widget.parcelle?.dateCreation ?? DateTime.now(),
      );
      if (widget.parcelle != null) {
        await provider.modifierParcelle(parcelle);
        if (mounted) {
          final themeProvider = context.watch<ThemeProvider>();
          final colors = AppTheme.getColors(themeProvider.isDarkMode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parcelle "${parcelle.nom}" modifiée avec succès'),
              backgroundColor: colors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        }
      } else {
        await provider.ajouterParcelle(parcelle);
        if (mounted) {
          final themeProvider = context.watch<ThemeProvider>();
          final colors = AppTheme.getColors(themeProvider.isDarkMode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parcelle "${parcelle.nom}" créée avec succès'),
              backgroundColor: colors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final themeProvider = context.watch<ThemeProvider>();
        final colors = AppTheme.getColors(themeProvider.isDarkMode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
