import 'package:flutter/material.dart';

/// Provider pour gérer le thème de l'application (dark/light)
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true; // Par défaut en mode sombre
  
  bool get isDarkMode => _isDarkMode;
  bool get isLightMode => !_isDarkMode;
  
  /// Bascule entre le mode sombre et clair
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  /// Force le mode sombre
  void setDarkMode() {
    if (!_isDarkMode) {
      _isDarkMode = true;
      notifyListeners();
    }
  }
  
  /// Force le mode clair
  void setLightMode() {
    if (_isDarkMode) {
      _isDarkMode = false;
      notifyListeners();
    }
  }
  
  /// Définit le mode selon une valeur booléenne
  void setTheme(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }
}
