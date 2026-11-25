import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations_v1';
  static const String _historyKey = 'search_history_v1';
  static const String _lastLocationKey = 'last_selected_location_v1';
  static const String _darkModeKey = 'is_dark_mode_v1';

  Future<List<LocationModel>> getFavoriteLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_favoritesKey) ?? const [];
    return _decodeLocationList(rawList);
  }

  Future<void> saveFavoriteLocations(List<LocationModel> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = locations.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }

  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_historyKey) ?? const [];
    return _decodeLocationList(rawList);
  }

  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = history.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<LocationModel?> getLastSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return LocationModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  Future<bool?> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey);
  }

  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }

  List<LocationModel> _decodeLocationList(List<String> rawList) {
    final result = <LocationModel>[];
    for (final item in rawList) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          result.add(LocationModel.fromJson(decoded));
        }
      } catch (_) {
        // Lewati entri yang rusak agar aplikasi tetap berjalan normal
      }
    }
    return result;
  }
}
