import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/chargement.dart';
import '../models/vente.dart';
import '../models/traitement.dart';
import '../models/semis.dart';
import '../models/parcelle.dart';

class ExportBilanCampagneScreen extends StatefulWidget {
  final Map<String, dynamic> params;

  const ExportBilanCampagneScreen({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  State<ExportBilanCampagneScreen> createState() => _ExportBilanCampagneScreenState();
}

class _ExportBilanCampagneScreenState extends State<ExportBilanCampagneScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Génération Bilan de Campagne'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Génération du bilan en cours...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Campagne ${widget.params['annee']}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generatePDF,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Générer PDF'),
      ),
    );
  }

  Future<void> _generatePDF() async {
    try {
      final provider = Provider.of<FirebaseProviderV4>(context, listen: false);
      final annee = widget.params['annee'] as int;

      // Charger les données
      final chargements = provider.chargements
          .where((c) => c.date.year == annee)
          .toList();
      final ventes = provider.ventes
          .where((v) => v.date.year == annee)
          .toList();
      final traitements = provider.traitements
          .where((t) => t.annee == annee)
          .toList();
      final semis = provider.semis
          .where((s) => s.date.year == annee)
          .toList();
      final parcelles = provider.parcelles;

      if (chargements.isEmpty && ventes.isEmpty && traitements.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune donnée pour cette campagne')),
        );
        return;
      }

      // Générer le PDF
      final pdf = await _buildPDF(
        provider,
        annee,
        chargements,
        ventes,
        traitements,
        semis,
        parcelles,
      );

      // Afficher le PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Bilan_Campagne_$annee.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<pw.Document> _buildPDF(
    FirebaseProviderV4 provider,
    int annee,
    List<Chargement> chargements,
    List<Vente> ventes,
    List<Traitement> traitements,
    List<Semis> semis,
    List<Parcelle> parcelles,
  ) async {
    final pdf = pw.Document();
    final mainColor = PdfColor.fromHex('#2E7D32');
    final secondaryColor = PdfColor.fromHex('#81C784');
    final headerBgColor = PdfColor.fromHex('#E8F5E9');

    // CALCULS DE BASE
    final kpi = _calculateKPI(
      chargements,
      ventes,
      traitements,
      semis,
      parcelles,
      annee,
      widget.params,
    );

    // PAGE DE GARDE
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'GAEC de la BARADE',
                  style: pw.TextStyle(
                    fontSize: 45,
                    color: mainColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: pw.BoxDecoration(
                    color: secondaryColor,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    'BILAN DE CAMPAGNE',
                    style: pw.TextStyle(
                      fontSize: 35,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 60),
                pw.Text(
                  'Campagne $annee',
                  style: const pw.TextStyle(
                    fontSize: 30,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Production • Intrants • Ventes • Marge',
                  style: pw.TextStyle(
                    fontSize: 18,
                    color: mainColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // SOMMAIRE
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SOMMAIRE',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: mainColor,
                ),
              ),
              pw.SizedBox(height: 30),
              _buildSommaireItem('1. Synthèse Exécutive', 3, mainColor),
              _buildSommaireItem('2. Production & Récolte', 4, mainColor),
              _buildSommaireItem('3. Intrants & Charges "Champ"', 5, mainColor),
              _buildSommaireItem('4. Ventes, Prix & Stock', 6, mainColor),
              _buildSommaireItem('5. Économie de Campagne (Marge)', 7, mainColor),
              _buildSommaireItem('6. Qualité & Humidité (Séchage)', 8, mainColor),
              _buildSommaireItem('7. Logistique & Traçabilité', 9, mainColor),
              _buildSommaireItem('8. Anomalies & Points d\'attention', 10, mainColor),
              _buildSommaireItem('9. Plan d\'action & Objectifs N+1', 11, mainColor),
              _buildSommaireItem('10. Annexes', 12, mainColor),
            ],
          );
        },
      ),
    );

    // SYNTHÈSE EXÉCUTIVE
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. SYNTHÈSE EXÉCUTIVE', mainColor),
              pw.SizedBox(height: 20),
              // KPI Cards
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildKPICard('Surface', '${kpi['surfaceTotale'].toStringAsFixed(2)} ha', mainColor),
                  _buildKPICard('Production', '${kpi['poidsNetTotal'].toStringAsFixed(2)} t', mainColor),
                  _buildKPICard('Rendement', '${kpi['rendementMoyen'].toStringAsFixed(2)} t/ha', mainColor),
                  _buildKPICard('Charges', '${kpi['chargesTotal'].toStringAsFixed(2)} €', mainColor),
                  _buildKPICard('CA Ventes', '${kpi['caVentes'].toStringAsFixed(2)} €', mainColor),
                  _buildKPICard('Stock', '${kpi['stockRestant'].toStringAsFixed(2)} t', mainColor),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: headerBgColor,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: mainColor, width: 2),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INDICATEURS CLÉS',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildIndicateur('Prix moyen vendu', '${kpi['prixMoyenVendu'].toStringAsFixed(2)} €/t'),
                    _buildIndicateur('Coût/ha', '${kpi['coutHa'].toStringAsFixed(2)} €/ha'),
                    _buildIndicateur('Coût/t', '${kpi['coutT'].toStringAsFixed(2)} €/t'),
                    _buildIndicateur('% Récolte vendue', '${kpi['pourcentageVendu'].toStringAsFixed(1)} %'),
                    pw.Divider(),
                    pw.Text(
                      'MARGE BRUTE: ${kpi['margeBrute'].toStringAsFixed(2)} €',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    pw.Text(
                      'Marge/ha: ${kpi['margeHa'].toStringAsFixed(2)} €/ha',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Note de bas de page
    final dateGeneration = DateTime.now();
    final footerText = 'GAEC de la BARADE - Bilan Campagne $annee - Généré le ${dateGeneration.day}/${dateGeneration.month}/${dateGeneration.year}';

    return pdf;
  }

  Map<String, dynamic> _calculateKPI(
    List<Chargement> chargements,
    List<Vente> ventes,
    List<Traitement> traitements,
    List<Semis> semis,
    List<Parcelle> parcelles,
    int annee,
    Map<String, dynamic> params,
  ) {
    // RÉCOLTE - Calculer surface unique
    final parcellesRecoltees = chargements.map((c) => c.parcelleId).toSet();
    final surfaceTotaleReelle = parcellesRecoltees.fold<double>(0.0, (sum, parcelleId) {
      final parcelle = parcelles.firstWhere(
        (p) => (p.firebaseId ?? p.id.toString()) == parcelleId,
        orElse: () => parcelles.first,
      );
      return sum + parcelle.surface;
    });

    final poidsNetTotal = chargements.fold<double>(0.0, (sum, c) => sum + c.poidsNet);
    final poidsNormesTotal = chargements.fold<double>(0.0, (sum, c) => sum + c.poidsNormes);
    final rendementMoyen = surfaceTotaleReelle > 0 ? poidsNetTotal / surfaceTotaleReelle : 0.0;

    // VENTES
    final tonnesVendues = ventes.fold<double>(0.0, (sum, v) => sum + v.poidsNet);
    final caVentes = ventes.fold<double>(0.0, (sum, v) => sum + v.prix);
    final ecartTotal = ventes.fold<double>(0.0, (sum, v) => sum + v.ecartPoidsNet);
    final stockRestant = poidsNetTotal - tonnesVendues;
    final prixMoyenVendu = tonnesVendues > 0 ? caVentes / tonnesVendues : 0.0;

    // INTRANTS (TRAITEMENTS)
    double chargesTotal = 0.0;
    final produitsAgreges = <String, Map<String, dynamic>>{};

    for (var parcelle in parcelles) {
      final parcelleId = parcelle.firebaseId ?? parcelle.id.toString();
      final traitementsP = traitements.where((t) => t.parcelleId == parcelleId).toList();

      for (var t in traitementsP) {
        final coutParHectare = t.produits.fold<double>(0.0, (sum, p) => sum + p.coutTotal);
        chargesTotal += coutParHectare * parcelle.surface;
      }
    }

    // MARGE
    final prixValoStock = params['usePrixMoyenVendu'] == true 
        ? prixMoyenVendu 
        : (params['prixValorisationStock'] as double? ?? prixMoyenVendu);
    
    final valorisationStock = stockRestant * prixValoStock;
    final produitTotal = caVentes + valorisationStock;
    final margeBrute = produitTotal - chargesTotal;
    final margeHa = surfaceTotaleReelle > 0 ? margeBrute / surfaceTotaleReelle : 0.0;
    final margeT = poidsNetTotal > 0 ? margeBrute / poidsNetTotal : 0.0;

    final coutHa = surfaceTotaleReelle > 0 ? chargesTotal / surfaceTotaleReelle : 0.0;
    final coutT = poidsNetTotal > 0 ? chargesTotal / poidsNetTotal : 0.0;

    final pourcentageVendu = poidsNetTotal > 0 ? (tonnesVendues / poidsNetTotal) * 100 : 0.0;

    return {
      'surfaceTotale': surfaceTotaleReelle,
      'poidsNetTotal': poidsNetTotal,
      'poidsNormesTotal': poidsNormesTotal,
      'rendementMoyen': rendementMoyen,
      'tonnesVendues': tonnesVendues,
      'caVentes': caVentes,
      'ecartTotal': ecartTotal,
      'stockRestant': stockRestant,
      'prixMoyenVendu': prixMoyenVendu,
      'chargesTotal': chargesTotal,
      'prixValoStock': prixValoStock,
      'valorisationStock': valorisationStock,
      'produitTotal': produitTotal,
      'margeBrute': margeBrute,
      'margeHa': margeHa,
      'margeT': margeT,
      'coutHa': coutHa,
      'coutT': coutT,
      'pourcentageVendu': pourcentageVendu,
    };
  }

  pw.Widget _buildSommaireItem(String title, int page, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
          pw.Text(
            page.toString(),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 22,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _buildKPICard(String label, String value, PdfColor color) {
    return pw.Container(
      width: 180,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildIndicateur(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

