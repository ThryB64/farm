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
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider_v4.dart';
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
      // Calculer le nombre total de pages (sera mis à jour dynamiquement)
      // Note: le calcul exact sera fait pendant la génération des pages
      // Pour chaque parcelle
      for (var parcelle in parcelles) {
        final parcelleId = parcelle.firebaseId ?? parcelle.id.toString();
        final traitementsP = traitementsAnnee
            .where((t) => t.parcelleId == parcelleId)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        // Vérifier s'il y a un semis même si pas de traitements
        Semis? semisParcelle;
        try {
          semisParcelle = semis.firstWhere(
            (s) => s.parcelleId == parcelle.firebaseId && s.date.year == _selectedYear,
          );
        } catch (e) {
          semisParcelle = null;
        }
        
        if (traitementsP.isEmpty && (semisParcelle == null || semisParcelle.prixSemis <= 0)) continue;
        nombreTraitementsTotal += traitementsP.length;
        double coutTotalParcelle = 0;
        
        // Ajouter le coût du semis
        if (semisParcelle != null && semisParcelle.prixSemis > 0) {
          coutTotalParcelle += semisParcelle.prixSemis;
          print('💰 Coût semis ajouté pour ${parcelle.nom}: ${semisParcelle.prixSemis}');
        }
        for (var t in traitementsP) {
          // Recalculer le coût à partir des produits (coût/ha × surface)
          final coutParHectare = t.produits.fold<double>(
            0.0,
            (sum, produit) => sum + produit.coutTotal,
          );
          coutTotalParcelle += coutParHectare * parcelle.surface;
        }
        coutTotalGlobal += coutTotalParcelle;
        
        // Créer une liste de toutes les lignes à afficher (produits)
        final List<Map<String, dynamic>> lignesAffichage = [];
        
        // Ajouter le semis si présent
        if (semisParcelle != null && semisParcelle.prixSemis > 0) {
          lignesAffichage.add({
            'type': 'semis',
            'semis': semisParcelle,
          });
        }
        
        // Ajouter tous les produits de tous les traitements
        for (var traitement in traitementsP) {
          if (traitement.produits.isNotEmpty) {
            for (var produit in traitement.produits) {
              lignesAffichage.add({
                'type': 'produit',
                'produit': produit,
              });
            }
          }
        }
        
        // Si aucune ligne à afficher, passer à la parcelle suivante
        if (lignesAffichage.isEmpty) continue;
        
        // Compter uniquement les produits (pas le semis) pour les statistiques
        final nombreProduitsParcelle = lignesAffichage.where((l) => l['type'] == 'produit').length;
        nombreProduitsTotal += nombreProduitsParcelle;
        
        // Diviser les lignes en pages de 15 lignes maximum (sécurité maximale)
        for (var i = 0; i < lignesAffichage.length; i += 15) {
          final pageLignes = lignesAffichage.skip(i).take(15).toList();
          
          // Compter les produits sur CETTE page uniquement
          final produitsPageActuelle = pageLignes.where((l) => l['type'] == 'produit').length;
          
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
                        // Prix semis retiré de l'en-tête car affiché dans le tableau
                              ],
                            ),
                          ),
                          pw.Text(
                            'Coût total: ${coutTotalParcelle.toStringAsFixed(2)}',
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
                          // Afficher toutes les lignes (semis + produits)
                          ...pageLignes.map((ligne) {
                            if (ligne['type'] == 'semis') {
                              final Semis semis = ligne['semis'];
                              final varietesText = semis.varietesSurfaces
                                  .map((vs) => '${vs.nom} (${vs.surface.toStringAsFixed(2)} ha)')
                                  .join(', ');
                              return pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey200,
                                ),
                                children: [
                                  _buildDataCell('${semis.date.day}/${semis.date.month}'),
                                  _buildDataCell('SEMIS: $varietesText'),
                                  _buildDataCell('${semis.densiteMais.toStringAsFixed(0)}'),
                                  _buildDataCell('${semis.prixSemis.toStringAsFixed(2)}'),
                                  _buildDataCell('${semis.prixSemis.toStringAsFixed(2)}'),
                                  _buildDataCell('grains/ha'),
                                ],
                              );
                            } else {
                              final ProduitTraitement produit = ligne['produit'];
                              return pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.white,
                                ),
                                children: [
                                  _buildDataCell('${produit.date.day}/${produit.date.month}'),
                                  _buildDataCell(produit.nomProduit),
                                  _buildDataCell('${produit.quantite.toStringAsFixed(2)}'),
                                  _buildDataCell('${produit.prixUnitaire.toStringAsFixed(2)}'),
                                  _buildDataCell('${produit.coutTotal.toStringAsFixed(2)}'),
                                  _buildDataCell(produit.mesure),
                                ],
                              );
                            }
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
                            'Total Coût: ${coutTotalParcelle.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                          pw.Text(
                            'Produits (page): $produitsPageActuelle / Total: $nombreProduitsParcelle',
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
                                '${coutTotalGlobal.toStringAsFixed(2)}',
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
    // Nettoyer le texte pour enlever les caractères problématiques et les euros
    final cleanText = text.replaceAll(RegExp(r'[^\w\s\.,\-/]'), '').replaceAll('€', '');
    
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        cleanText,
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
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.appBgGradient),
        child: Consumer<FirebaseProviderV4>(
        builder: (context, provider, child) {
          final traitements = provider.traitements;
          final annees = traitements
              .map((t) => t.annee)
              .toSet()
              .toList()
            ..sort((a, b) => b.compareTo(a));
          if (annees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.science,
                    size: AppTheme.iconSizeXXL,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Aucun traitement enregistré',
                    style: AppTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: AppTheme.padding(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: AppTheme.padding(AppTheme.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sélectionner l\'année',
                          style: AppTheme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingM),
                        DropdownButtonFormField<int>(
                          value: _selectedYear ?? annees.first,
                          decoration: AppTheme.createInputDecoration(
                            labelText: 'Année',
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
                SizedBox(height: AppTheme.spacingL),
                ElevatedButton.icon(
                  onPressed: _generatePDF,
                  icon: Icon(Icons.picture_as_pdf, color: AppTheme.onPrimary),
                  label: Text('Générer le PDF', style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.onPrimary)),
                  style: AppTheme.buttonStyle(
                    backgroundColor: AppTheme.warning,
                    foregroundColor: AppTheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
        return 'Prix semis: ${semisParcelle.prixSemis.toStringAsFixed(2)}';
      } else {
        return 'Prix semis: Non défini';
      }
    } catch (e) {
      return 'Prix semis: Non défini';
    }
  }
  List<pw.TableRow> _buildSemisAsTreatment(Parcelle parcelle, List<dynamic> semis, int annee) {
    try {
      print('🔍 Recherche semis pour parcelle ${parcelle.nom} (${parcelle.firebaseId}) année $annee');
      print('🔍 Semis disponibles: ${semis.length}');
      
      // Debug: afficher tous les semis
      for (int i = 0; i < semis.length; i++) {
        final s = semis[i];
        print('🔍 Semis $i: parcelleId=${s.parcelleId}, année=${s.date.year}');
      }
      
      final semisParcelle = semis.firstWhere(
        (s) => s.parcelleId == parcelle.firebaseId && s.date.year == annee,
        orElse: () => null,
      );
      
      print('🔍 Semis trouvé: ${semisParcelle != null}');
      if (semisParcelle != null) {
        print('🔍 Prix semis: ${semisParcelle.prixSemis}');
        print('🔍 Densité: ${semisParcelle.densiteMais}');
        print('🔍 Variétés: ${semisParcelle.varietesSurfaces?.map((v) => v.nom).join(', ') ?? 'N/A'}');
      }
      
      // Toujours afficher le semis même si prixSemis = 0
      if (semisParcelle == null) {
        print('❌ Aucun semis trouvé pour cette parcelle et cette année');
        // Test: forcer l'affichage d'un semis factice pour debug
        print('🧪 Test: Affichage d\'un semis factice pour debug');
        return [
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
            ),
            children: [
              _buildDataCell('15/3'),
              _buildDataCell('Semis (Test)'),
              _buildDataCell('4.33'),
              _buildDataCell('149.50'),
              _buildDataCell('647.40'),
              _buildDataCell('83000 graines/ha'),
            ],
          ),
        ];
      }
      // Calculer le nombre de doses pour toute la parcelle
      final nombreDoses = (semisParcelle.densiteMais * parcelle.surface) / 50000;
      final prixUnitaire = semisParcelle.prixSemis > 0 ? semisParcelle.prixSemis / nombreDoses : 0.0;
      print('✅ Création du semis dans le tableau: ${nombreDoses} doses, ${prixUnitaire} €/dose');
      return [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
          ),
          children: [
            _buildDataCell('${semisParcelle.date.day}/${semisParcelle.date.month}'),
            _buildDataCell('Semis (${semisParcelle.varietesSurfaces?.map((v) => v.nom).join(', ') ?? 'Variété inconnue'})'),
            _buildDataCell('${nombreDoses.toStringAsFixed(2)}'),
            _buildDataCell('${prixUnitaire.toStringAsFixed(2)}'),
            _buildDataCell('${semisParcelle.prixSemis.toStringAsFixed(2)}'),
            _buildDataCell('${semisParcelle.densiteMais.toStringAsFixed(0)} graines/ha'),
          ],
        ),
      ];
    } catch (e) {
      print('❌ Erreur _buildSemisAsTreatment: $e');
      return [];
    }
  }
}