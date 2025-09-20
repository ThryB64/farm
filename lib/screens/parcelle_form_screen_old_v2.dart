import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/parcelle.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';

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

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: AppColors.sand,
        foregroundColor: AppColors.deepNavy,
        elevation: 0,
        title: Text(
          isEditing ? 'Modifier la parcelle' : 'Nouvelle parcelle',
          style: AppTypography.h2Style.copyWith(
            color: AppColors.deepNavy,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.landscape,
                          color: AppColors.coral,
                          size: AppSpacing.iconSize,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          isEditing ? 'Modifier la parcelle' : 'Créer une nouvelle parcelle',
                          style: AppTypography.h2Style.copyWith(
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      isEditing
                          ? 'Modifiez les informations de votre parcelle'
                          : 'Remplissez les informations de votre nouvelle parcelle',
                      style: AppTypography.bodyStyle.copyWith(
                        color: AppColors.navy70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Formulaire
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de base',
                      style: AppTypography.h3Style.copyWith(
                        color: AppColors.deepNavy,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Nom de la parcelle
                    _buildTextField(
                      controller: _nomController,
                      label: 'Nom de la parcelle',
                      hint: 'Ex: Parcelle Nord',
                      icon: Icons.landscape,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Code de la parcelle
                    _buildTextField(
                      controller: _codeController,
                      label: 'Code de la parcelle',
                      hint: 'Ex: PN001',
                      icon: Icons.tag,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le code est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Surface et année
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _surfaceController,
                            label: 'Surface (ha)',
                            hint: 'Ex: 2.5',
                            icon: Icons.area_chart,
                            keyboardType: TextInputType.number,
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
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _buildTextField(
                            controller: _anneeController,
                            label: 'Année',
                            hint: 'Ex: 2024',
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
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

                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (optionnel)',
                      hint: 'Ajoutez des détails sur cette parcelle...',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Annuler',
                      isTertiary: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: GlassButton(
                      text: isEditing ? 'Modifier' : 'Créer',
                      icon: isEditing ? Icons.save : Icons.add,
                      isPrimary: true,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _saveParcelle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),
            ],
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
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyStyle.copyWith(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyStyle.copyWith(
              color: AppColors.navy50,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.navy70,
              size: AppSpacing.iconSize,
            ),
            filled: true,
            fillColor: AppColors.glassLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.coral, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
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
      final provider = Provider.of<FirebaseProviderV3>(context, listen: false);
      
      final parcelle = Parcelle(
        id: widget.parcelle?.id,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parcelle "${parcelle.nom}" modifiée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        await provider.ajouterParcelle(parcelle);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parcelle "${parcelle.nom}" créée avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.danger,
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
