import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
import '../models/traitement.dart';
import '../models/parcelle.dart';
import '../models/produit.dart';
import '../models/semis.dart';

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
                    'Traitements Phytosanitaires',
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
      Map<String, double> coutsParProduit = {};

      // Grouper les traitements par parcelle
      final Map<String, List<Traitement>> traitementsParParcelle = {};
      for (final traitement in traitementsAnnee) {
        final parcelleId = traitement.parcelleId;
        traitementsParParcelle.putIfAbsent(parcelleId, () => []).add(traitement);
      }

      // Créer une page pour chaque parcelle
      for (final entry in traitementsParParcelle.entries) {
        final parcelleId = entry.key;
        final traitementsParcelle = entry.value;
        
        final parcelle = parcelles.firstWhere(
          (p) => (p.firebaseId ?? p.id.toString()) == parcelleId,
          orElse: () => Parcelle(
            id: 0,
            nom: 'Parcelle inconnue',
            surface: 0,
            dateCreation: DateTime.now(),
          ),
        );

        // Calculer le coût total pour cette parcelle
        double coutTotalParcelle = 0;
        for (final traitement in traitementsParcelle) {
          coutTotalParcelle += traitement.coutTotal;
          coutTotalGlobal += traitement.coutTotal;
          
          // Compter les coûts par produit
          for (final produit in traitement.produits) {
            final nomProduit = produit.nomProduit;
            coutsParProduit[nomProduit] = (coutsParProduit[nomProduit] ?? 0) + produit.coutTotal;
          }
        }

        // Récupérer le prix du semis pour cette parcelle
        Semis? semisParcelle;
        try {
          semisParcelle = semis.firstWhere(
            (s) => s.parcelleId == parcelleId && s.date.year == _selectedYear,
          );
        } catch (e) {
          semisParcelle = null;
        }

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (context) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(40),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // En-tête de la parcelle
                    pw.Container(
                      padding: const pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: headerBgColor,
                        borderRadius: pw.BorderRadius.circular(10),
                        border: pw.Border.all(color: mainColor, width: 2),
                      ),
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
                                // Ajouter le prix du semis si disponible
                                if (semisParcelle != null && semisParcelle.prixSemis > 0)
                                  pw.Text(
                                    'Prix semis: ${semisParcelle.prixSemis.toStringAsFixed(2)} €',
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
                            decoration: pw.BoxDecoration(color: headerBgColor),
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'DATE',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'PRODUIT',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'QUANTITÉ',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'PRIX UNIT.',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'COÛT TOTAL',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: mainColor,
                                    fontSize: 12,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'MESURE',
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
                          // Données des traitements
                          ...traitementsParcelle.expand((traitement) {
                            return traitement.produits.map((produit) {
                              return pw.TableRow(
                                children: [
                                  pw.Container(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${traitement.date.day.toString().padLeft(2, '0')}/${traitement.date.month.toString().padLeft(2, '0')}/${traitement.date.year}',
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      produit.nomProduit,
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${produit.quantite.toStringAsFixed(2)}',
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${produit.prixUnitaire.toStringAsFixed(2)} €',
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      '${produit.coutTotal.toStringAsFixed(2)} €',
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(
                                      produit.mesure,
                                      style: const pw.TextStyle(fontSize: 10),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            });
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }

      // Page de résumé final
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Titre du résumé
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: headerBgColor,
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: mainColor, width: 2),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          'RÉSUMÉ GÉNÉRAL - ANNÉE $_selectedYear',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  
                  // Coût total global
                  pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#E8F5E9'),
                      borderRadius: pw.BorderRadius.circular(10),
                      border: pw.Border.all(color: mainColor, width: 1),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'COÛT TOTAL DES TRAITEMENTS:',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                        pw.Text(
                          '${coutTotalGlobal.toStringAsFixed(2)} €',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  
                  // Résumé par produit
                  pw.Text(
                    'RÉPARTITION PAR PRODUIT:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  
                  pw.Table(
                    border: pw.TableBorder.all(color: mainColor, width: 1),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1.5),
                    },
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: headerBgColor),
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Text(
                              'PRODUIT',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: mainColor,
                                fontSize: 12,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(12),
                            child: pw.Text(
                              'COÛT TOTAL',
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
                      ...coutsParProduit.entries.map((entry) {
                        return pw.TableRow(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                entry.key,
                                style: const pw.TextStyle(fontSize: 11),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(
                                '${entry.value.toStringAsFixed(2)} €',
                                style: const pw.TextStyle(fontSize: 11),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Afficher le PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
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
          final annees = traitements.map((t) => t.annee).toSet().toList()..sort((a, b) => b.compareTo(a));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Sélecteur d'année
                DropdownButtonFormField<int>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Année',
                    border: OutlineInputBorder(),
                  ),
                  items: annees.map((annee) {
                    return DropdownMenuItem(
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
                const SizedBox(height: 32),
                
                // Bouton de génération
                ElevatedButton.icon(
                  onPressed: _selectedYear != null ? _generatePDF : null,
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