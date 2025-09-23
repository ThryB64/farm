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

      // Couleurs personnalisées (même que les autres)
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
                          0: const pw.FlexColumnWidth(1.5), // Date
                          1: const pw.FlexColumnWidth(2),   // Produits
                          2: const pw.FlexColumnWidth(1.5),  // Quantité
                          3: const pw.FlexColumnWidth(1.5),  // Prix unit.
                          4: const pw.FlexColumnWidth(1.5),  // Coût total
                          5: const pw.FlexColumnWidth(1),    // Notes
                        },
                        children: [
                          // En-tête du tableau
                          pw.TableRow(
                            decoration: pw.BoxDecoration(color: headerBgColor),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Date',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Produit',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Quantité',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Prix unit.',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Coût total',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Notes',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          // Lignes des traitements
                          ...pageTraitements.expand((traitement) {
                            if (traitement.produits.isEmpty) {
                              return [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${traitement.date.day}/${traitement.date.month}/${traitement.date.year}',
                                        style: const pw.TextStyle(fontSize: 10),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        'Aucun produit',
                                        style: const pw.TextStyle(fontSize: 10),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '-',
                                        style: const pw.TextStyle(fontSize: 10),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '-',
                                        style: const pw.TextStyle(fontSize: 10),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        '${traitement.coutTotal.toStringAsFixed(2)} €',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                          color: mainColor,
                                        ),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.all(8),
                                      child: pw.Text(
                                        traitement.notes ?? '',
                                        style: const pw.TextStyle(fontSize: 10),
                                        textAlign: pw.TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ];
                            }
                            
                            return traitement.produits.map((produit) {
                              return pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${produit.date.day}/${produit.date.month}/${produit.date.year}',
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      produit.nomProduit,
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${produit.quantite.toStringAsFixed(2)} ${produit.mesure}',
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${produit.prixUnitaire.toStringAsFixed(2)} €',
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${produit.coutTotal.toStringAsFixed(2)} €',
                                      style: pw.TextStyle(
                                        fontSize: 10,
                                        fontWeight: pw.FontWeight.bold,
                                        color: mainColor,
                                      ),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      traitement.notes ?? '',
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            });
                          }),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      color: headerBgColor,
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Page $currentPage sur $totalPages',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: mainColor,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'GAEC de la BARADE - Traitements $_selectedYear',
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
          currentPage++;
        }
      }

      // Page de résumé
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  color: headerBgColor,
                  child: pw.Text(
                    'RÉSUMÉ GÉNÉRAL - TRAITEMENTS $_selectedYear',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: mainColor,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Expanded(
                  child: pw.Table(
                    border: pw.TableBorder.all(color: mainColor, width: 2),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: headerBgColor),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(15),
                            child: pw.Text(
                              'NOMBRE TOTAL DE TRAITEMENTS',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: mainColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(15),
                            child: pw.Text(
                              '$nombreTraitementsTotal',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: mainColor,
                                fontSize: 16,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(15),
                            child: pw.Text(
                              'COÛT TOTAL DES TRAITEMENTS',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(15),
                            child: pw.Text(
                              '${coutTotalGlobal.toStringAsFixed(2)} €',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: mainColor,
                                fontSize: 16,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: headerBgColor),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(15),
                            child: pw.Text(
                              'NOMBRE TOTAL DE PRODUITS UTILISÉS',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: mainColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(15),
                            child: pw.Text(
                              '$nombreProduitsTotal',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: mainColor,
                                fontSize: 16,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: headerBgColor,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Page $currentPage sur $totalPages',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: mainColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'GAEC de la BARADE - Traitements $_selectedYear',
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
}