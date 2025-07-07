import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeState {
  final ThemeMode mode;
  final Color primaryColor;
  AppThemeState({required this.mode, required this.primaryColor});
}

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeState> {
  ThemeNotifier() : super(AppThemeState(mode: ThemeMode.system, primaryColor: Colors.blue)) {
    _loadTheme();
  }

  /// Load saved theme and color from shared preferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    final colorValue = prefs.getInt('primary_color');
    state = AppThemeState(
      mode: ThemeMode.values[themeIndex],
      primaryColor: colorValue != null ? Color(colorValue) : Colors.blue,
    );
  }

  /// Save theme to shared preferences and update state
  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    state = AppThemeState(mode: mode, primaryColor: state.primaryColor);
  }

  /// Set and persist the primary color
  Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.value);
    state = AppThemeState(mode: state.mode, primaryColor: color);
  }

  /// Get the display name for a theme mode
  String getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  /// Get the description for a theme mode
  String getThemeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system settings';
    }
  }
} 