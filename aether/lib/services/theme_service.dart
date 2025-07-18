import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aether/constants/theme_constants.dart';

/// Theme mode preference key
const String _themePreferenceKey = 'theme_mode';

/// Service for managing app theme
class ThemeService extends ChangeNotifier {
  /// Singleton instance
  static final ThemeService _instance = ThemeService._internal();
  
  factory ThemeService() => _instance;
  
  ThemeService._internal();
  
  /// Current theme mode
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Get current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Initialize theme service
  Future<void> initialize() async {
    await loadThemePreference();
  }
  
  /// Load theme preference from shared preferences
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themePreferenceKey);
    
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }
  
  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themePreferenceKey, mode.index);
    
    notifyListeners();
  }
  
  /// Get light theme data
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: ThemeConstants.lightPrimary,
        secondary: ThemeConstants.lightSecondary,
        surface: ThemeConstants.lightSurface,
        error: ThemeConstants.lightError,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: ThemeConstants.lightPrimary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
  
  /// Get dark theme data
  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: ThemeConstants.darkPrimary,
        secondary: ThemeConstants.darkSecondary,
        surface: ThemeConstants.darkSurface,
        error: ThemeConstants.darkError,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: ThemeConstants.darkPrimary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
  
  /// Check if dark mode is active
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}