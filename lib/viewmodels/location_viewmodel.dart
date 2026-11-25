import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

class LocationViewModel extends ChangeNotifier {
  static const int _maxHistoryLength = 10;

  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  List<LocationModel> _searchResults = const [];
  List<LocationModel> _favorites = [];
  List<LocationModel> _searchHistory = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _currentQuery = '';
  String? _errorMessage;
  int _searchRequestId = 0;

  LocationViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  List<LocationModel> get searchResults => List.unmodifiable(_searchResults);
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  String get currentQuery => _currentQuery;
  String? get errorMessage => _errorMessage;

  bool get isSearchResultEmpty =>
      _hasSearched && !_isSearching && _errorMessage == null && _searchResults.isEmpty;

  /// Memuat daftar lokasi favorit dan riwayat pencarian dari Local Storage.
  Future<void> loadSavedLocations() async {
    _favorites = await _storageService.getFavoriteLocations();
    _searchHistory = await _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Mencari kota ke Open-Meteo Geocoding API menggunakan HTTP GET.
  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    _currentQuery = trimmed;
    final requestId = ++_searchRequestId;

    if (trimmed.isEmpty) {
      _searchResults = const [];
      _isSearching = false;
      _hasSearched = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.searchLocations(trimmed);
      if (requestId != _searchRequestId) return;

      _searchResults = results;
      _hasSearched = true;
      _errorMessage = null;
    } on ApiException catch (e) {
      if (requestId != _searchRequestId) return;
      _searchResults = const [];
      _hasSearched = true;
      _errorMessage = e.message;
    } catch (_) {
      if (requestId != _searchRequestId) return;
      _searchResults = const [];
      _hasSearched = true;
      _errorMessage = 'Terjadi kesalahan saat mencari kota.';
    } finally {
      if (requestId == _searchRequestId) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    ++_searchRequestId;
    _currentQuery = '';
    _searchResults = const [];
    _isSearching = false;
    _hasSearched = false;
    _errorMessage = null;
    notifyListeners();
  }

  bool isFavorite(LocationModel location) {
    return _favorites.any((item) => item.isSameLocation(location));
  }

  /// Menambahkan atau menghapus lokasi dari daftar favorit dan menyimpannya secara lokal.
  Future<bool> toggleFavorite(LocationModel location) async {
    final existingIndex =
        _favorites.indexWhere((item) => item.isSameLocation(location));

    final bool added;
    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
      added = false;
    } else {
      _favorites.insert(0, location);
      added = true;
    }

    await _storageService.saveFavoriteLocations(_favorites);
    notifyListeners();
    return added;
  }

  /// Menyimpan lokasi yang dipilih ke riwayat pencarian lokal.
  Future<void> addToHistory(LocationModel location) async {
    _searchHistory.removeWhere((item) => item.isSameLocation(location));
    _searchHistory.insert(0, location);
    if (_searchHistory.length > _maxHistoryLength) {
      _searchHistory = _searchHistory.sublist(0, _maxHistoryLength);
    }
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> removeFromHistory(LocationModel location) async {
    _searchHistory.removeWhere((item) => item.isSameLocation(location));
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _searchHistory.clear();
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }
}
