import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);

  void updateSystemTheme(Brightness brightness) {
    state = brightness == Brightness.dark;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider);
});
