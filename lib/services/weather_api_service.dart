import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class WeatherApiService {
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mencari daftar lokasi berdasarkan nama kota menggunakan Geocoding API (GET).
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const [];
    }

    final uri = Uri.parse(_geocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmedQuery,
        'count': '15',
        'language': 'id',
        'format': 'json',
      },
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal mencari lokasi (Kode HTTP: ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons pencarian lokasi tidak valid.');
      }

      final results = decoded['results'];
      if (results is! List) {
        return const [];
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } on SocketException {
      throw const ApiException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Permintaan ke server melebihi batas waktu (timeout). Silakan coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Gagal terhubung ke server Open-Meteo. Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw const ApiException('Gagal mengolah data JSON dari server.');
    }
  }

  /// Mengambil data cuaca terkini dan prakiraan harian dari Open-Meteo Forecast API (GET).
  Future<WeatherModel> getWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': [
          'temperature_2m',
          'relative_humidity_2m',
          'apparent_temperature',
          'precipitation',
          'weather_code',
          'wind_speed_10m',
        ].join(','),
        'daily': [
          'weather_code',
          'temperature_2m_max',
          'temperature_2m_min',
          'precipitation_probability_max',
        ].join(','),
        'timezone': 'auto',
      },
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Gagal memuat data cuaca (Kode HTTP: ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['current'] == null) {
        throw const ApiException('Data cuaca kosong atau format tidak sesuai.');
      }

      return WeatherModel.fromJson(decoded);
    } on SocketException {
      throw const ApiException(
        'Tidak dapat terhubung ke internet. Pastikan perangkat Anda online.',
      );
    } on TimeoutException {
      throw const ApiException(
        'Waktu tunggu pengambilan data cuaca habis. Silakan muat ulang.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Gagal menghubungi layanan cuaca Open-Meteo. Coba lagi nanti.',
      );
    } on FormatException {
      throw const ApiException('Respons data cuaca dari server tidak valid.');
    }
  }
}
