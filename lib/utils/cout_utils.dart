class CoutUtils {
  // Constantes pour les calculs
  static const double DOSE_GRAINES = 50000.0; // Une dose = 50 000 graines
  static const double DENSITE_DEFAUT = 83000.0; // Densité par défaut

  /// Calcule le nombre de doses par hectare
  static double calculerNombreDoses(double densite) {
    return densite / DOSE_GRAINES;
  }

  /// Calcule le coût du semis par hectare
  static double calculerCoutSemisParHectare(double prixDose, double densite) {
    final nombreDoses = calculerNombreDoses(densite);
    return nombreDoses * prixDose;
  }

  /// Calcule le coût total du semis pour une surface donnée
  static double calculerCoutTotalSemis(double prixDose, double densite, double surfaceHectares) {
    final coutParHectare = calculerCoutSemisParHectare(prixDose, densite);
    return coutParHectare * surfaceHectares;
  }

  /// Calcule le coût total du gaz pour une cellule
  static double calculerCoutTotalGaz(double quantiteGaz, double prixGaz) {
    return quantiteGaz * prixGaz;
  }

  /// Valide une densité de maïs (entre 50 000 et 150 000)
  static bool estDensiteValide(double densite) {
    return densite >= 50000 && densite <= 150000;
  }

  /// Valide un prix de dose (positif)
  static bool estPrixDoseValide(double prix) {
    return prix > 0;
  }

  /// Valide une quantité de gaz (positive)
  static bool estQuantiteGazValide(double quantite) {
    return quantite > 0;
  }

  /// Valide un prix de gaz (positif)
  static bool estPrixGazValide(double prix) {
    return prix > 0;
  }
}
