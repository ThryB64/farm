import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/parcelle.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.parcelle != null) {
      _nomController.text = widget.parcelle!.nom;
      _codeController.text = widget.parcelle!.code;
      _surfaceController.text = widget.parcelle!.surface.toString();
      _anneeController.text = widget.parcelle!.annee?.toString() ?? DateTime.now().year.toString();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.parcelle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier la parcelle' : 'Nouvelle parcelle',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.sand,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _deleteParcelle,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sand, AppColors.sand],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Glass(
            padding: const EdgeInsets.all(24),
            radius: AppRadius.lg,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.landscape,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Modifier la parcelle' : 'Nouvelle parcelle',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Nom
                  _buildTextField(
                    controller: _nomController,
                    label: 'Nom de la parcelle',
                    icon: Icons.title,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Code
                  _buildTextField(
                    controller: _codeController,
                    label: 'Code de la parcelle',
                    icon: Icons.tag,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le code est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Surface
                  _buildTextField(
                    controller: _surfaceController,
                    label: 'Surface (ha)',
                    icon: Icons.area_chart,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La surface est requise';
                      }
                      final surface = double.tryParse(value);
                      if (surface == null || surface <= 0) {
                        return 'Surface invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Année
                  _buildTextField(
                    controller: _anneeController,
                    label: 'Année',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'année est requise';
                      }
                      final annee = int.tryParse(value);
                      if (annee == null || annee < 2000 || annee > DateTime.now().year + 1) {
                        return 'Année invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Annuler',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassButton(
                          label: isEditing ? 'Modifier' : 'Créer',
                          icon: isEditing ? Icons.edit : Icons.add,
                          gradient: true,
                          onPressed: _isLoading ? null : _saveParcelle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.inter(
          color: AppColors.navy,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.coral),
          labelStyle: GoogleFonts.inter(
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _saveParcelle() async {
    if (!_formKey.currentState!.validate()) return;

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
      );

      if (widget.parcelle != null) {
        await provider.modifierParcelle(parcelle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Parcelle modifiée avec succès',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.coral,
          ),
        );
      } else {
        await provider.ajouterParcelle(parcelle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Parcelle créée avec succès',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.coral,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur: $e',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteParcelle() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sand,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Supprimer la parcelle',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette parcelle ?',
          style: GoogleFonts.inter(
            color: AppColors.navy,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GlassButton(
            label: 'Supprimer',
            gradient: true,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              if (widget.parcelle?.id != null) {
                Provider.of<FirebaseProviderV3>(context, listen: false)
                    .supprimerParcelle(widget.parcelle!.id.toString());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Parcelle supprimée',
                      style: GoogleFonts.inter(),
                    ),
                    backgroundColor: AppColors.coral,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}