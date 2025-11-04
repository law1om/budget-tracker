import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

enum ThemePreference {
  light,
  dark,
  system,
}

class ThemeProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final ApiService _apiService = ApiService();
  
  ThemePreference _themePreference = ThemePreference.system;
  bool _initialized = false;
  bool _syncWithBackend = false;

  ThemePreference get themePreference => _themePreference;
  bool get initialized => _initialized;

  /// Initialize theme from storage
  Future<void> initialize() async {
    await _storage.init();
    final savedTheme = _storage.themePreference;
    _themePreference = _parseThemePreference(savedTheme);
    _initialized = true;
    notifyListeners();
  }

  /// Get the current theme mode based on preference
  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  /// Check if dark mode is currently active
  bool isDarkMode(BuildContext context) {
    if (_themePreference == ThemePreference.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themePreference == ThemePreference.dark;
  }

  /// Enable backend sync (call after user login)
  void enableBackendSync() {
    _syncWithBackend = true;
  }
  
  /// Disable backend sync (call after user logout)
  void disableBackendSync() {
    _syncWithBackend = false;
  }
  
  /// Set theme preference
  Future<void> setThemePreference(ThemePreference preference) async {
    _themePreference = preference;
    await _storage.setThemePreference(_themePreferenceToString(preference));
    
    // Sync with backend if user is logged in
    if (_syncWithBackend) {
      try {
        await _apiService.updateUser(
          themePreference: _themePreferenceToString(preference),
        );
      } catch (e) {
        print('Failed to sync theme with backend: $e');
        // Continue anyway, local storage is updated
      }
    }
    
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themePreference == ThemePreference.light) {
      await setThemePreference(ThemePreference.dark);
    } else {
      await setThemePreference(ThemePreference.light);
    }
  }

  /// Parse theme preference from string
  ThemePreference _parseThemePreference(String value) {
    switch (value) {
      case 'light':
        return ThemePreference.light;
      case 'dark':
        return ThemePreference.dark;
      case 'system':
      default:
        return ThemePreference.system;
    }
  }

  /// Convert theme preference to string
  String _themePreferenceToString(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.light:
        return 'light';
      case ThemePreference.dark:
        return 'dark';
      case ThemePreference.system:
        return 'system';
    }
  }
}
