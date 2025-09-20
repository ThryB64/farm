import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/firebase_provider_v3.dart';
import '../models/parcelle.dart';
import '../models/chargement.dart';
import '../models/semis.dart';
import '../theme/app_theme.dart';
import '../widgets/glass.dart';
import 'parcelle_form_screen.dart';

class ParcelleDetailsScreen extends StatefulWidget {
  final Parcelle parcelle;

  const ParcelleDetailsScreen({Key? key, required this.parcelle}) : super(key: key);

  @override
  State<ParcelleDetailsScreen> createState() => _ParcelleDetailsScreenState();
}

class _ParcelleDetailsScreenState extends State<ParcelleDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.parcelle.nom,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.sand,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParcelleFormScreen(parcelle: widget.parcelle),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: AppColors.navy),
          ),
        ],
      ),
      body: Consumer<FirebaseProviderV3>(
        builder: (context, provider, child) {
          final chargements = provider.chargements
              .where((c) => c.parcelleId == widget.parcelle.id)
              .toList();
          final semis = provider.semis
              .where((s) => s.parcelleId == widget.parcelle.id)
              .toList();

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.sand, AppColors.sand],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations principales
                  Glass(
                    padding: const EdgeInsets.all(20),
                    radius: AppRadius.lg,
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
                            Expanded(
                              child: Text(
                                widget.parcelle.nom,
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.navy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Surface',
                                '${widget.parcelle.surface.toStringAsFixed(2)} ha',
                                Icons.area_chart,
                                AppColors.coral,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Code',
                                widget.parcelle.code,
                                Icons.tag,
                                AppColors.salmon,
                              ),
                            ),
                          ],
                        ),
                        if (widget.parcelle.annee != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Année',
                            widget.parcelle.annee.toString(),
                            Icons.calendar_today,
                            AppColors.navy,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Statistiques
                  Glass(
                    padding: const EdgeInsets.all(20),
                    radius: AppRadius.lg,
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
                                Icons.analytics,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Statistiques',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Chargements',
                                chargements.length.toString(),
                                Icons.local_shipping,
                                AppColors.coral,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Semis',
                                semis.length.toString(),
                                Icons.grass,
                                AppColors.salmon,
                              ),
                            ),
                          ],
                        ),
                        if (chargements.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Poids total',
                            '${(chargements.fold<double>(0, (sum, c) => sum + c.poidsNormes) / 1000).toStringAsFixed(2)} T',
                            Icons.scale,
                            AppColors.navy,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chargements
                  if (chargements.isNotEmpty) ...[
                    Text(
                      'Chargements',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...chargements.map((chargement) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        onTap: () {
                          // Navigation vers détails du chargement
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.coral.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                color: AppColors.coral,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${chargement.poidsNormes.toStringAsFixed(0)} kg',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  Text(
                                    '${chargement.dateChargement.day}/${chargement.dateChargement.month}/${chargement.dateChargement.year}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],

                  // Semis
                  if (semis.isNotEmpty) ...[
                    Text(
                      'Semis',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...semis.map((s) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        onTap: () {
                          // Navigation vers détails du semis
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.salmon.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: const Icon(
                                Icons.grass,
                                color: AppColors.salmon,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${s.varietes.length} variétés',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy,
                                    ),
                                  ),
                                  Text(
                                    '${s.dateSemis.day}/${s.dateSemis.month}/${s.dateSemis.year}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          );
        },
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}