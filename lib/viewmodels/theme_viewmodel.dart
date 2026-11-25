import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final LocalStorageService _storageService;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeViewModel({LocalStorageService? storageService})
      : _storageService = storageService ?? LocalStorageService();

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    final savedDark = await _storageService.getDarkMode();
    if (savedDark != null) {
      _themeMode = savedDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    final nextDark = _themeMode != ThemeMode.dark;
    _themeMode = nextDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _storageService.saveDarkMode(nextDark);
  }
}
