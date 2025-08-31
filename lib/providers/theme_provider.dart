import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadThemeFromPrefs();
  }
  
  // Cargar tema guardado
  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  // Cambiar tema
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
  
  // Obtener colores según el tema actual
  Color get primaryColor => _isDarkMode ? const Color(0xFFE74C3C) : const Color(0xFFE74C3C);
  Color get backgroundColor => _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
  Color get cardColor => _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor => _isDarkMode ? const Color(0xFFECF0F1) : const Color(0xFF2C3E50);
  Color get subtitleColor => _isDarkMode ? const Color(0xFFBDC3C7) : const Color(0xFF7F8C8D);
  
  // Gradientes según el tema
  LinearGradient get headerGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE74C3C), // Rojo
      Color(0xFFF39C12), // Amarillo
      Color(0xFF27AE60), // Verde
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  LinearGradient get backgroundGradient => _isDarkMode 
    ? const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2C3E50),
          Color(0xFF1A1A1A),
        ],
      )
    : const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFAFAFA),
          Colors.white,
        ],
      );
}
