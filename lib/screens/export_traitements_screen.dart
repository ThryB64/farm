import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/traitement.dart';
import '../models/parcelle.dart';
import '../models/produit.dart';

class ExportTraitementsScreen extends StatefulWidget {
  const ExportTraitementsScreen({Key? key}) : super(key: key);

  @override
  State<ExportTraitementsScreen> createState() => _ExportTraitementsScreenState();
}

class _ExportTraitementsScreenState extends State<ExportTraitementsScreen> {
  int? _selectedYear;

  Future<void> _generatePDF() async {
    try {
      final db = Provider.of<FirebaseProviderV4>(context, listen: false);
      final traitements = db.traitements;
      final parcelles = db.parcelles;
      final produits = db.produits;
      final semis = db.semis;
      
      final traitementsAnnee = traitements
          .where((t) => t.annee == _selectedYear)
          .toList();
      
      if (traitementsAnnee.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun traitement pour cette année')),
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
                    'Traitements',
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
      double coutTotalGlobal = 0;
      int nombreTraitementsTotal = 0;
      int nombreProduitsTotal = 0;
      int currentPage = 1;
      int totalPages = 1;

      // Calculer le nombre total de pages
      for (var parcelle in parcelles) {
        final parcelleId = parcelle.firebaseId ?? parcelle.id.toString();
        final traitementsP = traitementsAnnee
            .where((t) => t.parcelleId == parcelleId)
            .toList();
        if (traitementsP.isNotEmpty) {
          totalPages += (traitementsP.length / 25).ceil();
        }
      }
      if (parcelles.isNotEmpty) totalPages += 1; // Page de résumé

      // Pour chaque parcelle
      for (var parcelle in parcelles) {
        final parcelleId = parcelle.firebaseId ?? parcelle.id.toString();
        final traitementsP = traitementsAnnee
            .where((t) => t.parcelleId == parcelleId)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        if (traitementsP.isEmpty) continue;

        nombreTraitementsTotal += traitementsP.length;
        double coutTotalParcelle = 0;
        int nombreProduitsParcelle = 0;

        for (var t in traitementsP) {
          coutTotalParcelle += t.coutTotal;
          nombreProduitsParcelle += t.produits.length;
        }

        coutTotalGlobal += coutTotalParcelle;
        nombreProduitsTotal += nombreProduitsParcelle;

        // Diviser les traitements en pages de 25 lignes
        for (var i = 0; i < traitementsP.length; i += 25) {
          final pageTraitements = traitementsP.skip(i).take(25).toList();
          
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
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Row(
                              children: [
                                pw.Text(
                                  'Parcelle: ${parcelle.nom}',
                                  style: pw.TextStyle(
                                    fontSize: 20,
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                  ),
                                ),
                                pw.SizedBox(width: 20),
                                pw.Text(
                                  'Surface: ${parcelle.surface.toStringAsFixed(2)} ha',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    color: mainColor,
                                  ),
                                ),
                                pw.SizedBox(width: 20),
                                // Ajouter le prix du semis pour cette parcelle et cette année
                                pw.Text(
                                  _getPrixSemisParcelle(parcelle, semis, _selectedYear!),
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Text(
                            'Coût total: ${coutTotalParcelle.toStringAsFixed(2)} €',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Expanded(
                      child: pw.Table(
                        border: pw.TableBorder.all(color: mainColor, width: 1),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(1.5), // DATE
                          1: const pw.FlexColumnWidth(2),   // PRODUIT
                          2: const pw.FlexColumnWidth(1.5),  // QUANTITE
                          3: const pw.FlexColumnWidth(1.5),  // PRIX UNIT
                          4: const pw.FlexColumnWidth(1.5),  // COUT TOTAL
                          5: const pw.FlexColumnWidth(1),    // MESURE
                        },
                        children: [
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: mainColor,
                            ),
                            children: [
                              _buildHeaderCell('DATE'),
                              _buildHeaderCell('PRODUIT'),
                              _buildHeaderCell('QUANTITÉ'),
                              _buildHeaderCell('PRIX UNIT'),
                              _buildHeaderCell('COÛT TOTAL'),
                              _buildHeaderCell('MESURE'),
                            ],
                          ),
                          ...pageTraitements.expand((traitement) {
                            if (traitement.produits.isEmpty) {
                              return [
                                pw.TableRow(
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.white,
                                  ),
                                  children: [
                                    _buildDataCell('${traitement.date.day}/${traitement.date.month}'),
                                    _buildDataCell('Aucun produit'),
                                    _buildDataCell('-'),
                                    _buildDataCell('-'),
                                    _buildDataCell('${traitement.coutTotal.toStringAsFixed(2)} €'),
                                    _buildDataCell('-'),
                                  ],
                                ),
                              ];
                            }
                            
                            return traitement.produits.map((produit) {
                              return pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.white,
                                ),
                                children: [
                                  _buildDataCell('${produit.date.day}/${produit.date.month}'),
                                  _buildDataCell(produit.nomProduit),
                                  _buildDataCell('${produit.quantite.toStringAsFixed(2)}'),
                                  _buildDataCell('${produit.prixUnitaire.toStringAsFixed(2)} €'),
                                  _buildDataCell('${produit.coutTotal.toStringAsFixed(2)} €'),
                                  _buildDataCell(produit.mesure),
                                ],
                              );
                            });
                          }),
                        ],
                      ),
                    ),
                    
                    pw.Spacer(),
                    
                    // Totaux de la parcelle
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total Traitements: ${traitementsP.length}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                          pw.Text(
                            'Total Coût: ${coutTotalParcelle.toStringAsFixed(2)} €',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                          pw.Text(
                            'Produits utilisés: $nombreProduitsParcelle',
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
      }

      // Page de résumé global (même design que les autres pages)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // En-tête avec le même style que les autres pages
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: mainColor,
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(10),
                      topRight: pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Icon(
                        pw.IconData(0xe8b5), // Icône analytics
                        color: PdfColors.white,
                        size: 24,
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        'RÉSUMÉ GÉNÉRAL - TRAITEMENTS $_selectedYear',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Contenu principal avec le même style
                pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(20),
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: mainColor, width: 2),
                      // Note: BoxShadow non supporté dans le package PDF
                    ),
                    child: pw.Column(
                      children: [
                        // Statistiques avec le même style que les cartes
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: _buildStatCard(
                                'Traitements',
                                '$nombreTraitementsTotal',
                                'Traitements effectués',
                                mainColor,
                              ),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Expanded(
                              child: _buildStatCard(
                                'Coût total',
                                '${coutTotalGlobal.toStringAsFixed(2)} €',
                                'Coût des traitements',
                                secondaryColor,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 20),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: _buildStatCard(
                                'Produits',
                                '$nombreProduitsTotal',
                                'Produits utilisés',
                                mainColor,
                              ),
                            ),
                            pw.SizedBox(width: 20),
                            pw.Expanded(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(20),
                                decoration: pw.BoxDecoration(
                                  color: headerBgColor,
                                  borderRadius: pw.BorderRadius.circular(10),
                                  border: pw.Border.all(color: mainColor, width: 1),
                                ),
                                child: pw.Column(
                                  children: [
                                    pw.Text(
                                      'Année',
                                      style: pw.TextStyle(
                                        fontSize: 12,
                                        color: mainColor,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                      '$_selectedYear',
                                      style: pw.TextStyle(
                                        fontSize: 18,
                                        color: mainColor,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Pied de page avec le même style
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: headerBgColor,
                    borderRadius: const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(10),
                      bottomRight: pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'GAEC de la BARADE - Traitements $_selectedYear',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: mainColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: mainColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Traitements_$_selectedYear.pdf',
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération du PDF: $e')),
        );
      }
    }
  }

  pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          fontSize: 12,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildDataCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildStatCard(String title, String value, String subtitle, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: color, width: 1),
        // Note: BoxShadow non supporté dans le package PDF
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 24,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export PDF Traitements'),
        backgroundColor: Colors.orange,
      ),
      body: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final traitements = provider.traitements;
          final annees = traitements
              .map((t) => t.annee)
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));

          if (annees.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.science,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun traitement enregistré',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sélectionner l\'année',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedYear ?? annees.first,
                          decoration: const InputDecoration(
                            labelText: 'Année',
                            border: OutlineInputBorder(),
                          ),
                          items: annees.map((annee) {
                            return DropdownMenuItem<int>(
                              value: annee,
                              child: Text(annee.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _generatePDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Générer le PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getPrixSemisParcelle(Parcelle parcelle, List<dynamic> semis, int annee) {
    try {
      final semisParcelle = semis.firstWhere(
        (s) => s.parcelleId == parcelle.firebaseId && s.date.year == annee,
        orElse: () => null,
      );
      if (semisParcelle != null && semisParcelle.prixSemis > 0) {
        return 'Prix semis: ${semisParcelle.prixSemis.toStringAsFixed(2)} €';
      } else {
        return 'Prix semis: Non défini';
      }
    } catch (e) {
      return 'Prix semis: Non défini';
    }
  }
}