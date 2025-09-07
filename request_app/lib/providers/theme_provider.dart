import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple theme provider that follows system theme
class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);

  void updateSystemTheme(Brightness brightness) {
    state = brightness == Brightness.dark;
  }
}

// Provider for dark mode state
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

// Convenience provider
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider);
});
