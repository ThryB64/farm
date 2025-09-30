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
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
class ExportVentesScreen extends StatefulWidget {
  const ExportVentesScreen({Key? key}) : super(key: key);
  @override
  State<ExportVentesScreen> createState() => _ExportVentesScreenState();
}
class _ExportVentesScreenState extends State<ExportVentesScreen> {
  int? _selectedYear;
  Future<void> _generatePDF() async {
    try {
      final db = Provider.of<FirebaseProviderV4>(context, listen: false);
      final ventes = db.ventes;
      final parcelles = db.parcelles;
      final semis = db.semis;
      
      final ventesAnnee = ventes
          .where((v) => v.annee == _selectedYear)
          .toList();
      
      if (ventesAnnee.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune vente pour cette année')),
          );
        }
        return;
      }
      final pdf = pw.Document();
      // Couleurs personnalisées (même que récolte)
      final mainColor = PdfColor.fromHex('#2E7D32'); // Vert foncé
      final secondaryColor = PdfColor.fromHex('#81C784'); // Vert clair
      final headerBgColor = PdfColor.fromHex('#E8F5E9'); // Vert très clair
      // Page de garde
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) {
            return pw.Container(
              alignment: pw.Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'GAEC de la BARADE',
                    style: pw.TextStyle(
                      fontSize: 45,
                      color: mainColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'Ventes de Maïs',
                    style: pw.TextStyle(
                      fontSize: 35,
                      color: secondaryColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 60),
                  pw.Text(
                    'Année $_selectedYear',
                    style: const pw.TextStyle(
                      fontSize: 30,
                      color: PdfColors.black,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      );
      // Variables pour le résumé final
      double poidsNetTotalGlobal = 0;
      double prixTotalGlobal = 0;
      double ecartTotalGlobal = 0;
      int currentPage = 1;
      int totalPages = 1;
      // Calculer le nombre total de pages
      final ventesEnCours = ventesAnnee.where((v) => !v.terminee).toList();
      final ventesTerminees = ventesAnnee.where((v) => v.terminee).toList();
      
      totalPages += (ventesEnCours.length / 25).ceil();
      totalPages += (ventesTerminees.length / 25).ceil();
      totalPages += 2; // Pages de résumé
      // Page des ventes en cours
      if (ventesEnCours.isNotEmpty) {
        // Calculer les totaux pour les ventes en cours
        double totalPoidsNetEnCours = 0.0;
        double totalPrixEnCours = 0.0;
        double totalEcartEnCours = 0.0;
        
        for (var v in ventesEnCours) {
          totalPoidsNetEnCours += v.poidsNet ?? 0.0;
          totalPrixEnCours += v.prix ?? 0.0;
          totalEcartEnCours += v.ecartPoidsNet ?? 0.0;
        }
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    color: headerBgColor,
                    child: pw.Text(
                      'Ventes en Cours',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: mainColor,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  
                  pw.SizedBox(height: 10),
                  
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey400,
                      width: 0.5,
                    ),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.5), // DATE
                      1: const pw.FlexColumnWidth(2), // CLIENT
                      2: const pw.FlexColumnWidth(2), // REMORQUE
                      3: const pw.FlexColumnWidth(1.5), // POIDS VIDE
                      4: const pw.FlexColumnWidth(1.5), // POIDS PLEIN
                      5: const pw.FlexColumnWidth(1.5), // POIDS NET
                      6: const pw.FlexColumnWidth(1.5), // ECRAT
                      7: const pw.FlexColumnWidth(1.5), // PRIX
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: mainColor,
                        ),
                        children: [
                          _buildHeaderCell('DATE'),
                          _buildHeaderCell('CLIENT'),
                          _buildHeaderCell('REMORQUE'),
                          _buildHeaderCell('POIDS VIDE'),
                          _buildHeaderCell('POIDS PLEIN'),
                          _buildHeaderCell('POIDS NET'),
                          _buildHeaderCell('ÉCART'),
                          _buildHeaderCell('PRIX'),
                        ],
                      ),
                      ...ventesEnCours.map((v) => pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: ventesEnCours.indexOf(v) % 2 == 0 
                              ? PdfColors.white 
                              : PdfColors.grey200,
                        ),
                        children: [
                          _buildDataCell('${v.date.day}/${v.date.month}'),
                          _buildDataCell(v.client),
                          _buildDataCell(v.immatriculationRemorque),
                          _buildDataCell('${v.poidsVide.toStringAsFixed(2)} kg'),
                          _buildDataCell('${v.poidsPlein.toStringAsFixed(2)} kg'),
                          _buildDataCell('${(v.poidsNet ?? 0).toStringAsFixed(2)} kg'),
                          _buildDataCell('${(v.ecartPoidsNet ?? 0).toStringAsFixed(2)} kg'),
                          _buildDataCell('${(v.prix ?? 0).toStringAsFixed(2)} €'),
                        ],
                      )),
                    ],
                  ),
                  
                  pw.Spacer(),
                  
                  // Totaux des ventes en cours
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Poids Net: ${(totalPoidsNetEnCours / 1000).toStringAsFixed(2)} t',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        pw.Text(
                          'Total Prix: ${totalPrixEnCours.toStringAsFixed(2)} €',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        pw.Text(
                          'Total Écart: ${totalEcartEnCours.toStringAsFixed(2)} kg',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.Text(
                    'Page ${currentPage++}/$totalPages',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
      // Page des ventes terminées
      if (ventesTerminees.isNotEmpty) {
        // Calculer les totaux pour les ventes terminées
        double totalPoidsNetTerminees = 0.0;
        double totalPrixTerminees = 0.0;
        double totalEcartTerminees = 0.0;
        
        for (var v in ventesTerminees) {
          totalPoidsNetTerminees += v.poidsNet ?? 0.0;
          totalPrixTerminees += v.prix ?? 0.0;
          totalEcartTerminees += v.ecartPoidsNet ?? 0.0;
        }
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    color: headerBgColor,
                    child: pw.Text(
                      'Ventes Terminées',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: mainColor,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  
                  pw.SizedBox(height: 10),
                  
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey400,
                      width: 0.5,
                    ),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.5), // DATE
                      1: const pw.FlexColumnWidth(2), // CLIENT
                      2: const pw.FlexColumnWidth(2), // REMORQUE
                      3: const pw.FlexColumnWidth(1.5), // POIDS VIDE
                      4: const pw.FlexColumnWidth(1.5), // POIDS PLEIN
                      5: const pw.FlexColumnWidth(1.5), // POIDS NET
                      6: const pw.FlexColumnWidth(1.5), // ECRAT
                      7: const pw.FlexColumnWidth(1.5), // PRIX
                      8: const pw.FlexColumnWidth(1), // PAYÉ
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: mainColor,
                        ),
                        children: [
                          _buildHeaderCell('DATE'),
                          _buildHeaderCell('CLIENT'),
                          _buildHeaderCell('REMORQUE'),
                          _buildHeaderCell('POIDS VIDE'),
                          _buildHeaderCell('POIDS PLEIN'),
                          _buildHeaderCell('POIDS NET'),
                          _buildHeaderCell('ÉCART'),
                          _buildHeaderCell('PRIX'),
                          _buildHeaderCell('PAYÉ'),
                        ],
                      ),
                      ...ventesTerminees.map((v) => pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: ventesTerminees.indexOf(v) % 2 == 0 
                              ? PdfColors.white 
                              : PdfColors.grey200,
                        ),
                        children: [
                          _buildDataCell('${v.date.day}/${v.date.month}'),
                          _buildDataCell(v.client),
                          _buildDataCell(v.immatriculationRemorque),
                          _buildDataCell('${v.poidsVide.toStringAsFixed(2)} kg'),
                          _buildDataCell('${v.poidsPlein.toStringAsFixed(2)} kg'),
                          _buildDataCell('${(v.poidsNet ?? 0).toStringAsFixed(2)} kg'),
                          _buildDataCell('${(v.ecartPoidsNet ?? 0).toStringAsFixed(2)} kg'),
                          _buildDataCell('${(v.prix ?? 0).toStringAsFixed(2)} €'),
                          _buildDataCell(v.payer ? 'Oui' : 'Non'),
                        ],
                      )),
                    ],
                  ),
                  
                  pw.Spacer(),
                  
                  // Totaux des ventes terminées
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Poids Net: ${(totalPoidsNetTerminees / 1000).toStringAsFixed(2)} t',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        pw.Text(
                          'Total Prix: ${totalPrixTerminees.toStringAsFixed(2)} €',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        pw.Text(
                          'Total Écart: ${totalEcartTerminees.toStringAsFixed(2)} kg',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.Text(
                    'Page ${currentPage++}/$totalPages',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
      // Page de résumé global
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) {
            final totalVentes = ventesAnnee.length;
            final ventesEnCoursCount = ventesEnCours.length;
            final ventesTermineesCount = ventesTerminees.length;
            // Calculer les totaux globaux
            double poidsNetTotal = 0.0;
            double prixTotal = 0.0;
            double ecartTotal = 0.0;
            
            for (var v in ventesAnnee) {
              poidsNetTotal += v.poidsNet ?? 0.0;
              prixTotal += v.prix ?? 0.0;
              ecartTotal += v.ecartPoidsNet ?? 0.0;
            }
            final stockRestant = db.getStockRestantParAnnee(_selectedYear!);
            final chiffreAffaires = db.getChiffreAffairesParAnnee(_selectedYear!);
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  color: headerBgColor,
                  child: pw.Text(
                    'Résumé Global des Ventes',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: mainColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoBox('Total ventes', '$totalVentes'),
                    _buildInfoBox('Ventes en cours', '$ventesEnCoursCount'),
                    _buildInfoBox('Ventes terminées', '$ventesTermineesCount'),
                    _buildInfoBox('Stock restant', '${(stockRestant / 1000).toStringAsFixed(2)} t'),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoBox('Poids net total', '${(poidsNetTotal / 1000).toStringAsFixed(2)} t'),
                    _buildInfoBox('Prix total', '${prixTotal.toStringAsFixed(2)} €'),
                    _buildInfoBox('Écart total', '${ecartTotal.toStringAsFixed(2)} kg'),
                    _buildInfoBox('Chiffre d\'affaires', '${chiffreAffaires.toStringAsFixed(2)} €'),
                  ],
                ),
                pw.Spacer(),
                pw.Text(
                  'Page $totalPages/$totalPages',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    color: PdfColors.grey700,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
      );
      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'ventes_${_selectedYear}.pdf',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF des ventes généré avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du PDF: $e')),
        );
      }
    }
  }
  pw.Widget _buildHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
  pw.Widget _buildDataCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 11),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
  pw.Widget _buildInfoBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Ventes PDF'),
        backgroundColor: Colors.orange,
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final years = provider.ventes
              .map((v) => v.annee)
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));
          if (years.isEmpty) {
            return const Center(
              child: Text('Aucune donnée de vente disponible pour l\'export'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Année',
                    border: OutlineInputBorder(),
                  ),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedYear = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _selectedYear == null
                      ? null
                      : () => _generatePDF(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  icon: Icon(Icons.picture_as_pdf),
                  label: const Text('Générer PDF des Ventes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
