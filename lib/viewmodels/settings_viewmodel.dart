import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._storageService);

  final StorageService _storageService;

  bool _isDark = false;
  bool _isCelsius = true;

  bool get isDark => _isDark;
  bool get isCelsius => _isCelsius;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    _isDark = await _storageService.getIsDark();
    _isCelsius = await _storageService.getIsCelsius();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final nextValue = !_isDark;
    await _storageService.saveIsDark(nextValue);
    _isDark = nextValue;
    notifyListeners();
  }

  Future<void> toggleUnit() async {
    final nextValue = !_isCelsius;
    await _storageService.saveIsCelsius(nextValue);
    _isCelsius = nextValue;
    notifyListeners();
  }

  String formatTemp(double celsius) {
    final temperature = _isCelsius ? celsius : (celsius * 9 / 5) + 32;
    final unit = _isCelsius ? 'C' : 'F';
    return '${temperature.toStringAsFixed(1)}°$unit';
  }
}
