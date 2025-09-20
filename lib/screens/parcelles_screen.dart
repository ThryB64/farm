import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/parcelle.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'parcelle_details_screen.dart';
import 'parcelle_form_screen.dart';

class ParcellesScreen extends StatelessWidget {
  const ParcellesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parcelles',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.sand,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final parcelles = provider.parcelles;
          final isLoading = provider.isLoading;

          if (isLoading) {
            return Center(
              child: Glass(
                padding: const EdgeInsets.all(40),
                radius: AppRadius.lg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.coral,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement des parcelles...',
                      style: GoogleFonts.inter(
                        color: AppColors.navy,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (parcelles.isEmpty) {
            return Center(
              child: Glass(
                padding: const EdgeInsets.all(40),
                radius: AppRadius.lg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.landscape,
                      size: 64,
                      color: AppColors.coral,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune parcelle',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajoutez votre première parcelle',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassButton(
                      label: 'Ajouter une parcelle',
                      icon: Icons.add,
                      gradient: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ParcelleFormScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.sand, AppColors.sand],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: parcelles.length,
              itemBuilder: (context, index) {
                final parcelle = parcelles[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParcelleDetailsScreen(parcelle: parcelle),
                        ),
                      );
                    },
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
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                parcelle.nom,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ParcelleFormScreen(parcelle: parcelle),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, provider, parcelle);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, color: AppColors.navy),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Modifier',
                                        style: GoogleFonts.inter(
                                          color: AppColors.navy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Supprimer',
                                        style: GoogleFonts.inter(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Surface',
                                '${parcelle.surface.toStringAsFixed(2)} ha',
                                Icons.area_chart,
                                AppColors.coral,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Code',
                                parcelle.code,
                                Icons.tag,
                                AppColors.salmon,
                              ),
                            ),
                          ],
                        ),
                        if (parcelle.annee != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Année',
                                  parcelle.annee.toString(),
                                  Icons.calendar_today,
                                  AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ParcelleFormScreen(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: GlassButton(
          label: 'Ajouter',
          icon: Icons.add,
          gradient: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ParcelleFormScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FirebaseProviderV3 provider, Parcelle parcelle) {
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
          'Êtes-vous sûr de vouloir supprimer la parcelle "${parcelle.nom}" ?',
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
              if (parcelle.id != null) {
                provider.supprimerParcelle(parcelle.id.toString());
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