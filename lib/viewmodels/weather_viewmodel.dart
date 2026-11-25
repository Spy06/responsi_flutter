import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  LocationModel? _selectedLocation;
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  WeatherViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  LocationModel? get selectedLocation => _selectedLocation;
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _weather != null && _selectedLocation != null;
  bool get isEmptyState => !_isLoading && _errorMessage == null && _weather == null;

  /// Inisialisasi awal aplikasi:
  /// Memuat lokasi terakhir dari Local Storage atau mencari kota awal dari Geocoding API.
  Future<void> initialize({String initialCityQuery = 'Jakarta'}) async {
    if (_isInitialized) return;
    _isInitialized = true;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      LocationModel? targetLocation =
          await _storageService.getLastSelectedLocation();

      if (targetLocation == null) {
        final locations = await _apiService.searchLocations(initialCityQuery);
        if (locations.isNotEmpty) {
          targetLocation = locations.first;
          await _storageService.saveLastSelectedLocation(targetLocation);
        }
      }

      if (targetLocation == null) {
        _weather = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _selectedLocation = targetLocation;
      _weather = await _apiService.getWeatherForecast(
        latitude: targetLocation.latitude,
        longitude: targetLocation.longitude,
      );
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat memuat informasi cuaca.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memilih kota baru dan memperbarui data cuaca dari API Open-Meteo.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    _weather = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _storageService.saveLastSelectedLocation(location);
      final forecast = await _apiService.getWeatherForecast(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      _weather = forecast;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Gagal mengambil data cuaca untuk ${location.name}.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat ulang cuaca untuk lokasi yang sedang aktif.
  Future<void> refreshWeather() async {
    if (_selectedLocation == null) {
      _isInitialized = false;
      await initialize();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final forecast = await _apiService.getWeatherForecast(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );
      _weather = forecast;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui data cuaca. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
