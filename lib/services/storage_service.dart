import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

class StorageService {
  static const _favoritesKey = 'favorite_locations';
  static const _searchHistoryKey = 'search_history';
  static const _lastLocationKey = 'last_location';
  static const _isDarkKey = 'is_dark';
  static const _isCelsiusKey = 'is_celsius';

  Future<List<LocationModel>> getFavorites() async {
    final preferences = await SharedPreferences.getInstance();
    final storedLocations = preferences.getStringList(_favoritesKey);
    if (storedLocations == null) {
      return [];
    }

    final locations = <LocationModel>[];
    for (final storedLocation in storedLocations) {
      final location = _decodeLocation(storedLocation);
      if (location != null) {
        locations.add(location);
      }
    }
    return locations;
  }

  Future<void> saveFavorites(List<LocationModel> locations) async {
    final preferences = await SharedPreferences.getInstance();
    final storedLocations = locations
        .map((location) => jsonEncode(location.toJson()))
        .toList();
    await preferences.setStringList(_favoritesKey, storedLocations);
  }

  Future<List<String>> getSearchHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final history = preferences.getStringList(_searchHistoryKey) ?? [];
    return _limitHistory(history);
  }

  Future<void> saveSearchHistory(List<String> history) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_searchHistoryKey, _limitHistory(history));
  }

  Future<LocationModel?> getLastLocation() async {
    final preferences = await SharedPreferences.getInstance();
    final storedLocation = preferences.getString(_lastLocationKey);
    if (storedLocation == null) {
      return null;
    }
    return _decodeLocation(storedLocation);
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lastLocationKey,
      jsonEncode(location.toJson()),
    );
  }

  Future<bool> getIsDark() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isDarkKey) ?? false;
  }

  Future<void> saveIsDark(bool isDark) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isDarkKey, isDark);
  }

  Future<bool> getIsCelsius() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isCelsiusKey) ?? true;
  }

  Future<void> saveIsCelsius(bool isCelsius) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isCelsiusKey, isCelsius);
  }

  LocationModel? _decodeLocation(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return LocationModel.fromStoredJson(decoded);
      }
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
    return null;
  }

  List<String> _limitHistory(List<String> history) {
    final uniqueHistory = <String>{};
    for (final search in history) {
      if (uniqueHistory.length == 5) {
        break;
      }
      uniqueHistory.add(search);
    }
    return uniqueHistory.toList();
  }
}
