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
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier la parcelle' : 'Nouvelle parcelle',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Glass(
                padding: const EdgeInsets.all(20),
                radius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.landscape, color: AppColors.coral, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          isEditing ? 'Modifier la parcelle' : 'Créer une nouvelle parcelle',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing
                          ? 'Modifiez les informations de votre parcelle'
                          : 'Remplissez les informations de votre nouvelle parcelle',
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Formulaire
              Glass(
                padding: const EdgeInsets.all(20),
                radius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de base',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navy),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
                        const SizedBox(width: 16),
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
                    const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Glass(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        radius: 16,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, color: AppColors.navy, size: 18),
                            SizedBox(width: 8),
                            Text('Annuler', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600)),
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
          style: const TextStyle(fontSize: 14, color: AppColors.navy, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.coral, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parcelle "${parcelle.nom}" modifiée avec succès'),
              backgroundColor: AppColors.coral,
            ),
          );
        }
      } else {
        await provider.ajouterParcelle(parcelle);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parcelle "${parcelle.nom}" créée avec succès'),
              backgroundColor: AppColors.coral,
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
            backgroundColor: Colors.red,
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
